import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/models/auth_session.dart';
import '../domain/models/auth_user.dart';

class AuthRepository {
  const AuthRepository(this._client);

  final AppApiClient _client;

  Future<AuthSession> login(String email, String password) async {
    final response = await _client.postMap(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    return _mapSession(response);
  }

  Future<AuthSession> refresh(String refreshToken) async {
    final response = await _client.postMap(
      '/auth/refresh',
      bearerToken: refreshToken,
    );

    return _mapSession(response);
  }

  Future<AuthUser> getProfile(String accessToken) async {
    final response = await _client.getMap(
      '/auth/profile',
      bearerToken: accessToken,
    );

    return AuthUser.fromJson(response);
  }

  AuthSession _mapSession(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: (json['accessToken'] ?? json['access_token'] ?? '')
          .toString(),
      refreshToken: (json['refreshToken'] ?? json['refresh_token'] ?? '')
          .toString(),
      user: AuthUser.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(appApiClientProvider));
});
