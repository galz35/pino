import '../../domain/models/authorization_request.dart';
import '../../infrastructure/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthorizationService {
  final ApiClient _apiClient;

  AuthorizationService(this._apiClient);

  Future<String?> requestAuthorization(AuthorizationRequest request) async {
    try {
      final response = await _apiClient.post(
        '/authorizations',
        data: request.toMap(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['id'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<AuthorizationStatus> requestAuthorizationStream(
    AuthorizationRequest request,
  ) async* {
    final requestId = await requestAuthorization(request);
    if (requestId == null) {
      yield AuthorizationStatus.rejected;
      return;
    }

    yield* watchAuthorizationStatus(requestId);
  }

  Future<AuthorizationStatus> checkStatus(String requestId) async {
    try {
      final response = await _apiClient.get(
        '/authorizations/$requestId/status',
      );
      if (response.statusCode == 200) {
        final statusName = response.data['status'] as String? ?? 'pending';
        return AuthorizationStatus.values.firstWhere(
          (e) => e.name == statusName,
          orElse: () => AuthorizationStatus.pending,
        );
      }
      return AuthorizationStatus.pending;
    } catch (e) {
      return AuthorizationStatus.pending;
    }
  }

  Stream<AuthorizationStatus> watchAuthorizationStatus(
    String requestId,
  ) async* {
    while (true) {
      final status = await checkStatus(requestId);
      yield status;
      if (status != AuthorizationStatus.pending) break;
      await Future.delayed(const Duration(seconds: 5));
    }
  }
}

final authorizationServiceProvider = Provider<AuthorizationService>((ref) {
  return AuthorizationService(ref.watch(apiClientProvider));
});
