import '../entities/body_telemetry.dart';
import '../entities/fitness_profile.dart';
import '../entities/user_profile.dart';

abstract class IUserRepository {
  /// Retrieves the unified UserProfile entity for a given user (or default '1')
  Future<UserProfile?> getUserProfile(String userId);

  /// Saves or updates the UserProfile entity
  Future<void> saveUserProfile(UserProfile profile);

  /// Saves the user's body telemetry data (height, weight, age, etc.)
  Future<void> saveBodyTelemetry(BodyTelemetry telemetry);

  /// Retrieves the latest body telemetry for a given user
  Future<BodyTelemetry?> getBodyTelemetry(String userId);

  /// Saves the user's fitness profile (goals, equipment, frequency)
  Future<void> saveFitnessProfile(FitnessProfile profile);

  /// Retrieves the fitness profile for a given user
  Future<FitnessProfile?> getFitnessProfile(String userId);
}
