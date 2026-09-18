import 'package:sqflite/sqflite.dart';
import '../../domain/entities/body_telemetry.dart';
import '../../domain/entities/fitness_profile.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../datasources/local/database_helper.dart';

class SqliteUserRepository implements IUserRepository {
  final DatabaseHelper _dbHelper;

  SqliteUserRepository(this._dbHelper);

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    final db = await _dbHelper.database;
    // Prefer matching ID or fallback to single user row '1'
    List<Map<String, dynamic>> maps = await db.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) {
      maps = await db.query(
        'user_profile',
        where: 'id = ?',
        whereArgs: ['1'],
      );
    }

    if (maps.isEmpty) {
      return null;
    }

    return UserProfile.fromJson(maps.first);
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    final db = await _dbHelper.database;
    await db.insert(
      'user_profile',
      profile.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> saveBodyTelemetry(BodyTelemetry telemetry) async {
    final current = await getUserProfile(telemetry.userId);
    if (current != null) {
      final updated = current.copyWith(
        age: telemetry.age,
        weightKg: telemetry.weight,
        heightCm: telemetry.height,
      );
      await saveUserProfile(updated);
    }
  }

  @override
  Future<BodyTelemetry?> getBodyTelemetry(String userId) async {
    final profile = await getUserProfile(userId);
    if (profile == null) return null;
    return BodyTelemetry(
      id: 'telemetry_$userId',
      userId: userId,
      unitSystem: UnitSystem.metric,
      biologicalSex: BiologicalSex.male,
      age: profile.age,
      weight: profile.weightKg,
      height: profile.heightCm,
      recordedAt: DateTime.now(),
    );
  }

  @override
  Future<void> saveFitnessProfile(FitnessProfile profile) async {
    final current = await getUserProfile(profile.userId);
    if (current != null) {
      String exp = 'Advanced';
      if (profile.liftingExperience == LiftingExperience.beginner) {
        exp = 'Beginner';
      } else if (profile.liftingExperience == LiftingExperience.intermediate) {
        exp = 'Intermediate';
      }

      String goal = 'Hypertrophy & Strength';
      if (profile.primaryFocus == PrimaryFocus.strength) {
        goal = 'Pure Strength (Powerlifting)';
      } else if (profile.primaryFocus == PrimaryFocus.fatLoss) {
        goal = 'Fat Loss & Conditioning';
      }

      final updated = current.copyWith(
        experienceLevel: exp,
        primaryGoal: goal,
        weeklyTargetDays: profile.weeklyFrequency,
      );
      await saveUserProfile(updated);
    }
  }

  @override
  Future<FitnessProfile?> getFitnessProfile(String userId) async {
    final profile = await getUserProfile(userId);
    if (profile == null) return null;
    return FitnessProfile(
      id: 'fit_profile_$userId',
      userId: userId,
      primaryFocus: PrimaryFocus.hypertrophy,
      liftingExperience: LiftingExperience.advanced,
      weeklyFrequency: profile.weeklyTargetDays,
      availableEquipment: AvailableEquipment.fullGym,
      updatedAt: DateTime.now(),
    );
  }
}
