import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class CachedStores extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get chainId => text().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id, userId};
}

class CachedProducts extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get description => text()();
  RealColumn get salePrice => real()();
  IntColumn get currentStock => integer()();
  IntColumn get unitsPerBulk => integer()();
  IntColumn get stockBulks => integer()();
  IntColumn get stockUnits => integer()();
  TextColumn get barcode => text().nullable()();
  TextColumn get brand => text().nullable()();
  TextColumn get department => text().nullable()();
  TextColumn get subDepartment => text().nullable()();
  IntColumn get minStock => integer().withDefault(const Constant(0))();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id, storeId};
}

class CachedClients extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id, storeId};
}

class CachedReceivableAccounts extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get clientId => text()();
  TextColumn get clientName => text()();
  RealColumn get totalAmount => real()();
  RealColumn get remainingAmount => real()();
  RealColumn get pendingAmount => real()();
  TextColumn get status => text()();
  TextColumn get orderId => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id, storeId};
}

class CachedCollectionSummaries extends Table {
  TextColumn get storeId => text()();
  TextColumn get scopeKey => text()();
  IntColumn get totalCount => integer()();
  RealColumn get totalAmount => real()();
  RealColumn get cashTotal => real()();
  RealColumn get otherTotal => real()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {storeId, scopeKey};
}

class CachedRoutes extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get vendorId => text()();
  TextColumn get clientIdsJson => text()();
  DateTimeColumn get routeDate => dateTime().nullable()();
  TextColumn get status => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id, storeId};
}

class CachedDeliveries extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get orderId => text()();
  TextColumn get status => text()();
  TextColumn get itemsJson => text()();
  RealColumn get total => real()();
  TextColumn get clientId => text().nullable()();
  TextColumn get clientName => text().nullable()();
  TextColumn get clientAddress => text().nullable()();
  TextColumn get ruteroId => text().nullable()();
  TextColumn get paymentType => text().nullable()();
  TextColumn get salesManagerName => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id, storeId};
}

class RealtimeEventLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get channel => text()();
  TextColumn get eventType => text()();
  TextColumn get payloadJson => text()();
  TextColumn get storeId => text().nullable()();
  DateTimeColumn get receivedAt => dateTime()();
}

class SyncQueueEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get method => text()();
  TextColumn get endpoint => text()();
  TextColumn get payloadJson => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get storeId => text().nullable()();
  TextColumn get operationType => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
}

@DriftDatabase(
  tables: [
    CachedStores,
    CachedProducts,
    CachedClients,
    CachedReceivableAccounts,
    CachedCollectionSummaries,
    CachedRoutes,
    CachedDeliveries,
    RealtimeEventLogs,
    SyncQueueEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(cachedProducts);
        await migrator.createTable(cachedClients);
      }
      if (from < 3) {
        await migrator.createTable(cachedReceivableAccounts);
        await migrator.createTable(cachedRoutes);
        await migrator.createTable(cachedDeliveries);
      }
      if (from < 4) {
        await migrator.createTable(cachedCollectionSummaries);
      }
    },
  );

  Future<void> replaceAssignedStores(
    String userId,
    List<CachedStoresCompanion> stores,
  ) async {
    await transaction(() async {
      await (delete(
        cachedStores,
      )..where((table) => table.userId.equals(userId))).go();

      if (stores.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(
            cachedStores,
            stores,
            mode: InsertMode.insertOrReplace,
          );
        });
      }
    });
  }

  Future<List<CachedStore>> getAssignedStores(String userId) {
    return (select(cachedStores)
          ..where((table) => table.userId.equals(userId))
          ..orderBy([(table) => OrderingTerm.asc(table.name)]))
        .get();
  }

  Stream<List<CachedStore>> watchAssignedStores(String userId) {
    return (select(cachedStores)
          ..where((table) => table.userId.equals(userId))
          ..orderBy([(table) => OrderingTerm.asc(table.name)]))
        .watch();
  }

  Future<void> replaceCatalogProducts(
    String storeId,
    List<CachedProductsCompanion> products,
  ) async {
    await transaction(() async {
      await (delete(
        cachedProducts,
      )..where((table) => table.storeId.equals(storeId))).go();

      if (products.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(
            cachedProducts,
            products,
            mode: InsertMode.insertOrReplace,
          );
        });
      }
    });
  }

  Future<List<CachedProduct>> getCatalogProducts(String storeId) {
    return (select(cachedProducts)
          ..where((table) => table.storeId.equals(storeId))
          ..orderBy([(table) => OrderingTerm.asc(table.description)]))
        .get();
  }

  Future<void> replaceClients(
    String storeId,
    List<CachedClientsCompanion> clients,
  ) async {
    await transaction(() async {
      await (delete(
        cachedClients,
      )..where((table) => table.storeId.equals(storeId))).go();

      if (clients.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(
            cachedClients,
            clients,
            mode: InsertMode.insertOrReplace,
          );
        });
      }
    });
  }

  Future<List<CachedClient>> getClients(String storeId) {
    return (select(cachedClients)
          ..where((table) => table.storeId.equals(storeId))
          ..orderBy([(table) => OrderingTerm.asc(table.name)]))
        .get();
  }

  Future<void> replaceReceivableAccounts(
    String storeId,
    List<CachedReceivableAccountsCompanion> accounts,
  ) async {
    await transaction(() async {
      await (delete(
        cachedReceivableAccounts,
      )..where((table) => table.storeId.equals(storeId))).go();

      if (accounts.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(
            cachedReceivableAccounts,
            accounts,
            mode: InsertMode.insertOrReplace,
          );
        });
      }
    });
  }

  Future<List<CachedReceivableAccount>> getReceivableAccounts(String storeId) {
    return (select(cachedReceivableAccounts)
          ..where((table) => table.storeId.equals(storeId))
          ..orderBy([(table) => OrderingTerm.asc(table.clientName)]))
        .get();
  }

  Future<void> replaceCollectionsSummary(
    CachedCollectionSummariesCompanion summary,
  ) async {
    await into(
      cachedCollectionSummaries,
    ).insert(summary, mode: InsertMode.insertOrReplace);
  }

  Future<CachedCollectionSummary?> getCollectionsSummary(
    String storeId,
    String scopeKey,
  ) {
    return (select(cachedCollectionSummaries)
          ..where(
            (table) =>
                table.storeId.equals(storeId) & table.scopeKey.equals(scopeKey),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> replaceRoutes(
    String storeId,
    List<CachedRoutesCompanion> routes,
  ) async {
    await transaction(() async {
      await (delete(
        cachedRoutes,
      )..where((table) => table.storeId.equals(storeId))).go();

      if (routes.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(
            cachedRoutes,
            routes,
            mode: InsertMode.insertOrReplace,
          );
        });
      }
    });
  }

  Future<List<CachedRoute>> getRoutes(String storeId) {
    return (select(cachedRoutes)
          ..where((table) => table.storeId.equals(storeId))
          ..orderBy([(table) => OrderingTerm.asc(table.status)]))
        .get();
  }

  Future<void> replaceDeliveries(
    String storeId,
    List<CachedDeliveriesCompanion> deliveries,
  ) async {
    await transaction(() async {
      await (delete(
        cachedDeliveries,
      )..where((table) => table.storeId.equals(storeId))).go();

      if (deliveries.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(
            cachedDeliveries,
            deliveries,
            mode: InsertMode.insertOrReplace,
          );
        });
      }
    });
  }

  Future<List<CachedDelivery>> getDeliveries(String storeId) {
    return (select(cachedDeliveries)
          ..where((table) => table.storeId.equals(storeId))
          ..orderBy([(table) => OrderingTerm.asc(table.status)]))
        .get();
  }

  Future<int> insertRealtimeEvent(RealtimeEventLogsCompanion entry) {
    return into(realtimeEventLogs).insert(entry);
  }

  Stream<RealtimeEventLog?> watchLatestRealtimeEvent() {
    return (select(realtimeEventLogs)
          ..orderBy([(table) => OrderingTerm.desc(table.receivedAt)])
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<int> enqueueSyncEntry(SyncQueueEntriesCompanion entry) {
    return into(syncQueueEntries).insert(entry);
  }

  Future<List<SyncQueueEntry>> getPendingSyncEntries({int limit = 25}) {
    return (select(syncQueueEntries)
          ..where((table) => table.status.equals('pending'))
          ..orderBy([(table) => OrderingTerm.asc(table.createdAt)])
          ..limit(limit))
        .get();
  }

  Future<void> retryFailedSyncEntries() {
    return (update(syncQueueEntries)
          ..where((table) => table.status.equals('failed')))
        .write(
          const SyncQueueEntriesCompanion(
            status: Value('pending'),
            errorMessage: Value(null),
          ),
        );
  }

  Future<void> markSyncEntryCompleted(int id) {
    return (update(syncQueueEntries)..where((table) => table.id.equals(id))).write(
      SyncQueueEntriesCompanion(
        status: const Value('completed'),
        errorMessage: const Value(null),
        lastAttemptAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> registerSyncAttempt(
    int id, {
    required String errorMessage,
    required bool keepPending,
  }) {
    return customStatement(
      '''
      UPDATE sync_queue_entries
      SET status = ?,
          error_message = ?,
          attempt_count = attempt_count + 1,
          last_attempt_at = ?
      WHERE id = ?
      ''',
      [
        keepPending ? 'pending' : 'failed',
        errorMessage,
        DateTime.now().toUtc(),
        id,
      ],
    );
  }

  Stream<int> watchPendingSyncCount() {
    final pendingCount = syncQueueEntries.id.count();

    return (selectOnly(syncQueueEntries)
          ..addColumns([pendingCount])
          ..where(syncQueueEntries.status.equals('pending')))
        .watchSingle()
        .map((row) => row.read(pendingCount) ?? 0);
  }

  Stream<int> watchFailedSyncCount() {
    final failedCount = syncQueueEntries.id.count();

    return (selectOnly(syncQueueEntries)
          ..addColumns([failedCount])
          ..where(syncQueueEntries.status.equals('failed')))
        .watchSingle()
        .map((row) => row.read(failedCount) ?? 0);
  }

  Stream<List<SyncQueueEntry>> watchRecentSyncEntries({int limit = 8}) {
    return (select(syncQueueEntries)
          ..orderBy([(table) => OrderingTerm.desc(table.createdAt)])
          ..limit(limit))
        .watch();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, 'pino_mobile.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});
