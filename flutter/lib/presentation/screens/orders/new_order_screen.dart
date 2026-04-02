import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/products_provider.dart';
import '../../providers/cart_provider.dart';
import '../../../data/providers/providers.dart';
import 'checkout_screen.dart';
import 'dart:async';

class NewOrderScreen extends ConsumerStatefulWidget {
  const NewOrderScreen({super.key});

  @override
  ConsumerState<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends ConsumerState<NewOrderScreen> {
  StreamSubscription? _scannerSubscription;

  @override
  void initState() {
    super.initState();
    _initHardwareScanner();
  }

  @override
  void dispose() {
    _scannerSubscription?.cancel();
    super.dispose();
  }

  void _initHardwareScanner() {
    _scannerSubscription = ref.read(scannerServiceProvider).barcodeStream.listen((barcode) {
      _onBarcodeScanned(barcode);
    });
  }

  Future<void> _onBarcodeScanned(String barcode) async {
    // 1. Search for product in local DB via provider
    final products = await ref.read(productsProvider.future);
    final product = products.cast<dynamic>().firstWhere(
      (p) => p.barcode == barcode || p.id == barcode,
      orElse: () => null,
    );

    if (product != null) {
      _addProductToOrder(product);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Producto no encontrado: $barcode'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _addProductToOrder(dynamic product) {
    // Implement actual state-managed order basket
    ref.read(cartProvider.notifier).addItem(
      product,
      product.price1, // Primary price
      1,              // Default price level
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agregado: ${product.description}'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _openCameraScanner() async {
    final String? result = await context.push<String>('/camera-scanner');
    if (result != null) {
      _onBarcodeScanned(result);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Nueva Preventa',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.textPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Client Header Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.info,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.store, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CLIENTE',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tienda Don Jose',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'ID: #BP-88291 • Zona Norte',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.edit, color: AppColors.textSecondary),
              ],
            ),
          ),

          // Products Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Productos Agregados',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${ref.watch(cartProvider).totalItems} Items',
                  style: const TextStyle(
                    color: AppColors.info,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Product List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: ref.watch(cartProvider).items.length,
              itemBuilder: (context, index) {
                final item = ref.watch(cartProvider).items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildProductItem(
                    item: item,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        // Using bottomSheet for fixed positioning
        color: AppColors.background,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subtotal',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  Text(
                    'C\$ ${ref.watch(cartProvider).totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'IVA (15%)', // Local Nicaragua IVA is 15%, previously was 16% in placeholder
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  Text(
                    'C\$ ${(ref.watch(cartProvider).totalAmount * 0.15).toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Estimado',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'C\$ ${(ref.watch(cartProvider).totalAmount * 1.15).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (ref.read(cartProvider).items.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Agregue productos antes de finalizar')),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CheckoutScreen(client: null),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Finalizar Preventa',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'REQUIERE VALIDACIÓN DE PRECIO: BOTANA ARTESANAL XL',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'camera_scan',
            onPressed: _openCameraScanner,
            backgroundColor: AppColors.info,
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'hardware_scan',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Escáner de hardware activo. Use el botón físico del PDA.')),
              );
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.barcode_reader),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem({
    required CartItem item,
  }) {
    final product = item.product;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              image: product.imageUrl != null 
                ? DecorationImage(
                    image: NetworkImage(product.imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
            ),
            child: product.imageUrl == null 
              ? const Icon(Icons.shopping_bag, color: AppColors.textSecondary, size: 40)
              : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.description,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'C\$ ${item.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.info,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SKU: ${product.id} • C\$ ${item.price}/u',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildQtyButton(Icons.remove, () {
                ref.read(cartProvider.notifier).updateQuantity(
                  product.id,
                  item.price,
                  item.unitType,
                  item.quantity - 1,
                );
              }),
              Container(
                width: 30,
                alignment: Alignment.center,
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              _buildQtyButton(Icons.add, () {
                ref.read(cartProvider.notifier).updateQuantity(
                  product.id,
                  item.price,
                  item.unitType,
                  item.quantity + 1,
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: AppColors.textPrimary, size: 16),
        onPressed: onTap,
      ),
    );
  }
}
