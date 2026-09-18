import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/domain/entities/user_profile.dart';

void main() {
  group('UserProfile.isComplete Tests', () {
    test('Initial uncompleted profile has isComplete == false', () {
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
      expect(initialProfile.isComplete, isFalse);
    });

    test('Profile with only name entered (after Auth) has isComplete == false', () {
      const authProfile = UserProfile(
        id: '1',
        name: 'Alex',
        age: 24,
        weightKg: 0.0,
        heightCm: 0.0,
        experienceLevel: '',
        primaryGoal: '',
        weeklyTargetDays: 0,
      );
      expect(authProfile.isComplete, isFalse);
    });

    test('Profile after Telemetry setup (weight and height set) still has isComplete == false', () {
      const telemetryProfile = UserProfile(
        id: '1',
        name: 'Alex',
        age: 25,
        weightKg: 78.5,
        heightCm: 180.0,
        experienceLevel: '',
        primaryGoal: '',
        weeklyTargetDays: 0,
      );
      // Ensures the user is NOT prematurely redirected to dashboard before Step 4 (Fitness Profile)
      expect(telemetryProfile.isComplete, isFalse);
    });

    test('Profile after both Telemetry and Fitness Profile setup has isComplete == true', () {
      const fullProfile = UserProfile(
        id: '1',
        name: 'Alex',
        age: 25,
        weightKg: 78.5,
        heightCm: 180.0,
        experienceLevel: 'Intermediate',
        primaryGoal: 'Hypertrophy & Strength',
        weeklyTargetDays: 4,
      );
      expect(fullProfile.isComplete, isTrue);
    });
  });

  group('Safe BMI calculation tests', () {
    test('BMI calculation with zero height or weight returns 0.0 without divide-by-zero errors', () {
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
      expect(initialProfile.calculateBMI, equals(0.0));
      expect(initialProfile.getBMICategory, equals('UNDERWEIGHT'));
    });

    test('Valid height and weight calculates correct BMI', () {
      const profile = UserProfile(
        id: '1',
        name: 'Alex',
        age: 24,
        weightKg: 80.0,
        heightCm: 200.0, // 2.0m -> BMI = 80 / (2*2) = 20.0
        experienceLevel: 'Beginner',
        primaryGoal: 'Hypertrophy',
        weeklyTargetDays: 3,
      );
      expect(profile.calculateBMI, closeTo(20.0, 0.01));
      expect(profile.getBMICategory, equals('NORMAL'));
    });
  });

  group('Router Redirect Logic Tests', () {
    String? computeRedirect({
      required bool isAuthLoading,
      required bool isAuthenticated,
      required bool profileComplete,
      required String matchedLocation,
    }) {
      final isSplash = matchedLocation == '/splash';
      final isWelcome = matchedLocation == '/welcome';
      final isAuth = matchedLocation == '/auth';
      final isReset = matchedLocation.startsWith('/reset');

      if (isAuthLoading) return null;

      if (!isAuthenticated) {
        if (isWelcome || isAuth || isReset) return null;
        return '/welcome';
      }

      final isTelemetry = matchedLocation == '/onboarding/telemetry';
      final isFitness = matchedLocation == '/onboarding/fitness';

      if (!profileComplete) {
        if (isTelemetry || isFitness) return null;
        return '/onboarding/telemetry';
      }

      if (isSplash || isWelcome || isAuth || isReset || isTelemetry || isFitness) {
        return '/dashboard';
      }

      return null;
    }

    test('Fresh install: unauthenticated splash redirects to welcome', () {
      final result = computeRedirect(
        isAuthLoading: false,
        isAuthenticated: false,
        profileComplete: false,
        matchedLocation: '/splash',
      );
      expect(result, equals('/welcome'));
    });

    test('Fresh install: unauthenticated welcome or auth stays on page', () {
      expect(
        computeRedirect(
          isAuthLoading: false,
          isAuthenticated: false,
          profileComplete: false,
          matchedLocation: '/welcome',
        ),
        isNull,
      );
      expect(
        computeRedirect(
          isAuthLoading: false,
          isAuthenticated: false,
          profileComplete: false,
          matchedLocation: '/auth',
        ),
        isNull,
      );
    });

    test('Fresh install: user logs in/signs up on auth screen -> redirects to telemetry (Step 3)', () {
      final result = computeRedirect(
        isAuthLoading: false,
        isAuthenticated: true,
        profileComplete: false, // Not yet complete
        matchedLocation: '/auth',
      );
      expect(result, equals('/onboarding/telemetry'));
    });

    test('Onboarding in progress: user on telemetry screen stays on telemetry screen', () {
      final result = computeRedirect(
        isAuthLoading: false,
        isAuthenticated: true,
        profileComplete: false,
        matchedLocation: '/onboarding/telemetry',
      );
      expect(result, isNull);
    });

    test('Onboarding in progress: user navigates to fitness profile screen stays on fitness screen', () {
      final result = computeRedirect(
        isAuthLoading: false,
        isAuthenticated: true,
        profileComplete: false,
        matchedLocation: '/onboarding/fitness',
      );
      expect(result, isNull);
    });

    test('Onboarding completed: user completing fitness profile redirects to dashboard', () {
      final result = computeRedirect(
        isAuthLoading: false,
        isAuthenticated: true,
        profileComplete: true, // Now complete!
        matchedLocation: '/onboarding/fitness',
      );
      expect(result, equals('/dashboard'));
    });

    test('Future launches: authenticated user with completed profile on splash redirects to dashboard', () {
      final result = computeRedirect(
        isAuthLoading: false,
        isAuthenticated: true,
        profileComplete: true,
        matchedLocation: '/splash',
      );
      expect(result, equals('/dashboard'));
    });
  });
}
