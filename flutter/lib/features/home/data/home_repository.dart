import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/models/store_summary.dart';

class HomeRepository {
  const HomeRepository(this._client);

  final AppApiClient _client;

  Future<List<StoreSummary>> getAssignedStores({
    required String userId,
    required String accessToken,
  }) async {
    final response = await _client.getList(
      '/users/$userId/stores',
      bearerToken: accessToken,
    );

    return response
        .map(
          (item) =>
              StoreSummary.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }
}

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.read(appApiClientProvider));
});
