import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/local_cache_repository.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/network/sync_queue_processor.dart';
import '../../../../core/realtime/realtime_event.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/warehouse_repository.dart';
import '../../domain/models/warehouse_models.dart';

final warehouseSnapshotProvider = FutureProvider.family
    .autoDispose<WarehouseSnapshot, String>((ref, storeId) async {
      ref.watch(networkStatusProvider);
      ref.watch(syncQueueProcessorProvider.select((state) => state.lastSyncAt));
      ref.watch(
        latestRealtimeEventProvider.select((asyncEvent) {
          final event = asyncEvent.asData?.value;
          if (event == null || event.storeId != storeId) {
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
        return const WarehouseSnapshot(ordersByStatus: {}, assignees: []);
      }

      return ref.read(warehouseRepositoryProvider).getSnapshot(
            storeId: storeId,
            accessToken: session.accessToken,
          );
    });

class WarehouseBoardScreen extends ConsumerStatefulWidget {
  const WarehouseBoardScreen({
    required this.storeId,
    this.storeName,
    super.key,
  });

  final String storeId;
  final String? storeName;

  @override
  ConsumerState<WarehouseBoardScreen> createState() =>
      _WarehouseBoardScreenState();
}

class _WarehouseBoardScreenState extends ConsumerState<WarehouseBoardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = <String>[
    'RECIBIDO',
    'EN_PREPARACION',
    'ALISTADO',
    'CARGADO_CAMION',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(warehouseSnapshotProvider(widget.storeId));
    await ref.read(warehouseSnapshotProvider(widget.storeId).future);
  }

  Future<void> _openOrderAction(
    WarehouseOrder order,
    List<WarehouseAssignee> assignees,
  ) async {
    final session = ref.read(authControllerProvider).session;
    if (session == null) {
      return;
    }

    try {
      final detail = await ref.read(warehouseRepositoryProvider).getOrderDetail(
            orderId: order.id,
            accessToken: session.accessToken,
          );

      if (!mounted) {
        return;
      }

      if (detail.status == 'RECIBIDO') {
        final confirmed = await showModalBottomSheet<bool>(
          context: context,
          showDragHandle: true,
          builder: (context) => _WarehouseConfirmSheet(
            title: 'Iniciar preparación',
            message:
                'Este pedido pasará a EN_PREPARACION para que bodega lo trabaje ya.',
            confirmLabel: 'Preparar ahora',
          ),
        );
        if (confirmed == true) {
          await ref.read(warehouseRepositoryProvider).updateStatus(
                orderId: order.id,
                accessToken: session.accessToken,
                status: 'EN_PREPARACION',
              );
          await _refresh();
        }
        return;
      }

      if (detail.status == 'EN_PREPARACION') {
        final confirmed = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (context) => _PickingSheet(order: detail),
        );
        if (confirmed == true) {
          await ref.read(warehouseRepositoryProvider).updateStatus(
                orderId: order.id,
                accessToken: session.accessToken,
                status: 'ALISTADO',
              );
          await _refresh();
        }
        return;
      }

      if (detail.status == 'ALISTADO') {
        final assignee = await showModalBottomSheet<WarehouseAssignee>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (context) => _AssigneePickerSheet(
            assignees: assignees,
            order: detail,
          ),
        );
        if (assignee != null) {
          await ref.read(warehouseRepositoryProvider).updateStatus(
                orderId: order.id,
                accessToken: session.accessToken,
                status: 'CARGADO_CAMION',
                vendorId: assignee.id,
              );
          await _refresh();
        }
        return;
      }

      if (detail.status == 'CARGADO_CAMION') {
        final confirmed = await showModalBottomSheet<bool>(
          context: context,
          showDragHandle: true,
          builder: (context) => _WarehouseConfirmSheet(
            title: 'Marcar salida',
            message:
                'El pedido pasará a EN_ENTREGA. Esta acción libera la salida de ruta.',
            confirmLabel: 'Enviar a ruta',
          ),
        );
        if (confirmed == true) {
          await ref.read(warehouseRepositoryProvider).updateStatus(
                orderId: order.id,
                accessToken: session.accessToken,
                status: 'EN_ENTREGA',
              );
          await _refresh();
        }
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshotAsync = ref.watch(warehouseSnapshotProvider(widget.storeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bodega rápida'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((status) => Tab(text: status.replaceAll('_', ' '))).toList(),
        ),
      ),
      body: snapshotAsync.when(
        data: (snapshot) {
          return Column(
            children: [
              _WarehouseHero(storeName: widget.storeName, snapshot: snapshot),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: TabBarView(
                    controller: _tabController,
                    children: _tabs.map((status) {
                      final orders = snapshot.ordersByStatus[status] ?? const [];
                      if (orders.isEmpty) {
                        return ListView(
                          padding: const EdgeInsets.all(20),
                          children: const [
                            _WarehouseEmptyCard(
                              title: 'Sin pedidos en este estado',
                              message: 'Cuando entren pedidos aquí aparecerán.',
                            ),
                          ],
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _WarehouseOrderCard(
                              order: order,
                              onTap: () => _openOrderAction(order, snapshot.assignees),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
      ),
    );
  }
}

class _WarehouseHero extends StatelessWidget {
  const _WarehouseHero({
    required this.snapshot,
    this.storeName,
  });

  final WarehouseSnapshot snapshot;
  final String? storeName;

  @override
  Widget build(BuildContext context) {
    final received = snapshot.ordersByStatus['RECIBIDO']?.length ?? 0;
    final preparing = snapshot.ordersByStatus['EN_PREPARACION']?.length ?? 0;
    final staged = snapshot.ordersByStatus['ALISTADO']?.length ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF7C2D12)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            storeName == null ? 'Bodega móvil' : 'Bodega • $storeName',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ver, tocar y mover. Sin pantallas extras para sacar el trabajo.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _WarehouseMetric(label: 'Recibidos', value: '$received'),
              _WarehouseMetric(label: 'Preparando', value: '$preparing'),
              _WarehouseMetric(label: 'Alistados', value: '$staged'),
            ],
          ),
        ],
      ),
    );
  }
}

class _WarehouseMetric extends StatelessWidget {
  const _WarehouseMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _WarehouseOrderCard extends StatelessWidget {
  const _WarehouseOrderCard({
    required this.order,
    required this.onTap,
  });

  final WarehouseOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
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
                    order.clientName?.isNotEmpty == true
                        ? order.clientName!
                        : 'Cliente sin nombre',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: Color(0xFF475569)),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _WarehousePill(
                  icon: Icons.payments_outlined,
                  text: 'C\$ ${order.total.toStringAsFixed(2)}',
                ),
                if ((order.salesManagerName ?? '').isNotEmpty)
                  _WarehousePill(
                    icon: Icons.person_outline_rounded,
                    text: order.salesManagerName!,
                  ),
              ],
            ),
            if ((order.notes ?? '').isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                order.notes!,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WarehousePill extends StatelessWidget {
  const _WarehousePill({
    required this.icon,
    required this.text,
  });

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

class _WarehouseEmptyCard extends StatelessWidget {
  const _WarehouseEmptyCard({
    required this.title,
    required this.message,
  });

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
          const Icon(Icons.inventory_2_outlined, size: 42, color: Color(0xFF64748B)),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _WarehouseConfirmSheet extends StatelessWidget {
  const _WarehouseConfirmSheet({
    required this.title,
    required this.message,
    required this.confirmLabel,
  });

  final String title;
  final String message;
  final String confirmLabel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            Text(message),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.check_circle_rounded),
              label: Text(confirmLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickingSheet extends StatelessWidget {
  const _PickingSheet({required this.order});

  final WarehouseOrder order;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Picking list',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: order.items.length,
                separatorBuilder: (_, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return ListTile(
                    tileColor: const Color(0xFFF8FAFC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    title: Text(
                      item.productName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${item.pickingBulks} bultos • ${item.pickingUnits} unidades sueltas',
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.fact_check_rounded),
              label: const Text('Marcar alistado'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssigneePickerSheet extends StatefulWidget {
  const _AssigneePickerSheet({
    required this.assignees,
    required this.order,
  });

  final List<WarehouseAssignee> assignees;
  final WarehouseOrder order;

  @override
  State<_AssigneePickerSheet> createState() => _AssigneePickerSheetState();
}

class _AssigneePickerSheetState extends State<_AssigneePickerSheet> {
  WarehouseAssignee? _selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cargar a camión',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona el rutero o vendedor que recibe esta carga.',
            ),
            const SizedBox(height: 14),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.assignees.length,
                separatorBuilder: (_, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final assignee = widget.assignees[index];
                  final selected = _selected?.id == assignee.id;
                  return ListTile(
                    tileColor: selected
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFF8FAFC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    title: Text(
                      assignee.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(assignee.role),
                    trailing: selected
                        ? const Icon(Icons.check_circle_rounded, color: Color(0xFF166534))
                        : null,
                    onTap: () => setState(() => _selected = assignee),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _selected == null
                  ? null
                  : () => Navigator.of(context).pop(_selected),
              icon: const Icon(Icons.local_shipping_rounded),
              label: const Text('Confirmar carga'),
            ),
          ],
        ),
      ),
    );
  }
}
