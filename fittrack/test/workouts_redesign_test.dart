import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fittrack/presentation/screens/workouts_screen.dart';
import 'package:fittrack/presentation/screens/workout_search_screen.dart';
import 'package:fittrack/presentation/providers/schedules_provider.dart';
import 'package:fittrack/domain/entities/schedule.dart';
import 'package:fittrack/domain/entities/exercise.dart';
import 'package:fittrack/domain/entities/muscle_activation.dart';
import 'package:fittrack/domain/entities/execution_step.dart';
import 'package:fittrack/domain/entities/form_cue.dart';
import 'package:fittrack/domain/repositories/i_schedule_repository.dart';
import 'package:fittrack/domain/repositories/i_exercise_repository.dart';
import 'package:fittrack/presentation/providers/repository_providers.dart';

class _TestScheduleRepository implements IScheduleRepository {
  List<Schedule> schedules = [
    const Schedule(
      id: 'sch1',
      name: 'Push–Pull–Legs Split',
      description: 'High mechanical tension for progressive muscular overload.',
      targetMuscles: ['Chest', 'Shoulders', 'Triceps'],
      assignedWeekdays: [1, 4],
      orderIndex: 1,
      isArchived: false,
      isFavorite: true,
      focus: 'Hypertrophy',
      experience: 'Advanced',
      equipment: 'Full Gym',
      durationWeeks: 8,
      daysPerWeek: 4,
      estimatedMinutes: 50,
      isCustom: false,
    ),
    const Schedule(
      id: 'sch2',
      name: 'Strength Plateau Breaker',
      description: 'Periodized heavy singles and dynamic effort waves.',
      targetMuscles: ['Back', 'Core', 'Quads'],
      assignedWeekdays: [2, 5],
      orderIndex: 2,
      isArchived: false,
      isFavorite: false,
      focus: 'Strength',
      experience: 'Advanced',
      equipment: 'Full Gym',
      durationWeeks: 6,
      daysPerWeek: 3,
      estimatedMinutes: 55,
      isCustom: false,
    ),
    const Schedule(
      id: 'sch3',
      name: 'Arnold Split Classic',
      description: 'Chest & Back agonist/antagonist pairings.',
      targetMuscles: ['Chest', 'Back', 'Shoulders'],
      assignedWeekdays: [3, 6],
      orderIndex: 3,
      isArchived: false,
      isFavorite: true,
      focus: 'Hypertrophy',
      experience: 'Advanced',
      equipment: 'Full Gym',
      durationWeeks: 10,
      daysPerWeek: 6,
      estimatedMinutes: 60,
      isCustom: false,
    ),
    const Schedule(
      id: 'sch4',
      name: 'German Volume Training (GVT)',
      description: '10×10 volume protocol for extreme hypertrophy.',
      targetMuscles: ['Chest', 'Quads', 'Back'],
      assignedWeekdays: [1, 2, 4, 5],
      orderIndex: 4,
      isArchived: false,
      isFavorite: false,
      focus: 'Advanced',
      experience: 'Advanced',
      equipment: 'Full Gym',
      durationWeeks: 6,
      daysPerWeek: 4,
      estimatedMinutes: 40,
      isCustom: false,
    ),
    const Schedule(
      id: 'sch5',
      name: 'Torso & Limb Split',
      description: 'Separates chest/back days from arm and quad isolation.',
      targetMuscles: ['Torso', 'Arms'],
      assignedWeekdays: [1, 2, 4, 5],
      orderIndex: 5,
      isArchived: false,
      isFavorite: false,
      focus: 'Intermediate',
      experience: 'Intermediate',
      equipment: 'Barbell & Cable',
      durationWeeks: 8,
      daysPerWeek: 4,
      estimatedMinutes: 45,
      isCustom: false,
    ),
  ];

  @override
  Future<List<Schedule>> getAllSchedules() async => List.of(schedules);

  @override
  Future<Schedule?> getScheduleById(String id) async {
    final idx = schedules.indexWhere((s) => s.id == id);
    return idx != -1 ? schedules[idx] : null;
  }

  @override
  Future<List<ScheduleExercise>> getScheduleExercises(String scheduleId) async {
    return [
      ScheduleExercise(
        id: '${scheduleId}_ex1',
        scheduleId: scheduleId,
        exerciseId: 'ex1',
        sortOrder: 1,
        targetSets: 4,
        targetReps: 8,
        targetWeightKg: 85.0,
        restDurationSeconds: 120,
      ),
      ScheduleExercise(
        id: '${scheduleId}_ex2',
        scheduleId: scheduleId,
        exerciseId: 'ex2',
        sortOrder: 2,
        targetSets: 3,
        targetReps: 10,
        targetWeightKg: 30.0,
        restDurationSeconds: 90,
      ),
      ScheduleExercise(
        id: '${scheduleId}_ex3',
        scheduleId: scheduleId,
        exerciseId: 'ex3',
        sortOrder: 3,
        targetSets: 3,
        targetReps: 12,
        targetWeightKg: 15.0,
        restDurationSeconds: 60,
      ),
    ];
  }

  @override
  Future<void> saveSchedule(Schedule schedule, List<ScheduleExercise> exercises) async {}

  @override
  Future<void> deleteSchedule(String scheduleId) async {}

  @override
  Future<void> toggleBookmark(String scheduleId, bool isFavorite) async {}

  @override
  Future<List<Schedule>> getBookmarkedSchedules() async =>
      schedules.where((s) => s.isFavorite).toList();

  @override
  Future<List<Schedule>> searchSchedules(String query, {String? category}) async =>
      List.of(schedules);
}

class _TestExerciseRepository implements IExerciseRepository {
  @override
  Future<List<Exercise>> getAllExercises() async => [];

  @override
  Future<Exercise?> getExerciseById(String id) async {
    return Exercise(
      id: id,
      name: switch (id) {
        'ex1' => 'BB Bench Press',
        'ex2' => 'Incline DB Press',
        'ex3' => 'Cable Flyes',
        _ => 'Exercise $id',
      },
      equipment: Equipment.barbell,
      movementClassification: MovementClassification.compound,
    );
  }

  @override
  Future<List<MuscleActivation>> getMuscleActivations(String exerciseId) async => [];

  @override
  Future<List<ExecutionStep>> getExecutionSteps(String exerciseId) async => [];

  @override
  Future<List<FormCue>> getFormCues(String exerciseId) async => [];

  @override
  Future<void> saveExercise(Exercise exercise) async {}

  @override
  Future<void> saveMuscleActivations(String exerciseId, List<MuscleActivation> activations) async {}

  @override
  Future<void> saveExecutionSteps(String exerciseId, List<ExecutionStep> steps) async {}

  @override
  Future<void> saveFormCues(String exerciseId, List<FormCue> cues) async {}
}

Widget _createTestApp({
  required Widget home,
  ThemeData? theme,
}) {
  return ProviderScope(
    overrides: [
      scheduleRepositoryProvider.overrideWithValue(_TestScheduleRepository()),
      exerciseRepositoryProvider.overrideWithValue(_TestExerciseRepository()),
    ],
    child: MaterialApp(
      theme: theme ??
          ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF7C5CFA),
              primary: const Color(0xFF7C5CFA),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF6F4FF),
          ),
      home: home,
    ),
  );
}

Widget _createRouterTestApp({
  required GoRouter router,
}) {
  return ProviderScope(
    overrides: [
      scheduleRepositoryProvider.overrideWithValue(_TestScheduleRepository()),
      exerciseRepositoryProvider.overrideWithValue(_TestExerciseRepository()),
    ],
    child: MaterialApp.router(
      routerConfig: router,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorkoutsScreen Redesign - Visual Elements & Sections', () {
    testWidgets('renders header, title, subtitle, bell, and avatar',
        (tester) async {
      tester.view.physicalSize = const Size(393, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_createTestApp(home: const WorkoutsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Workouts'), findsOneWidget);
      expect(
        find.text('Explore splits, routines & programs'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('renders search bar and filter chips row', (tester) async {
      tester.view.physicalSize = const Size(393, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_createTestApp(home: const WorkoutsScreen()));
      await tester.pumpAndSettle();

      expect(
        find.text('Search splits, goals or equipment...'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
      expect(find.text('All Goals'), findsOneWidget);
      expect(find.text('Hypertrophy'), findsWidgets);
      expect(find.text('Strength Peak'), findsOneWidget);
    });

    testWidgets('renders Trending Programs section with HOT badge and cards',
        (tester) async {
      tester.view.physicalSize = const Size(393, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_createTestApp(home: const WorkoutsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Trending Programs'), findsOneWidget);
      expect(find.text('HOT'), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Posterior Chain & Pull Focus'), findsOneWidget);
      expect(find.text('Start Split'), findsWidgets);
    });

    testWidgets(
        "renders Today's Routine Spotlight with top 3 exercises and stats",
        (tester) async {
      tester.view.physicalSize = const Size(393, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_createTestApp(home: const WorkoutsScreen()));
      await tester.pumpAndSettle();

      expect(find.text("Today's Routine Spotlight"), findsOneWidget);
      expect(find.text('Day 14'), findsOneWidget);
      expect(find.text('TIME'), findsOneWidget);
      expect(find.text('BURN'), findsOneWidget);
      expect(find.text('INTENSITY'), findsOneWidget);
      expect(find.text('DRILL CIRCUIT PREVIEW'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    testWidgets(
        'renders My Saved & Custom section and Browse All Schedules up to 5',
        (tester) async {
      tester.view.physicalSize = const Size(393, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_createTestApp(home: const WorkoutsScreen()));
      await tester.pumpAndSettle();

      // My Saved & Custom
      expect(find.text('My Saved & Custom'), findsOneWidget);
      expect(find.text('New routine'), findsOneWidget);
      expect(find.text('Push Hypertrophy Custom'), findsOneWidget);
      expect(find.text('70% done'), findsOneWidget);

      // Browse All Schedules
      expect(find.text('Browse All Schedules'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is Text && w.data != null && w.data!.contains('Pull'),
        ),
        findsWidgets,
      );
      expect(find.text('View Split'), findsWidgets);
    });

    testWidgets('toggling bookmark reacts in state', (tester) async {
      tester.view.physicalSize = const Size(393, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [
          scheduleRepositoryProvider.overrideWithValue(_TestScheduleRepository()),
          exerciseRepositoryProvider.overrideWithValue(_TestExerciseRepository()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: const WorkoutsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final notifier = container.read(schedulesNotifierProvider.notifier);
      expect(container.read(schedulesNotifierProvider).bookmarkedIds.contains('trend_1'), isTrue);

      // Toggle bookmark via notifier
      notifier.toggleBookmark('trend_1');
      await tester.pumpAndSettle();

      expect(container.read(schedulesNotifierProvider).bookmarkedIds.contains('trend_1'), isFalse);
    });
  });

  group('WorkoutSearchScreen Redesign - Search & Feed', () {
    testWidgets('renders search bar, back button, chips, and results meta',
        (tester) async {
      tester.view.physicalSize = const Size(393, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _createTestApp(home: const WorkoutSearchScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Search Workouts'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.textContaining('Showing '), findsOneWidget);
      expect(find.text('Most Relevant'), findsOneWidget);
    });

    testWidgets(
        'top most relevant result is expanded and remaining results are collapsed',
        (tester) async {
      tester.view.physicalSize = const Size(393, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _createTestApp(home: const WorkoutSearchScreen()),
      );
      await tester.pumpAndSettle();

      // Top result is expanded
      expect(find.text('98% MATCH'), findsOneWidget);
      expect(find.text('FEATURED'), findsOneWidget);
      expect(find.text('View Program & Schedule'), findsOneWidget);
      expect(find.text('Cadence'), findsOneWidget);
      expect(find.text('Duration'), findsWidgets);

      // Collapsed lower items have Preview Split
      expect(find.text('Preview Split'), findsWidgets);
    });

    testWidgets('tapping collapse/expand toggles item expansion state',
        (tester) async {
      tester.view.physicalSize = const Size(393, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [
          scheduleRepositoryProvider.overrideWithValue(_TestScheduleRepository()),
          exerciseRepositoryProvider.overrideWithValue(_TestExerciseRepository()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: WorkoutSearchScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final notifier = container.read(schedulesNotifierProvider.notifier);

      // Initially top item 'sch1' is expanded
      expect(notifier.isExpanded('sch1'), isTrue);

      // Toggle top item
      notifier.toggleExpand('sch1');
      await tester.pumpAndSettle();
      expect(notifier.isExpanded('sch1'), isFalse);

      // Toggle expand all
      notifier.toggleExpandAll();
      await tester.pumpAndSettle();
      expect(notifier.isExpanded('sch1'), isTrue);
    });

    testWidgets('typing search query filters live results', (tester) async {
      tester.view.physicalSize = const Size(393, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _createTestApp(home: const WorkoutSearchScreen()),
      );
      await tester.pumpAndSettle();

      final inputFinder = find.byType(TextField);
      expect(inputFinder, findsOneWidget);

      await tester.enterText(inputFinder, 'Texas');
      await tester.pumpAndSettle();

      expect(find.text('Texas Method 3-Day'), findsOneWidget);
      expect(find.text('Push-Pull-Legs Split'), findsNothing);
    });

    testWidgets('shows empty state when no workouts match query',
        (tester) async {
      tester.view.physicalSize = const Size(393, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _createTestApp(home: const WorkoutSearchScreen()),
      );
      await tester.pumpAndSettle();

      final inputFinder = find.byType(TextField);
      await tester.enterText(inputFinder, 'xyz123nonexistentroutine');
      await tester.pumpAndSettle();

      expect(find.text('No workout splits match your criteria'), findsOneWidget);
    });
  });

  group('Navigation Bindings', () {
    testWidgets('tapping search bar navigates to /workouts/search',
        (tester) async {
      tester.view.physicalSize = const Size(393, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = GoRouter(
        initialLocation: '/workouts',
        routes: [
          GoRoute(
            path: '/workouts',
            builder: (context, state) => const WorkoutsScreen(),
            routes: [
              GoRoute(
                path: 'search',
                builder: (context, state) => const WorkoutSearchScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/workouts/detail/:id',
            builder: (context, state) => const Scaffold(body: Text('Detail Screen')),
          ),
          GoRoute(
            path: '/workouts/active/:id',
            builder: (context, state) => const Scaffold(body: Text('Active Workout Screen')),
          ),
          GoRoute(
            path: '/workouts/create-schedule',
            builder: (context, state) =>
                const Scaffold(body: Text('Create Schedule Screen')),
          ),
          GoRoute(
            path: '/settings/profile',
            builder: (context, state) => const Scaffold(body: Text('Profile Screen')),
          ),
        ],
      );

      await tester.pumpWidget(_createRouterTestApp(router: router));
      await tester.pumpAndSettle();

      // Tap search placeholder
      final searchFieldFinder =
          find.text('Search splits, goals or equipment...');
      expect(searchFieldFinder, findsOneWidget);

      await tester.tap(searchFieldFinder);
      await tester.pumpAndSettle();

      // Arrived at Search Workouts
      expect(find.text('Search Workouts'), findsOneWidget);

      // Tap back button
      final backButton = find.byIcon(Icons.arrow_back_rounded);
      expect(backButton, findsOneWidget);

      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Back on Workouts library
      expect(find.text('Workouts'), findsOneWidget);
    });
  });

  group('Theme Adaptability - Dark Theme', () {
    testWidgets('renders WorkoutsScreen cleanly in Dark Theme',
        (tester) async {
      tester.view.physicalSize = const Size(393, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final darkTheme = ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C5CFA),
          primary: const Color(0xFF7C5CFA),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0C0A18),
      );

      await tester.pumpWidget(
        _createTestApp(
          home: const WorkoutsScreen(),
          theme: darkTheme,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Workouts'), findsOneWidget);
    });

    testWidgets('renders WorkoutSearchScreen cleanly in Dark Theme',
        (tester) async {
      tester.view.physicalSize = const Size(393, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final darkTheme = ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C5CFA),
          primary: const Color(0xFF7C5CFA),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0C0A18),
      );

      await tester.pumpWidget(
        _createTestApp(
          home: const WorkoutSearchScreen(),
          theme: darkTheme,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Search Workouts'), findsOneWidget);
    });
  });
}
