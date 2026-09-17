import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

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

  /// Checks if minimum profile criteria is complete.
  bool get isComplete => name.isNotEmpty && weightKg > 0 && heightCm > 0;
}
