import '../entities/theme_settings.dart';

abstract class IThemeRepository {
  /// Retrieves the persisted theme settings synchronously from local storage.
  ThemeSettings getThemeSettings();

  /// Persists updated theme settings to local storage.
  Future<void> saveThemeSettings(ThemeSettings settings);
}
