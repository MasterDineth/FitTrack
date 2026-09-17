// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SecuritySettings _$SecuritySettingsFromJson(Map<String, dynamic> json) =>
    _SecuritySettings(
      isAppLockEnabled: json['isAppLockEnabled'] as bool? ?? true,
      isBiometricEnabled: json['isBiometricEnabled'] as bool? ?? true,
      isPasscodeFallbackEnabled:
          json['isPasscodeFallbackEnabled'] as bool? ?? true,
      lockTimeout:
          $enumDecodeNullable(_$LockTimeoutEnumMap, json['lockTimeout']) ??
          LockTimeout.immediate,
      hideContent: json['hideContent'] as bool? ?? true,
      requireForSensitive: json['requireForSensitive'] as bool? ?? true,
      failedAttemptsCooldown: json['failedAttemptsCooldown'] as bool? ?? true,
    );

Map<String, dynamic> _$SecuritySettingsToJson(_SecuritySettings instance) =>
    <String, dynamic>{
      'isAppLockEnabled': instance.isAppLockEnabled,
      'isBiometricEnabled': instance.isBiometricEnabled,
      'isPasscodeFallbackEnabled': instance.isPasscodeFallbackEnabled,
      'lockTimeout': _$LockTimeoutEnumMap[instance.lockTimeout]!,
      'hideContent': instance.hideContent,
      'requireForSensitive': instance.requireForSensitive,
      'failedAttemptsCooldown': instance.failedAttemptsCooldown,
    };

const _$LockTimeoutEnumMap = {
  LockTimeout.immediate: 'immediate',
  LockTimeout.min5: 'min5',
  LockTimeout.min15: 'min15',
  LockTimeout.min30: 'min30',
};
