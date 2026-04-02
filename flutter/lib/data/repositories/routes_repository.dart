import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/api_client.dart';
import '../../infrastructure/local_database.dart';
import '../../infrastructure/connectivity_service.dart';
import '../../domain/models/route_manifest.dart';

/// Routes Repository — OFFLINE-FIRST
/// Caches today's route manifest locally for uninterrupted field ops.
class RoutesRepository {
  final ApiClient _apiClient;
  final LocalDatabase _localDb;
  final ConnectivityService _connectivity;

  RoutesRepository(this._apiClient, this._localDb, this._connectivity);

  /// Get today's route from local DB, falls back to network
  Future<RouteManifest?> getTodayRoute(String driverId) async {
    // Try local first
    final rows = await _localDb.getAll(
      'route_manifests',
      where: 'driver_id = ?',
      whereArgs: [driverId],
    );

    // If we have a cached route for today, use it
    final today = DateTime.now().toIso8601String().substring(0, 10);
    for (final row in rows) {
      final manifest = RouteManifest.fromJson(row);
      if (manifest.date.toIso8601String().substring(0, 10) == today) {
        return manifest;
      }
    }

    // Fallback: try network
    if (_connectivity.isOnline) {
      try {
        final response = await _apiClient.get(
          '/routes/today',
          queryParameters: {'driverId': driverId},
        );
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data as Map<String, dynamic>;
          await _localDb.upsert(
            'route_manifests',
            data['id'] ?? driverId,
            data,
            extraColumns: {'driver_id': driverId, 'date': today},
          );
          return RouteManifest.fromJson(data);
        }
      } catch (_) {}
    }
    return null;
  }

  /// Update stop status locally + enqueue
  Future<void> updateStopStatus(
    String routeId,
    String stopId,
    String status,
  ) async {
    await _localDb.enqueue(
      'PUT',
      '/routes/$routeId/stops/$stopId',
      body: {'status': status},
    );
  }
}

final routesRepositoryProvider = Provider<RoutesRepository>((ref) {
  return RoutesRepository(
    ref.watch(apiClientProvider),
    LocalDatabase.instance,
    ConnectivityService.instance,
  );
});
