import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/providers.dart';
import '../../../config/theme/app_colors.dart';

import 'package:intl/intl.dart';
import '../../../domain/models/client.dart';
import '../../providers/sales_dashboard_provider.dart';
import '../../../domain/models/visit_log.dart';

class PreventaHomeScreen extends ConsumerWidget {
  const PreventaHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(salesDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: dashboardAsync.when(
        data: (data) => SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, ref),
                  const SizedBox(height: 24),
                  _buildSalesStats(data),
                  const SizedBox(height: 24),
                  if (data.todaysVisits.isNotEmpty) ...[
                    _buildVisitSection(
                      context,
                      'Visitas de Hoy',
                      data.todaysVisits,
                      data.todaysLogs,
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (data.pendingVisits.isNotEmpty) ...[
                    _buildVisitSection(
                      context,
                      'Visitas Pendientes',
                      data.pendingVisits,
                      [], // No logs for pending visits in this context
                      isPending: true,
                    ),
                    const SizedBox(height: 24),
                  ],
                  const Text(
                    'Acciones Rápidas',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildRecentOrders(data),
                ],
              ),
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenido,',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const Text(
              'Agente de Ventas',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Zona Norte - 04',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => context.push('/sync-debug'),
              icon: const Icon(Icons.sync, color: AppColors.textPrimary),
            ),
            IconButton(
              onPressed: () async {
                await ref.read(authRepositoryProvider).signOut();
                ref.read(currentUserProvider.notifier).state = null;
              },
              icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSalesStats(SalesDashboardData data) {
    final formatter = NumberFormat.currency(symbol: 'C\$ ', decimalDigits: 2);
    final growthSign = data.growthPercentage >= 0 ? '+' : '';
    final growthColor = data.growthPercentage >= 0
        ? AppColors.success
        : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ventas del Mes',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Icon(Icons.trending_up, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatter.format(data.currentMonthTotal),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$growthSign${data.growthPercentage.toStringAsFixed(1)}% vs mes anterior',
            style: TextStyle(
              color: growthColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Pedidos',
                  '${data.ordersCount}',
                  Icons.shopping_bag,
                ),
              ),
              Container(width: 1, height: 30, color: Colors.white24),
              Expanded(child: _buildStatItem('Meta', '85%', Icons.flag)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildActionCard(
          icon: Icons.add_shopping_cart,
          label: 'Nueva Preventa',
          color: AppColors.primary,
          onTap: () {
            context.push('/client-portfolio', extra: {'isSelectionMode': true});
          },
        ),
        _buildActionCard(
          icon: Icons.attach_money,
          label: 'Cobranza',
          color: Colors.green,
          onTap: () {
            context.push('/cobranza');
          },
        ),
        _buildActionCard(
          icon: Icons.people,
          label: 'Clientes',
          color: Colors.orange,
          onTap: () {
            context.push('/client-portfolio');
          },
        ),
        _buildActionCard(
          icon: Icons.menu_book,
          label: 'Catálogo',
          color: Colors.purple,
          onTap: () {
            context.push('/product-catalog');
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrders(SalesDashboardData data) {
    final formatter = NumberFormat.currency(symbol: 'C\$ ', decimalDigits: 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pedidos Recientes',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (data.recentOrders.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No hay pedidos recientes hoy',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.recentOrders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final order = data.recentOrders[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pedido #${order.id.substring(0, 6)}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat.MMMd().format(order.createdAt),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      formatter.format(order.payment.amountCordobas),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildVisitSection(
    BuildContext context,
    String title,
    List<dynamic> clients,
    List<dynamic> logs, {
    bool isPending = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: clients.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final client = clients[index];
              final isVisited = logs.any((l) => l.clientId == client.id);

              return _buildVisitCard(context, client, isVisited, isPending);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVisitCard(
    BuildContext context,
    dynamic client,
    bool isVisited,
    bool isPending,
  ) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVisited
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.surfaceVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  client.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isVisited)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 16,
                ),
            ],
          ),
          Text(
            client.address,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          if (isVisited)
            const Text(
              'COMPLETADO',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 32,
              child: ElevatedButton(
                onPressed: () => _showVisitDialog(context, client),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPending
                      ? Colors.orange
                      : AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Visitar', style: TextStyle(fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }

  void _showVisitDialog(BuildContext context, dynamic client) {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            client.name,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'Desea registrar la visita o realizar un pedido?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = ref.read(currentUserProvider);
                if (user != null) {
                  // This part needs the recordVisit implementation
                  // Actually I should move this logic to a provider/controller
                  // But for the MVP of the UI:
                  Navigator.pop(context);
                  _recordVisitNoOrder(context, ref, client, user.uid);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text('Visita (Sin Pedido)'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/create-order', extra: client);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Nuevo Pedido'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _recordVisitNoOrder(
    BuildContext context,
    WidgetRef ref,
    Client client,
    String vendorId,
  ) async {
    final repository = ref.read(visitLogsRepositoryProvider);

    final visitLog = VisitLog(
      id: '', // Will be set by repository
      clientId: client.id,
      clientName: client.name,
      storeId: client.storeId,
      vendorId: vendorId,
      date: DateTime.now(),
      status: 'visited_no_order',
    );

    try {
      await repository.recordVisit(visitLog);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visita registrada (Sin pedido)'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar visita: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
