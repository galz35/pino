import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../domain/models/order.dart';
import '../../../../domain/models/route_manifest.dart';

class StopDetailsScreen extends StatelessWidget {
  final ManifestStop stop;

  const StopDetailsScreen({super.key, required this.stop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detalle de Parada'),
        backgroundColor: AppColors.surface,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClientInfoCard(),
            const SizedBox(height: 16),
            _buildActionButtons(context),
            const SizedBox(height: 16),
            // Placeholder for specific stop type details (items to deliver, amount to collect)
            if (stop is DeliveryStop)
              _buildDeliveryDetails(stop as DeliveryStop),
            if (stop is CollectionStop)
              _buildCollectionDetails(stop as CollectionStop),
            if (stop is CombinedStop) ...[
              _buildOrderInfo((stop as CombinedStop).order),
              const SizedBox(height: 16),
              _buildAmountInfo((stop as CombinedStop).amountToCollect),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.store, color: AppColors.primary, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stop.client.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Código: ${stop.client.id}', // Assuming ID is the code
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.surfaceVariant, height: 32),
          _buildInfoRow(Icons.location_on, stop.client.address),
          if (stop.client.phone.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.phone, stop.client.phone),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _openMaps(context),
            icon: const Icon(Icons.navigation),
            label: const Text('Navegar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final phone = stop.client.phone;
              if (phone.isEmpty) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cliente sin teléfono registrado'),
                    ),
                  );
                }
                return;
              }

              final Uri launchUri = Uri(scheme: 'tel', path: phone);

              try {
                if (await canLaunchUrl(launchUri)) {
                  await launchUrl(launchUri);
                } else {
                  // Fallback or attempt to launch anyway if canLaunch returns false due to queries config
                  await launchUrl(launchUri);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No se pudo llamar: $e')),
                  );
                }
              }
            },
            icon: const Icon(Icons.call),
            label: const Text('Llamar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openMaps(BuildContext context) async {
    final location = stop.client.location;
    if (location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente sin ubicación registrada')),
      );
      return;
    }

    try {
      final availableMaps = await MapLauncher.installedMaps;
      if (!context.mounted) return;

      if (availableMaps.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay apps de mapas instaladas')),
        );
        return;
      }

      await showModalBottomSheet(
        context: context,
        builder: (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...availableMaps.map(
                (map) => ListTile(
                  title: Text(map.mapName),
                  leading: const Icon(Icons.map),
                  onTap: () {
                    Navigator.pop(context);
                    map.showMarker(
                      coords: Coords(location.lat, location.lng),
                      title: stop.client.name,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      log('Error opening maps', error: e);
    }
  }

  Widget _buildDeliveryDetails(DeliveryStop stop) {
    return _buildOrderInfo(stop.order);
  }

  Widget _buildCollectionDetails(CollectionStop stop) {
    return _buildAmountInfo(stop.amountToCollect);
  }

  // New helper methods
  Widget _buildOrderInfo(Order order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pedido a Entregar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#${order.id.substring(0, order.id.length > 6 ? 6 : order.id.length)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.surfaceVariant),
          const SizedBox(height: 8),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.description,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${item.quantity} ${item.unitType == 'BULTO' ? 'Bultos' : 'Unidades'}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'C\$ ${item.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: AppColors.surfaceVariant),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'C\$ ${order.payment.amountCordobas.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInfo(double amount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cobro Pendiente',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Monto: $amount',
            style: const TextStyle(
              color: AppColors.success,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
