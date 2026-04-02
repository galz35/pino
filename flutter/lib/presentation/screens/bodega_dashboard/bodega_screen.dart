import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/providers.dart';
import '../../../config/theme/app_colors.dart';

class BodegaScreen extends ConsumerStatefulWidget {
  const BodegaScreen({super.key});

  @override
  ConsumerState<BodegaScreen> createState() => _BodegaScreenState();
}

class _BodegaScreenState extends ConsumerState<BodegaScreen> {
  final int _totalItems = 150;
  int _scannedItems = 67; // Mock initial progress
  bool _isLoading = false;

  void _simulateScan() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate delay
    if (!mounted) return;

    setState(() {
      if (_scannedItems + 15 <= _totalItems) {
        _scannedItems += 15;
      } else {
        _scannedItems = _totalItems;
      }
      _isLoading = false;
    });

    if (_scannedItems == _totalItems) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Carga completada! Listo para confirmar.'),
        ),
      );
    }
  }

  void _confirmLoad() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulate backend call
    if (!mounted) return;

    setState(() => _isLoading = false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Carga Confirmada',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'El camión ha sido liberado exitosamente.\nInventario actualizado.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, ref),
                const SizedBox(height: 24),
                _buildTruckLoadCard(),
                const SizedBox(height: 24),
                const Text(
                  'Gestión de Inventario',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInventoryActions(context),
                const SizedBox(height: 24),
                _buildRecentActivity(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bodega Central',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const Text(
              'Panel de Control',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Turno: Mañana',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () async {
            await ref.read(authRepositoryProvider).signOut();
            if (context.mounted) {
              context.go('/login');
            }
          },
          icon: const Icon(Icons.logout, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildTruckLoadCard() {
    final progress = _scannedItems / _totalItems;
    final isComplete = _scannedItems == _totalItems;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isComplete
              ? Colors.green
              : AppColors.primary.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Carga de Camión',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isComplete ? Colors.green : AppColors.primary)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isComplete ? 'Completado' : 'En Progreso',
                  style: TextStyle(
                    color: isComplete ? Colors.green : AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTruckInfo('Placa: ABC-123', 'Ruta Norte 05'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progreso Total',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                isComplete ? Colors.green : Colors.orange,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_scannedItems / $_totalItems items',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                '${_totalItems - _scannedItems} pendientes',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: isComplete ? _confirmLoad : _simulateScan,
                    icon: Icon(
                      isComplete ? Icons.check_circle : Icons.qr_code_scanner,
                    ),
                    label: Text(
                      isComplete ? 'Confirmar Salida' : 'Escanear Carga',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isComplete
                          ? Colors.green
                          : AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTruckInfo(String plate, String route) {
    return Row(
      children: [
        const Icon(Icons.local_shipping, color: Colors.white, size: 32),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plate,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              route,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInventoryActions(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildActionCard(
          icon: Icons.search,
          label: 'Buscar Producto',
          color: Colors.blue,
          onTap: () {},
        ),
        _buildActionCard(
          icon: Icons.move_to_inbox,
          label: 'Recepción',
          color: Colors.green,
          onTap: () {},
        ),
        _buildActionCard(
          icon: Icons.warning_amber,
          label: 'Alertas Stock',
          color: Colors.redAccent,
          onTap: () {},
        ),
        _buildActionCard(
          icon: Icons.check_circle_outline,
          label: 'Aprobar Cargas',
          color: Colors.orange,
          onTap: () => context.push('/bodeguero-approval'),
        ),
        _buildActionCard(
          icon: Icons.sync,
          label: 'Sincronizar',
          color: Colors.teal,
          onTap: () {},
        ),
        _buildActionCard(
          icon: Icons.security,
          label: 'Autorizaciones',
          color: Colors.red,
          onTap: () => context.push('/admin-authorizations'),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actividad Reciente',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'Sin movimientos recientes',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}
