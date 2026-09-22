import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/body_telemetry.dart';
import '../../../domain/entities/fitness_profile.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/i_user_repository.dart';

class MockUserRepository implements IUserRepository {
  BodyTelemetry? _telemetry;
  FitnessProfile? _profile;

  @override
  Future<BodyTelemetry?> getBodyTelemetry(String userId) async {
    if (_telemetry != null) return _telemetry;
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('telemetry_$userId');
    if (data != null) {
      try {
        final map = jsonDecode(data) as Map<String, dynamic>;
        _telemetry = BodyTelemetry(
          id: map['id'],
          userId: map['userId'],
          unitSystem: UnitSystem.values[map['unitSystem']],
          biologicalSex: BiologicalSex.values[map['biologicalSex']],
          age: map['age'],
          weight: map['weight'],
          height: map['height'],
          recordedAt: DateTime.parse(map['recordedAt']),
        );
      } catch (e) {
        // Handle potential parsing errors from old data formats during dev
      }
    }
    return _telemetry;
  }

  @override
  Future<void> saveBodyTelemetry(BodyTelemetry telemetry) async {
    _telemetry = telemetry;
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'id': telemetry.id,
      'userId': telemetry.userId,
      'unitSystem': telemetry.unitSystem.index,
      'biologicalSex': telemetry.biologicalSex.index,
      'age': telemetry.age,
      'weight': telemetry.weight,
      'height': telemetry.height,
      'recordedAt': telemetry.recordedAt.toIso8601String(),
    };
    await prefs.setString('telemetry_${telemetry.userId}', jsonEncode(map));
  }

  @override
  Future<FitnessProfile?> getFitnessProfile(String userId) async {
    if (_profile != null) return _profile;
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('fitness_profile_$userId');
    if (data != null) {
      try {
        final map = jsonDecode(data) as Map<String, dynamic>;
        _profile = FitnessProfile(
          id: map['id'],
          userId: map['userId'],
          primaryFocus: PrimaryFocus.values[map['primaryFocus']],
          liftingExperience: LiftingExperience.values[map['liftingExperience']],
          weeklyFrequency: map['weeklyFrequency'],
          availableEquipment: AvailableEquipment.values[map['availableEquipment']],
          updatedAt: DateTime.parse(map['updatedAt']),
        );
      } catch (e) {
        // Handle potential parsing errors from old data formats during dev
      }
    }
    return _profile;
  }

  @override
  Future<void> saveFitnessProfile(FitnessProfile profile) async {
    _profile = profile;
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'id': profile.id,
      'userId': profile.userId,
      'primaryFocus': profile.primaryFocus.index,
      'liftingExperience': profile.liftingExperience.index,
      'weeklyFrequency': profile.weeklyFrequency,
      'availableEquipment': profile.availableEquipment.index,
      'updatedAt': profile.updatedAt.toIso8601String(),
    };
    await prefs.setString('fitness_profile_${profile.userId}', jsonEncode(map));
  }

  UserProfile? _userProfile;

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    return _userProfile;
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    _userProfile = profile;
  }
}
