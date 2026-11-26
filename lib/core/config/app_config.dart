/// Compile-time configuration for the VIDE app.
class AppConfig {
  AppConfig._();

  /// Base URL for the VIDE API.
  ///
  /// Override at build time with:
  /// `flutter run --dart-define=VIDE_API_URL=https://api.example.com`
  static const String apiBaseUrl = String.fromEnvironment(
    'VIDE_API_URL',
    defaultValue: 'https://api.vide.app',
  );

  /// SharedPreferences key used to decide whether the welcome flow was seen.
  static const String hasSeenWelcomeKey = 'has_seen_welcome';
}
