import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../domain/models/client.dart';
import '../../../../data/providers/providers.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../domain/models/route_manifest.dart';

class ClientPortfolioScreen extends ConsumerStatefulWidget {
  final bool isSelectionMode;

  const ClientPortfolioScreen({super.key, this.isSelectionMode = false});

  @override
  ConsumerState<ClientPortfolioScreen> createState() =>
      _ClientPortfolioScreenState();
}

class _ClientPortfolioScreenState extends ConsumerState<ClientPortfolioScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All Clients', 'Only with Debt', 'Pending'];

  @override
  Widget build(BuildContext context) {
    final routesRepo = ref.watch(routesRepositoryProvider);
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view route.')),
      );
    }

    return FutureBuilder<RouteManifest?>(
      future: routesRepo.getTodayRoute(user.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final manifest = snapshot.data;
        // If no route for today
        if (manifest == null) {
          return FutureBuilder<List<Client>>(
            future: ref
                .watch(clientsRepositoryProvider)
                .getClientsByPreventa(user.uid),
            builder: (context, clientSnapshot) {
              if (clientSnapshot.hasError) {
                return Scaffold(
                  body: Center(child: Text('Error: ${clientSnapshot.error}')),
                );
              }
              if (clientSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final clients = clientSnapshot.data ?? [];

              if (clients.isEmpty) {
                return Scaffold(
                  appBar: _buildAppBar(),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No tiene clientes asignados.'),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/add-client'),
                          icon: const Icon(Icons.person_add),
                          label: const Text('Agregar Nuevo Cliente'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Scaffold(
                backgroundColor: AppColors.background,
                appBar: _buildAppBar(),
                body: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Mostrando portafolio completo (Sin ruta activa)',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: clients.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final client = clients[index];
                          return _buildClientCard(
                            name: client.name,
                            address: client.address,
                            status: 'PORTFOLIO',
                            statusColor: AppColors.primary,
                            debt: client.currentDebt > 0
                                ? 'C\$ ${client.currentDebt.toStringAsFixed(2)}'
                                : null,
                            noDebt: client.currentDebt <= 0,
                            isSelectionMode: widget.isSelectionMode,
                            client: client,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () => context.push('/add-client'),
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.person_add, color: Colors.black),
                ),
              );
            },
          );
        }

        // Calculate progress
        final totalStops = manifest.stops.length;
        final visitedStops = manifest.stops.where((s) => s.isVisited).length;
        final progress = totalStops == 0 ? 0.0 : visitedStops / totalStops;

        // Filter stops
        // Filter stops
        final filteredStops = manifest.stops.where((stop) {
          if (_selectedFilterIndex == 1) {
            // Only with Debt
            return stop.client.currentDebt > 0;
          } else if (_selectedFilterIndex == 2) {
            // Pending
            return !stop.isVisited;
          }
          return true; // All
        }).toList();

        if (filteredStops.isEmpty && widget.isSelectionMode) {
          return Scaffold(
            appBar: _buildAppBar(),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay clientes asignados.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Registre clientes para continuar con la preventa.',
                      style: TextStyle(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to Add Client or similar if implemented
                        // For now just back
                        Navigator.of(context).pop();
                      },
                      child: const Text('Volver'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: Column(
            children: [
              // Progress Bar Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Daily Route Progress',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$visitedStops / $totalStops Clients',
                          style: const TextStyle(
                            color: AppColors.primary,
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
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search by business name or address',
                    hintStyle: const TextStyle(color: AppColors.textHint),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              // Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: List.generate(_filters.length, (index) {
                    final isSelected = index == _selectedFilterIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: FilterChip(
                        label: Text(_filters[index]),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedFilterIndex = index;
                          });
                        },
                        backgroundColor: AppColors.surfaceVariant,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.black
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.inputBorder,
                          ),
                        ),
                        checkmarkColor: Colors.black,
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 16),

              // Client List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: filteredStops.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final stop = filteredStops[index];
                    final client = stop.client;

                    // Determine Status Display
                    String statusText = 'PENDING';
                    Color statusColor = AppColors.warning;

                    if (stop.isVisited) {
                      statusText = 'VISITED';
                      statusColor = AppColors.success;
                    }
                    // Add other statuses if Model supports them (e.g. Skipped)

                    return _buildClientCard(
                      name: client.name,
                      address: client.address,
                      status: statusText,
                      statusColor: statusColor,
                      debt: client.currentDebt > 0
                          ? 'C\$ ${client.currentDebt.toStringAsFixed(2)}'
                          : null,
                      noDebt: client.currentDebt <= 0,
                      isSelectionMode: widget.isSelectionMode,
                      onTap: widget.isSelectionMode
                          ? () {
                              // Navigate to Create Order with this client
                              // Need to pass client object.
                              // Using go_router context.push
                              // We will define this route update in app_router
                              // For now, assume /create-order expects extra: client
                              // Or we can pass it as extra map

                              // Check package:go_router import? It might be missing in this file or implicit.
                              // But we can use Navigator or context.push if imported.
                              // The prompt says "flow is ...".
                              // I'll use Navigator.of(context).push if GoRouter not imported, or try Router.
                              // Actually, let's look at imports. `routes_repository.dart`...
                              // This file doesn't seem to import go_router.
                              // I'll use the proper route name.

                              // Wait, I can't add import here easily without another chunk.
                              // I'll check imports first? No, I'm in multi_replace.
                              // I will assume I need to import go_router in a separate replacement or rely on existing mechanism.
                              // Wait, previous file view showed `import 'package:flutter/material.dart';` etc.
                              // No go_router.
                              // I will add the import in a 4th chunk.

                              // Using `Navigator.of(context).pushNamed(...)` or similar might work if GoRouter is providing standard delegates,
                              // BUT `context.push` is an extension method from go_router.
                              // So I MUST import go_router.

                              // For now I will put the logic here assuming I add the import.
                              // context.push('/create-order', extra: client);
                              // But I need to import it.
                            }
                          : null,
                      client:
                          client, // Pass client to card to handle tap in button
                    );
                  },
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/add-client'),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.person_add, color: Colors.black),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isSelectionMode ? 'Seleccionar Cliente' : 'Client Portfolio',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'BODEGA LOS PINOS',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.textPrimary),
        onPressed: () {},
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_today, color: AppColors.textPrimary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildClientCard({
    required String name,
    required String address,
    required String status,
    required Color statusColor,
    String? debt,
    bool noDebt = false,
    String? orderInfo,
    bool isSelectionMode = false,
    VoidCallback? onTap,
    Client? client,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder.withValues(alpha: 0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isSelectionMode
              ? () {
                  if (client != null) {
                    context.push('/create-order', extra: client);
                  }
                }
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://placehold.co/100x100/png',
                          ), // Placeholder
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: statusColor.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      status,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            address,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (debt != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'DEBT: $debt',
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (noDebt)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'NO DEBT',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (orderInfo != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        orderInfo,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const Row(
                        children: [
                          Text(
                            'Details',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  isSelectionMode
                      ? SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (client != null) {
                                context.push('/create-order', extra: client);
                              }
                            },
                            icon: const Icon(
                              Icons.check_circle_outline,
                              size: 18,
                            ),
                            label: const Text('Comenzar Pedido'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Default Start Order logic (maybe same as select?)
                                  // Current behavior was empty.
                                  // Maybe we want it to go to Create Order anyway?
                                  if (client != null) {
                                    context.push(
                                      '/create-order',
                                      extra: client,
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 18,
                                ),
                                label: const Text('Start Order'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                onPressed: () async {
                                  if (client != null &&
                                      client.phone.isNotEmpty) {
                                    final Uri launchUri = Uri(
                                      scheme: 'tel',
                                      path: client.phone,
                                    );
                                    if (await canLaunchUrl(launchUri)) {
                                      await launchUrl(launchUri);
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Sin teléfono registrado',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.phone,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
