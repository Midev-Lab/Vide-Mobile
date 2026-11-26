import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages access / refresh tokens and expiry bookkeeping.
///
/// * Access token is kept in memory only.
/// * Refresh token is persisted in [FlutterSecureStorage].
class TokenManager {
  TokenManager({FlutterSecureStorage? secureStorage})
    : _secure = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secure;

  static const _refreshTokenKey = 'vide_refresh_token';
  static const _accessTokenKey = 'vide_access_token';

  /// In-memory cache of the current access token.
  String? _accessToken;
  String? get accessToken => _accessToken;

  /// The instant the current access token expires (epoch millis).
  DateTime? _expiresAt;
  DateTime? get expiresAt => _expiresAt;

  /// Timer for proactive refresh.
  Timer? _refreshTimer;

  /// Callback invoked when a proactive refresh is needed.
  Future<void> Function()? onTokenExpiring;

  // ─── Persistence ─────────────────────────────────────────────────────

  Future<void> setAccessToken(
    String token, {
    int expiresInSeconds = 3600,
  }) async {
    _accessToken = token;
    _expiresAt = DateTime.now().add(Duration(seconds: expiresInSeconds));
    _scheduleProactiveRefresh(expiresInSeconds);
  }

  Future<void> setRefreshToken(String token) async {
    await _secure.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return _secure.read(key: _refreshTokenKey);
  }

  /// Access tokens are intentionally memory-only; a cold start restores the
  /// session by exchanging the persisted refresh token instead.
  Future<void> loadTokens() async {}

  /// Whether the access token will expire within [buffer].
  bool isExpiringSoon({Duration buffer = const Duration(seconds: 60)}) {
    if (_expiresAt == null) return true;
    return DateTime.now().isAfter(_expiresAt!.subtract(buffer));
  }

  bool get isAuthenticated => _accessToken != null;

  Future<void> clearAll() async {
    _accessToken = null;
    _expiresAt = null;
    _refreshTimer?.cancel();
    _refreshTimer = null;
    await _secure.delete(key: _accessTokenKey);
    await _secure.delete(key: _refreshTokenKey);
  }

  // ─── Proactive refresh timer ─────────────────────────────────────────

  void _scheduleProactiveRefresh(int expiresInSeconds) {
    _refreshTimer?.cancel();
    // Refresh 60 s before expiry.
    final refreshIn = expiresInSeconds - 60;
    if (refreshIn <= 0) return;
    _refreshTimer = Timer(Duration(seconds: refreshIn), () {
      onTokenExpiring?.call();
    });
  }

  void dispose() {
    _refreshTimer?.cancel();
  }
}
