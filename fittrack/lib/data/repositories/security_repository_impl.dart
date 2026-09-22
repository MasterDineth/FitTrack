import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/security_settings.dart';
import '../../domain/repositories/i_security_repository.dart';

/// Concrete implementation of [ISecurityRepository] using [SharedPreferences].
class SecurityRepositoryImpl implements ISecurityRepository {
  static const String _storageKey = 'fittrack_security_settings_v1';

  @override
  Future<SecuritySettings> getSecuritySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return SecuritySettings.fromJson(decoded);
      }
    } catch (_) {
      // In case of any deserialization issues, fall back to safe default settings.
    }
    return const SecuritySettings();
  }

  @override
  Future<void> saveSecuritySettings(SecuritySettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(settings.toJson());
    await prefs.setString(_storageKey, encoded);
  }
}
