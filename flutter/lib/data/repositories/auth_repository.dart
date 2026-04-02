import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../infrastructure/api_client.dart';
import '../../domain/models/user_model.dart';
import '../../domain/models/authorization_request.dart';
import 'dart:convert';

class AuthRepository {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  AuthRepository(this._apiClient, this._storage);

  Future<AppUser?> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'];
        final userData = response.data['user'];

        // Store JWT token safely
        await _storage.write(key: 'jwt_token', value: token);
        await _storage.write(key: 'user_data', value: jsonEncode(userData));

        return AppUser.fromJson({
          'uid': userData['id'],
          'email': userData['email'],
          'role': userData['role'] ?? 'preventa',
        });
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Credenciales inválidas');
      }
      throw Exception('Error de servidor: ${e.message}');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_data');
  }

  Future<void> signOut() => logout();

  Future<AppUser?> getCurrentUser() async {
    final userDataStr = await _storage.read(key: 'user_data');
    if (userDataStr != null) {
      final data = jsonDecode(userDataStr);
      return AppUser.fromJson({
        'uid': data['id'],
        'email': data['email'],
        'role': data['role'],
      });
    }
    return null;
  }

  Future<AppUser?> get currentUser => getCurrentUser();

  Future<List<AuthorizationRequest>> getPendingAuthorizations() async {
    final response = await _apiClient.get('/admin/authorizations/pending');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => AuthorizationRequest.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> updateAuthorizationStatus(
    String id,
    AuthorizationStatus status,
  ) async {
    await _apiClient.put(
      '/admin/authorizations/$id/status',
      data: {'status': status.name},
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageProvider),
  );
});
