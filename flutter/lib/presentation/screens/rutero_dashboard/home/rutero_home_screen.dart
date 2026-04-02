import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:map_launcher/map_launcher.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../providers/route_provider.dart';
import '../../../../domain/models/route_manifest.dart';
import '../../../../data/providers/providers.dart';

class RuteroHomeScreen extends ConsumerWidget {
  const RuteroHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextStopAsync = ref.watch(nextStopProvider);
    final statsAsync = ref.watch(routeStatsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(currentRouteProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, ref, user?.email ?? 'Conductor'),
                  const SizedBox(height: 24),
                  _buildRouteProgress(
                    statsAsync.value?['visited'] ?? 0,
                    statsAsync.value?['total'] ?? 0,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Próxima Parada',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildNextStopCard(context, nextStopAsync.value),
                  const SizedBox(height: 24),
                  const Text(
                    'Operaciones',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildOperationsGrid(
                    context,
                    ref,
                    (statsAsync.value?['total'] ?? 0) - (statsAsync.value?['visited'] ?? 0),
                  ),
                  const SizedBox(height: 24),
                  _buildStatusFooter(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
                image: const DecorationImage(
                  image: NetworkImage('https://i.pravatar.cc/150?u=driver'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Ruta Bodega Los Pinos',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => context.push('/sync-debug'),
              icon: const Icon(Icons.sync, color: Colors.white),
            ),
            IconButton(
              onPressed: () async {
                await ref.read(authRepositoryProvider).signOut();
                ref.read(currentUserProvider.notifier).state = null;
              },
              icon: const Icon(Icons.logout, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRouteProgress(int visited, int total) {
    final progress = total == 0 ? 0.0 : visited / total;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progreso de jornada',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              Text(
                '$visited/$total Paradas',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStopCard(BuildContext context, ManifestStop? stop) {
    if (stop == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No hay paradas pendientes',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SIGUIENTE',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              if (stop is CombinedStop)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Prioridad Alta',
                    style: TextStyle(color: Colors.blue, fontSize: 10),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.storefront,
                  color: AppColors.textSecondary,
                ),
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stop.client.address,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final location = stop.client.location;
                if (location != null) {
                  try {
                    final availableMaps = await MapLauncher.installedMaps;

                    if (!context.mounted) return;

                    if (availableMaps.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No hay aplicaciones de mapas instaladas',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    await showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder: (context) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'Abrir ruta en...',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ...availableMaps.map(
                                (map) => ListTile(
                                  leading: const Icon(Icons.map_outlined),
                                  title: Text(map.mapName),
                                  onTap: () {
                                    Navigator.pop(context);
                                    map.showMarker(
                                      coords: Coords(
                                        location.lat,
                                        location.lng,
                                      ),
                                      title: stop.client.name,
                                      description: stop.client.address,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      },
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No se pudo abrir el mapa'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Este cliente no tiene ubicación registrada',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.navigation, size: 16),
              label: const Text('Iniciar Navegación'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsGrid(
    BuildContext context,
    WidgetRef ref,
    int pendingCount,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildOperationCard(
          icon: Icons.map,
          label: 'Mapa de Ruta',
          subLabel: 'Vista Satelital',
          color: Colors.blue,
          onTap: () async {
            final routeAsync = ref.read(currentRouteProvider);

            routeAsync.whenData((manifest) async {
              if (manifest == null || manifest.stops.isEmpty) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No hay ruta activa para mostrar'),
                    ),
                  );
                }
                return;
              }

              final stops = manifest.stops;
              final origin =
                  '${stops.first.client.location!.lat},${stops.first.client.location!.lng}';
              final destination =
                  '${stops.last.client.location!.lat},${stops.last.client.location!.lng}';

              final waypoints = stops
                  .skip(1)
                  .take(stops.length - 2)
                  .map(
                    (s) =>
                        '${s.client.location!.lat},${s.client.location!.lng}',
                  )
                  .join('|');

              final googleMapsUrl =
                  'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&waypoints=$waypoints&travelmode=driving';

              final uri = Uri.parse(googleMapsUrl);

              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No se pudo abrir el mapa')),
                  );
                }
              }
            });
          },
        ),
        _buildOperationCard(
          icon: Icons.list_alt,
          label: 'Lista Entregas',
          subLabel: '$pendingCount pendientes',
          color: Colors.orange,
          onTap: () {
            context.push('/delivery-list');
          },
        ),
        _buildOperationCard(
          icon: Icons.inventory_2,
          label: 'Carga/Recolección',
          subLabel: 'Validar Inventario',
          color: Colors.purple,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Módulo de inventario en desarrollo'),
              ),
            );
          },
        ),
        _buildOperationCard(
          icon: Icons.assignment_turned_in,
          label: 'Liquidación Final',
          subLabel: 'Cierre de caja',
          color: Colors.green,
          onTap: () {
            context.push('/day-closing');
          },
        ),
      ],
    );
  }

  Widget _buildOperationCard({
    required IconData icon,
    required String label,
    required String subLabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subLabel,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatusItem(Icons.local_gas_station, '85%', 'Combustible'),
          _buildStatusItem(Icons.check_circle, 'Óptimo', 'Estado Vehículo'),
          _buildStatusItem(Icons.speed, '32 PSI', 'Presión'),
        ],
      ),
    );
  }

  Widget _buildStatusItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
        ),
      ],
    );
  }
}
