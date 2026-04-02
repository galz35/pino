import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Central Local Database — the "offline Firestore" replacement.
/// Stores products, clients, orders, visit logs, and a sync queue
/// so the app works 100% without internet.
class LocalDatabase {
  static Database? _db;
  static final LocalDatabase instance = LocalDatabase._();
  LocalDatabase._();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'lospinos_offline.db');

    return openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    // Products cache — downloaded from NestJS on login/sync
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        store_id TEXT NOT NULL,
        data TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Clients cache
    await db.execute('''
      CREATE TABLE clients (
        id TEXT PRIMARY KEY,
        store_id TEXT NOT NULL,
        assigned_preventa_id TEXT,
        data TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Orders — both from server and created locally
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        store_id TEXT,
        status TEXT,
        preparation_status TEXT,
        driver_id TEXT,
        data TEXT NOT NULL,
        is_local INTEGER NOT NULL DEFAULT 0,
        synced INTEGER NOT NULL DEFAULT 1,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Visit logs
    await db.execute('''
      CREATE TABLE visit_logs (
        id TEXT PRIMARY KEY,
        vendor_id TEXT,
        client_id TEXT,
        data TEXT NOT NULL,
        synced INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL
      )
    ''');

    // Route manifests
    await db.execute('''
      CREATE TABLE route_manifests (
        id TEXT PRIMARY KEY,
        driver_id TEXT NOT NULL,
        date TEXT NOT NULL,
        data TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Settings cache
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // =============================================
    // SYNC QUEUE — the heart of offline-first
    // =============================================
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        method TEXT NOT NULL,
        endpoint TEXT NOT NULL,
        body TEXT,
        created_at INTEGER NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'pending'
      )
    ''');

    // Indexes for fast lookups
    await db.execute('CREATE INDEX idx_products_store ON products(store_id)');
    await db.execute(
      'CREATE INDEX idx_clients_preventa ON clients(assigned_preventa_id)',
    );
    await db.execute('CREATE INDEX idx_orders_driver ON orders(driver_id)');
    await db.execute('CREATE INDEX idx_orders_status ON orders(status)');
    await db.execute(
      'CREATE INDEX idx_orders_prep ON orders(preparation_status)',
    );
    await db.execute('CREATE INDEX idx_sync_status ON sync_queue(status)');
  }

  // ==========================================
  // GENERIC JSON DOCUMENT CRUD
  // ==========================================

  /// Upsert a JSON document into a table
  Future<void> upsert(
    String table,
    String id,
    Map<String, dynamic> json, {
    Map<String, dynamic>? extraColumns,
  }) async {
    final db = await database;
    final row = <String, dynamic>{
      'id': id,
      'data': jsonEncode(json),
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
    if (extraColumns != null) row.addAll(extraColumns);
    await db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Bulk upsert (for initial sync)
  Future<void> bulkUpsert(
    String table,
    List<Map<String, dynamic>> items,
    String idField, {
    Map<String, dynamic> Function(Map<String, dynamic>)? extraColumnsBuilder,
  }) async {
    final db = await database;
    final batch = db.batch();
    for (final item in items) {
      final row = <String, dynamic>{
        'id': item[idField] ?? item['id'],
        'data': jsonEncode(item),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      };
      if (extraColumnsBuilder != null) row.addAll(extraColumnsBuilder(item));
      batch.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  /// Get a single document
  Future<Map<String, dynamic>?> getById(String table, String id) async {
    final db = await database;
    final rows = await db.query(table, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return jsonDecode(rows.first['data'] as String) as Map<String, dynamic>;
  }

  /// Get all documents from a table, optionally filtered
  Future<List<Map<String, dynamic>>> getAll(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    final rows = await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
    return rows
        .map((r) => jsonDecode(r['data'] as String) as Map<String, dynamic>)
        .toList();
  }

  /// Delete a document
  Future<void> deleteById(String table, String id) async {
    final db = await database;
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  /// Clear a table (for full refresh)
  Future<void> clearTable(String table) async {
    final db = await database;
    await db.delete(table);
  }

  // ==========================================
  // SYNC QUEUE OPERATIONS
  // ==========================================

  /// Enqueue an API call for background sync
  Future<void> enqueue(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final db = await database;
    await db.insert('sync_queue', {
      'method': method,
      'endpoint': endpoint,
      'body': body != null ? jsonEncode(body) : null,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'status': 'pending',
    });
  }

  /// Get all pending sync items
  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    final db = await database;
    return db.query(
      'sync_queue',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at ASC',
    );
  }

  /// Mark a sync item as completed
  Future<void> markSynced(int id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  /// Mark a sync item as failed (increment retry)
  Future<void> markFailed(int id) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE sync_queue SET retry_count = retry_count + 1, status = CASE WHEN retry_count >= 5 THEN \'failed\' ELSE \'pending\' END WHERE id = ?',
      [id],
    );
  }

  /// Count pending items
  Future<int> pendingCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as c FROM sync_queue WHERE status = ?',
      ['pending'],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
