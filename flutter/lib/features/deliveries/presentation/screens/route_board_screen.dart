import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/local_cache_repository.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/network/sync_queue_processor.dart';
import '../../../../core/realtime/realtime_event.dart';
import '../../../../core/utils/role_utils.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/route_board_repository.dart';
import '../../domain/models/delivery_summary.dart';
import '../../domain/models/route_summary.dart';

class RouteBoardArgs {
  const RouteBoardArgs({
    required this.storeId,
    required this.storeName,
    required this.userId,
    required this.role,
  });

  final String storeId;
  final String? storeName;
  final String userId;
  final AppRole role;

  @override
  bool operator ==(Object other) {
    return other is RouteBoardArgs &&
        other.storeId == storeId &&
        other.storeName == storeName &&
        other.userId == userId &&
        other.role == role;
  }

  @override
  int get hashCode => Object.hash(storeId, storeName, userId, role);
}

final routeBoardProvider = FutureProvider.family
    .autoDispose<RouteBoardSnapshot, RouteBoardArgs>((ref, args) async {
      ref.watch(networkStatusProvider);
      ref.watch(syncQueueProcessorProvider.select((state) => state.lastSyncAt));
      ref.watch(
        latestRealtimeEventProvider.select((asyncEvent) {
          final event = asyncEvent.asData?.value;
          if (event == null || event.storeId != args.storeId) {
            return null;
          }
          switch (event.type) {
            case RealtimeEventType.newOrder:
            case RealtimeEventType.orderStatusChange:
            case RealtimeEventType.inventoryTransfer:
              return '${event.label}:${event.payload.hashCode}';
            case RealtimeEventType.unknown:
              return null;
          }
        }),
      );

      final session = ref.watch(authControllerProvider).session;
      if (session == null) {
        return const RouteBoardSnapshot(routes: [], deliveries: []);
      }

      final vendorId = switch (args.role) {
        AppRole.vendor || AppRole.salesManager => args.userId,
        _ => null,
      };
      final ruteroId = switch (args.role) {
        AppRole.rutero => args.userId,
        _ => null,
      };

      return ref
          .read(routeBoardRepositoryProvider)
          .getSnapshot(
            storeId: args.storeId,
            accessToken: session.accessToken,
            vendorId: vendorId,
            ruteroId: ruteroId,
          );
    });

class RouteBoardScreen extends ConsumerStatefulWidget {
  const RouteBoardScreen({
    required this.storeId,
    this.storeName,
    super.key,
  });

  final String storeId;
  final String? storeName;

  @override
  ConsumerState<RouteBoardScreen> createState() => _RouteBoardScreenState();
}

class _RouteBoardScreenState extends ConsumerState<RouteBoardScreen> {
  final _searchController = TextEditingController();
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final session = authState.session;
    if (session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final role = normalizeRole(session.user.role);
    final args = RouteBoardArgs(
      storeId: widget.storeId,
      storeName: widget.storeName,
      userId: session.user.id,
      role: role,
    );
    final snapshotAsync = ref.watch(routeBoardProvider(args));

    return Scaffold(
      appBar: AppBar(title: const Text('Ruta y entregas')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(routeBoardProvider(args));
          await ref.read(routeBoardProvider(args).future);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _RouteHero(
              role: roleLabel(role),
              storeName: widget.storeName,
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchText = value.trim().toLowerCase();
                });
              },
            ),
            const SizedBox(height: 18),
            snapshotAsync.when(
              data: (snapshot) {
                final visibleRoutes = snapshot.routes.where((route) {
                  if (_searchText.isEmpty) {
                    return true;
                  }
                  final haystack = [
                    route.status,
                    route.notes ?? '',
                    route.id,
                  ].join(' ').toLowerCase();
                  return haystack.contains(_searchText);
                }).toList();

                final visibleDeliveries = snapshot.deliveries.where((delivery) {
                  if (_searchText.isEmpty) {
                    return true;
                  }
                  final haystack = [
                    delivery.clientName ?? '',
                    delivery.clientAddress ?? '',
                    delivery.status,
                    delivery.salesManagerName ?? '',
                  ].join(' ').toLowerCase();
                  return haystack.contains(_searchText);
                }).toList();

                final assignedCount = snapshot.deliveries
                    .where((delivery) => (delivery.ruteroId ?? '').isNotEmpty)
                    .length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _BoardMetric(
                          label: 'Rutas',
                          value: '${snapshot.routes.length}',
                          color: const Color(0xFF14532D),
                        ),
                        _BoardMetric(
                          label: 'Entregas',
                          value: '${snapshot.deliveries.length}',
                          color: const Color(0xFF1D4ED8),
                        ),
                        _BoardMetric(
                          label: 'Asignadas',
                          value: '$assignedCount',
                          color: const Color(0xFFD97706),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _SectionHeader(
                      title: 'Rutas activas',
                      subtitle: 'Visión rápida de manifiestos y recorridos.',
                    ),
                    const SizedBox(height: 12),
                    if (visibleRoutes.isEmpty)
                      const _BoardEmptyCard(
                        title: 'Sin rutas visibles',
                        message: 'No hay rutas para el filtro actual.',
                      )
                    else
                      ...visibleRoutes.map(
                        (route) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RouteCard(route: route),
                        ),
                      ),
                    const SizedBox(height: 18),
                    _SectionHeader(
                      title: 'Entregas',
                      subtitle:
                          'Lista rápida para ruta, despacho o supervisión.',
                    ),
                    const SizedBox(height: 12),
                    if (visibleDeliveries.isEmpty)
                      const _BoardEmptyCard(
                        title: 'Sin entregas visibles',
                        message: 'No hay entregas para el filtro actual.',
                      )
                    else
                      ...visibleDeliveries.map(
                        (delivery) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _DeliveryCard(delivery: delivery),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const _BoardLoadingCard(
                title: 'Cargando ruta y entregas...',
              ),
              error: (error, stackTrace) => _BoardErrorCard(
                message: error.toString(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteHero extends StatelessWidget {
  const _RouteHero({
    required this.role,
    required this.controller,
    required this.onChanged,
    this.storeName,
  });

  final String role;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? storeName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            storeName == null ? 'Ruta viva' : 'Ruta viva • $storeName',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vista rápida para $role. Menos pasos, más operación.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Buscar cliente, dirección o estado...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.route});

  final RouteSummary route;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ruta ${route.id.substring(0, route.id.length > 8 ? 8 : route.id.length)}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              _StatusBadge(status: route.status),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _BoardPill(
                icon: Icons.groups_rounded,
                text: '${route.clientIds.length} clientes',
              ),
              _BoardPill(
                icon: Icons.event_rounded,
                text: route.routeDate == null
                    ? 'Sin fecha'
                    : _shortDate(route.routeDate!),
              ),
            ],
          ),
          if ((route.notes ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              route.notes!,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.delivery});

  final DeliverySummary delivery;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      delivery.clientName?.isNotEmpty == true
                          ? delivery.clientName!
                          : 'Cliente sin nombre',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      delivery.clientAddress?.isNotEmpty == true
                          ? delivery.clientAddress!
                          : 'Sin dirección registrada',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: delivery.status),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _BoardPill(
                icon: Icons.inventory_2_outlined,
                text: '${delivery.totalItems} items',
              ),
              _BoardPill(
                icon: Icons.payments_outlined,
                text: 'C\$ ${delivery.total.toStringAsFixed(2)}',
              ),
              if ((delivery.paymentType ?? '').isNotEmpty)
                _BoardPill(
                  icon: Icons.receipt_long_outlined,
                  text: delivery.paymentType!,
                ),
            ],
          ),
          if ((delivery.salesManagerName ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Gestor: ${delivery.salesManagerName}',
              style: const TextStyle(
                color: Color(0xFF1D4ED8),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    Color background;
    Color foreground;

    if (normalized.contains('entrega') || normalized.contains('progress')) {
      background = const Color(0xFFDBEAFE);
      foreground = const Color(0xFF1D4ED8);
    } else if (normalized.contains('alist') || normalized.contains('load')) {
      background = const Color(0xFFFDE68A);
      foreground = const Color(0xFF92400E);
    } else if (normalized.contains('entregado') ||
        normalized.contains('complete')) {
      background = const Color(0xFFDCFCE7);
      foreground = const Color(0xFF166534);
    } else {
      background = const Color(0xFFF1F5F9);
      foreground = const Color(0xFF475569);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        status,
        style: TextStyle(color: foreground, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _BoardMetric extends StatelessWidget {
  const _BoardMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _BoardPill extends StatelessWidget {
  const _BoardPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF475569)),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}

class _BoardLoadingCard extends StatelessWidget {
  const _BoardLoadingCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(title)),
        ],
      ),
    );
  }
}

class _BoardErrorCard extends StatelessWidget {
  const _BoardErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFDA4AF)),
      ),
      child: Text(message),
    );
  }
}

class _BoardEmptyCard extends StatelessWidget {
  const _BoardEmptyCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.route_outlined, size: 42, color: Color(0xFF64748B)),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

String _shortDate(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$day/$month/$year';
}
