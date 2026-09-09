import '../../../domain/entities/body_telemetry.dart';
import '../../../domain/entities/fitness_profile.dart';
import '../../../domain/repositories/i_user_repository.dart';

class MockUserRepository implements IUserRepository {
  BodyTelemetry? _telemetry;
  FitnessProfile? _profile;

  @override
  Future<BodyTelemetry?> getBodyTelemetry(String userId) async {
    return _telemetry;
  }

  @override
  Future<void> saveBodyTelemetry(BodyTelemetry telemetry) async {
    _telemetry = telemetry;
  }

  @override
  Future<FitnessProfile?> getFitnessProfile(String userId) async {
    return _profile;
  }

  @override
  Future<void> saveFitnessProfile(FitnessProfile profile) async {
    _profile = profile;
  }
}
