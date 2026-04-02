import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../../../config/theme/app_colors.dart';
import '../../../../domain/models/client.dart';
import '../../../../domain/models/authorization_request.dart';
import '../../../../data/providers/providers.dart';

class AddClientScreen extends ConsumerStatefulWidget {
  const AddClientScreen({super.key});

  @override
  ConsumerState<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends ConsumerState<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _creditLimitController = TextEditingController(text: '0');

  final String _selectedZoneId = 'zone_default';
  final String _selectedSubZoneId = 'subzone_default';
  final String _storeId = 'store_default';
  bool _isLoading = false;
  Position? _currentPosition;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El GPS está desactivado. Por favor actívalo.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Check and request permissions
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permiso de ubicación denegado')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Permiso de ubicación denegado permanentemente. Por favor actívalo en los ajustes del sistema.',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Attempt to get position with timeout
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicación capturada correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tiempo de espera agotado. Asegúrate de estar en un lugar abierto.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } on LocationServiceDisabledException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El servicio de ubicación fue desactivado.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado al obtener ubicación: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _requestAuthorization(double creditLimit) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;

    final request = AuthorizationRequest(
      id: '', // Set by service
      storeId: _storeId,
      requesterId: user.uid,
      type: AuthorizationType.creditLimit,
      details: {
        'clientName': _nameController.text.trim(),
        'creditLimit': creditLimit,
      },
      status: AuthorizationStatus.pending,
    );

    final authService = ref.read(authorizationServiceProvider);

    // Show waiting dialog
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StreamBuilder<AuthorizationStatus>(
        stream: authService.requestAuthorizationStream(request),
        builder: (context, snapshot) {
          final status = snapshot.data ?? AuthorizationStatus.pending;

          if (status == AuthorizationStatus.approved) {
            Future.delayed(const Duration(seconds: 1), () {
              if (context.mounted) Navigator.pop(context, true);
            });
          } else if (status == AuthorizationStatus.rejected) {
            Future.delayed(const Duration(seconds: 1), () {
              if (context.mounted) Navigator.pop(context, false);
            });
          }

          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text(
              'Esperando Autorización',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Solicitando límite de crédito: C\$ $creditLimit',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  status == AuthorizationStatus.pending
                      ? 'El administrador debe aprobar esta solicitud...'
                      : status == AuthorizationStatus.approved
                      ? '¡Autorizado!'
                      : 'Solicitud rechazada.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: status == AuthorizationStatus.approved
                        ? AppColors.success
                        : status == AuthorizationStatus.rejected
                        ? AppColors.error
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              if (status == AuthorizationStatus.pending)
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('CANCELAR'),
                ),
            ],
          );
        },
      ),
    );

    return result ?? false;
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) return;

    final creditLimit = double.tryParse(_creditLimitController.text) ?? 0;

    // Trigger authorization if credit limit is requested
    if (creditLimit > 0) {
      final authorized = await _requestAuthorization(creditLimit);
      if (!authorized) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se puede guardar el cliente sin autorización'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('User not logged in');

      final newClient = Client(
        id: '', // Will be set by repo
        storeId: _storeId,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        zoneId: _selectedZoneId,
        subZoneId: _selectedSubZoneId,
        assignedPreventaId: user.uid,
        creditLimit: creditLimit,
        currentDebt: 0,
        location: _currentPosition != null
            ? ClientLocation(
                lat: _currentPosition!.latitude,
                lng: _currentPosition!.longitude,
              )
            : null,
      );

      await ref.read(clientsRepositoryProvider).createClient(newClient);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente agregado correctamente')),
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nuevo Cliente'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration(
                  'Nombre del Negocio/Cliente',
                  Icons.person,
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Teléfono', Icons.phone),
                keyboardType: TextInputType.phone,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration(
                  'Dirección Completa',
                  Icons.location_on,
                ),
                maxLines: 2,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _creditLimitController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration(
                  'Límite de Crédito (C\$)',
                  Icons.account_balance_wallet,
                ),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // GPS Button
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _getCurrentLocation,
                icon: Icon(
                  _currentPosition == null
                      ? Icons.gps_not_fixed
                      : Icons.gps_fixed,
                  color: _currentPosition == null
                      ? Colors.white
                      : AppColors.success,
                ),
                label: Text(
                  _currentPosition == null
                      ? 'CAPTURAR UBICACIÓN GPS'
                      : 'UBICACIÓN CAPTURADA',
                  style: TextStyle(
                    color: _currentPosition == null
                        ? Colors.white
                        : AppColors.success,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _currentPosition == null
                        ? Colors.white24
                        : AppColors.success,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveClient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        'GUARDAR CLIENTE',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}
