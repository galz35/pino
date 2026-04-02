import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/startup/presentation/screens/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    ],
    redirect: (context, state) {
      final location = state.uri.path;
      final stage = authState.stage;

      if (stage == AuthStage.initial || stage == AuthStage.loading) {
        return location == '/' ? null : '/';
      }

      if (stage == AuthStage.unauthenticated) {
        return location == '/login' ? null : '/login';
      }

      if (stage == AuthStage.authenticated) {
        if (location == '/' || location == '/login') {
          return '/home';
        }
      }

      return null;
    },
  );
});
