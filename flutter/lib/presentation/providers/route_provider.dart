import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/providers/providers.dart';
import '../../domain/models/route_manifest.dart';

part 'route_provider.g.dart';

@riverpod
Future<RouteManifest?> currentRoute(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  return ref.watch(routesRepositoryProvider).getTodayRoute(user.uid);
}

@riverpod
Future<ManifestStop?> nextStop(Ref ref) async {
  final route = await ref.watch(currentRouteProvider.future);

  if (route == null || route.stops.isEmpty) return null;
  try {
    return route.stops.firstWhere((stop) => !stop.isVisited);
  } catch (e) {
    return null; // All visited
  }
}

@riverpod
Future<Map<String, int>> routeStats(Ref ref) async {
  final route = await ref.watch(currentRouteProvider.future);

  if (route == null) return {'visited': 0, 'total': 0};
  final total = route.stops.length;
  final visited = route.stops.where((s) => s.isVisited).length;
  return {'visited': visited, 'total': total};
}
