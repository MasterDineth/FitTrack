import '../entities/security_settings.dart';

abstract class ISecurityRepository {
  /// Retrieves the persisted security settings from local storage.
  Future<SecuritySettings> getSecuritySettings();

  /// Persists updated security settings to local storage.
  Future<void> saveSecuritySettings(SecuritySettings settings);
}
