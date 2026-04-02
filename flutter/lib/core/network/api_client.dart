import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';

class ApiFailure implements Exception {
  const ApiFailure(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiFailure.fromDio(DioException error) {
    final statusCode = error.response?.statusCode;
    final payload = error.response?.data;

    if (payload is Map<String, dynamic>) {
      final message = payload['message'];
      if (message is String && message.trim().isNotEmpty) {
        return ApiFailure(message, statusCode: statusCode);
      }
      if (message is List && message.isNotEmpty) {
        return ApiFailure(message.join(', '), statusCode: statusCode);
      }
    }

    if (statusCode == 401) {
      return ApiFailure('Sesión inválida o expirada.', statusCode: statusCode);
    }

    if (statusCode == 403) {
      return ApiFailure(
        'No tienes permiso para realizar esta acción.',
        statusCode: statusCode,
      );
    }

    if (statusCode == 404) {
      return ApiFailure(
        'No se encontró el recurso solicitado.',
        statusCode: statusCode,
      );
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return ApiFailure(
        'La API tardó demasiado en responder.',
        statusCode: statusCode,
      );
    }

    return ApiFailure(
      error.message ?? 'No se pudo completar la petición.',
      statusCode: statusCode,
    );
  }

  @override
  String toString() => message;
}

class AppApiClient {
  AppApiClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 20),
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

  final Dio _dio;

  Future<Map<String, dynamic>> getMap(
    String path, {
    Map<String, dynamic>? queryParameters,
    String? bearerToken,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: _options(bearerToken),
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, dynamic>? queryParameters,
    String? bearerToken,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: _options(bearerToken),
      );
      return List<dynamic>.from(response.data as List);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  Future<Map<String, dynamic>> postMap(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    String? bearerToken,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _options(bearerToken),
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  Options _options(String? bearerToken) {
    if (bearerToken == null || bearerToken.isEmpty) {
      return Options();
    }

    return Options(headers: {'Authorization': 'Bearer $bearerToken'});
  }
}

final appApiClientProvider = Provider<AppApiClient>((ref) {
  return AppApiClient();
});
