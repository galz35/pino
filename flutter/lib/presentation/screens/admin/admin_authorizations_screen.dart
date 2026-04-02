import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../domain/models/authorization_request.dart';
import '../../../../data/repositories/auth_repository.dart';

class AdminAuthorizationsScreen extends ConsumerStatefulWidget {
  const AdminAuthorizationsScreen({super.key});

  @override
  ConsumerState<AdminAuthorizationsScreen> createState() =>
      _AdminAuthorizationsScreenState();
}

class _AdminAuthorizationsScreenState
    extends ConsumerState<AdminAuthorizationsScreen> {
  late Future<List<AuthorizationRequest>> _authorizationsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _authorizationsFuture = ref
          .read(authRepositoryProvider)
          .getPendingAuthorizations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Autorizaciones Pendientes'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: FutureBuilder<List<AuthorizationRequest>>(
        future: _authorizationsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data ?? [];
          if (requests.isEmpty) {
            return const Center(
              child: Text(
                'No hay solicitudes pendientes',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildRequestCard(context, request),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, AuthorizationRequest request) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    request.type.name.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _formatDate(request.createdAt),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Cliente: ${request.details['clientName'] ?? 'N/A'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Límite de Crédito solicitado: C\$ ${request.details['creditLimit']}',
              style: const TextStyle(color: AppColors.primary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleResponse(
                      request.id,
                      AuthorizationStatus.rejected,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('RECHAZAR'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleResponse(
                      request.id,
                      AuthorizationStatus.approved,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('APROBAR'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _handleResponse(
    String requestId,
    AuthorizationStatus status,
  ) async {
    try {
      await ref
          .read(authRepositoryProvider)
          .updateAuthorizationStatus(requestId, status);
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Solicitud ${status == AuthorizationStatus.approved ? 'aprobada' : 'rechazada'}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
