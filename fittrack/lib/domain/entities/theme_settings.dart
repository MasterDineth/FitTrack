import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'theme_settings.freezed.dart';
part 'theme_settings.g.dart';

/// Custom JSON converter to serialize [ThemeMode] safely as a string.
class ThemeModeConverter implements JsonConverter<ThemeMode, String> {
  const ThemeModeConverter();

  @override
  ThemeMode fromJson(String json) {
    switch (json) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  @override
  String toJson(ThemeMode object) => object.name;
}

@freezed
abstract class ThemeSettings with _$ThemeSettings {
  const ThemeSettings._();

  const factory ThemeSettings({
    @ThemeModeConverter() @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(0xFF00D68F) int accentColorValue,
    @Default(false) bool useDynamicAccent,
    @Default(false) bool useOledBlack,
    @Default(false) bool useHighContrast,
    @Default(true) bool autoDarkWorkout,
    @Default(true) bool keepScreenAwake,
  }) = _ThemeSettings;

  factory ThemeSettings.fromJson(Map<String, dynamic> json) =>
      _$ThemeSettingsFromJson(json);

  /// Helper getter to retrieve the current accent [Color].
  Color get accentColor => Color(accentColorValue);

  /// Default baseline configuration.
  static const defaultSettings = ThemeSettings();
}
