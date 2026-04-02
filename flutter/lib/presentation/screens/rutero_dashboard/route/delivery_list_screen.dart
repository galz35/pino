import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../providers/route_provider.dart';
import '../../../../domain/models/route_manifest.dart';

class DeliveryListScreen extends ConsumerStatefulWidget {
  const DeliveryListScreen({super.key});

  @override
  ConsumerState<DeliveryListScreen> createState() => _DeliveryListScreenState();
}

class _DeliveryListScreenState extends ConsumerState<DeliveryListScreen> {
  String _searchQuery = '';
  String _filter = 'Todas';

  @override
  Widget build(BuildContext context) {
    final routeAsync = ref.watch(currentRouteProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lista de Entregas'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: routeAsync.when(
              data: (route) {
                if (route == null || route.stops.isEmpty) {
                  return _buildEmptyState();
                }

                final filteredStops = route.stops.where((stop) {
                  final matchesSearch =
                      stop.client.name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      stop.client.address.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      );

                  bool matchesFilter = true;
                  if (_filter == 'Pendientes') matchesFilter = !stop.isVisited;
                  if (_filter == 'Completadas') matchesFilter = stop.isVisited;

                  return matchesSearch && matchesFilter;
                }).toList();

                if (filteredStops.isEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron paradas',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredStops.length,
                  itemBuilder: (context, index) {
                    return _buildStopCard(filteredStops[index]);
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

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        children: [
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Buscar cliente o dirección...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Todas', 'Pendientes', 'Completadas'].map((f) {
              final isSelected = _filter == f;
              return GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey,
                    ),
                  ),
                  child: Text(
                    f,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.grey,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStopCard(ManifestStop stop) {
    IconData icon;
    Color color;
    String typeText;

    if (stop is DeliveryStop) {
      icon = Icons.local_shipping;
      color = Colors.blue;
      typeText = 'ENTREGA';
    } else if (stop is CollectionStop) {
      icon = Icons.payments;
      color = Colors.green;
      typeText = 'COBRO';
    } else {
      icon = Icons.assignment;
      color = Colors.orange;
      typeText = 'COMBINADO';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          context.push('/stop-details', extra: stop);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stop.client.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      stop.client.address,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            typeText,
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (stop.isVisited)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 16,
                          )
                        else
                          const Icon(
                            Icons.pending,
                            color: AppColors.warning,
                            size: 16,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.route, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No hay ruta asignada para hoy',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
