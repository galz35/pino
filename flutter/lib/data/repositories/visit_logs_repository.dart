import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../infrastructure/api_client.dart';
import '../../infrastructure/local_database.dart';
import '../../infrastructure/connectivity_service.dart';
import '../../domain/models/visit_log.dart';

/// Visit Logs Repository — OFFLINE-FIRST
/// Records visits locally (with UUID) for instant UI, enqueues for server sync.
class VisitLogsRepository {
  final ApiClient _apiClient;
  final LocalDatabase _localDb;
  final ConnectivityService _connectivity;
  static const _uuid = Uuid();

  VisitLogsRepository(this._apiClient, this._localDb, this._connectivity);

  /// Record a visit — saves locally + enqueues for server
  Future<void> recordVisit(VisitLog log) async {
    final json = log.toJson();
    final id = json['id'] ?? _uuid.v4();
    await _localDb.upsert(
      'visit_logs',
      id,
      json,
      extraColumns: {
        'vendor_id': json['vendorId'] ?? '',
        'client_id': json['clientId'] ?? '',
        'synced': 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
    );
    await _localDb.enqueue('POST', '/visit-logs', body: json);
  }

  /// Get visit logs for a client — from local DB
  Future<List<VisitLog>> getVisitLogsForClient(String clientId) async {
    final rows = await _localDb.getAll(
      'visit_logs',
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'created_at DESC',
    );
    if (rows.isEmpty && _connectivity.isOnline) {
      try {
        final response = await _apiClient.get('/visit-logs/client/$clientId');
        if (response.statusCode == 200 && response.data is List) {
          return List<Map<String, dynamic>>.from(
            response.data,
          ).map((json) => VisitLog.fromJson(json)).toList();
        }
      } catch (_) {}
    }
    return rows.map((json) => VisitLog.fromJson(json)).toList();
  }

  /// Get today's visit logs — from local DB
  Future<List<VisitLog>> getVisitLogsForToday(String vendorId) async {
    final rows = await _localDb.getAll(
      'visit_logs',
      where: 'vendor_id = ?',
      whereArgs: [vendorId],
      orderBy: 'created_at DESC',
    );
    // Filter for today
    final today = DateTime.now();
    final logs = rows.map((json) => VisitLog.fromJson(json)).toList();
    return logs.where((l) {
      final logDate = l.date;
      return logDate.year == today.year &&
          logDate.month == today.month &&
          logDate.day == today.day;
    }).toList();
  }

  /// Get weekly visit logs
  Future<List<VisitLog>> getVisitLogsForCurrentWeek(String vendorId) async {
    final rows = await _localDb.getAll(
      'visit_logs',
      where: 'vendor_id = ?',
      whereArgs: [vendorId],
      orderBy: 'created_at DESC',
    );
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final logs = rows.map((json) => VisitLog.fromJson(json)).toList();
    return logs.where((l) => l.date.isAfter(weekStart)).toList();
  }
}

final visitLogsRepositoryProvider = Provider<VisitLogsRepository>((ref) {
  return VisitLogsRepository(
    ref.watch(apiClientProvider),
    LocalDatabase.instance,
    ConnectivityService.instance,
  );
});
