// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ThemeSettings _$ThemeSettingsFromJson(Map<String, dynamic> json) =>
    _ThemeSettings(
      themeMode: json['themeMode'] == null
          ? ThemeMode.system
          : const ThemeModeConverter().fromJson(json['themeMode'] as String),
      accentColorValue:
          (json['accentColorValue'] as num?)?.toInt() ?? 0xFF00D68F,
      useDynamicAccent: json['useDynamicAccent'] as bool? ?? false,
      useOledBlack: json['useOledBlack'] as bool? ?? false,
      useHighContrast: json['useHighContrast'] as bool? ?? false,
      autoDarkWorkout: json['autoDarkWorkout'] as bool? ?? true,
      keepScreenAwake: json['keepScreenAwake'] as bool? ?? true,
    );

Map<String, dynamic> _$ThemeSettingsToJson(_ThemeSettings instance) =>
    <String, dynamic>{
      'themeMode': const ThemeModeConverter().toJson(instance.themeMode),
      'accentColorValue': instance.accentColorValue,
      'useDynamicAccent': instance.useDynamicAccent,
      'useOledBlack': instance.useOledBlack,
      'useHighContrast': instance.useHighContrast,
      'autoDarkWorkout': instance.autoDarkWorkout,
      'keepScreenAwake': instance.keepScreenAwake,
    };
