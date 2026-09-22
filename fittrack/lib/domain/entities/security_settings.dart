import 'package:freezed_annotation/freezed_annotation.dart';

part 'security_settings.freezed.dart';
part 'security_settings.g.dart';

enum LockTimeout {
  immediate,
  min5,
  min15,
  min30;

  String get title {
    switch (this) {
      case LockTimeout.immediate:
        return 'Immediately';
      case LockTimeout.min5:
        return 'After 5 minutes';
      case LockTimeout.min15:
        return 'After 15 minutes';
      case LockTimeout.min30:
        return 'After 30 minutes';
    }
  }

  String get subtitle {
    switch (this) {
      case LockTimeout.immediate:
        return 'Locks as soon as app goes to background or screen turns off';
      case LockTimeout.min5:
        return 'Convenient during continuous workout supersets';
      case LockTimeout.min15:
        return 'Locks after extended inactivity';
      case LockTimeout.min30:
        return 'Gym session grace period';
    }
  }

  String? get badge {
    switch (this) {
      case LockTimeout.immediate:
        return 'Most Secure';
      default:
        return null;
    }
  }
}

@freezed
abstract class SecuritySettings with _$SecuritySettings {
  const SecuritySettings._();

  const factory SecuritySettings({
    @Default(false) bool isAppLockEnabled,
    @Default(false) bool isBiometricEnabled,
    @Default(true) bool isPasscodeFallbackEnabled,
    @Default(LockTimeout.immediate) LockTimeout lockTimeout,
    @Default(true) bool hideContent,
    @Default(true) bool requireForSensitive,
    @Default(true) bool failedAttemptsCooldown,
  }) = _SecuritySettings;

  factory SecuritySettings.fromJson(Map<String, dynamic> json) =>
      _$SecuritySettingsFromJson(json);

  /// Default baseline instance.
  static const defaultSettings = SecuritySettings();
}
