import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../../data/repositories/orders_repository.dart';
import '../../../domain/models/order.dart';

class AyudanteDashboardScreen extends ConsumerWidget {
  const AyudanteDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Asistente de Bodega'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
      body: FutureBuilder<List<Order>>(
        future: ref
            .watch(ordersRepositoryProvider)
            .getOrdersByPreparationStatus(PreparationStatus.pending),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(
              child: Text(
                'No hay pedidos pendientes',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.builder(
            itemCount: orders.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                color: AppColors.surface,
                child: ListTile(
                  title: Text(
                    'Pedido #${order.id.substring(0, 8)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Cliente ID: ${order.clientId}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () =>
                        context.push('/order-preparation', extra: order),
                    child: const Text('Iniciar'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
