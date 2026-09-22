import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

class BoolIntConverter implements JsonConverter<bool, dynamic> {
  const BoolIntConverter();

  @override
  bool fromJson(dynamic json) {
    if (json is bool) return json;
    if (json is num) return json != 0;
    if (json is String) return json == '1' || json.toLowerCase() == 'true';
    return false;
  }

  @override
  dynamic toJson(bool object) => object ? 1 : 0;
}

@freezed
abstract class UserProfile with _$UserProfile {
  const UserProfile._();

  const factory UserProfile({
    required String id,
    required String name,
    required int age,
    required double weightKg,
    required double heightCm,
    required String experienceLevel,
    required String primaryGoal,
    required int weeklyTargetDays,
    String? profileImagePath,
    String? address,
    String? phone,
    @Default(false) @BoolIntConverter() bool isPhoneVerified,
    String? dob,
    String? email,
    String? username,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  /// Dynamic BMI calculation based on weight (kg) and height (cm).
  double get calculateBMI {
    if (heightCm <= 0) return 0.0;
    final heightInMeters = heightCm / 100.0;
    return weightKg / (heightInMeters * heightInMeters);
  }

  /// Dynamic BMI category classification.
  String get getBMICategory {
    final bmi = calculateBMI;
    if (bmi < 18.5) return 'UNDERWEIGHT';
    if (bmi <= 24.9) return 'NORMAL';
    return 'OVERWEIGHT';
  }

  /// Checks if onboarding criteria (both telemetry and fitness profile) is complete.
  bool get isComplete =>
      name.trim().isNotEmpty &&
      weightKg > 0 &&
      heightCm > 0 &&
      experienceLevel.trim().isNotEmpty &&
      primaryGoal.trim().isNotEmpty &&
      weeklyTargetDays > 0;
}
