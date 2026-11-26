import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show VoidCallback, kDebugMode;

import 'auth_interceptor.dart';
import 'token_manager.dart';

/// App-wide Dio HTTP client with auth handling.
///
/// Usage:
/// ```dart
/// final client = DioClient(baseUrl: 'https://api.vide.app');
/// final response = await client.dio.get('/courses');
/// ```
class DioClient {
  DioClient({
    required String baseUrl,
    required TokenManager tokenManager,
    VoidCallback? onForceLogout,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _authInterceptor = AuthInterceptor(
      tokenManager: tokenManager,
      dio: _dio,
      onForceLogout: onForceLogout,
    );

    _dio.interceptors.add(_authInterceptor);
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          requestBody: false,
          responseHeader: false,
          responseBody: false,
        ),
      );
    }
  }

  late final Dio _dio;
  late final AuthInterceptor _authInterceptor;

  /// The raw [Dio] instance – use for direct requests.
  Dio get dio => _dio;
}
