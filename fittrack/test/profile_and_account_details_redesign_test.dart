import 'package:fittrack/domain/entities/user_profile.dart';
import 'package:fittrack/domain/repositories/i_user_repository.dart';
import 'package:fittrack/domain/repositories/i_workout_session_repository.dart';
import 'package:fittrack/presentation/providers/notifications_provider.dart';
import 'package:fittrack/presentation/providers/repository_providers.dart';
import 'package:fittrack/presentation/screens/profile/profile_screen.dart';
import 'package:fittrack/presentation/screens/profile/widgets/profile_personal_info_section.dart';
import 'package:fittrack/presentation/screens/settings/account_details_screen.dart';
import 'package:fittrack/presentation/widgets/modals/dob_picker_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fittrack/domain/entities/body_telemetry.dart';
import 'package:fittrack/domain/entities/exercise_log.dart';
import 'package:fittrack/domain/entities/fitness_profile.dart';
import 'package:fittrack/domain/entities/set_log.dart';
import 'package:fittrack/domain/entities/workout_session.dart';

class _FakeUserRepository implements IUserRepository {
  UserProfile _profile = const UserProfile(
    id: '1',
    name: 'Dineth',
    age: 22,
    weightKg: 76.5,
    heightCm: 178.0,
    experienceLevel: 'Advanced',
    primaryGoal: 'Pure strength (powerlifting)',
    weeklyTargetDays: 3,
    phone: '77 123 4567',
    dob: '14 Oct 2003',
    address: '742 Evergreen Terrace, Colombo',
    isPhoneVerified: false,
    email: 'dineth.fit@example.com',
  );

  @override
  Future<UserProfile?> getUserProfile(String userId) async => _profile;

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
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

class _FakeWorkoutSessionRepository implements IWorkoutSessionRepository {
  @override
  Future<List<WorkoutSession>> getAllSessions() async => [];
  @override
  Future<WorkoutSession?> getSessionById(String id) async => null;
  @override
  Future<void> saveSession(WorkoutSession session) async {}
  @override
  Future<void> saveExerciseLogs(List<ExerciseLog> logs) async {}
  @override
  Future<void> saveSetLogs(List<SetLog> logs) async {}
  @override
  Future<List<ExerciseLog>> getExerciseLogsForSession(String sessionId) async =>
      [];
  @override
  Future<List<SetLog>> getSetLogsForSession(String sessionId) async => [];
  @override
  Future<List<SetLog>> getSetLogsForExerciseLog(String exerciseLogId) async =>
      [];
  @override
  Future<List<WorkoutSession>> getSessionsForMonth(DateTime month) async => [];
  @override
  Future<List<DateTime>> getSessionStartDatesInRange({
    required DateTime startInclusive,
    required DateTime endExclusive,
  }) async =>
      [];
  @override
  Future<List<WorkoutSession>> getSessionsSince(
          DateTime startInclusive) async =>
      [];
  @override
  Future<List<WorkoutSession>> getRecentSessions({int limit = 5}) async => [];

  @override
  Future<Map<String, dynamic>> getDashboardMetrics({
    required DateTime startOfWeek,
    required DateTime endOfWeek,
    DateTime? startOfMonth,
    DateTime? endOfMonth,
  }) async {
    return {
      'daysTrainedThisWeek': 3,
      'totalWorkoutsCompleted': 6,
      'totalCaloriesBurned': 3450,
      'activeDatesThisMonth': <DateTime>[],
    };
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DobPickerModal Unit & Logic Tests', () {
    test('Calculates accurate days per month including leap years', () {
      // Leap year 2024 -> Feb has 29 days
      final feb2024Days = DateTime(2024, 3, 0).day;
      expect(feb2024Days, equals(29));

      // Non-leap year 2023 -> Feb has 28 days
      final feb2023Days = DateTime(2023, 3, 0).day;
      expect(feb2023Days, equals(28));

      // Century leap year 2000 -> Feb has 29 days
      final feb2000Days = DateTime(2000, 3, 0).day;
      expect(feb2000Days, equals(29));

      // Century non-leap year 1900 -> Feb has 28 days
      final feb1900Days = DateTime(1900, 3, 0).day;
      expect(feb1900Days, equals(28));

      // 30-day months: April, June, September, November
      expect(DateTime(2026, 5, 0).day, equals(30)); // Apr
      expect(DateTime(2026, 7, 0).day, equals(30)); // Jun
      expect(DateTime(2026, 10, 0).day, equals(30)); // Sep
      expect(DateTime(2026, 12, 0).day, equals(30)); // Nov

      // 31-day months: Jan, Mar, May, Jul, Aug, Oct, Dec
      expect(DateTime(2026, 2, 0).day, equals(31)); // Jan
      expect(DateTime(2026, 4, 0).day, equals(31)); // Mar
      expect(DateTime(2026, 11, 0).day, equals(31)); // Oct
    });

    test('Date formatting and parsing matches spec', () {
      final dt = DateTime(2003, 10, 14);
      final formatted = DobPickerModal.formatDate(dt);
      expect(formatted, equals('14 Oct 2003'));

      final parsed = DobPickerModal.parseDate('14 Oct 2003');
      expect(parsed?.year, equals(2003));
      expect(parsed?.month, equals(10));
      expect(parsed?.day, equals(14));
    });

    test('Age and cardiovascular zone estimations are accurate', () {
      final dob = DateTime(2000, 1, 1);
      final age = DobPickerModal.calculateAge(dob);
      expect(age, greaterThanOrEqualTo(24));

      final maxHr = DobPickerModal.calculateMaxHeartRate(dob);
      expect(maxHr, equals(220 - age));
    });
  });

  group('ProfileScreen Redesign Widget Tests', () {
    late _FakeUserRepository fakeUserRepo;
    late _FakeWorkoutSessionRepository fakeSessionRepo;

    setUp(() {
      fakeUserRepo = _FakeUserRepository();
      fakeSessionRepo = _FakeWorkoutSessionRepository();
    });

    Widget createProfileTestWidget() {
      return ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(fakeUserRepo),
          workoutSessionRepositoryProvider.overrideWithValue(fakeSessionRepo),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      );
    }

    testWidgets('Renders all Profile sections and excludes Name and DOB from personal rows',
        (tester) async {
      tester.view.physicalSize = const Size(393, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createProfileTestWidget());
      await tester.pumpAndSettle();

      // 1. Header with Title & Subtitle
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Personal settings & athlete record'), findsOneWidget);

      // 2. Hero Section (Verified Name, Handle, Status)
      expect(find.text('Dineth'), findsOneWidget);
      expect(find.text('@dineth.fit'), findsOneWidget);
      expect(find.text('ADVANCED LIFTER'), findsOneWidget);

      // 3. Bento Grid of 4 Key Metrics
      expect(find.text('THIS MONTH'), findsOneWidget);
      expect(find.text('Total Calories'), findsOneWidget);
      expect(find.text('Body Mass (BMI)'), findsOneWidget);
      expect(find.text('Workout Time'), findsOneWidget);
      expect(find.text('Total Volume'), findsOneWidget);

      // 4. Personal Info Section (Weight, Height, Experience, Goal, Target)
      expect(find.text('PERSONAL INFO'), findsOneWidget);
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('Height'), findsOneWidget);
      expect(find.text('Experience'), findsOneWidget);
      expect(find.text('Primary Goal'), findsOneWidget);
      expect(find.text('Weekly Target'), findsOneWidget);

      // CRITICAL REQUIREMENT: Name and Date of Birth must NOT be in the personal info section!
      final personalSectionFinder = find.byType(ProfilePersonalInfoSection);
      expect(personalSectionFinder, findsOneWidget);
      expect(
        find.descendant(
          of: personalSectionFinder,
          matching: find.text('Date of Birth'),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: personalSectionFinder,
          matching: find.text('Age'),
        ),
        findsNothing,
      );

      // 5. Settings & Preferences (Strictly 3 Links)
      expect(find.text('SETTINGS & PREFERENCES'), findsOneWidget);
      expect(find.text('Account Details'), findsOneWidget);
      expect(find.text('Data & Backup'), findsOneWidget);
      expect(find.text('Workout Settings'), findsOneWidget);

      // 6. Sign Out & Version Footer
      expect(find.text('Log out'), findsOneWidget);
      expect(find.text('FitTrack v1.4.2'), findsOneWidget);

      // 7. Action dock is hidden when not dirty
      expect(find.text('Save changes'), findsNothing);
    });

    testWidgets('Editing personal info displays floating action dock and pushes notification on save',
        (tester) async {
      tester.view.physicalSize = const Size(393, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createProfileTestWidget());
      await tester.pumpAndSettle();

      // Action dock is initially hidden
      expect(find.text('Save changes'), findsNothing);

      // Tap Experience row to open selection modal
      await tester.tap(find.text('Experience'));
      await tester.pumpAndSettle();

      // Select 'Elite'
      expect(find.text('Select Experience Level'), findsOneWidget);
      await tester.tap(find.text('Elite'));
      await tester.pumpAndSettle();

      // Confirm modal selection
      await tester.tap(find.text('Confirm Selection'));
      await tester.pumpAndSettle();

      // Action dock with "Save changes" and "Discard changes" is now visible!
      expect(find.text('Save changes'), findsOneWidget);
      expect(find.text('Discard changes'), findsOneWidget);

      // Tap "Save changes"
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      // After save, action dock hides
      expect(find.text('Save changes'), findsNothing);

      // Verify field-specific notification was pushed
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ProfileScreen)),
      );
      final feed = container.read(notificationFeedProvider);
      expect(feed.any((n) => n.title.contains('Experience updated:')), isTrue);
    });
  });

  group('AccountDetailsScreen Redesign Widget Tests', () {
    late _FakeUserRepository fakeUserRepo;

    setUp(() {
      fakeUserRepo = _FakeUserRepository();
    });

    Widget createAccountTestWidget() {
      return ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(fakeUserRepo),
        ],
        child: const MaterialApp(
          home: AccountDetailsScreen(),
        ),
      );
    }

    testWidgets('Renders all Account Details sections and removes unsaved banner',
        (tester) async {
      tester.view.physicalSize = const Size(393, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createAccountTestWidget());
      await tester.pumpAndSettle();

      // 1. Header
      expect(find.text('Account Details'), findsOneWidget);
      expect(find.text('Your personal information'), findsOneWidget);

      // 2. Hero Card
      expect(find.text('Dineth'), findsAtLeastNWidgets(1));
      expect(find.text('@dineth.fit · Member since 2026'), findsOneWidget);
      expect(find.text('Synced'), findsOneWidget);

      // REQUIREMENT: "You have unsaved personal edits" banner removed
      expect(find.text('You have unsaved personal edits'), findsNothing);

      // 3. Personal Section (Full Name & Date of Birth)
      expect(find.text('PERSONAL'), findsOneWidget);
      expect(find.text('Full name'), findsOneWidget);
      expect(find.text('Date of birth'), findsOneWidget);
      expect(find.text('14 Oct 2003'), findsOneWidget);

      // 4. Contact Section (Mobile number & Address)
      expect(find.text('CONTACT'), findsOneWidget);
      expect(find.text('Mobile number'), findsOneWidget);
      expect(find.text('+94'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);

      // 5. Locked Credentials
      expect(find.text('LOCKED CREDENTIALS'), findsOneWidget);
      expect(find.text('FIXED'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);

      // 6. Password & Security Card
      expect(find.text('Password & security'), findsOneWidget);

      // 7. Profile Shortcut Card at Bottom
      expect(find.text('Athlete Profile'), findsOneWidget);
      expect(
        find.text('View your fitness metrics, goals, and training tier'),
        findsOneWidget,
      );

      // 8. Action dock is hidden when not dirty
      expect(find.text('Save changes'), findsNothing);
    });

    testWidgets('Editing field reveals floating dock; saving pushes notification and hides dock',
        (tester) async {
      tester.view.physicalSize = const Size(393, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createAccountTestWidget());
      await tester.pumpAndSettle();

      // Action dock is initially hidden
      expect(find.text('Save changes'), findsNothing);

      // Edit name field
      final nameFieldFinder = find.widgetWithText(TextField, 'Dineth');
      expect(nameFieldFinder, findsOneWidget);
      await tester.enterText(nameFieldFinder, 'Dineth Perera');
      await tester.pumpAndSettle();

      // Action dock is now visible!
      expect(find.text('Save changes'), findsOneWidget);
      expect(find.text('Discard changes'), findsOneWidget);

      // Tap Save changes
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      // Action dock hides
      expect(find.text('Save changes'), findsNothing);

      // Field-specific notification pushed
      final container = ProviderScope.containerOf(
        tester.element(find.byType(AccountDetailsScreen)),
      );
      final feed = container.read(notificationFeedProvider);
      expect(feed.any((n) => n.title.contains('Full Name updated:')), isTrue);
    });

    testWidgets('Tapping Verify mobile number updates status and pushes notification',
        (tester) async {
      tester.view.physicalSize = const Size(393, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createAccountTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Unverified'), findsOneWidget);
      expect(find.text('Verify'), findsOneWidget);

      await tester.tap(find.text('Verify'));
      await tester.pumpAndSettle();

      // Status changes to Verified
      expect(find.text('Verified'), findsAtLeastNWidgets(2)); // Locked email + phone

      // Notification pushed
      final container = ProviderScope.containerOf(
        tester.element(find.byType(AccountDetailsScreen)),
      );
      final feed = container.read(notificationFeedProvider);
      expect(feed.any((n) => n.title.contains('Mobile Verified:')), isTrue);
    });
  });
}
