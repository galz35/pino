import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/models/order.dart';
import '../../providers/cart_provider.dart';
import '../../../data/providers/providers.dart';
import '../../../data/repositories/settings_repository.dart';

import '../../../domain/models/client.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final Client? client;
  const CheckoutScreen({super.key, this.client});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _addressController = TextEditingController();

  PaymentType _paymentType = PaymentType.cash;
  bool _isLoading = false;
  double _exchangeRate = 36.5; // Will be loaded from settings

  @override
  void initState() {
    super.initState();
    if (widget.client != null) {
      _clientNameController.text = widget.client!.name;
      _addressController.text = widget.client!.address;
    }
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await ref.read(settingsRepositoryProvider).getSettings();
      if (mounted) {
        setState(() => _exchangeRate = settings.exchangeRate);
      }
    } catch (_) {
      // Use default if settings unavailable
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _processOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cart = ref.read(cartProvider);
      final currentUser = ref.read(currentUserProvider);

      if (cart.items.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('El carrito está vacío')));
        return;
      }

      // 1. Create Order Objects
      final now = DateTime.now();
      final orderId = const Uuid().v4();

      final orderItems = cart.items.map((item) {
        return OrderItem(
          productId: item.product.id,
          description: item.product.description,
          quantity: item.quantity,
          price: item.price,
          total: item.total,
          unitType: item.unitType,
        );
      }).toList();

      final paymentInfo = PaymentInfo(
        type: _paymentType,
        dueDate: now,
        amountCordobas: cart.totalAmount,
        amountDollars: _exchangeRate > 0 ? cart.totalAmount / _exchangeRate : 0,
        exchangeRate: _exchangeRate,
      );

      final deliveryInfo = DeliveryInfo(
        driverId: currentUser?.uid ?? 'unknown',
        routeId: '',
        lat: 0,
        lng: 0,
        deliveredAt: null,
      );

      final order = Order(
        id: orderId,
        clientId: widget.client?.id ?? 'temp_client_id',
        sectorId:
            widget.client?.sectorId ??
            widget.client?.subZoneId ??
            'unknown_sector',
        scheduledDeliveryDate: now, // Placeholder
        status: OrderStatus.pending,
        items: orderItems,
        payment: paymentInfo,
        delivery: deliveryInfo,
        createdAt: now,
        updatedAt: now,
      );

      // 2. Save to Repository
      await ref.read(ordersRepositoryProvider).createOrder(order);

      // 3. Print Ticket
      try {
        final printer = await ref.read(printerServiceProvider.future);
        await printer.printTicket(order);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al imprimir: $e')));
        }
      }

      // 4. Clear Cart
      ref.read(cartProvider.notifier).clear();

      if (!mounted) return;

      // 5. Success & Navigate Back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido creado exitosamente')),
      );

      // Navigate back to Home or Orders List, pop until first
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al crear pedido: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar Pedido')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cart Summary Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Items:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('${cart.totalItems}'),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total a Pagar:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'C\$ ${cart.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Datos del Cliente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _clientNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Cliente',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Requerido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Dirección',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        // Make optional for now
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Método de Pago',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    RadioGroup<PaymentType>(
                      groupValue: _paymentType,
                      onChanged: (val) {
                        if (val != null) setState(() => _paymentType = val);
                      },
                      child: Column(
                        children: [
                          RadioListTile<PaymentType>(
                            title: const Text('Efectivo'),
                            value: PaymentType.cash,
                          ),
                          RadioListTile<PaymentType>(
                            title: const Text('Crédito'),
                            value: PaymentType.credit,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _processOrder,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'FINALIZAR PEDIDO',
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
    );
  }
}
