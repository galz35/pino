import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/services/hardware_interfaces.dart';
import '../../infrastructure/services/sunmi_printer_service.dart';
import '../../infrastructure/services/generic_printer_service.dart';
import '../../infrastructure/services/scanner_service.dart';
import '../../infrastructure/local_database.dart';
import '../../infrastructure/connectivity_service.dart';
import '../../infrastructure/sync_engine.dart';
import '../../infrastructure/api_client.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/models/user_model.dart';

// Re-export all repository providers
export '../../data/repositories/auth_repository.dart'
    show authRepositoryProvider;
export '../../data/repositories/clients_repository.dart'
    show clientsRepositoryProvider;
export '../../data/repositories/orders_repository.dart'
    show ordersRepositoryProvider;
export '../../data/repositories/routes_repository.dart'
    show routesRepositoryProvider;
export '../../data/repositories/products_repository.dart'
    show productsRepositoryProvider;
export '../../data/repositories/visit_logs_repository.dart'
    show visitLogsRepositoryProvider;
export '../../data/services/authorization_service.dart'
    show authorizationServiceProvider;
export '../../infrastructure/api_client.dart' show apiClientProvider;

// ==========================================
// Infrastructure Providers
// ==========================================

final storageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Local SQLite database — the offline Firestore replacement
final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  return LocalDatabase.instance;
});

/// Connectivity watcher
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService.instance;
});

/// Reactive stream: is the device online?
final isOnlineProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onConnectivityChanged;
});

/// Sync Engine — bridges Local DB ↔ NestJS
final syncEngineProvider = Provider<SyncEngine>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final localDb = ref.watch(localDatabaseProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return SyncEngine(apiClient, localDb, connectivity);
});

/// Pending sync operations count (for UI badge)
final pendingSyncCountProvider = StreamProvider<int>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return engine.pendingCountStream;
});

// ==========================================
// Hardware Providers
// ==========================================

final scannerServiceProvider = Provider<ScannerService>((ref) {
  return ScannerService();
});

final printerServiceProvider = FutureProvider<IPrinterService>((ref) async {
  final sunmi = SunmiPrinterService();
  if (await sunmi.isDeviceSupported()) {
    return sunmi;
  }
  return GenericPrinterService();
});

// ==========================================
// App User Management
// ==========================================

final currentUserProvider = StateProvider<AppUser?>((ref) => null);

final authStatusProvider = FutureProvider<bool>((ref) async {
  final user = await ref.watch(authRepositoryProvider).getCurrentUser();
  if (user != null) {
    ref.read(currentUserProvider.notifier).state = user;
    return true;
  }
  return false;
});
