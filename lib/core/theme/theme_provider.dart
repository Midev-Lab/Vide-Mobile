import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's [ThemeMode] choice across restarts.
///
/// Listens to changes via [ChangeNotifier].
class ThemeProvider extends ChangeNotifier {
  ThemeProvider({ThemeMode initial = ThemeMode.system}) : _mode = initial;

  static const _key = 'vide_theme_mode';

  ThemeMode _mode;
  ThemeMode get mode => _mode;

  /// Call once at app start after [SharedPreferences] is available.
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored != null) {
      _mode = ThemeMode.values.firstWhere(
        (e) => e.name == stored,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  /// Convenience toggle between light ↔ dark.
  Future<void> toggle() async {
    final next = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setMode(next);
  }
}
