import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Unified storage layer.
///
/// * [SharedPreferences] for non-sensitive key-value data.
/// * [FlutterSecureStorage] for tokens and secrets.
class AppStorage {
  AppStorage({FlutterSecureStorage? secureStorage})
    : _secure = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secure;

  // ─── SharedPreferences (non-sensitive) ───────────────────────────────

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<String?> getString(String key) async => (await _prefs).getString(key);

  Future<bool> setString(String key, String value) async =>
      (await _prefs).setString(key, value);

  Future<bool?> getBool(String key) async => (await _prefs).getBool(key);

  Future<bool> setBool(String key, bool value) async =>
      (await _prefs).setBool(key, value);

  Future<int?> getInt(String key) async => (await _prefs).getInt(key);

  Future<bool> setInt(String key, int value) async =>
      (await _prefs).setInt(key, value);

  Future<bool> remove(String key) async => (await _prefs).remove(key);

  // ─── Secure Storage (tokens / secrets) ───────────────────────────────

  Future<String?> getSecure(String key) => _secure.read(key: key);

  Future<void> setSecure(String key, String value) =>
      _secure.write(key: key, value: value);

  Future<void> deleteSecure(String key) => _secure.delete(key: key);

  Future<void> clearSecure() => _secure.deleteAll();
}
