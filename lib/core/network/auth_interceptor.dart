import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show VoidCallback;

import 'token_manager.dart';

/// Intercepts outgoing requests to attach the access token and handles
/// 401 responses by attempting a single token refresh.
///
/// ### Refresh-token handling
/// The server returns `refreshToken: null` in the JSON body but sends the
/// real token via a `Set-Cookie: refresh_token=...` response header.
/// This interceptor reads that header, stores the value in secure storage,
/// and sends it as `{"refreshToken": "..."}` on `POST /auth/refresh`.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.tokenManager,
    required this.dio,
    this.onForceLogout,
  }) {
    // Wire proactive refresh.
    tokenManager.onTokenExpiring = () async {
      try {
        await _refreshAccessToken();
      } catch (_) {
        await tokenManager.clearAll();
        onForceLogout?.call();
      }
    };
  }

  final TokenManager tokenManager;
  final Dio dio;

  /// Called when both the token and the refresh attempt fail.
  VoidCallback? onForceLogout;

  /// Paths that should never carry the auth header.
  static const _publicPaths = [
    '/auth/login',
    '/auth/register',
    '/auth/refresh',
  ];

  bool _isRefreshing = false;

  // ─── Request ─────────────────────────────────────────────────────────

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final isPublic = _publicPaths.any((p) => options.path.contains(p));
    final token = tokenManager.accessToken;

    if (!isPublic && token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  // ─── Response (extract Set-Cookie refresh_token) ─────────────────────

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _extractRefreshTokenFromCookies(response.headers);
    handler.next(response);
  }

  // ─── Error (401 → try refresh once) ──────────────────────────────────

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Auth endpoints (login, register, refresh, reset, …) report their own
    // failures. Refreshing here would mask the real error or cause loops.
    if (err.requestOptions.path.contains('/auth/')) {
      return handler.next(err);
    }

    // A refresh is already in flight; let it finish first.
    if (_isRefreshing) {
      return handler.next(err);
    }

    // The retried request still failed — the session cannot be recovered.
    if (err.requestOptions.extra['_authRetried'] == true) {
      await tokenManager.clearAll();
      onForceLogout?.call();
      return handler.next(err);
    }

    try {
      await _refreshAccessToken();

      // Retry the original request with the new token (once only).
      final opts = err.requestOptions;
      opts.extra['_authRetried'] = true;
      opts.headers['Authorization'] = 'Bearer ${tokenManager.accessToken}';
      final retryResponse = await dio.fetch(opts);
      return handler.resolve(retryResponse);
    } catch (_) {
      await tokenManager.clearAll();
      onForceLogout?.call();
      return handler.next(err);
    }
  }

  // ─── Refresh logic ──────────────────────────────────────────────────

  Future<void> _refreshAccessToken() async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      final refreshToken = await tokenManager.getRefreshToken();
      if (refreshToken == null) throw Exception('No refresh token available');

      final response = await dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        // Don't trigger this interceptor again for the refresh call itself.
        options: Options(headers: {'_skip_auth': true}),
      );

      final newAccessToken = response.data['accessToken'] as String;
      final expiresIn = (response.data['expiresIn'] as int?) ?? 3600;

      await tokenManager.setAccessToken(
        newAccessToken,
        expiresInSeconds: expiresIn,
      );

      // The refresh endpoint may also rotate the refresh token.
      _extractRefreshTokenFromCookies(response.headers);
    } finally {
      _isRefreshing = false;
    }
  }

  // ─── Cookie parsing ──────────────────────────────────────────────────

  void _extractRefreshTokenFromCookies(Headers headers) {
    final cookies = headers.map['set-cookie'];
    if (cookies == null) return;

    for (final cookie in cookies) {
      // e.g. "refresh_token=abc123; Path=/; HttpOnly; Secure"
      if (cookie.startsWith('refresh_token=')) {
        final value = cookie.split(';').first.split('=').sublist(1).join('=');
        if (value.isNotEmpty) {
          tokenManager.setRefreshToken(value);
        }
        break;
      }
    }
  }
}
