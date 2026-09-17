import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/security_settings.dart';
import 'repository_providers.dart';

part 'security_settings_provider.g.dart';

/// Riverpod notifier managing [SecuritySettings] state and persistence.
@Riverpod(keepAlive: true)
class SecuritySettingsNotifier extends _$SecuritySettingsNotifier {
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  FutureOr<SecuritySettings> build() async {
    final repository = ref.watch(securityRepositoryProvider);
    return await repository.getSecuritySettings();
  }

  /// Toggles master App Lock requirement.
  Future<void> toggleAppLock(bool value) async {
    final current = state.value ?? SecuritySettings.defaultSettings;
    final updated = current.copyWith(isAppLockEnabled: value);
    state = AsyncData(updated);
    await ref.read(securityRepositoryProvider).saveSecuritySettings(updated);
  }

  /// Toggles biometric unlock support.
  Future<void> toggleBiometric(bool value) async {
    final current = state.value ?? SecuritySettings.defaultSettings;
    final updated = current.copyWith(isBiometricEnabled: value);
    state = AsyncData(updated);
    await ref.read(securityRepositoryProvider).saveSecuritySettings(updated);
  }

  /// Toggles device passcode or PIN fallback.
  Future<void> togglePasscodeFallback(bool value) async {
    final current = state.value ?? SecuritySettings.defaultSettings;
    final updated = current.copyWith(isPasscodeFallbackEnabled: value);
    state = AsyncData(updated);
    await ref.read(securityRepositoryProvider).saveSecuritySettings(updated);
  }

  /// Updates the auto-timeout lock interval.
  Future<void> setLockTimeout(LockTimeout timeout) async {
    final current = state.value ?? SecuritySettings.defaultSettings;
    final updated = current.copyWith(lockTimeout: timeout);
    state = AsyncData(updated);
    await ref.read(securityRepositoryProvider).saveSecuritySettings(updated);
  }

  /// Toggles hiding sensitive content in the OS app switcher.
  Future<void> toggleHideContent(bool value) async {
    final current = state.value ?? SecuritySettings.defaultSettings;
    final updated = current.copyWith(hideContent: value);
    state = AsyncData(updated);
    await ref.read(securityRepositoryProvider).saveSecuritySettings(updated);
  }

  /// Toggles requiring biometrics for sensitive actions (exports, deletions).
  Future<void> toggleRequireForSensitive(bool value) async {
    final current = state.value ?? SecuritySettings.defaultSettings;
    final updated = current.copyWith(requireForSensitive: value);
    state = AsyncData(updated);
    await ref.read(securityRepositoryProvider).saveSecuritySettings(updated);
  }

  /// Toggles 30s security cooldown after consecutive failed attempts.
  Future<void> toggleFailedAttemptsCooldown(bool value) async {
    final current = state.value ?? SecuritySettings.defaultSettings;
    final updated = current.copyWith(failedAttemptsCooldown: value);
    state = AsyncData(updated);
    await ref.read(securityRepositoryProvider).saveSecuritySettings(updated);
  }

  /// Persists current security settings.
  Future<void> savePreferences() async {
    final current = state.value ?? SecuritySettings.defaultSettings;
    await ref.read(securityRepositoryProvider).saveSecuritySettings(current);
  }

  /// Prompts user's FaceID/TouchID/Fingerprint using [LocalAuthentication].
  /// Returns a boolean indicating success.
  Future<bool> testBiometrics() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;

      if (!isSupported && !canCheck) {
        debugPrint('LocalAuth: Biometric hardware is not available on this device/simulator.');
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason:
            'Authenticate using biometrics to verify instant zero-latency FitTrack unlock',
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('LocalAuth PlatformException: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('LocalAuth Error: $e');
      return false;
    }
  }
}

/// Compatibility alias matching user prompt naming specification.
final securitySettingsNotifierProvider = securitySettingsProvider;

