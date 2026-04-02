import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';

import '../../../config/theme/app_colors.dart';
import '../../../domain/models/product.dart';
import '../../../domain/models/authorization_request.dart';
import '../../../data/providers/providers.dart';
import '../../providers/products_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/authorization_guard.dart';
import '../orders/checkout_screen.dart';

class ProductCatalogScreen extends ConsumerStatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  ConsumerState<ProductCatalogScreen> createState() =>
      _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends ConsumerState<ProductCatalogScreen> {
  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(filteredProductsProvider);
    final searchQuery = ref.watch(productSearchQueryProvider);
    final formatter = NumberFormat.currency(symbol: 'C\$ ', decimalDigits: 2);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Catálogo de Productos',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              _showCart(context, ref);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                ref.read(productSearchQueryProvider.notifier).setQuery(value);
              },
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o código...',
                hintStyle: const TextStyle(color: AppColors.textHint),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Products List
          Expanded(
            child: productsAsync.when(
              data: (products) => products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            searchQuery.isEmpty
                                ? 'No hay productos disponibles'
                                : 'No se encontraron resultados',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        // Use price1 (Public Price) or salePrice if available
                        final displayPrice = product.salePrice ?? product.price1;

                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.surfaceVariant),
                          ),
                          child: Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.all(12),
                              childrenPadding: const EdgeInsets.fromLTRB(
                                16,
                                0,
                                16,
                                16,
                              ),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: AppColors.primary,
                                ),
                              ),
                              title: Text(
                                product.description, // Corrected from name
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                product.barcode,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Text(
                                formatter.format(
                                  displayPrice,
                                ), // Corrected from unitPrice
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 16,
                                ),
                              ),
                              children: [
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildStockInfo(
                                      'Unidades',
                                      product.currentStock,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _showPriceSelector(product);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Agregar al Pedido'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockInfo(String label, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        Text(
          '$count',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  void _showCart(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent, // Important for rounded corners effect
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Consumer(
              builder: (context, ref, child) {
                final cart = ref.watch(cartProvider);

                return Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle bar for better UX
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      AppBar(
                        title: Text(
                          'Carrito (${cart.totalItems} items)',
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                        leading: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        centerTitle: true,
                      ),
                      const Divider(),
                      Expanded(
                        child: cart.items.isEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 64,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'El carrito está vacío',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                controller: scrollController,
                                padding: const EdgeInsets.all(16),
                                itemCount: cart.items.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = cart.items[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.surfaceVariant,
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(12),
                                      title: Text(
                                        item.product.description,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            '${item.quantity} x ${NumberFormat.currency(symbol: 'C\$ ', decimalDigits: 2).format(item.price)}',
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          if (item.unitType == 'BULTO')
                                            Container(
                                              margin: const EdgeInsets.only(
                                                top: 4,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'BULTO',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            NumberFormat.currency(
                                              symbol: 'C\$ ',
                                              decimalDigits: 2,
                                            ).format(item.total),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                              fontSize: 16,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              ref
                                                  .read(cartProvider.notifier)
                                                  .removeItem(item.product.id, item.price, item.unitType);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      SafeArea(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total:',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    NumberFormat.currency(
                                      symbol: 'C\$ ',
                                      decimalDigits: 2,
                                    ).format(cart.totalAmount),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: cart.items.isEmpty
                                      ? null
                                      : () {
                                          Navigator.pop(
                                            context,
                                          ); // Close Cart BottomSheet
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const CheckoutScreen(
                                                    client: null,
                                                  ), // Passed null client for now
                                            ),
                                          );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'CONFIRMAR PEDIDO',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showPriceSelector(Product product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Seleccionar Precio',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildPriceOption(context, product, 1, product.price1, 'Público'),
              _buildPriceOption(context, product, 2, product.price2, 'Cliente'),
              _buildPriceOption(
                context,
                product,
                3,
                product.price3,
                'Mayorista',
              ),
              const Divider(color: AppColors.surfaceVariant),
              _buildPriceOption(
                context,
                product,
                4,
                product.price4,
                'Super Mayorista (Req. Auth)',
              ),
              _buildPriceOption(
                context,
                product,
                5,
                product.price5,
                'Distribuidor (Req. Auth)',
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceOption(
    BuildContext context,
    Product product,
    int level,
    double unitPrice,
    String label,
  ) {
    final isRestricted = level >= 4;
    final bool canSellBulto = product.packagingType == 'BULTO';
    final double bultoPrice = unitPrice * product.unitsPerBulto;
    final formatter = NumberFormat.currency(symbol: 'C\$ ', decimalDigits: 2);

    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: isRestricted
                ? Colors.orange.withValues(alpha: 0.2)
                : AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              '$level',
              style: TextStyle(
                color: isRestricted ? Colors.orange : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            '$label (Unidad)',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          trailing: Text(
            formatter.format(unitPrice),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            if (isRestricted) {
              _handleRestrictedSelection(
                product,
                unitPrice,
                level,
                unitType: 'UNIT',
              );
            } else {
              _addToCart(product, unitPrice, level, unitType: 'UNIT');
            }
          },
        ),
        if (canSellBulto)
          ListTile(
            leading: CircleAvatar(
              backgroundColor: isRestricted
                  ? Colors.orange.withValues(alpha: 0.2)
                  : Colors.purple.withValues(alpha: 0.2),
              child: Icon(
                Icons.inventory_2,
                size: 16,
                color: isRestricted ? Colors.orange : Colors.purple,
              ),
            ),
            title: Text(
              '$label (Bulto x${product.unitsPerBulto})',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            trailing: Text(
              formatter.format(bultoPrice),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              if (isRestricted) {
                _handleRestrictedSelection(
                  product,
                  bultoPrice,
                  level,
                  unitType: 'BULTO',
                );
              } else {
                _addToCart(product, bultoPrice, level, unitType: 'BULTO');
              }
            },
          ),
      ],
    );
  }

  Future<void> _handleRestrictedSelection(
    Product product,
    double price,
    int level, {
    String unitType = 'UNIT',
  }) async {
    final authService = ref.read(authorizationServiceProvider);
    // Create the request object
    final request = AuthorizationRequest(
      id: '', // Backend will assign ID
      storeId: product.storeId,
      requesterId: ref.read(currentUserProvider)?.uid ?? 'unknown_user',
      type: AuthorizationType.priceOverride,
      details: {
        'productId': product.id,
        'productName': product.description,
        'requestedPrice': price,
        'priceLevel': level,
        'unitType': unitType,
      },
      status: AuthorizationStatus.pending,
    );

    // Show Guard
    if (!mounted) return;

    final approved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AuthorizationGuard(
        statusStream: authService.requestAuthorizationStream(request),
        requestId: 'Solicitando...',
      ),
    );

    if (approved == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Autorización concedida! Agregando al carrito...'),
            backgroundColor: AppColors.success,
          ),
        );
        _addToCart(product, price, level, unitType: unitType);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud rechazada o cancelada.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _addToCart(
    Product product,
    double price,
    int priceLevel, {
    String unitType = 'UNIT',
  }) {
    // Validate stock
    if (product.usesInventory && product.currentStock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto sin stock disponible'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    ref
        .read(cartProvider.notifier)
        .addItem(product, price, priceLevel, unitType: unitType);

    if (mounted) {
      final unitLabel = unitType == 'BULTO' ? 'Bulto' : 'Unidad';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.description} agregado ($unitLabel)'),
          backgroundColor: AppColors.success,
          action: SnackBarAction(
            label: 'VER CARRITO',
            textColor: Colors.white,
            onPressed: () {
              _showCart(context, ref);
            },
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
