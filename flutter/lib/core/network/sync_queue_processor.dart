import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../database/local_cache_repository.dart';
import 'api_client.dart';
import 'connectivity_service.dart';

enum SyncQueueStatus { idle, syncing, offline, error }

class SyncQueueState {
  const SyncQueueState({
    required this.status,
    this.lastError,
    this.lastSyncAt,
  });

  final SyncQueueStatus status;
  final String? lastError;
  final DateTime? lastSyncAt;

  factory SyncQueueState.initial() {
    return const SyncQueueState(status: SyncQueueStatus.idle);
  }

  SyncQueueState copyWith({
    SyncQueueStatus? status,
    String? lastError,
    DateTime? lastSyncAt,
    bool clearError = false,
  }) {
    return SyncQueueState(
      status: status ?? this.status,
      lastError: clearError ? null : lastError ?? this.lastError,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }
}

class SyncQueueProcessor extends Notifier<SyncQueueState> {
  bool _isProcessing = false;
  StreamSubscription<NetworkStatus>? _connectivitySub;

  late final AppApiClient _client;
  late final LocalCacheRepository _localCache;
  late final ConnectivityService _connectivityService;

  @override
  SyncQueueState build() {
    _client = ref.read(appApiClientProvider);
    _localCache = ref.read(localCacheRepositoryProvider);
    _connectivityService = ref.read(connectivityServiceProvider);

    _connectivitySub ??= _connectivityService.statuses.listen((status) {
      if (status == NetworkStatus.online) {
        unawaited(processPendingQueue());
      } else {
        state = state.copyWith(status: SyncQueueStatus.offline);
      }
    });

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.isAuthenticated) {
        unawaited(processPendingQueue());
      } else {
        state = SyncQueueState.initial();
      }
    });

    ref.onDispose(() async {
      await _connectivitySub?.cancel();
    });

    unawaited(processPendingQueue());

    return SyncQueueState.initial();
  }

  Future<void> processPendingQueue() async {
    if (_isProcessing) {
      return;
    }

    final authState = ref.read(authControllerProvider);
    final session = authState.session;
    if (!authState.isAuthenticated || session == null) {
      return;
    }

    final online = await _connectivityService.isOnline();
    if (!online) {
      state = state.copyWith(status: SyncQueueStatus.offline);
      return;
    }

    _isProcessing = true;
    state = state.copyWith(
      status: SyncQueueStatus.syncing,
      clearError: true,
    );

    try {
      final entries = await _localCache.getPendingSyncEntries(limit: 50);
      var hasFailedEntries = false;
      String? failedMessage;

      for (final entry in entries) {
        final payload = entry.payloadJson == null
            ? null
            : jsonDecode(entry.payloadJson!) as Map<String, dynamic>;

        try {
          switch (entry.method.toUpperCase()) {
            case 'POST':
              await _client.postMap(
                entry.endpoint,
                bearerToken: session.accessToken,
                data: payload,
              );
              break;
            case 'PATCH':
              await _client.patchMap(
                entry.endpoint,
                bearerToken: session.accessToken,
                data: payload,
              );
              break;
            default:
              await _localCache.registerSyncAttempt(
                entry.id,
                errorMessage: 'Método ${entry.method} no soportado.',
                keepPending: false,
              );
              continue;
          }

          await _localCache.markSyncEntryCompleted(entry.id);
        } on ApiFailure catch (error) {
          final keepPending =
              error.isConnectivityIssue || error.statusCode == 401;

          await _localCache.registerSyncAttempt(
            entry.id,
            errorMessage: error.message,
            keepPending: keepPending,
          );

          if (error.isConnectivityIssue) {
            state = state.copyWith(
              status: SyncQueueStatus.offline,
              lastError: error.message,
            );
            break;
          }

          if (!keepPending) {
            hasFailedEntries = true;
            failedMessage = error.message;
          }
        } catch (error) {
          await _localCache.registerSyncAttempt(
            entry.id,
            errorMessage: error.toString(),
            keepPending: false,
          );
          hasFailedEntries = true;
          failedMessage = error.toString();
        }
      }

      if (state.status != SyncQueueStatus.offline) {
        if (hasFailedEntries) {
          state = state.copyWith(
            status: SyncQueueStatus.error,
            lastError: failedMessage ?? 'Hay operaciones que requieren revisión.',
            lastSyncAt: DateTime.now().toUtc(),
          );
        } else {
          state = state.copyWith(
            status: SyncQueueStatus.idle,
            lastSyncAt: DateTime.now().toUtc(),
            clearError: true,
          );
        }
      }
    } catch (error) {
      state = state.copyWith(
        status: SyncQueueStatus.error,
        lastError: error.toString(),
      );
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> retryFailedQueue() async {
    await _localCache.retryFailedSyncEntries();
    await processPendingQueue();
  }
}

final syncQueueProcessorProvider =
    NotifierProvider<SyncQueueProcessor, SyncQueueState>(
      SyncQueueProcessor.new,
    );
