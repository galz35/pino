import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../data/providers/providers.dart';

class RuteroProfileScreen extends ConsumerWidget {
  const RuteroProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(user?.email ?? 'Conductor'),
            const SizedBox(height: 24),
            _buildStatsSection(),
            const SizedBox(height: 24),
            _buildMenuSection(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 32, left: 16, right: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 3),
              image: const DecorationImage(
                image: NetworkImage('https://i.pravatar.cc/150?u=driver'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Conductor de Ruta #4',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatCard(
            'Entregas',
            '1,240',
            Icons.check_circle_outline,
            Colors.green,
          ),
          const SizedBox(width: 12),
          _buildStatCard('Eficiencia', '98%', Icons.speed, Colors.blue),
          const SizedBox(width: 12),
          _buildStatCard('Rating', '4.9', Icons.star_border, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuItem(Icons.person_outline, 'Datos Personales', () {
            _showNotImplemented(context, 'Datos Personales');
          }),
          _buildMenuItem(
            Icons.directions_car_outlined,
            'Vehículo Asignado',
            () {
              _showNotImplemented(context, 'Vehículo Asignado');
            },
          ),
          _buildMenuItem(Icons.history, 'Historial de Rutas', () {
            _showNotImplemented(context, 'Historial de Rutas');
          }),
          _buildMenuItem(Icons.help_outline, 'Soporte Técnico', () {
            _showNotImplemented(context, 'Soporte Técnico');
          }),
          const Divider(
            color: AppColors.surfaceVariant,
            indent: 20,
            endIndent: 20,
          ),
          _buildMenuItem(Icons.logout, 'Cerrar Sesión', () async {
            await ref.read(authRepositoryProvider).signOut();
          }, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppColors.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.white,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }

  void _showNotImplemented(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(feature, style: const TextStyle(color: Colors.white)),
        content: const Text(
          'Esta función estará disponible en próximas versiones.',
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
}
