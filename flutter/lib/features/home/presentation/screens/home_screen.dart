import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/database/local_cache_repository.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/network/sync_queue_processor.dart';
import '../../../../core/realtime/realtime_controller.dart';
import '../../../../core/realtime/realtime_event.dart';
import '../../../../core/realtime/websocket_service.dart';
import '../../../../core/utils/role_utils.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/home_repository.dart';
import '../../domain/models/store_summary.dart';

final assignedStoresProvider = FutureProvider<List<StoreSummary>>((ref) async {
  ref.watch(networkStatusProvider);
  ref.watch(syncQueueProcessorProvider.select((state) => state.lastSyncAt));

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
  bool _realtimeBootstrapped = false;

  @override
  void dispose() {
    ref.read(realtimeControllerProvider.notifier).disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final syncQueueState = ref.watch(syncQueueProcessorProvider);
    final networkStatusAsync = ref.watch(networkStatusProvider);
    final realtimeState = ref.watch(realtimeControllerProvider);
    final pendingSyncCountAsync = ref.watch(pendingSyncCountProvider);
    final failedSyncCountAsync = ref.watch(failedSyncCountProvider);
    final latestRealtimeEventAsync = ref.watch(latestRealtimeEventProvider);
    final storesAsync = ref.watch(assignedStoresProvider);
    final session = authState.session;

    if (session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final role = normalizeRole(session.user.role);

    if (!_realtimeBootstrapped) {
      _realtimeBootstrapped = true;
      Future<void>.microtask(
        () => ref
            .read(realtimeControllerProvider.notifier)
            .connect(
              session,
              storeId: _selectedStoreId ?? session.user.primaryStoreId,
            ),
      );
    }

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
          await ref.read(syncQueueProcessorProvider.notifier).processPendingQueue();
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
                        ref
                            .read(realtimeControllerProvider.notifier)
                            .connect(session, storeId: storeId);
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
              networkStatus: networkStatusAsync.asData?.value,
              syncQueueState: syncQueueState,
              realtimeState: realtimeState,
              pendingSyncCount: pendingSyncCountAsync.asData?.value ?? 0,
              failedSyncCount: failedSyncCountAsync.asData?.value ?? 0,
              latestCachedEvent: latestRealtimeEventAsync.asData?.value,
              onRetrySync: () =>
                  ref.read(syncQueueProcessorProvider.notifier).processPendingQueue(),
              onRetryFailed: () =>
                  ref.read(syncQueueProcessorProvider.notifier).retryFailedQueue(),
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
    final primaryAction = actions.first;
    final secondaryActions = actions.skip(1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Modo rápido',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Un usuario de calle o bodega no debería perder tiempo navegando.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
        ),
        const SizedBox(height: 12),
        _ActionCard(
          title: primaryAction.title,
          subtitle: primaryAction.subtitle,
          icon: primaryAction.icon,
          storeName: store?.name,
          primary: true,
          onTap: store == null
              ? null
              : () => _openAction(
                    context,
                    action: primaryAction,
                    storeId: store!.id,
                    storeName: store?.name,
                  ),
        ),
        const SizedBox(height: 12),
        ...secondaryActions.map(
          (action) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ActionCard(
              title: action.title,
              subtitle: action.subtitle,
              icon: action.icon,
              storeName: store?.name,
              onTap: store == null
                  ? null
                  : () => _openAction(
                        context,
                        action: action,
                        storeId: store!.id,
                        storeName: store?.name,
                      ),
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
            title: 'Capturar pedido',
            subtitle: 'Cliente pide, tú apuntas y guardas sin salir del flujo.',
            icon: Icons.flash_on_rounded,
            routeKey: _RouteKey.quickOrder,
          ),
          _ActionDescriptor(
            title: 'Bodega',
            subtitle: 'Recibir, alistar y cargar pedidos sin vueltas extras.',
            icon: Icons.warehouse_rounded,
            routeKey: _RouteKey.warehouse,
          ),
          _ActionDescriptor(
            title: 'Cobros',
            subtitle: 'Revisar cartera y registrar cobros rápidos.',
            icon: Icons.payments_rounded,
            routeKey: _RouteKey.collections,
          ),
          _ActionDescriptor(
            title: 'Catálogo operativo',
            subtitle: 'Stock, precio y bultos visibles al instante.',
            icon: Icons.inventory_2_rounded,
            routeKey: _RouteKey.catalog,
          ),
          _ActionDescriptor(
            title: 'Ruta y entregas',
            subtitle: 'Seguimiento vivo de pedidos y entregas por tienda.',
            icon: Icons.route_rounded,
            routeKey: _RouteKey.routeBoard,
          ),
        ];
      case AppRole.storeAdmin:
        return const [
          _ActionDescriptor(
            title: 'Capturar pedido',
            subtitle: 'Pantalla rápida para tomar pedido sin pelear con la app.',
            icon: Icons.flash_on_rounded,
            routeKey: _RouteKey.quickOrder,
          ),
          _ActionDescriptor(
            title: 'Bodega',
            subtitle: 'Tomar pedidos y moverlos rápido en operación.',
            icon: Icons.warehouse_rounded,
            routeKey: _RouteKey.warehouse,
          ),
          _ActionDescriptor(
            title: 'Cobros',
            subtitle: 'Ver pendientes y registrar pagos sin perder tiempo.',
            icon: Icons.payments_rounded,
            routeKey: _RouteKey.collections,
          ),
          _ActionDescriptor(
            title: 'Clientes',
            subtitle: 'Buscar cartera y contacto en segundos.',
            icon: Icons.people_alt_rounded,
            routeKey: _RouteKey.clients,
          ),
          _ActionDescriptor(
            title: 'Ruta y entregas',
            subtitle: 'Despacho, pendientes y seguimiento operativo.',
            icon: Icons.route_rounded,
            routeKey: _RouteKey.routeBoard,
          ),
        ];
      case AppRole.inventory:
        return const [
          _ActionDescriptor(
            title: 'Bodega',
            subtitle: 'Recibir, preparar y cargar en una sola vista.',
            icon: Icons.warehouse_rounded,
            routeKey: _RouteKey.warehouse,
          ),
          _ActionDescriptor(
            title: 'Catálogo operativo',
            subtitle: 'Revisar stock, bultos y precio rápido.',
            icon: Icons.inventory_2_rounded,
            routeKey: _RouteKey.catalog,
          ),
          _ActionDescriptor(
            title: 'Ruta y entregas',
            subtitle: 'Ver lo que sale hoy y a quién se despacha.',
            icon: Icons.local_shipping_rounded,
            routeKey: _RouteKey.routeBoard,
          ),
        ];
      case AppRole.dispatcher:
        return const [
          _ActionDescriptor(
            title: 'Ruta y entregas',
            subtitle: 'Asignación viva, pendientes y estado de cumplimiento.',
            icon: Icons.alt_route_rounded,
            routeKey: _RouteKey.routeBoard,
          ),
          _ActionDescriptor(
            title: 'Clientes',
            subtitle: 'Datos rápidos para coordinar despacho.',
            icon: Icons.people_alt_rounded,
            routeKey: _RouteKey.clients,
          ),
          _ActionDescriptor(
            title: 'Catálogo operativo',
            subtitle: 'Apoyo rápido para confirmar artículos.',
            icon: Icons.inventory_2_rounded,
            routeKey: _RouteKey.catalog,
          ),
        ];
      case AppRole.rutero:
        return const [
          _ActionDescriptor(
            title: 'Ruta y entrega',
            subtitle: 'Paradas, entregas y cobro en una sola vista móvil.',
            icon: Icons.map_rounded,
            routeKey: _RouteKey.routeBoard,
          ),
          _ActionDescriptor(
            title: 'Cobros',
            subtitle: 'Llegar, cobrar y guardar sin perder el ritmo.',
            icon: Icons.payments_rounded,
            routeKey: _RouteKey.collections,
          ),
          _ActionDescriptor(
            title: 'Devoluciones',
            subtitle: 'Marcar devoluciones por ticket en la misma jornada.',
            icon: Icons.assignment_return_rounded,
            routeKey: _RouteKey.returns,
          ),
          _ActionDescriptor(
            title: 'Clientes',
            subtitle: 'Ubicar contacto y dirección sin perder ritmo.',
            icon: Icons.people_alt_rounded,
            routeKey: _RouteKey.clients,
          ),
        ];
      case AppRole.vendor:
      case AppRole.salesManager:
        return const [
          _ActionDescriptor(
            title: 'Preventa',
            subtitle: 'Cliente pide, tú capturas y guardas en segundos.',
            icon: Icons.flash_on_rounded,
            routeKey: _RouteKey.quickOrder,
          ),
          _ActionDescriptor(
            title: 'Devoluciones',
            subtitle: 'Registrar devolución rápida si el pedido regresa.',
            icon: Icons.assignment_return_rounded,
            routeKey: _RouteKey.returns,
          ),
          _ActionDescriptor(
            title: 'Clientes',
            subtitle: 'Buscar cliente rápido sin salir del trabajo.',
            icon: Icons.people_alt_rounded,
            routeKey: _RouteKey.clients,
          ),
          _ActionDescriptor(
            title: 'Catálogo operativo',
            subtitle: 'Precio, stock y bultos sin abrir varias pantallas.',
            icon: Icons.inventory_2_rounded,
            routeKey: _RouteKey.catalog,
          ),
        ];
      case AppRole.cashier:
        return const [
          _ActionDescriptor(
            title: 'Devoluciones',
            subtitle: 'Buscar ticket y devolver unidades sin rodeos.',
            icon: Icons.assignment_return_rounded,
            routeKey: _RouteKey.returns,
          ),
          _ActionDescriptor(
            title: 'Catálogo operativo',
            subtitle: 'Confirmar producto y precio rápidamente.',
            icon: Icons.inventory_2_rounded,
            routeKey: _RouteKey.catalog,
          ),
          _ActionDescriptor(
            title: 'Clientes',
            subtitle: 'Consultar datos del cliente sin fricción.',
            icon: Icons.people_alt_rounded,
            routeKey: _RouteKey.clients,
          ),
        ];
      case AppRole.unknown:
        return const [
          _ActionDescriptor(
            title: 'Catálogo operativo',
            subtitle:
                'La sesión existe; este acceso puede apoyarse con catálogo rápido.',
            icon: Icons.inventory_2_rounded,
            routeKey: _RouteKey.catalog,
          ),
          _ActionDescriptor(
            title: 'Clientes',
            subtitle: 'Consulta básica por cliente y dirección.',
            icon: Icons.people_alt_rounded,
            routeKey: _RouteKey.clients,
          ),
          _ActionDescriptor(
            title: 'Ruta y entregas',
            subtitle: 'Vista general de operación.',
            icon: Icons.lock_open_rounded,
            routeKey: _RouteKey.routeBoard,
          ),
        ];
    }
  }

  void _openAction(
    BuildContext context, {
    required _ActionDescriptor action,
    required String storeId,
    required String? storeName,
  }) {
    final path = switch (action.routeKey) {
      _RouteKey.quickOrder => '/quick-order/$storeId',
      _RouteKey.catalog => '/catalog/$storeId',
      _RouteKey.clients => '/clients/$storeId',
      _RouteKey.routeBoard => '/route-board/$storeId',
      _RouteKey.collections => '/collections/$storeId',
      _RouteKey.returns => '/returns/$storeId',
      _RouteKey.warehouse => '/warehouse/$storeId',
    };

    context.push(
      Uri(
        path: path,
        queryParameters: {
          if (storeName != null && storeName.isNotEmpty) 'storeName': storeName,
        },
      ).toString(),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.storeName,
    this.primary = false,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? storeName;
  final bool primary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: primary ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: primary ? const Color(0xFF0F172A) : Colors.grey.shade200,
          ),
          boxShadow: primary
              ? const [
                  BoxShadow(
                    color: Color(0x220F172A),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: primary
                    ? Colors.white.withValues(alpha: 0.12)
                    : theme.colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: primary ? Colors.white : theme.colorScheme.primary,
              ),
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
                      color: primary ? Colors.white : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: primary
                          ? Colors.white.withValues(alpha: 0.82)
                          : Colors.black54,
                      height: 1.35,
                    ),
                  ),
                  if (storeName != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Tienda activa: $storeName',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: primary
                            ? const Color(0xFFFACC15)
                            : theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: primary ? Colors.white : const Color(0xFF475569),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackendRuntimeCard extends StatelessWidget {
  const _BackendRuntimeCard({
    required this.apiBaseUrl,
    required this.socketBaseUrl,
    required this.namespace,
    required this.networkStatus,
    required this.syncQueueState,
    required this.realtimeState,
    required this.pendingSyncCount,
    required this.failedSyncCount,
    required this.latestCachedEvent,
    required this.onRetrySync,
    required this.onRetryFailed,
  });

  final String apiBaseUrl;
  final String socketBaseUrl;
  final String namespace;
  final NetworkStatus? networkStatus;
  final SyncQueueState syncQueueState;
  final RealtimeState realtimeState;
  final int pendingSyncCount;
  final int failedSyncCount;
  final RealtimeEvent? latestCachedEvent;
  final Future<void> Function() onRetrySync;
  final Future<void> Function() onRetryFailed;

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
          const SizedBox(height: 8),
          _RuntimeLine(
            label: 'Internet',
            value: networkStatus == null
                ? 'Verificando'
                : networkStatus == NetworkStatus.online
                    ? 'Disponible'
                    : 'Sin conexión',
          ),
          const SizedBox(height: 8),
          _RuntimeLine(
            label: 'Sync',
            value: _syncStatusLabel(syncQueueState.status),
          ),
          const SizedBox(height: 8),
          _RuntimeLine(
            label: 'Realtime',
            value: _statusLabel(realtimeState.status),
          ),
          const SizedBox(height: 8),
          _RuntimeLine(
            label: 'Cola offline',
            value: '$pendingSyncCount pendientes',
          ),
          const SizedBox(height: 8),
          _RuntimeLine(
            label: 'Fallidas',
            value: '$failedSyncCount requieren reintento',
          ),
          if (realtimeState.lastEvent != null) ...[
            const SizedBox(height: 8),
            _RuntimeLine(
              label: 'Último evento',
              value: realtimeState.lastEvent!.label,
            ),
          ],
          if (latestCachedEvent != null) ...[
            const SizedBox(height: 8),
            _RuntimeLine(
              label: 'Último evento cache',
              value: latestCachedEvent!.label,
            ),
          ],
          if (syncQueueState.lastError != null) ...[
            const SizedBox(height: 8),
            _RuntimeLine(
              label: 'Error sync',
              value: syncQueueState.lastError!,
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.tonal(
                onPressed: pendingSyncCount > 0 ? onRetrySync : null,
                child: const Text('Sincronizar ahora'),
              ),
              FilledButton.tonal(
                onPressed: failedSyncCount > 0 ? onRetryFailed : null,
                child: const Text('Reintentar fallidas'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(RealtimeConnectionStatus status) {
    switch (status) {
      case RealtimeConnectionStatus.disconnected:
        return 'Desconectado';
      case RealtimeConnectionStatus.connecting:
        return 'Conectando';
      case RealtimeConnectionStatus.connected:
        return 'Conectado';
      case RealtimeConnectionStatus.error:
        return 'Error';
    }
  }

  String _syncStatusLabel(SyncQueueStatus status) {
    switch (status) {
      case SyncQueueStatus.idle:
        return 'En espera';
      case SyncQueueStatus.syncing:
        return 'Sincronizando';
      case SyncQueueStatus.offline:
        return 'Offline';
      case SyncQueueStatus.error:
        return 'Con error';
    }
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
    required this.routeKey,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final _RouteKey routeKey;
}

enum _RouteKey {
  quickOrder,
  catalog,
  clients,
  routeBoard,
  collections,
  returns,
  warehouse,
}
