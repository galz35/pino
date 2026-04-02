import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../config/theme/app_colors.dart';
import '../../providers/collection_provider.dart';
import '../../providers/settings_provider.dart';
import '../../../domain/models/client.dart';

class CobranzaScreen extends ConsumerStatefulWidget {
  const CobranzaScreen({super.key});

  @override
  ConsumerState<CobranzaScreen> createState() => _CobranzaScreenState();
}

class _CobranzaScreenState extends ConsumerState<CobranzaScreen> {
  String _searchQuery = '';
  final _amountController = TextEditingController();
  final _dollarsController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _dollarsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsWithDebtProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Módulo de Cobranza'),
        backgroundColor: AppColors.surface,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar cliente...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: clientsAsync.when(
              data: (clients) {
                final filtered = clients
                    .where(
                      (c) => c.name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron clientes con deuda',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final client = filtered[index];
                    return _buildClientTile(client);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientTile(Client client) {
    final formatter = NumberFormat.currency(symbol: 'C\$ ', decimalDigits: 2);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface,
      child: ListTile(
        title: Text(
          client.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              client.address,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              'Deuda: ${formatter.format(client.currentDebt)}',
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _showPaymentDialog(client),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Cobrar', style: TextStyle(color: Colors.black)),
        ),
      ),
    );
  }

  void _showPaymentDialog(Client client) {
    _amountController.clear();
    _dollarsController.clear();
    _notesController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final settingsAsync = ref.watch(settingsProvider);

            return settingsAsync.when(
              data: (settings) {
                final exchangeRate = settings.exchangeRate;

                return AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: Text(
                    'Cobro: ${client.name}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Tasa de Cambio: C\$ $exchangeRate',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Monto en Córdobas',
                            labelStyle: TextStyle(color: Colors.grey),
                            prefixText: 'C\$ ',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _dollarsController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Monto en Dólares',
                            labelStyle: TextStyle(color: Colors.grey),
                            prefixText: '\$ ',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _notesController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Notas / Referencia',
                            labelStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final amountC =
                            double.tryParse(_amountController.text) ?? 0;
                        final amountD =
                            double.tryParse(_dollarsController.text) ?? 0;

                        if (amountC == 0 && amountD == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ingrese un monto válido'),
                            ),
                          );
                          return;
                        }

                        await ref
                            .read(collectionNotifierProvider.notifier)
                            .recordPayment(
                              client: client,
                              amountCordobas: amountC,
                              amountDollars: amountD,
                              exchangeRate: exchangeRate,
                              notes: _notesController.text,
                            );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cobro registrado exitosamente'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text(
                        'Guardar',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, st) => AlertDialog(
                title: const Text('Error'),
                content: Text(e.toString()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
