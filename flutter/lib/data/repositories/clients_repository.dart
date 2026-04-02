import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/api_client.dart';
import '../../infrastructure/local_database.dart';
import '../../infrastructure/connectivity_service.dart';
import '../../domain/models/client.dart';

/// Clients Repository — OFFLINE-FIRST
/// Reads from local SQLite. Writes enqueue to sync queue.
class ClientsRepository {
  final ApiClient _apiClient;
  final LocalDatabase _localDb;
  final ConnectivityService _connectivity;

  ClientsRepository(this._apiClient, this._localDb, this._connectivity);

  Future<List<Client>> getClientsByPreventa(String preventaId) async {
    final rows = await _localDb.getAll(
      'clients',
      where: 'assigned_preventa_id = ?',
      whereArgs: [preventaId],
    );
    if (rows.isEmpty && _connectivity.isOnline) {
      try {
        final response = await _apiClient.get(
          '/clients',
          queryParameters: {'assignedPreventaId': preventaId},
        );
        if (response.statusCode == 200 && response.data is List) {
          final items = List<Map<String, dynamic>>.from(response.data);
          await _localDb.bulkUpsert(
            'clients',
            items,
            'id',
            extraColumnsBuilder: (item) => {
              'store_id': item['storeId'] ?? '',
              'assigned_preventa_id': item['assignedPreventaId'] ?? '',
            },
          );
          return items.map((json) => Client.fromJson(json)).toList();
        }
      } catch (_) {}
      return [];
    }
    return rows.map((json) => Client.fromJson(json)).toList();
  }

  Future<List<Client>> getClientsWithDebtByPreventa(String preventaId) async {
    final clients = await getClientsByPreventa(preventaId);
    return clients.where((c) => c.currentDebt > 0).toList();
  }

  Future<void> updateClientDebt(String clientId, double paymentAmount) async {
    // Update locally first
    final data = await _localDb.getById('clients', clientId);
    if (data != null) {
      data['currentDebt'] = (data['currentDebt'] as num? ?? 0) - paymentAmount;
      await _localDb.upsert(
        'clients',
        clientId,
        data,
        extraColumns: {
          'store_id': data['storeId'] ?? '',
          'assigned_preventa_id': data['assignedPreventaId'] ?? '',
        },
      );
    }
    // Enqueue for server
    await _localDb.enqueue(
      'POST',
      '/clients/$clientId/payment',
      body: {'amount': paymentAmount},
    );
  }

  Future<void> createClient(Client client) async {
    final json = client.toJson();
    // Save locally
    await _localDb.upsert(
      'clients',
      client.id,
      json,
      extraColumns: {
        'store_id': client.storeId,
        'assigned_preventa_id': client.assignedPreventaId,
      },
    );
    // Enqueue for server
    await _localDb.enqueue('POST', '/clients', body: json);
  }

  Future<List<Map<String, dynamic>>> getZones() async {
    if (_connectivity.isOnline) {
      try {
        final response = await _apiClient.get('/zones');
        if (response.statusCode == 200) {
          return List<Map<String, dynamic>>.from(response.data);
        }
      } catch (_) {}
    }
    return [];
  }
}

final clientsRepositoryProvider = Provider<ClientsRepository>((ref) {
  return ClientsRepository(
    ref.watch(apiClientProvider),
    LocalDatabase.instance,
    ConnectivityService.instance,
  );
});
