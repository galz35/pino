import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../../domain/models/order.dart';
import '../../../data/providers/providers.dart';
import '../../widgets/primary_button.dart';

class OrderPreparationScreen extends ConsumerStatefulWidget {
  final Order order;
  const OrderPreparationScreen({super.key, required this.order});

  @override
  ConsumerState<OrderPreparationScreen> createState() =>
      _OrderPreparationScreenState();
}

class _OrderPreparationScreenState
    extends ConsumerState<OrderPreparationScreen> {
  late List<OrderItem> _items;
  bool _isSaving = false;
  final Map<String, String> _barcodeToProductId = {};
  StreamSubscription? _scannerSubscription;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.order.items);
    _loadBarcodes();
    _scannerSubscription = ref.read(scannerServiceProvider).barcodeStream.listen(_onBarcodeScanned);
  }

  @override
  void dispose() {
    _scannerSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadBarcodes() async {
    // In a real app, we might fetch only the relevant products
    // For now, we'll try to match productId as barcode if no specific mapping is found
  }

  void _onBarcodeScanned(String barcode) {
    if (_isSaving) return;

    // Find the item by barcode
    final index = _items.indexWhere(
      (item) =>
          item.productId == barcode ||
          _barcodeToProductId[barcode] == item.productId,
    );

    if (index != -1) {
      final item = _items[index];
      if (item.scannedCount < item.quantity) {
        setState(() {
          _items[index] = item.copyWith(scannedCount: item.scannedCount + 1);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Escaneado: ${item.description}'),
            duration: const Duration(seconds: 1),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cantidad completa para este item'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Código no reconocido: $barcode'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _reportDiscrepancy(int index) {
    final item = _items[index];
    final controller = TextEditingController(
      text: item.scannedCount.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Reportar Discrepancia',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Producto: ${item.description}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Cantidad Real Encontrada',
                labelStyle: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text) ?? 0;
              setState(() {
                _items[index] = item.copyWith(
                  hasDiscrepancy: true,
                  actualQuantity: val,
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Reportar'),
          ),
        ],
      ),
    );
  }

  Future<void> _finalize() async {
    setState(() => _isSaving = true);
    try {
      await ref
          .read(ordersRepositoryProvider)
          .finalizePreparation(widget.order.id, _items);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preparación finalizada con éxito')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allDone = _items.every(
      (item) => item.scannedCount >= item.quantity || item.hasDiscrepancy,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Preparando #${widget.order.id.substring(0, 8)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () async {
              final code = await context.push<String>('/camera-scanner');
              if (code != null) {
                _onBarcodeScanned(code);
              }
            },
            tooltip: 'Escanear con Cámara',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final item = _items[index];
                final isDone = item.scannedCount >= item.quantity;

                return Card(
                  color: AppColors.surface,
                  child: ListTile(
                    leading: Icon(
                      isDone ? Icons.check_circle : Icons.circle_outlined,
                      color: isDone
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                    title: Text(
                      item.description,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Solicitado: ${item.quantity} | Escaneado: ${item.scannedCount}',
                          style: TextStyle(
                            color: isDone
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                        ),
                        if (item.hasDiscrepancy)
                          Text(
                            'DISCREPANCIA: ${item.actualQuantity} real',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    trailing: item.hasDiscrepancy
                        ? const Icon(Icons.warning, color: Colors.red)
                        : IconButton(
                            icon: const Icon(
                              Icons.edit_note,
                              color: Colors.orange,
                            ),
                            onPressed: () => _reportDiscrepancy(index),
                          ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: PrimaryButton(
              text: 'Finalizar Preparación',
              onPressed: allDone ? _finalize : null,
              isLoading: _isSaving,
            ),
          ),
        ],
      ),
    );
  }
}
