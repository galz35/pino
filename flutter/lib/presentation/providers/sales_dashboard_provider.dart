import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/providers/providers.dart';
import '../../domain/models/order.dart';
import '../../domain/models/client.dart';
import '../../domain/models/visit_log.dart';

part 'sales_dashboard_provider.freezed.dart';
part 'sales_dashboard_provider.g.dart';

@freezed
class SalesDashboardData with _$SalesDashboardData {
  const factory SalesDashboardData({
    @Default(0.0) double currentMonthTotal,
    @Default(0.0) double previousMonthTotal,
    @Default(0) int ordersCount,
    @Default([]) List<Order> recentOrders,
    @Default(0.0) double growthPercentage,
    @Default([]) List<Client> todaysVisits,
    @Default([]) List<Client> pendingVisits,
    @Default([]) List<VisitLog> todaysLogs,
  }) = _SalesDashboardData;
}

@riverpod
class SalesDashboard extends _$SalesDashboard {
  @override
  Future<SalesDashboardData> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SalesDashboardData();

    // Fetch data simultaneously from local DB
    final res = await Future.wait([
      ref.watch(ordersRepositoryProvider).getOrdersByDriver(user.uid),
      ref.watch(clientsRepositoryProvider).getClientsByPreventa(user.uid),
      ref.watch(clientsRepositoryProvider).getZones(),
      ref
          .watch(visitLogsRepositoryProvider)
          .getVisitLogsForCurrentWeek(user.uid),
    ]);

    final orders = res[0] as List<Order>;
    final clients = res[1] as List<Client>;
    final zones = res[2] as List<Map<String, dynamic>>;
    final logs = res[3] as List<VisitLog>;

    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    // Calculate previous month/year logic
    final prevMonthDate = DateTime(now.year, now.month - 1);
    final prevMonth = prevMonthDate.month;
    final prevYear = prevMonthDate.year;

    double currentTotal = 0;
    double prevTotal = 0;
    int count = 0;

    for (final order in orders) {
      if (order.status == OrderStatus.cancelled) continue;

      final date = order.createdAt;
      final amount = order.payment.amountCordobas;

      if (date.year == currentYear && date.month == currentMonth) {
        currentTotal += amount;
        count++;
      } else if (date.year == prevYear && date.month == prevMonth) {
        prevTotal += amount;
      }
    }

    // Recent orders: take top 5
    final recent = orders.take(5).toList();

    // Growth
    double growth = 0.0;
    if (prevTotal > 0) {
      growth = ((currentTotal - prevTotal) / prevTotal) * 100;
    } else if (currentTotal > 0) {
      growth = 100.0;
    }

    // Visit Logic
    final todaySpanish = _getWeekdaySpanish(now.weekday);
    final startOfToday = DateTime(now.year, now.month, now.day);

    final todaysLogs = logs.where((l) => l.date.isAfter(startOfToday)).toList();

    final todaysVisits = <Client>[];
    final pendingVisits = <Client>[];

    for (final client in clients) {
      final zoneData = zones.firstWhere(
        (z) => z['id'] == client.zoneId,
        orElse: () => <String, dynamic>{},
      );
      final visitDay = zoneData['visitDay'] as String? ?? 'Ninguno';

      if (visitDay == todaySpanish) {
        todaysVisits.add(client);
      } else if (visitDay != 'Ninguno' && visitDay != 'Mensual') {
        // Check if visited this week
        final visitedThisWeek = logs.any((l) => l.clientId == client.id);
        if (!visitedThisWeek) {
          pendingVisits.add(client);
        }
      }
    }

    return SalesDashboardData(
      currentMonthTotal: currentTotal,
      previousMonthTotal: prevTotal,
      ordersCount: count,
      recentOrders: recent,
      growthPercentage: growth,
      todaysVisits: todaysVisits,
      pendingVisits: pendingVisits,
      todaysLogs: todaysLogs,
    );
  }

  // Action methods to mutate and refresh dashboard
  Future<void> refresh() async {
    // Optionally trigger a sync before refreshing
    ref.invalidateSelf();
  }

  String _getWeekdaySpanish(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Lunes';
      case DateTime.tuesday:
        return 'Martes';
      case DateTime.wednesday:
        return 'Miércoles';
      case DateTime.thursday:
        return 'Jueves';
      case DateTime.friday:
        return 'Viernes';
      case DateTime.saturday:
        return 'Sábado';
      case DateTime.sunday:
        return 'Domingo';
      default:
        return 'Ninguno';
    }
  }
}
