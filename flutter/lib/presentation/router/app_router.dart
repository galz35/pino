import 'package:go_router/go_router.dart';
import '../screens/preventa_dashboard/preventa_home_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/orders/create_order_screen.dart';
import '../screens/bodega_dashboard/bodega_screen.dart';
import '../screens/rutero_dashboard/rutero_screen.dart';
import '../screens/orders/new_order_screen.dart';
import '../screens/orders/order_history_screen.dart';
import '../screens/rutero_dashboard/route/client_portfolio_screen.dart';
import '../screens/products/product_catalog_screen.dart';
import '../screens/preventa_dashboard/cobranza_screen.dart';
import '../screens/rutero_dashboard/route/delivery_list_screen.dart';
import '../screens/rutero_dashboard/home/day_closing_screen.dart';
import '../screens/rutero_dashboard/route/stop_details_screen.dart';
import '../../domain/models/client.dart';
import '../../domain/models/route_manifest.dart';
import '../screens/bodega_dashboard/ayudante_dashboard_screen.dart';
import '../screens/bodega_dashboard/order_preparation_screen.dart';
import '../screens/bodega_dashboard/bodeguero_approval_screen.dart';
import '../widgets/camera_scanner_screen.dart';
import '../screens/rutero_dashboard/route/add_client_screen.dart';
import '../screens/admin/admin_authorizations_screen.dart';
import '../../domain/models/order.dart';
import '../screens/settings/sync_debug_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/providers.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(currentUserProvider);
  // Using authStatusProvider to wait for initial load if needed, but currentUserProvider works reactively.

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isGoingToLogin = state.matchedLocation == '/login';

      if (user == null && !isGoingToLogin) {
        return '/login';
      }

      if (user != null && isGoingToLogin) {
        final role = user.role;
        if (role == 'bodega') return '/bodega';
        if (role == 'rutero') return '/rutero';
        if (role == 'ayudante_bodega') return '/ayudante_bodega';
        return '/preventa';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/preventa',
        builder: (context, state) => const PreventaHomeScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const PreventaHomeScreen(),
        routes: [
          GoRoute(
            path: 'create-order',
            builder: (context, state) {
              final client = state.extra as Client?;
              return CreateOrderScreen(client: client);
            },
          ),
        ],
      ),
      GoRoute(path: '/bodega', builder: (context, state) => const BodegaScreen()),
      GoRoute(path: '/rutero', builder: (context, state) => const RuteroScreen()),
      GoRoute(
        path: '/new-order',
        builder: (context, state) => const NewOrderScreen(),
      ),
      GoRoute(
        path: '/order-history',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: '/client-portfolio',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final isSelectionMode = extra?['isSelectionMode'] as bool? ?? false;
          return ClientPortfolioScreen(isSelectionMode: isSelectionMode);
        },
      ),
      GoRoute(
        path: '/product-catalog',
        builder: (context, state) => const ProductCatalogScreen(),
      ),
      GoRoute(
        path: '/cobranza',
        builder: (context, state) => const CobranzaScreen(),
      ),
      GoRoute(
        path: '/delivery-list',
        builder: (context, state) => const DeliveryListScreen(),
      ),
      GoRoute(
        path: '/stop-details',
        builder: (context, state) {
          final stop = state.extra as ManifestStop;
          return StopDetailsScreen(stop: stop);
        },
      ),
      GoRoute(
        path: '/day-closing',
        builder: (context, state) => const DayClosingScreen(),
      ),
      GoRoute(
        path: '/ayudante_bodega',
        builder: (context, state) => const AyudanteDashboardScreen(),
      ),
      GoRoute(
        path: '/order-preparation',
        builder: (context, state) {
          final order = state.extra as Order;
          return OrderPreparationScreen(order: order);
        },
      ),
      GoRoute(
        path: '/bodeguero-approval',
        builder: (context, state) => const BodegueroApprovalScreen(),
      ),
      GoRoute(
        path: '/camera-scanner',
        builder: (context, state) => const CameraScannerScreen(),
      ),
      GoRoute(
        path: '/add-client',
        builder: (context, state) => const AddClientScreen(),
      ),
      GoRoute(
        path: '/admin-authorizations',
        builder: (context, state) => const AdminAuthorizationsScreen(),
      ),
      GoRoute(
        path: '/sync-debug',
        builder: (context, state) => const SyncDebugScreen(),
      ),
    ],
  );
});
