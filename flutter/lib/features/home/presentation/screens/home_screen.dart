import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/utils/role_utils.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/home_repository.dart';
import '../../domain/models/store_summary.dart';

final assignedStoresProvider = FutureProvider<List<StoreSummary>>((ref) async {
  final authState = ref.watch(authControllerProvider);
  final session = authState.session;

  if (session == null) {
    return <StoreSummary>[];
  }

  final repository = ref.read(homeRepositoryProvider);
  return repository.getAssignedStores(
    userId: session.user.id,
    accessToken: session.accessToken,
  );
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedStoreId;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final storesAsync = ref.watch(assignedStoresProvider);
    final session = authState.session;

    if (session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final role = normalizeRole(session.user.role);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pino Mobile'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(assignedStoresProvider);
          await ref.read(assignedStoresProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _HeroSessionCard(
              name: session.user.name,
              email: session.user.email,
              roleLabelText: roleLabel(role),
            ),
            const SizedBox(height: 18),
            storesAsync.when(
              data: (stores) {
                final currentStoreId =
                    _selectedStoreId ??
                    (stores.isNotEmpty ? stores.first.id : null);
                final currentStore =
                    stores
                        .where((store) => store.id == currentStoreId)
                        .isNotEmpty
                    ? stores.firstWhere((store) => store.id == currentStoreId)
                    : (stores.isNotEmpty ? stores.first : null);

                return Column(
                  children: [
                    _StoreScopeCard(
                      stores: stores,
                      currentStoreId: currentStoreId,
                      onSelected: (storeId) {
                        setState(() {
                          _selectedStoreId = storeId;
                        });
                      },
                    ),
                    const SizedBox(height: 18),
                    _RoleActionGrid(role: role, store: currentStore),
                  ],
                );
              },
              loading: () =>
                  const _LoadingCard(title: 'Cargando tiendas asignadas...'),
              error: (error, stackTrace) => _ErrorCard(
                title: 'No se pudieron cargar las tiendas del usuario.',
                message: error.toString(),
              ),
            ),
            const SizedBox(height: 18),
            _BackendRuntimeCard(
              apiBaseUrl: AppConfig.apiBaseUrl,
              socketBaseUrl:
                  '${AppConfig.socketBaseUrl}${AppConfig.socketPath}',
              namespace: AppConfig.socketNamespace,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroSessionCard extends StatelessWidget {
  const _HeroSessionCard({
    required this.name,
    required this.email,
    required this.roleLabelText,
  });

  final String name;
  final String email;
  final String roleLabelText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF14532D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.phone_iphone_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.84),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              roleLabelText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreScopeCard extends StatelessWidget {
  const _StoreScopeCard({
    required this.stores,
    required this.currentStoreId,
    required this.onSelected,
  });

  final List<StoreSummary> stores;
  final String? currentStoreId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alcance operativo',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stores.isEmpty
                ? 'Este usuario no tiene tiendas asignadas todavía.'
                : 'Selecciona la tienda de trabajo activa para el siguiente corte móvil.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          if (stores.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: stores
                  .map(
                    (store) => ChoiceChip(
                      label: Text(store.name),
                      selected: store.id == currentStoreId,
                      onSelected: (_) => onSelected(store.id),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _RoleActionGrid extends StatelessWidget {
  const _RoleActionGrid({required this.role, required this.store});

  final AppRole role;
  final StoreSummary? store;

  @override
  Widget build(BuildContext context) {
    final actions = _actionsForRole(role);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frente móvil por rol',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        ...actions.map(
          (action) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ActionCard(
              title: action.title,
              subtitle: action.subtitle,
              icon: action.icon,
              storeName: store?.name,
            ),
          ),
        ),
      ],
    );
  }

  List<_ActionDescriptor> _actionsForRole(AppRole role) {
    switch (role) {
      case AppRole.masterAdmin:
      case AppRole.owner:
        return const [
          _ActionDescriptor(
            title: 'Supervisión global',
            subtitle: 'Tiendas, usuarios, licencias y monitoreo operativo.',
            icon: Icons.travel_explore_rounded,
          ),
          _ActionDescriptor(
            title: 'Configuración maestra',
            subtitle: 'Cadenas, zonas, subzonas y control de activación.',
            icon: Icons.admin_panel_settings_rounded,
          ),
        ];
      case AppRole.storeAdmin:
        return const [
          _ActionDescriptor(
            title: 'Operación de tienda',
            subtitle: 'Catálogo, inventario, caja, pedidos y finanzas.',
            icon: Icons.store_mall_directory_rounded,
          ),
          _ActionDescriptor(
            title: 'Control de personal',
            subtitle: 'Usuarios, vendedores, rutas, cobros y autorizaciones.',
            icon: Icons.groups_rounded,
          ),
        ];
      case AppRole.inventory:
        return const [
          _ActionDescriptor(
            title: 'Bodega e inventario',
            subtitle: 'Recepción, ajustes, movimientos y alistamiento.',
            icon: Icons.inventory_2_rounded,
          ),
          _ActionDescriptor(
            title: 'Despacho físico',
            subtitle: 'Preparación y transición hacia carga de camión.',
            icon: Icons.local_shipping_rounded,
          ),
        ];
      case AppRole.dispatcher:
        return const [
          _ActionDescriptor(
            title: 'Despacho',
            subtitle:
                'Pedidos pendientes, control tower y seguimiento de salida.',
            icon: Icons.alt_route_rounded,
          ),
          _ActionDescriptor(
            title: 'Entrega',
            subtitle: 'Asignación operativa de ruta y estado de cumplimiento.',
            icon: Icons.route_rounded,
          ),
        ];
      case AppRole.rutero:
        return const [
          _ActionDescriptor(
            title: 'Ruta y entrega',
            subtitle: 'Manifiesto, paradas, entregas y devoluciones.',
            icon: Icons.map_rounded,
          ),
          _ActionDescriptor(
            title: 'Cobranza',
            subtitle: 'Cartera pendiente, abonos y cierre diario.',
            icon: Icons.payments_rounded,
          ),
        ];
      case AppRole.vendor:
      case AppRole.salesManager:
        return const [
          _ActionDescriptor(
            title: 'Preventa',
            subtitle: 'Catálogo, pedido móvil, clientes y visitas.',
            icon: Icons.point_of_sale_rounded,
          ),
          _ActionDescriptor(
            title: 'Seguimiento comercial',
            subtitle: 'Cobros, cartera y avance operativo por zona.',
            icon: Icons.query_stats_rounded,
          ),
        ];
      case AppRole.cashier:
        return const [
          _ActionDescriptor(
            title: 'Caja',
            subtitle: 'Apertura, cierre, cobros y conciliación diaria.',
            icon: Icons.account_balance_wallet_rounded,
          ),
        ];
      case AppRole.unknown:
        return const [
          _ActionDescriptor(
            title: 'Sesión válida',
            subtitle:
                'El rol se autenticó, pero aún no tiene un mapa móvil asignado.',
            icon: Icons.lock_open_rounded,
          ),
        ];
    }
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.storeName,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? storeName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    height: 1.35,
                  ),
                ),
                if (storeName != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Tienda activa: $storeName',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackendRuntimeCard extends StatelessWidget {
  const _BackendRuntimeCard({
    required this.apiBaseUrl,
    required this.socketBaseUrl,
    required this.namespace,
  });

  final String apiBaseUrl;
  final String socketBaseUrl;
  final String namespace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Runtime técnico',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _RuntimeLine(label: 'API', value: apiBaseUrl),
          const SizedBox(height: 8),
          _RuntimeLine(label: 'Socket', value: socketBaseUrl),
          const SizedBox(height: 8),
          _RuntimeLine(label: 'Namespace', value: namespace),
        ],
      ),
    );
  }
}

class _RuntimeLine extends StatelessWidget {
  const _RuntimeLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 84,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.76),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
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

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFDA4AF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF9F1239),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF9F1239),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionDescriptor {
  const _ActionDescriptor({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
