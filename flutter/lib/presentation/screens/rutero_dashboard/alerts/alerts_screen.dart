import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';

class RuteroAlertsScreen extends StatelessWidget {
  const RuteroAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Alertas de Ruta'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAlertItem(
            icon: Icons.warning_amber_rounded,
            color: Colors.orange,
            title: 'Desvío en Ruta',
            message:
                'Tráfico pesado en Carretera Norte. Se sugiere usar vía alterna por Altamira.',
            time: 'Hace 10 min',
          ),
          _buildAlertItem(
            icon: Icons.inventory_2_outlined,
            color: Colors.blue,
            title: 'Stock Bajo',
            message: 'El producto "Aceite 1L" está por agotarse en su camión.',
            time: 'Hace 45 min',
          ),
          _buildAlertItem(
            icon: Icons.info_outline,
            color: Colors.purple,
            title: 'Cambio de Prioridad',
            message:
                'El cliente "Abarrotes La Bendición" ha sido marcado como prioridad alta.',
            time: 'Hace 2 horas',
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required String time,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
