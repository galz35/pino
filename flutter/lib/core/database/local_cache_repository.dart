import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/catalog/domain/models/catalog_product.dart';
import '../../features/clients/domain/models/client_summary.dart';
import '../../features/collections/domain/models/receivable_account.dart';
import '../../features/deliveries/domain/models/delivery_summary.dart';
import '../../features/deliveries/domain/models/route_summary.dart';
import '../../features/home/domain/models/store_summary.dart';
import '../realtime/realtime_event.dart';
import 'app_database.dart';

class LocalCacheRepository {
  const LocalCacheRepository(this._database);

  final AppDatabase _database;

  String _collectionsScopeKey(String? ruteroId) {
    if (ruteroId != null && ruteroId.isNotEmpty) {
      return 'rutero:$ruteroId';
    }
    return 'global';
  }

  Future<void> cacheAssignedStores({
    required String userId,
    required List<StoreSummary> stores,
  }) async {
    final now = DateTime.now().toUtc();
    final rows = stores
        .map(
          (store) => CachedStoresCompanion.insert(
            id: store.id,
            userId: userId,
            name: store.name,
            address: Value(store.address),
            phone: Value(store.phone),
            chainId: Value(store.chainId),
            cachedAt: now,
          ),
        )
        .toList();

    await _database.replaceAssignedStores(userId, rows);
  }

  Future<List<StoreSummary>> getAssignedStores(String userId) async {
    final rows = await _database.getAssignedStores(userId);
    return rows
        .map(
          (row) => StoreSummary(
            id: row.id,
            name: row.name,
            address: row.address,
            phone: row.phone,
            chainId: row.chainId,
          ),
        )
        .toList();
  }

  Future<void> cacheCatalogProducts({
    required String storeId,
    required List<CatalogProduct> products,
  }) async {
    final now = DateTime.now().toUtc();
    final rows = products
        .map(
          (product) => CachedProductsCompanion.insert(
            id: product.id,
            storeId: storeId,
            description: product.description,
            salePrice: product.salePrice,
            currentStock: product.currentStock,
            unitsPerBulk: product.unitsPerBulk,
            stockBulks: product.stockBulks,
            stockUnits: product.stockUnits,
            barcode: Value(product.barcode),
            brand: Value(product.brand),
            department: Value(product.department),
            subDepartment: Value(product.subDepartment),
            minStock: Value(product.minStock),
            cachedAt: now,
          ),
        )
        .toList();

    await _database.replaceCatalogProducts(storeId, rows);
  }

  Future<List<CatalogProduct>> getCatalogProducts(String storeId) async {
    final rows = await _database.getCatalogProducts(storeId);
    return rows
        .map(
          (row) => CatalogProduct(
            id: row.id,
            storeId: row.storeId,
            description: row.description,
            salePrice: row.salePrice,
            currentStock: row.currentStock,
            unitsPerBulk: row.unitsPerBulk,
            stockBulks: row.stockBulks,
            stockUnits: row.stockUnits,
            barcode: row.barcode,
            brand: row.brand,
            department: row.department,
            subDepartment: row.subDepartment,
            minStock: row.minStock,
          ),
        )
        .toList();
  }

  Future<void> cacheClients({
    required String storeId,
    required List<ClientSummary> clients,
  }) async {
    final now = DateTime.now().toUtc();
    final rows = clients
        .map(
          (client) => CachedClientsCompanion.insert(
            id: client.id,
            storeId: storeId,
            name: client.name,
            email: Value(client.email),
            phone: Value(client.phone),
            address: Value(client.address),
            cachedAt: now,
          ),
        )
        .toList();

    await _database.replaceClients(storeId, rows);
  }

  Future<List<ClientSummary>> getClients(String storeId) async {
    final rows = await _database.getClients(storeId);
    return rows
        .map(
          (row) => ClientSummary(
            id: row.id,
            storeId: row.storeId,
            name: row.name,
            email: row.email,
            phone: row.phone,
            address: row.address,
          ),
        )
        .toList();
  }

  Future<void> cacheReceivableAccounts({
    required String storeId,
    required List<ReceivableAccount> accounts,
  }) async {
    final now = DateTime.now().toUtc();
    final rows = accounts
        .map(
          (account) => CachedReceivableAccountsCompanion.insert(
            id: account.id,
            storeId: storeId,
            clientId: account.clientId,
            clientName: account.clientName,
            totalAmount: account.totalAmount,
            remainingAmount: account.remainingAmount,
            pendingAmount: account.pendingAmount,
            status: account.status,
            orderId: Value(account.orderId),
            description: Value(account.description),
            cachedAt: now,
          ),
        )
        .toList();

    await _database.replaceReceivableAccounts(storeId, rows);
  }

  Future<List<ReceivableAccount>> getReceivableAccounts(String storeId) async {
    final rows = await _database.getReceivableAccounts(storeId);
    return rows
        .map(
          (row) => ReceivableAccount(
            id: row.id,
            storeId: row.storeId,
            clientId: row.clientId,
            clientName: row.clientName,
            totalAmount: row.totalAmount,
            remainingAmount: row.remainingAmount,
            pendingAmount: row.pendingAmount,
            status: row.status,
            orderId: row.orderId,
            description: row.description,
          ),
        )
        .toList();
  }

  Future<void> cacheCollectionsSummary({
    required String storeId,
    String? ruteroId,
    required CollectionsSummary summary,
  }) async {
    await _database.replaceCollectionsSummary(
      CachedCollectionSummariesCompanion.insert(
        storeId: storeId,
        scopeKey: _collectionsScopeKey(ruteroId),
        totalCount: summary.totalCount,
        totalAmount: summary.totalAmount,
        cashTotal: summary.cashTotal,
        otherTotal: summary.otherTotal,
        cachedAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<CollectionsSummary?> getCollectionsSummary({
    required String storeId,
    String? ruteroId,
  }) async {
    final row = await _database.getCollectionsSummary(
      storeId,
      _collectionsScopeKey(ruteroId),
    );
    if (row == null) {
      return null;
    }

    return CollectionsSummary(
      totalCount: row.totalCount,
      totalAmount: row.totalAmount,
      cashTotal: row.cashTotal,
      otherTotal: row.otherTotal,
    );
  }

  Future<void> cacheRoutes({
    required String storeId,
    required List<RouteSummary> routes,
  }) async {
    final now = DateTime.now().toUtc();
    final rows = routes
        .map(
          (route) => CachedRoutesCompanion.insert(
            id: route.id,
            storeId: storeId,
            vendorId: route.vendorId,
            clientIdsJson: jsonEncode(route.clientIds),
            routeDate: Value(route.routeDate),
            status: route.status,
            notes: Value(route.notes),
            cachedAt: now,
          ),
        )
        .toList();

    await _database.replaceRoutes(storeId, rows);
  }

  Future<List<RouteSummary>> getRoutes(String storeId) async {
    final rows = await _database.getRoutes(storeId);
    return rows
        .map((row) {
          final rawClientIds = jsonDecode(row.clientIdsJson);
          final clientIds = rawClientIds is List
              ? rawClientIds.map((value) => value.toString()).toList()
              : <String>[];

          return RouteSummary(
            id: row.id,
            storeId: row.storeId,
            vendorId: row.vendorId,
            clientIds: clientIds,
            routeDate: row.routeDate,
            status: row.status,
            notes: row.notes,
          );
        })
        .toList();
  }

  Future<void> cacheDeliveries({
    required String storeId,
    required List<DeliverySummary> deliveries,
  }) async {
    final now = DateTime.now().toUtc();
    final rows = deliveries
        .map(
          (delivery) => CachedDeliveriesCompanion.insert(
            id: delivery.id,
            storeId: storeId,
            orderId: delivery.orderId,
            status: delivery.status,
            itemsJson: jsonEncode(
              delivery.items
                  .map(
                    (item) => {
                      'id': item.id,
                      'description': item.description,
                      'quantity': item.quantity,
                      'salePrice': item.salePrice,
                    },
                  )
                  .toList(),
            ),
            total: delivery.total,
            clientId: Value(delivery.clientId),
            clientName: Value(delivery.clientName),
            clientAddress: Value(delivery.clientAddress),
            ruteroId: Value(delivery.ruteroId),
            paymentType: Value(delivery.paymentType),
            salesManagerName: Value(delivery.salesManagerName),
            notes: Value(delivery.notes),
            cachedAt: now,
          ),
        )
        .toList();

    await _database.replaceDeliveries(storeId, rows);
  }

  Future<List<DeliverySummary>> getDeliveries(String storeId) async {
    final rows = await _database.getDeliveries(storeId);
    return rows
        .map((row) {
          final rawItems = jsonDecode(row.itemsJson);
          final items = rawItems is List
              ? rawItems
                    .map(
                      (item) => DeliveryItemSummary.fromJson(
                        Map<String, dynamic>.from(item as Map),
                      ),
                    )
                    .toList()
              : <DeliveryItemSummary>[];

          return DeliverySummary(
            id: row.id,
            storeId: row.storeId,
            orderId: row.orderId,
            status: row.status,
            items: items,
            total: row.total,
            clientId: row.clientId,
            clientName: row.clientName,
            clientAddress: row.clientAddress,
            ruteroId: row.ruteroId,
            paymentType: row.paymentType,
            salesManagerName: row.salesManagerName,
            notes: row.notes,
          );
        })
        .toList();
  }

  Stream<int> watchPendingSyncCount() {
    return _database.watchPendingSyncCount();
  }

  Stream<int> watchFailedSyncCount() {
    return _database.watchFailedSyncCount();
  }

  Stream<List<SyncQueueEntry>> watchRecentSyncEntries({int limit = 8}) {
    return _database.watchRecentSyncEntries(limit: limit);
  }

  Future<void> logRealtimeEvent(RealtimeEvent event) async {
    await _database.insertRealtimeEvent(
      RealtimeEventLogsCompanion.insert(
        channel: event.channel,
        eventType: event.label,
        payloadJson: jsonEncode(event.payload),
        storeId: Value(event.storeId),
        receivedAt: DateTime.now().toUtc(),
      ),
    );
  }

  Stream<RealtimeEvent?> watchLatestRealtimeEvent() {
    return _database.watchLatestRealtimeEvent().map((row) {
      if (row == null) {
        return null;
      }

      return RealtimeEvent.fromCache(
        channel: row.channel,
        eventType: row.eventType,
        storeId: row.storeId,
        payloadJson: row.payloadJson,
      );
    });
  }

  Future<int> enqueueSyncAction({
    required String method,
    required String endpoint,
    String? storeId,
    String? operationType,
    Map<String, dynamic>? payload,
  }) async {
    return _database.enqueueSyncEntry(
      SyncQueueEntriesCompanion.insert(
        method: method.toUpperCase(),
        endpoint: endpoint,
        payloadJson: Value(payload == null ? null : jsonEncode(payload)),
        storeId: Value(storeId),
        operationType: Value(operationType),
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<List<SyncQueueEntry>> getPendingSyncEntries({int limit = 25}) {
    return _database.getPendingSyncEntries(limit: limit);
  }

  Future<void> markSyncEntryCompleted(int id) {
    return _database.markSyncEntryCompleted(id);
  }

  Future<void> registerSyncAttempt(
    int id, {
    required String errorMessage,
    required bool keepPending,
  }) {
    return _database.registerSyncAttempt(
      id,
      errorMessage: errorMessage,
      keepPending: keepPending,
    );
  }

  Future<void> retryFailedSyncEntries() {
    return _database.retryFailedSyncEntries();
  }
}

final localCacheRepositoryProvider = Provider<LocalCacheRepository>((ref) {
  return LocalCacheRepository(ref.read(appDatabaseProvider));
});

final pendingSyncCountProvider = StreamProvider<int>((ref) {
  return ref.read(localCacheRepositoryProvider).watchPendingSyncCount();
});

final failedSyncCountProvider = StreamProvider<int>((ref) {
  return ref.read(localCacheRepositoryProvider).watchFailedSyncCount();
});

final recentSyncEntriesProvider = StreamProvider<List<SyncQueueEntry>>((ref) {
  return ref.read(localCacheRepositoryProvider).watchRecentSyncEntries();
});

final latestRealtimeEventProvider = StreamProvider<RealtimeEvent?>((ref) {
  return ref.read(localCacheRepositoryProvider).watchLatestRealtimeEvent();
});
