import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme/app_colors.dart';
import '../../../data/repositories/orders_repository.dart';
import '../../../domain/models/order.dart';

class BodegueroApprovalScreen extends ConsumerWidget {
  const BodegueroApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pedidos por Cargar')),
      body: FutureBuilder<List<Order>>(
        future: ref
            .watch(ordersRepositoryProvider)
            .getOrdersByPreparationStatus(PreparationStatus.prepared),
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
                'No hay pedidos listos para cargar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.builder(
            itemCount: orders.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final order = orders[index];
              final hasDiscrepancy = order.items.any(
                (item) => item.hasDiscrepancy,
              );

              return Card(
                color: AppColors.surface,
                child: ExpansionTile(
                  iconColor: Colors.white,
                  collapsedIconColor: AppColors.textSecondary,
                  title: Text(
                    'Pedido #${order.id.substring(0, 8)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    hasDiscrepancy
                        ? 'DIFERENCIA REPORTADA'
                        : 'Preparado por: ${order.preparedBy ?? "N/A"}',
                    style: TextStyle(
                      color: hasDiscrepancy
                          ? Colors.red
                          : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  children: [
                    ...order.items.map(
                      (item) => ListTile(
                        title: Text(
                          item.description,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          'Cant: ${item.quantity} | Prep: ${item.scannedCount}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        trailing: item.hasDiscrepancy
                            ? const Icon(
                                Icons.warning,
                                color: Colors.red,
                                size: 20,
                              )
                            : const Icon(
                                Icons.check,
                                color: AppColors.success,
                                size: 20,
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.local_shipping),
                        label: const Text('Aprobar y Cargar al Camión'),
                        onPressed: () => _approveOrder(context, ref, order.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 45),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _approveOrder(
    BuildContext context,
    WidgetRef ref,
    String orderId,
  ) async {
    try {
      await ref.read(ordersRepositoryProvider).approveOrderForLoading(orderId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido cargado con éxito')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
