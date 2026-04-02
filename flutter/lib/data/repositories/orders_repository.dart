import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/local_database.dart';
import '../../domain/models/order.dart';
import '../../domain/models/daily_closing.dart';

/// Orders Repository — OFFLINE-FIRST
/// Creates orders locally. Syncs to server in background.
/// NO MORE while(true) polling loops.
class OrdersRepository {
  final LocalDatabase _localDb;

  OrdersRepository(this._localDb);

  /// Get all orders from local DB
  Future<List<Order>> getOrders() async {
    final rows = await _localDb.getAll('orders', orderBy: 'updated_at DESC');
    return rows.map((json) => Order.fromJson(json)).toList();
  }

  /// Get orders by driver from local DB
  Future<List<Order>> getOrdersByDriver(String driverId) async {
    final rows = await _localDb.getAll(
      'orders',
      where: 'driver_id = ?',
      whereArgs: [driverId],
    );
    return rows.map((json) => Order.fromJson(json)).toList();
  }

  /// Get orders by preparation status from local DB
  Future<List<Order>> getOrdersByPreparationStatus(
    PreparationStatus status,
  ) async {
    final rows = await _localDb.getAll(
      'orders',
      where: 'preparation_status = ?',
      whereArgs: [status.name],
    );
    return rows.map((json) => Order.fromJson(json)).toList();
  }

  /// Get a single order
  Future<Order?> getOrder(String orderId) async {
    final data = await _localDb.getById('orders', orderId);
    if (data != null) return Order.fromJson(data);
    return null;
  }

  /// CREATE an order — saves locally, enqueues for server
  Future<void> createOrder(Order order) async {
    final json = order.toJson();

    await _localDb.upsert(
      'orders',
      order.id,
      json,
      extraColumns: {
        'store_id': '',
        'status': order.status.name,
        'preparation_status': order.preparationStatus.name,
        'driver_id': order.delivery.driverId,
        'is_local': 1,
        'synced': 0,
      },
    );

    await _localDb.enqueue('POST', '/orders', body: json);
  }

  /// Update preparation status locally + enqueue
  Future<void> updatePreparationStatus(
    String orderId,
    PreparationStatus status, {
    String? preparedBy,
  }) async {
    final data = await _localDb.getById('orders', orderId);
    if (data != null) {
      data['preparationStatus'] = status.name;
      if (preparedBy != null) data['preparedBy'] = preparedBy;
      await _localDb.upsert(
        'orders',
        orderId,
        data,
        extraColumns: {
          'preparation_status': status.name,
          'store_id': data['storeId'] ?? '',
          'status': data['status'] ?? '',
          'driver_id': data['delivery']?['driverId'] ?? '',
          'is_local': 0,
          'synced': 0,
        },
      );
    }

    final updates = <String, dynamic>{'preparationStatus': status.name};
    if (preparedBy != null) updates['preparedBy'] = preparedBy;
    await _localDb.enqueue(
      'PUT',
      '/orders/$orderId/preparation-status',
      body: updates,
    );
  }

  /// Update order items locally + enqueue
  Future<void> updateOrderItems(String orderId, List<OrderItem> items) async {
    final data = await _localDb.getById('orders', orderId);
    if (data != null) {
      data['items'] = items.map((e) => e.toJson()).toList();
      await _localDb.upsert(
        'orders',
        orderId,
        data,
        extraColumns: {
          'store_id': data['storeId'] ?? '',
          'status': data['status'] ?? '',
          'preparation_status': data['preparationStatus'] ?? '',
          'driver_id': data['delivery']?['driverId'] ?? '',
          'is_local': 0,
          'synced': 0,
        },
      );
    }
    await _localDb.enqueue(
      'PUT',
      '/orders/$orderId/items',
      body: {'items': items.map((e) => e.toJson()).toList()},
    );
  }

  Future<void> finalizePreparation(
    String orderId,
    List<OrderItem> items,
  ) async {
    await _localDb.enqueue(
      'POST',
      '/orders/$orderId/finalize-preparation',
      body: {'items': items.map((e) => e.toJson()).toList()},
    );
  }

  Future<void> approveOrderForLoading(String orderId) async {
    await _localDb.enqueue('POST', '/orders/$orderId/approve-loading');
  }

  Future<void> requestAuthorization(String orderId, AuthRequest request) async {
    await _localDb.enqueue(
      'POST',
      '/orders/$orderId/auth-requests',
      body: request.toJson(),
    );
  }

  Future<void> recordDailyClosing(DailyClosing closing) async {
    await _localDb.enqueue('POST', '/daily-closings', body: closing.toJson());
  }
}

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository(LocalDatabase.instance);
});
