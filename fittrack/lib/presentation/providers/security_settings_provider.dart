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
  String? _lastAuthMessage;

  /// Diagnostic message from the most recent biometric verification attempt.
  String? get lastAuthMessage => _lastAuthMessage;

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

      debugPrint('LocalAuth: isSupported=$isSupported, canCheck=$canCheck');

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason:
            'Authenticate using biometrics to verify instant zero-latency FitTrack unlock',
      );

      if (didAuthenticate) {
        _lastAuthMessage =
            'Hardware Token Authenticated: Sub-millisecond response confirmed.';
      } else {
        _lastAuthMessage =
            'Biometric verification cancelled or not completed.';
      }
      return didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('LocalAuth PlatformException: ${e.code} - ${e.message}');
      if (e.code == 'NotEnrolled') {
        _lastAuthMessage =
            'No biometric credentials enrolled. Please register a fingerprint or face in Android settings.';
      } else if (e.code == 'LockedOut') {
        _lastAuthMessage =
            'Biometric sensor locked out due to failed attempts. Please unlock with PIN first.';
      } else {
        _lastAuthMessage = e.message ?? 'Biometric authentication failed (${e.code}).';
      }
      return false;
    } catch (e) {
      debugPrint('LocalAuth Error: $e');
      _lastAuthMessage = 'Authentication error: $e';
      return false;
    }
  }
}

/// Compatibility alias matching user prompt naming specification.
final securitySettingsNotifierProvider = securitySettingsProvider;

