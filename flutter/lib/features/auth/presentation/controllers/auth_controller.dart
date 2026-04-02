import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/auth_repository.dart';
import '../../domain/models/auth_session.dart';

enum AuthStage { initial, loading, authenticated, unauthenticated }

class AuthState {
  const AuthState({required this.stage, this.session, this.errorMessage});

  final AuthStage stage;
  final AuthSession? session;
  final String? errorMessage;

  bool get isAuthenticated =>
      stage == AuthStage.authenticated && session != null;
  bool get isLoading => stage == AuthStage.loading;

  factory AuthState.initial() => const AuthState(stage: AuthStage.initial);

  factory AuthState.unauthenticated({String? message}) {
    return AuthState(stage: AuthStage.unauthenticated, errorMessage: message);
  }

  factory AuthState.authenticated(AuthSession session) {
    return AuthState(stage: AuthStage.authenticated, session: session);
  }

  AuthState copyWith({
    AuthStage? stage,
    AuthSession? session,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      stage: stage ?? this.stage,
      session: session ?? this.session,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  late final AuthRepository _repository;
  late final TokenStorage _storage;

  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);
    _storage = ref.read(tokenStorageProvider);
    return AuthState.initial();
  }

  Future<void> restoreSession() async {
    if (state.stage == AuthStage.loading) {
      return;
    }

    state = state.copyWith(stage: AuthStage.loading, clearError: true);

    final cachedSession = await _storage.readSession();
    if (cachedSession == null) {
      state = AuthState.unauthenticated();
      return;
    }

    try {
      final profile = await _repository.getProfile(cachedSession.accessToken);
      final refreshedSession = cachedSession.copyWith(user: profile);
      await _storage.saveSession(refreshedSession);
      state = AuthState.authenticated(refreshedSession);
      return;
    } catch (_) {
      if (cachedSession.refreshToken.isNotEmpty) {
        try {
          final refreshedSession = await _repository.refresh(
            cachedSession.refreshToken,
          );
          await _storage.saveSession(refreshedSession);
          state = AuthState.authenticated(refreshedSession);
          return;
        } catch (error) {
          await _storage.clear();
          state = AuthState.unauthenticated(message: _mapError(error));
          return;
        }
      }
    }

    await _storage.clear();
    state = AuthState.unauthenticated(
      message: 'La sesión expiró. Inicia nuevamente.',
    );
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(stage: AuthStage.loading, clearError: true);

    try {
      final session = await _repository.login(email, password);
      await _storage.saveSession(session);
      state = AuthState.authenticated(session);
      return true;
    } catch (error) {
      state = AuthState.unauthenticated(message: _mapError(error));
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clear();
    state = AuthState.unauthenticated();
  }

  void clearError() {
    if (state.errorMessage == null) {
      return;
    }

    state = state.copyWith(clearError: true);
  }

  String _mapError(Object error) {
    if (error is ApiFailure) {
      return error.message;
    }

    return 'No se pudo completar la operación.';
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
