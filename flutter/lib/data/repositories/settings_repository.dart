import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/api_client.dart';
import '../../infrastructure/local_database.dart';
import '../../infrastructure/connectivity_service.dart';
import '../../domain/models/global_settings.dart';

/// Settings Repository — OFFLINE-FIRST
/// Caches settings locally. Refreshes on sync.
class SettingsRepository {
  final ApiClient _apiClient;
  final LocalDatabase _localDb;
  final ConnectivityService _connectivity;

  SettingsRepository(this._apiClient, this._localDb, this._connectivity);

  Future<GlobalSettings> getSettings() async {
    // Try local cache first
    final cached = await _localDb.getById('settings', 'global');
    if (cached != null) {
      return GlobalSettings.fromJson(cached);
    }
    // Fallback to network
    if (_connectivity.isOnline) {
      try {
        final response = await _apiClient.get('/settings/global');
        if (response.statusCode == 200) {
          final data = response.data as Map<String, dynamic>;
          await _localDb.upsert('settings', 'global', data);
          return GlobalSettings.fromJson(data);
        }
      } catch (_) {}
    }
    return const GlobalSettings(defaultCreditDays: 30, exchangeRate: 36.5);
  }

  Future<void> updateSettings(GlobalSettings settings) async {
    final json = settings.toJson();
    await _localDb.upsert('settings', 'global', json);
    await _localDb.enqueue('PUT', '/settings/global', body: json);
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(
    ref.watch(apiClientProvider),
    LocalDatabase.instance,
    ConnectivityService.instance,
  );
});
