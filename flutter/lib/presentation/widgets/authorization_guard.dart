import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/authorization_request.dart';

class AuthorizationGuard extends ConsumerStatefulWidget {
  final Stream<AuthorizationStatus> statusStream;
  final String requestId;

  const AuthorizationGuard({
    super.key,
    required this.statusStream,
    required this.requestId,
  });

  @override
  ConsumerState<AuthorizationGuard> createState() => _AuthorizationGuardState();
}

class _AuthorizationGuardState extends ConsumerState<AuthorizationGuard> {
  Timer? _orphanTimer;
  bool _canCancel = false;

  @override
  void initState() {
    super.initState();
    // Start orphan timer (2 minutes)
    _orphanTimer = Timer(const Duration(minutes: 2), () {
      if (mounted) {
        setState(() {
          _canCancel = true;
        });
        HapticFeedback.mediumImpact();
      }
    });
  }

  @override
  void dispose() {
    _orphanTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Impossible to close manually
      child: StreamBuilder<AuthorizationStatus>(
        stream: widget.statusStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final status = snapshot.data ?? AuthorizationStatus.pending;

          // Side-effect: Check for approved/rejected to trigger actions
          // Note: doing side-effects in build is risky, but with StreamBuilder it triggers on new data.
          // Better to use a separate listener, but for simplicity we handle "Approved" auto-pop here carefully.
          if (status == AuthorizationStatus.approved) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && Navigator.canPop(context)) {
                Navigator.pop(context, true);
              }
            });
          }

          if (status == AuthorizationStatus.rejected) {
            HapticFeedback.heavyImpact(); // This might trigger multiple times on rebuilds, careful.
            // Ideally we should use specific state management for "event consumed".
            // For now, we trust StreamBuilder doesn't rebuild aggressively without new data.
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                _buildContent(status),
                const SizedBox(height: 20),
                if (_canCancel)
                  TextButton(
                    onPressed: () => Navigator.pop(context, false), // Cancel
                    style: TextButton.styleFrom(foregroundColor: Colors.grey),
                    child: const Text('Cancelar Solicitud (Tiempo excedido)'),
                  ),
                // Always allow cancelling if rejected to "change price or cancel"
                if (status == AuthorizationStatus.rejected)
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(AuthorizationStatus status) {
    switch (status) {
      case AuthorizationStatus.pending:
        return Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              "Solicitando autorización al Admin...",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "ID: ${widget.requestId}",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        );
      case AuthorizationStatus.approved:
        return const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 20),
            Text(
              "¡Autorizado!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        );
      case AuthorizationStatus.rejected:
        return const Column(
          children: [
            Icon(Icons.cancel, color: Colors.red, size: 64),
            SizedBox(height: 20),
            Text(
              "Solicitud Rechazada",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "El administrador ha denegado esta operación.",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildErrorState(String error) {
    return AlertDialog(
      title: const Text('Error'),
      content: Text(error),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
