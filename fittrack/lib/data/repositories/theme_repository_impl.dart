import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/theme_settings.dart';
import '../../domain/repositories/i_theme_repository.dart';

/// Concrete implementation of [IThemeRepository] using pre-initialized [SharedPreferences].
class ThemeRepositoryImpl implements IThemeRepository {
  final SharedPreferences _prefs;
  static const String _storageKey = 'fittrack_theme_settings_v1';

  ThemeRepositoryImpl(this._prefs);

  @override
  ThemeSettings getThemeSettings() {
    try {
      final raw = _prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return ThemeSettings.fromJson(decoded);
      }
    } catch (_) {
      // In case of any deserialization issues, fall back to safe default settings.
    }
    return const ThemeSettings();
  }

  @override
  Future<void> saveThemeSettings(ThemeSettings settings) async {
    final encoded = jsonEncode(settings.toJson());
    await _prefs.setString(_storageKey, encoded);
  }
}
