import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/security_activity.dart';

part 'security_provider.g.dart';

/// Alias for [securityProvider] to support both naming conventions.
final securityNotifierProvider = securityProvider;

/// State representation for password security, strength metrics, and audit activities.
class SecurityState {
  const SecurityState({
    this.currentPassword = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.obscureCurrent = true,
    this.obscureNew = true,
    this.obscureConfirm = true,
    this.activities = const [],
  });

  final String currentPassword;
  final String newPassword;
  final String confirmPassword;
  final bool obscureCurrent;
  final bool obscureNew;
  final bool obscureConfirm;
  final List<SecurityActivity> activities;

  /// Requirement 1: 8+ characters required
  bool get hasMinLength => newPassword.length >= 8;

  /// Requirement 2: Uppercase & lowercase letters
  bool get hasUpperAndLower =>
      RegExp(r'[a-z]').hasMatch(newPassword) &&
      RegExp(r'[A-Z]').hasMatch(newPassword);

  /// Requirement 3: At least 1 numerical digit (0–9)
  bool get hasNumber => RegExp(r'[0-9]').hasMatch(newPassword);

  /// Requirement 4: Special symbol (!@#$%^&*...)
  bool get hasSymbol =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>\-_=+]').hasMatch(newPassword);

  /// Password strength score from 0 to 4
  int get passwordStrength {
    int score = 0;
    if (hasMinLength) score++;
    if (hasUpperAndLower) score++;
    if (hasNumber) score++;
    if (hasSymbol) score++;
    return score;
  }

  /// Label description for the current strength
  String get strengthLabel {
    switch (passwordStrength) {
      case 0:
        return newPassword.isEmpty ? 'Not entered' : 'Too Weak';
      case 1:
        return 'Weak Password';
      case 2:
        return 'Fair Password';
      case 3:
        return 'Good Password';
      case 4:
        return 'Strong Password';
      default:
        return 'Strong Password';
    }
  }

  /// Whether passwords match and are non-empty
  bool get passwordsMatch =>
      newPassword.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      newPassword == confirmPassword;

  /// Whether the form meets criteria to trigger confirmation
  bool get canSubmit =>
      currentPassword.isNotEmpty &&
      passwordsMatch &&
      passwordStrength >= 4;

  SecurityState copyWith({
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
    bool? obscureCurrent,
    bool? obscureNew,
    bool? obscureConfirm,
    List<SecurityActivity>? activities,
  }) {
    return SecurityState(
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      obscureCurrent: obscureCurrent ?? this.obscureCurrent,
      obscureNew: obscureNew ?? this.obscureNew,
      obscureConfirm: obscureConfirm ?? this.obscureConfirm,
      activities: activities ?? this.activities,
    );
  }
}

@riverpod
class SecurityNotifier extends _$SecurityNotifier {
  @override
  SecurityState build() {
    return const SecurityState(
      currentPassword: 'OriginalAthletePass2024!',
      newPassword: 'P@ceSetter2025#',
      confirmPassword: 'P@ceSetter2025#',
      obscureCurrent: true,
      obscureNew: true,
      obscureConfirm: true,
      activities: _mockActivities,
    );
  }

  static const List<SecurityActivity> _mockActivities = [
    SecurityActivity(
      id: 'sec_1',
      title: 'Password Changed',
      timestamp: 'Oct 14, 2025 • 14:22 GMT',
      deviceInfo: 'iPhone 15 Pro',
      location: 'Colombo, LK (Current Device)',
      statusBadge: 'Successful',
    ),
    SecurityActivity(
      id: 'sec_2',
      title: 'Password Reset via Email',
      timestamp: 'Jul 02, 2025 • 09:15 GMT',
      deviceInfo: 'Chrome Web',
      location: 'Colombo, LK • IP 192.168.1.42',
      statusBadge: 'Verified',
    ),
    SecurityActivity(
      id: 'sec_3',
      title: 'Two-Factor Auth Enabled',
      timestamp: 'Mar 18, 2025 • 18:40 GMT',
      deviceInfo: 'Hardware Key & Authenticator App Paired',
      location: 'Colombo, LK',
      statusBadge: 'Security Update',
    ),
  ];

  void updateCurrentPassword(String value) {
    state = state.copyWith(currentPassword: value);
  }

  void updateNewPassword(String value) {
    state = state.copyWith(newPassword: value);
  }

  void updateConfirmPassword(String value) {
    state = state.copyWith(confirmPassword: value);
  }

  void toggleObscureCurrent() {
    state = state.copyWith(obscureCurrent: !state.obscureCurrent);
  }

  void toggleObscureNew() {
    state = state.copyWith(obscureNew: !state.obscureNew);
  }

  void toggleObscureConfirm() {
    state = state.copyWith(obscureConfirm: !state.obscureConfirm);
  }

  void resetForm() {
    state = state.copyWith(
      currentPassword: '',
      newPassword: '',
      confirmPassword: '',
      obscureCurrent: true,
      obscureNew: true,
      obscureConfirm: true,
    );
  }

  void recordSuccessfulChange() {
    final newActivity = SecurityActivity(
      id: 'sec_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Password Changed',
      timestamp: 'Today • Just now',
      deviceInfo: 'iPhone 15 Pro',
      location: 'Colombo, LK (Current Device)',
      statusBadge: 'Successful',
    );
    state = state.copyWith(
      activities: [newActivity, ...state.activities],
      currentPassword: state.newPassword,
      newPassword: '',
      confirmPassword: '',
    );
  }
}
