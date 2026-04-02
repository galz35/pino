import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/product.dart';
import '../../../domain/models/client.dart';
import 'package:flutter/services.dart';
import '../../../domain/models/authorization_request.dart';
import '../../widgets/product_image.dart';
import '../../../data/providers/providers.dart';
import '../../widgets/authorization_guard.dart';
import '../../providers/products_provider.dart';
import '../../providers/cart_provider.dart';
import 'checkout_screen.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  final Client? client;
  const CreateOrderScreen({super.key, this.client});

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nueva Preventa'),
            if (widget.client != null)
              Text(
                'Cliente: ${widget.client!.name}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar producto',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final productsAsync = ref.watch(productsProvider);

                return productsAsync.when(
                  data: (products) {
                    final filteredProducts = products.where((product) {
                      return product.description.toLowerCase().contains(
                            _searchQuery,
                          ) ||
                          product.barcode.contains(_searchQuery);
                    }).toList();

                    if (filteredProducts.isEmpty) {
                      return const Center(
                        child: Text('No se encontraron productos'),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: ProductImage(
                              imageUrl: product.imageUrl,
                              size: 50,
                            ),
                            title: Text(product.description),
                            subtitle: Text(
                              'Stock: ${product.formattedTotalStock}',
                            ),
                            trailing: const Icon(Icons.add_shopping_cart),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _showPriceSelector(product);
                            },
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          final cartConfig = ref.watch(cartProvider);
          if (cartConfig.items.isEmpty) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: () => _showCart(context, ref),
            label: Text(
              'Ver Carrito (\$${cartConfig.totalAmount.toStringAsFixed(2)})',
            ),
            icon: const Icon(Icons.shopping_cart),
          );
        },
      ),
    );
  }

  void _showPriceSelector(Product product) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Seleccionar Precio para ${product.description}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
              const Divider(),
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

    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: isRestricted
                ? Colors.orange.shade100
                : Colors.blue.shade100,
            child: Text('$level'),
          ),
          title: Text('$label (Unidad)'),
          trailing: Text('\$${unitPrice.toStringAsFixed(2)}'),
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
                  ? Colors.orange.shade100
                  : Colors.purple.shade100,
              child: const Icon(Icons.inventory_2, size: 16),
            ),
            title: Text('$label (Bulto x${product.unitsPerBulto})'),
            trailing: Text('\$${bultoPrice.toStringAsFixed(2)}'),
            onTap: () {
              Navigator.pop(context);
              if (isRestricted) {
                _handleRestrictedSelection(
                  product,
                  bultoPrice, // Store full price of Bulto? Or Unit Price?
                  // Usually Cart stores Item Price. If UnitType is BULTO, is Price per Bulto or Unit?
                  // Cart item has `price` and `quantity`.
                  // If I sell 1 Bulto, Quantity = 1, Price = BultoPrice.
                  // Total = 1 * BultoPrice. Correct.
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
          ),
        );
        _addToCart(product, price, level, unitType: unitType);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitud rechazada o cancelada.')),
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
    HapticFeedback.lightImpact();
    ref
        .read(cartProvider.notifier)
        .addItem(product, price, priceLevel, unitType: unitType);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Producto agregado: ${product.description}'),
          action: SnackBarAction(
            label: 'DESHACER',
            onPressed: () {
              // Optional: Implement remove/undo logic here if desired
              ref.read(cartProvider.notifier).removeItemByProductId(product.id);
            },
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showCart(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Consumer(
              builder: (context, ref, child) {
                final cart = ref.watch(cartProvider);

                return Column(
                  children: [
                    AppBar(
                      title: Text('Carrito (${cart.totalItems} items)'),
                      leading: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.black,
                    ),
                    Expanded(
                      child: cart.items.isEmpty
                          ? const Center(child: Text('El carrito está vacío'))
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: cart.items.length,
                              itemBuilder: (context, index) {
                                final item = cart.items[index];
                                return ListTile(
                                  title: Text(item.product.description),
                                  subtitle: Text(
                                    '${item.quantity} x \$${item.price.toStringAsFixed(2)}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '\$${item.total.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
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
                                );
                              },
                            ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total:',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '\$${cart.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
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
                                            builder: (_) => CheckoutScreen(
                                              client: widget.client,
                                            ),
                                          ),
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: const Text('CONFIRMAR PEDIDO'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
