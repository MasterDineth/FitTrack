import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/body_telemetry.dart';
import '../../domain/entities/fitness_profile.dart';
import '../../domain/entities/user_profile.dart';
import 'repository_providers.dart';

part 'user_profile_provider.g.dart';

@Riverpod(keepAlive: true)
class UserProfileNotifier extends _$UserProfileNotifier {
  @override
  FutureOr<UserProfile> build() async {
    final userRepo = ref.watch(userRepositoryProvider);
    final profile = await userRepo.getUserProfile('1');
    if (profile != null) {
      return profile;
    }

    const initialProfile = UserProfile(
      id: '1',
      name: '',
      age: 24,
      weightKg: 0.0,
      heightCm: 0.0,
      experienceLevel: '',
      primaryGoal: '',
      weeklyTargetDays: 0,
    );
    return initialProfile;
  }

  /// Dynamic calculation for BMI based on current height and weight.
  double calculateBMI() {
    final profile = state.value;
    if (profile == null || profile.heightCm <= 0 || profile.weightKg <= 0) {
      return 22.5;
    }
    return profile.calculateBMI;
  }

  /// Dynamic classification for BMI category ("UNDERWEIGHT", "NORMAL", "OVERWEIGHT").
  String getBMICategory() {
    final profile = state.value;
    if (profile == null) return 'NORMAL';
    return profile.getBMICategory;
  }

  /// Updates any profile fields and persists immediately to SQLite.
  Future<void> updateField({
    String? name,
    int? age,
    double? weightKg,
    double? heightCm,
    String? experienceLevel,
    String? primaryGoal,
    int? weeklyTargetDays,
    String? address,
    String? phone,
    bool? isPhoneVerified,
    String? dob,
    String? email,
    String? username,
  }) async {
    final current = state.value ??
        const UserProfile(
          id: '1',
          name: '',
          age: 24,
          weightKg: 0.0,
          heightCm: 0.0,
          experienceLevel: '',
          primaryGoal: '',
          weeklyTargetDays: 0,
        );

    final updated = current.copyWith(
      name: name ?? current.name,
      age: age ?? current.age,
      weightKg: weightKg ?? current.weightKg,
      heightCm: heightCm ?? current.heightCm,
      experienceLevel: experienceLevel ?? current.experienceLevel,
      primaryGoal: primaryGoal ?? current.primaryGoal,
      weeklyTargetDays: weeklyTargetDays ?? current.weeklyTargetDays,
      address: address ?? current.address,
      phone: phone ?? current.phone,
      isPhoneVerified: isPhoneVerified ?? current.isPhoneVerified,
      dob: dob ?? current.dob,
      email: email ?? current.email,
      username: username ?? current.username,
    );

    state = AsyncData(updated);
    final userRepo = ref.read(userRepositoryProvider);
    await userRepo.saveUserProfile(updated);
  }

  /// Updates profile info specifically for the Account Details screen.
  Future<void> updateProfileInfo({
    String? name,
    String? address,
    String? phone,
    bool? isPhoneVerified,
    String? dob,
    String? email,
    String? username,
  }) async {
    await updateField(
      name: name,
      address: address,
      phone: phone,
      isPhoneVerified: isPhoneVerified,
      dob: dob,
      email: email,
      username: username,
    );
  }

  /// Verifies the user's phone number and persists state.
  Future<void> verifyPhoneNumber() async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(isPhoneVerified: true);
    state = AsyncData(updated);
    final userRepo = ref.read(userRepositoryProvider);
    await userRepo.saveUserProfile(updated);
  }

  /// Picks a gallery image, copies to documents directory, saves to SQLite, and updates state.
  Future<void> updateProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final extension = p.extension(pickedFile.path);
    final fileName =
        'profile_avatar_${DateTime.now().millisecondsSinceEpoch}$extension';
    final savedImage =
        await File(pickedFile.path).copy(p.join(appDir.path, fileName));

    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(profileImagePath: savedImage.path);
    state = AsyncData(updated);
    final userRepo = ref.read(userRepositoryProvider);
    await userRepo.saveUserProfile(updated);
  }

  /// Compatibility helper for onboarding telemetry setup screen.
  Future<void> saveTelemetry(BodyTelemetry telemetry) async {
    await updateField(
      age: telemetry.age,
      weightKg: telemetry.weight,
      heightCm: telemetry.height,
    );
  }

  /// Compatibility helper for onboarding fitness profile setup screen.
  Future<void> saveFitnessProfile(FitnessProfile profile) async {
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

    await updateField(
      experienceLevel: exp,
      primaryGoal: goal,
      weeklyTargetDays: profile.weeklyFrequency,
    );
  }
}
