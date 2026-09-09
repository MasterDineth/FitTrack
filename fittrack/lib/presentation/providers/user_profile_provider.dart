import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/body_telemetry.dart';
import '../../domain/entities/fitness_profile.dart';
import 'repository_providers.dart';
import 'auth_provider.dart';

part 'user_profile_provider.g.dart';

class UserProfileState {
  final BodyTelemetry? telemetry;
  final FitnessProfile? fitnessProfile;

  UserProfileState({this.telemetry, this.fitnessProfile});

  bool get isComplete => telemetry != null && fitnessProfile != null;
}

@Riverpod(keepAlive: true)
class UserProfileNotifier extends _$UserProfileNotifier {
  @override
  FutureOr<UserProfileState> build() async {
    final userAsync = ref.watch(authNotifierProvider);
    
    if (userAsync.isLoading || userAsync.hasError || userAsync.value == null) {
      return UserProfileState();
    }

    final userId = userAsync.value!.id;
    final userRepo = ref.watch(userRepositoryProvider);
    
    final telemetry = await userRepo.getBodyTelemetry(userId);
    final profile = await userRepo.getFitnessProfile(userId);
    
    return UserProfileState(telemetry: telemetry, fitnessProfile: profile);
  }

  Future<void> saveTelemetry(BodyTelemetry telemetry) async {
    final userRepo = ref.read(userRepositoryProvider);
    await userRepo.saveBodyTelemetry(telemetry);
    ref.invalidateSelf();
  }

  Future<void> saveFitnessProfile(FitnessProfile profile) async {
    final userRepo = ref.read(userRepositoryProvider);
    await userRepo.saveFitnessProfile(profile);
    ref.invalidateSelf();
  }
}
