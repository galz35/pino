import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_colors.dart';
import '../../../data/providers/providers.dart';

class SyncDebugScreen extends ConsumerStatefulWidget {
  const SyncDebugScreen({super.key});

  @override
  ConsumerState<SyncDebugScreen> createState() => _SyncDebugScreenState();
}

class _SyncDebugScreenState extends ConsumerState<SyncDebugScreen> {
  bool _isSyncing = false;

  Future<void> _handleManualSync() async {
    setState(() => _isSyncing = true);
    
    final engine = ref.read(syncEngineProvider);
    try {
      // 1. Flush any pending local writes to NestJS
      await engine.flushQueue();
      // 2. Pull fresh data from NestJS to Local DB
      await engine.pullFromServer();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sincronización completada exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al sincronizar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnlineAsync = ref.watch(isOnlineProvider);
    final pendingCountAsync = ref.watch(pendingSyncCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Estado de Sincronización', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceVariant),
              ),
              child: Column(
                children: [
                  isOnlineAsync.when(
                    data: (isOnline) => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isOnline ? Icons.wifi : Icons.wifi_off,
                          color: isOnline ? AppColors.success : AppColors.error,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isOnline ? 'CONECTADO A RED' : 'MÓDULO OFFLINE ACTIVO',
                          style: TextStyle(
                            color: isOnline ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('Error al verificar red'),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: AppColors.surfaceVariant),
                  const SizedBox(height: 24),
                  
                  // Pending count
                  pendingCountAsync.when(
                    data: (count) => Column(
                      children: [
                        Text(
                          count.toString(),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: count > 0 ? AppColors.warning : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          count == 1 ? 'Operación en cola' : 'Operaciones en cola',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('No disponible'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Sync Button
            ElevatedButton.icon(
              onPressed: _isSyncing ? null : _handleManualSync,
              icon: _isSyncing 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) 
                : const Icon(Icons.sync),
              label: Text(
                _isSyncing ? 'Sincronizando...' : 'FORZAR SINCRONIZACIÓN',
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            
            const Spacer(),
            
            // Info text
            const Text(
              'Nota: El SyncEngine procesa automáticamente la cola cuando hay conexión a internet (ping constante). Usa este botón sólo si necesitas traer datos frescos desde el servidor de forma inmediata.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
