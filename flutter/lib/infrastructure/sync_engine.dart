import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'local_database.dart';
import 'connectivity_service.dart';
import 'api_client.dart';

/// The Sync Engine: the brain that bridges Local DB ↔ NestJS API.
///
/// Responsibilities:
/// 1. On login / app start: bulk-download products, clients, routes into local DB.
/// 2. On write operations (create order, record visit): save locally FIRST, then enqueue for server.
/// 3. On connectivity restored: flush the queue by replaying enqueued API calls.
/// 4. Periodic pull: re-fetch data from server every N minutes if online.
class SyncEngine {
  final ApiClient _apiClient;
  final LocalDatabase _localDb;
  final ConnectivityService _connectivity;

  StreamSubscription? _connectivitySub;
  Timer? _periodicSync;
  bool _isSyncing = false;

  // Expose pending count for UI badge
  final _pendingCountController = StreamController<int>.broadcast();
  Stream<int> get pendingCountStream => _pendingCountController.stream;

  SyncEngine(this._apiClient, this._localDb, this._connectivity);

  /// Start the engine: listen for connectivity changes, begin periodic sync.
  void start() {
    // When connectivity returns, flush the queue
    _connectivitySub = _connectivity.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        debugPrint('[SyncEngine] Online detected — flushing queue...');
        flushQueue();
      }
    });

    // Periodic pull every 2 minutes if online
    _periodicSync = Timer.periodic(const Duration(minutes: 2), (_) {
      if (_connectivity.isOnline) {
        pullFromServer();
      }
    });

    // Initial flush if we're already online
    if (_connectivity.isOnline) {
      flushQueue();
    }

    _updatePendingCount();
  }

  void dispose() {
    _connectivitySub?.cancel();
    _periodicSync?.cancel();
    _pendingCountController.close();
  }

  // ================================================================
  // PULL: Download data from NestJS → Local DB
  // ================================================================

  /// Full pull — called on login and periodically
  Future<void> pullFromServer({String? storeId}) async {
    if (!_connectivity.isOnline) return;

    try {
      debugPrint('[SyncEngine] Pulling data from server...');

      // Pull products
      final productsRes = await _apiClient.get(
        '/products',
        queryParameters: storeId != null ? {'storeId': storeId} : null,
      );
      if (productsRes.statusCode == 200 && productsRes.data is List) {
        await _localDb.clearTable('products');
        await _localDb.bulkUpsert(
          'products',
          List<Map<String, dynamic>>.from(productsRes.data),
          'id',
          extraColumnsBuilder: (item) => {'store_id': item['storeId'] ?? ''},
        );
        debugPrint(
          '[SyncEngine] Synced ${(productsRes.data as List).length} products',
        );
      }

      // Pull clients
      final clientsRes = await _apiClient.get(
        '/clients',
        queryParameters: storeId != null ? {'storeId': storeId} : null,
      );
      if (clientsRes.statusCode == 200 && clientsRes.data is List) {
        await _localDb.clearTable('clients');
        await _localDb.bulkUpsert(
          'clients',
          List<Map<String, dynamic>>.from(clientsRes.data),
          'id',
          extraColumnsBuilder: (item) => {
            'store_id': item['storeId'] ?? '',
            'assigned_preventa_id': item['assignedPreventaId'] ?? '',
          },
        );
        debugPrint(
          '[SyncEngine] Synced ${(clientsRes.data as List).length} clients',
        );
      }

      // Pull orders (recent ones)
      final ordersRes = await _apiClient.get(
        '/orders',
        queryParameters: storeId != null ? {'storeId': storeId} : null,
      );
      if (ordersRes.statusCode == 200 && ordersRes.data is List) {
        await _localDb.bulkUpsert(
          'orders',
          List<Map<String, dynamic>>.from(ordersRes.data),
          'id',
          extraColumnsBuilder: (item) => {
            'store_id': item['storeId'] ?? '',
            'status': item['status'] ?? '',
            'preparation_status': item['preparationStatus'] ?? '',
            'driver_id': item['delivery']?['driverId'] ?? '',
            'is_local': 0,
            'synced': 1,
          },
        );
        debugPrint(
          '[SyncEngine] Synced ${(ordersRes.data as List).length} orders',
        );
      }

      debugPrint('[SyncEngine] Pull complete ✓');
    } catch (e) {
      debugPrint('[SyncEngine] Pull failed: $e');
    }
  }

  // ================================================================
  // PUSH: Flush offline queue → NestJS
  // ================================================================

  /// Flush all pending items in the sync queue.
  ///
  /// OPTIMIZED: Groups operations by storeId and sends them in a single
  /// POST /sync/batch request, matching the Web sync-service pattern.
  /// Operations without a storeId fall back to individual requests.
  Future<void> flushQueue() async {
    if (_isSyncing || !_connectivity.isOnline) return;
    _isSyncing = true;

    try {
      final pending = await _localDb.getPendingSyncItems();
      if (pending.isEmpty) {
        _isSyncing = false;
        return;
      }

      debugPrint(
        '[SyncEngine] Flushing ${pending.length} queued operations...',
      );

      // Separate batch-eligible operations (POSTs with body containing storeId)
      // from legacy individual operations.
      final List<Map<String, dynamic>> batchOps = [];
      final List<Map<String, dynamic>> individualOps = [];

      for (final item in pending) {
        final bodyStr = item['body'] as String?;
        if (bodyStr != null) {
          try {
            final body = jsonDecode(bodyStr) as Map<String, dynamic>;
            if (body.containsKey('storeId')) {
              batchOps.add(item);
              continue;
            }
          } catch (_) {}
        }
        individualOps.add(item);
      }

      // ── BATCH PATH: Group by storeId → single POST /sync/batch ──
      if (batchOps.isNotEmpty) {
        final Map<String, List<Map<String, dynamic>>> grouped = {};
        for (final item in batchOps) {
          final body = jsonDecode(item['body'] as String) as Map<String, dynamic>;
          final storeId = body['storeId'] as String;
          grouped.putIfAbsent(storeId, () => []).add(item);
        }

        for (final entry in grouped.entries) {
          final storeId = entry.key;
          final ops = entry.value;

          try {
            // Build the batch payload matching NestJS SyncService.processBatch()
            final operations = ops.map((item) {
              final body = jsonDecode(item['body'] as String) as Map<String, dynamic>;
              final endpoint = item['endpoint'] as String;

              // Infer type from endpoint
              String type = 'SALE';
              if (endpoint.contains('order')) type = 'ORDER';
              if (endpoint.contains('visit')) type = 'VISIT_LOG';
              if (endpoint.contains('client')) type = 'CLIENT';
              if (endpoint.contains('sale')) type = 'SALE';

              return {
                'id': 'flutter_${item['id']}',
                'type': type,
                'data': body,
                'timestamp': DateTime.fromMillisecondsSinceEpoch(
                  item['created_at'] as int,
                ).toIso8601String(),
              };
            }).toList();

            await _apiClient.post('/sync/batch', data: {
              'storeId': storeId,
              'operations': operations,
            });

            // All succeeded — remove from queue
            for (final item in ops) {
              await _localDb.markSynced(item['id'] as int);
            }
            debugPrint(
              '[SyncEngine] ✓ Batch synced ${ops.length} ops for store $storeId',
            );
          } on DioException catch (e) {
            if (e.response?.statusCode != null &&
                e.response!.statusCode! >= 400 &&
                e.response!.statusCode! < 500) {
              // Client error — drop, will never succeed
              for (final item in ops) {
                await _localDb.markSynced(item['id'] as int);
              }
              debugPrint(
                '[SyncEngine] ✗ Batch dropped (4xx) for store $storeId',
              );
            } else {
              // Server/network error — retry later
              for (final item in ops) {
                await _localDb.markFailed(item['id'] as int);
              }
              debugPrint(
                '[SyncEngine] ⟳ Batch retry later for store $storeId',
              );
            }
          }
        }
      }

      // ── INDIVIDUAL PATH: Legacy fallback for non-batch operations ──
      for (final item in individualOps) {
        final id = item['id'] as int;
        final method = item['method'] as String;
        final endpoint = item['endpoint'] as String;
        final bodyStr = item['body'] as String?;
        final body = bodyStr != null ? jsonDecode(bodyStr) : null;

        try {
          switch (method.toUpperCase()) {
            case 'POST':
              await _apiClient.post(endpoint, data: body);
              break;
            case 'PUT':
              await _apiClient.put(endpoint, data: body);
              break;
            case 'DELETE':
              await _apiClient.delete(endpoint);
              break;
          }
          await _localDb.markSynced(id);
          debugPrint('[SyncEngine] ✓ Synced: $method $endpoint');
        } on DioException catch (e) {
          if (e.response?.statusCode != null &&
              e.response!.statusCode! >= 400 &&
              e.response!.statusCode! < 500) {
            await _localDb.markSynced(id);
            debugPrint('[SyncEngine] ✗ Dropped (4xx): $method $endpoint');
          } else {
            await _localDb.markFailed(id);
            debugPrint('[SyncEngine] ⟳ Retry later: $method $endpoint');
          }
        }
      }

      _updatePendingCount();
      debugPrint('[SyncEngine] Queue flush complete');
    } catch (e) {
      debugPrint('[SyncEngine] Queue flush error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _updatePendingCount() async {
    final count = await _localDb.pendingCount();
    _pendingCountController.add(count);
  }

  /// Called by repositories to enqueue a write operation
  Future<void> enqueueWrite(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    await _localDb.enqueue(method, endpoint, body: body);
    _updatePendingCount();

    // Try to flush immediately if online
    if (_connectivity.isOnline) {
      flushQueue(); // fire-and-forget
    }
  }
}
