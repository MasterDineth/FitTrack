import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fittrack/presentation/screens/telemetry_setup_screen.dart';
import 'package:fittrack/domain/entities/user_profile.dart';
import 'package:fittrack/domain/repositories/i_user_repository.dart';
import 'package:fittrack/domain/entities/body_telemetry.dart';
import 'package:fittrack/domain/entities/fitness_profile.dart';
import 'package:fittrack/presentation/providers/repository_providers.dart';

class _FakeUserRepository implements IUserRepository {
  _FakeUserRepository({this.shouldThrowOnSave = false});

  final bool shouldThrowOnSave;
  UserProfile? _profile = const UserProfile(
    id: '1',
    name: 'Dineth',
    age: 24,
    weightKg: 0.0,
    heightCm: 0.0,
    experienceLevel: '',
    primaryGoal: '',
    weeklyTargetDays: 0,
  );

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    return _profile;
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    if (shouldThrowOnSave) {
      throw Exception('Database write failure');
    }
    _profile = profile;
  }

  @override
  Future<void> saveBodyTelemetry(BodyTelemetry telemetry) async {}

  @override
  Future<BodyTelemetry?> getBodyTelemetry(String userId) async => null;

  @override
  Future<void> saveFitnessProfile(FitnessProfile profile) async {}

  @override
  Future<FitnessProfile?> getFitnessProfile(String userId) async => null;
}

void main() {
  testWidgets('TelemetrySetupScreen Continue button saves and navigates to fitness profile', (tester) async {
    final fakeRepo = _FakeUserRepository();
    String? navigatedRoute;

    final router = GoRouter(
      initialLocation: '/onboarding/telemetry',
      routes: [
        GoRoute(
          path: '/onboarding/telemetry',
          builder: (context, state) => const TelemetrySetupScreen(),
        ),
        GoRoute(
          path: '/onboarding/fitness',
          builder: (context, state) {
            navigatedRoute = '/onboarding/fitness';
            return const Scaffold(body: Text('Fitness Screen'));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Tell us about yourself'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    // Tap Continue
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(navigatedRoute, equals('/onboarding/fitness'));
  });

  testWidgets('TelemetrySetupScreen Back button does not crash when cannot pop and goes to /welcome', (tester) async {
    final fakeRepo = _FakeUserRepository();
    String? navigatedRoute;

    final router = GoRouter(
      initialLocation: '/onboarding/telemetry',
      routes: [
        GoRoute(
          path: '/onboarding/telemetry',
          builder: (context, state) => const TelemetrySetupScreen(),
        ),
        GoRoute(
          path: '/welcome',
          builder: (context, state) {
            navigatedRoute = '/welcome';
            return const Scaffold(body: Text('Welcome Screen'));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap bottom Back button
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(navigatedRoute, equals('/welcome'));
  });

  testWidgets('TelemetrySetupScreen handles database error without getting permanently stuck', (tester) async {
    final fakeRepo = _FakeUserRepository(shouldThrowOnSave: true);

    final router = GoRouter(
      initialLocation: '/onboarding/telemetry',
      routes: [
        GoRoute(
          path: '/onboarding/telemetry',
          builder: (context, state) => const TelemetrySetupScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap Continue
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Verify error SnackBar is shown and button is NOT permanently stuck in loading
    expect(find.textContaining('Failed to save profile'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget); // Label is restored, not stuck loading
  });
}
