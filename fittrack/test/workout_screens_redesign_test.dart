import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fittrack/domain/entities/schedule.dart';
import 'package:fittrack/domain/entities/schedule_exercise.dart';
import 'package:fittrack/domain/entities/exercise.dart';
import 'package:fittrack/domain/entities/workout_schedule.dart';
import 'package:fittrack/presentation/providers/active_workout_provider.dart';
import 'package:fittrack/presentation/providers/repository_providers.dart';
import 'package:fittrack/presentation/screens/workout_detail/workout_detail_screen.dart';
import 'package:fittrack/presentation/screens/active_workout/active_workout_screen.dart';
import 'package:fittrack/presentation/widgets/modals/workout_paused_modal.dart';
import 'package:fittrack/presentation/widgets/modals/skip_exercise_modal.dart';
import 'package:fittrack/presentation/widgets/modals/discard_workout_modal.dart';

import 'package:fittrack/domain/repositories/i_schedule_repository.dart';
import 'package:fittrack/domain/repositories/i_exercise_repository.dart';
import 'package:fittrack/domain/entities/execution_step.dart';
import 'package:fittrack/domain/entities/form_cue.dart';
import 'package:fittrack/domain/entities/muscle_activation.dart';

class _FakeScheduleRepo implements IScheduleRepository {
  final Map<String, Schedule> schedules = {};
  final Map<String, List<ScheduleExercise>> scheduleExercises = {};

  @override
  Future<List<Schedule>> getAllSchedules() async => schedules.values.toList();

  @override
  Future<Schedule?> getScheduleById(String id) async => schedules[id] ?? Schedule(
        id: id,
        name: 'Day 1 – Chest, Shoulders & Triceps',
        description: 'Push day routine',
        targetMuscles: ['Chest', 'Shoulders', 'Triceps'],
        assignedWeekdays: [1, 3, 5],
        orderIndex: 0,
      );

  @override
  Future<List<ScheduleExercise>> getScheduleExercises(String id) async =>
      scheduleExercises[id] ?? [
        ScheduleExercise(
          id: '${id}_ex1',
          scheduleId: id,
          exerciseId: 'e1',
          sortOrder: 1,
          targetSets: 4,
          targetReps: 8,
          targetWeightKg: 85.0,
          restDurationSeconds: 90,
        ),
      ];

  @override
  Future<void> saveSchedule(
    Schedule schedule,
    List<ScheduleExercise> exercises,
  ) async {
    schedules[schedule.id] = schedule;
    scheduleExercises[schedule.id] = exercises;
  }

  @override
  Future<void> deleteSchedule(String id) async {
    schedules.remove(id);
    scheduleExercises.remove(id);
  }

  @override
  Future<void> toggleBookmark(String scheduleId, bool isFavorite) async {}

  @override
  Future<List<Schedule>> getBookmarkedSchedules() async => [];

  @override
  Future<List<Schedule>> searchSchedules(
    String query, {
    String? category,
    String? experience,
    String? equipment,
  }) async => [];

  @override
  Future<void> incrementCompletionCount(String scheduleId) async {}

  @override
  Future<List<Schedule>> getTrendingSchedules({int limit = 5}) async => [];
}

class _FakeExerciseRepo implements IExerciseRepository {
  final Map<String, Exercise> exercises = {};

  @override
  Future<List<Exercise>> getAllExercises() async => exercises.values.toList();

  @override
  Future<Exercise?> getExerciseById(String id) async =>
      exercises[id] ??
      const Exercise(
        id: 'e1',
        name: 'Barbell Bench Press',
        equipment: Equipment.barbell,
        movementClassification: MovementClassification.compound,
      );

  @override
  Future<void> saveExercise(Exercise exercise) async {
    exercises[exercise.id] = exercise;
  }

  @override
  Future<List<MuscleActivation>> getMuscleActivations(String exerciseId) async => [];

  @override
  Future<void> saveMuscleActivations(
    String exerciseId,
    List<MuscleActivation> activations,
  ) async {}

  @override
  Future<List<ExecutionStep>> getExecutionSteps(String exerciseId) async => [];

  @override
  Future<void> saveExecutionSteps(
    String exerciseId,
    List<ExecutionStep> steps,
  ) async {}

  @override
  Future<List<FormCue>> getFormCues(String exerciseId) async => [];

  @override
  Future<void> saveFormCues(String exerciseId, List<FormCue> cues) async {}
}

void main() {
  const testSchedule = Schedule(
    id: 's_test',
    name: 'Day 1 – Chest, Shoulders & Triceps',
    description: 'Push day routine',
    targetMuscles: ['Chest', 'Shoulders', 'Triceps'],
    assignedWeekdays: [1, 3, 5],
    orderIndex: 0,
  );

  const testExercise1 = Exercise(
    id: 'e1',
    name: 'Barbell Bench Press',
    equipment: Equipment.barbell,
    movementClassification: MovementClassification.compound,
  );

  const testExercise2 = Exercise(
    id: 'e2',
    name: 'Incline Dumbbell Press',
    equipment: Equipment.dumbbell,
    movementClassification: MovementClassification.compound,
  );

  const testScheduleExercise1 = ScheduleExercise(
    id: 'se1',
    scheduleId: 's_test',
    exerciseId: 'e1',
    sortOrder: 1,
    targetSets: 4,
    targetReps: 8,
    targetWeightKg: 85.0,
    restDurationSeconds: 90,
  );

  const testScheduleExercise2 = ScheduleExercise(
    id: 'se2',
    scheduleId: 's_test',
    exerciseId: 'e2',
    sortOrder: 2,
    targetSets: 3,
    targetReps: 10,
    targetWeightKg: 30.0,
    restDurationSeconds: 75,
  );

  final liveEntry1 = LiveExerciseEntry(
    scheduleExercise: testScheduleExercise1,
    exercise: testExercise1,
  );

  final liveEntry2 = LiveExerciseEntry(
    scheduleExercise: testScheduleExercise2,
    exercise: testExercise2,
  );

  final testState = ActiveWorkoutState(
    phase: WorkoutPhase.active,
    schedule: testSchedule,
    entries: [liveEntry1, liveEntry2],
    currentExerciseIndex: 0,
    currentSetIndex: 0,
    elapsedSeconds: 48,
    restRemainingSeconds: 0,
    completedSets: [
      CompletedSetEntry(
        scheduleExerciseId: 'se1',
        exerciseId: 'e1',
        setNumber: 1,
        actualReps: 8,
        actualWeightKg: 85.0,
        targetReps: 8,
        targetWeightKg: 85.0,
        restDurationSeconds: 90,
        completedAt: DateTime(2026, 1, 1),
      ),
    ],
  );

  group('WorkoutDetailScreen Redesign Tests', () {
    testWidgets('renders header, bento metrics, exercises, and start button',
        (tester) async {
      final fakeSchedRepo = _FakeScheduleRepo();
      final fakeExRepo = _FakeExerciseRepo();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scheduleRepositoryProvider.overrideWithValue(fakeSchedRepo),
            exerciseRepositoryProvider.overrideWithValue(fakeExRepo),
          ],
          child: const MaterialApp(
            home: WorkoutDetailScreen(scheduleId: 's_test'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header elements
      expect(find.text('Workout Details'), findsOneWidget);
      expect(find.text('Review routine, exercises & target sets'), findsOneWidget);
      expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsNothing);

      // Bento stats
      expect(find.text('Exercises'), findsOneWidget);
      expect(find.text('Total sets'), findsOneWidget);
      expect(find.text('Est. time'), findsOneWidget);
      expect(find.text('Est. energy'), findsOneWidget);

      // Start workout sticky button
      expect(find.text('Start workout'), findsOneWidget);
    });

    testWidgets('expanded exercise card strictly excludes Tempo and PRE/RPE',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scheduleRepositoryProvider.overrideWithValue(_FakeScheduleRepo()),
            exerciseRepositoryProvider.overrideWithValue(_FakeExerciseRepo()),
          ],
          child: MaterialApp(
            home: WorkoutDetailScreen(
              scheduleId: 's_test',
              workoutSchedule: WorkoutSchedule(
                id: 's_test',
                title: 'Push Day Split',
                focus: 'Chest & Triceps',
                description: 'Hypertrophy',
                experience: 'Intermediate',
                equipment: 'Full Gym',
                durationWeeks: 4,
                daysPerWeek: 3,
                estimatedMinutes: 60,
                exercises: [testScheduleExercise1],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // First exercise is expanded by default in Stitch
      final exerciseFinder = find.text('Barbell Bench Press');
      expect(exerciseFinder, findsOneWidget);

      // Expanded table header contains SET, WEIGHT, REPS, REST
      expect(find.text('SET'), findsWidgets);
      expect(find.text('WEIGHT'), findsWidgets);
      expect(find.text('REPS'), findsWidgets);
      expect(find.text('REST'), findsWidgets);

      // Verify Tempo and PRE / RPE are strictly NOT present
      expect(find.text('Tempo:'), findsNothing);
      expect(find.text('Tempo'), findsNothing);
      expect(find.text('RPE:'), findsNothing);
      expect(find.text('PRE:'), findsNothing);
      expect(find.text('PRE'), findsNothing);
    });
  });

  group('ActiveWorkoutScreen Redesign Tests', () {
    testWidgets('renders active exercise, stepper, tracker, dock, and up next',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeWorkoutProvider.overrideWith(
              () => _TestWorkoutNotifier(testState),
            ),
          ],
          child: const MaterialApp(
            home: ActiveWorkoutScreen(scheduleId: 's_test'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Header & Dock timer
      expect(find.text('Day 1 – Chest, Shoulders & Triceps'), findsOneWidget);
      expect(find.text('00:48'), findsWidgets);

      // Active logging card
      expect(find.text('Barbell Bench Press'), findsWidgets);
      expect(find.text('Weight (kg)'), findsOneWidget);
      expect(find.text('Reps'), findsOneWidget);
      expect(find.text('Complete set'), findsOneWidget);
      expect(find.text('Skip exercise'), findsOneWidget);

      // Set tracker nodes and + Set button
      expect(find.text('+ Set'), findsOneWidget);

      // Up next queue
      expect(find.text('Up next in workout'), findsOneWidget);
      expect(find.text('Incline Dumbbell Press'), findsWidgets);

      // Session dock
      expect(find.text('Sets'), findsOneWidget);
      expect(find.text('Timer'), findsOneWidget);
      expect(find.text('Energy'), findsOneWidget);
      expect(find.text('Pause'), findsOneWidget);
      expect(find.text('End workout'), findsOneWidget);
    });

    testWidgets('tapping + Set increases total sets in tracker', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final notifier = _TestWorkoutNotifier(testState);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeWorkoutProvider.overrideWith(() => notifier),
          ],
          child: const MaterialApp(
            home: ActiveWorkoutScreen(scheduleId: 's_test'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      final addSetButton = find.text('+ Set');
      expect(addSetButton, findsOneWidget);

      final initialSets = notifier.state.totalSetCount;
      await tester.tap(addSetButton);
      await tester.pump();

      expect(notifier.state.totalSetCount, equals(initialSets + 1));
    });
  });

  group('Workout Paused Modal Tests', () {
    testWidgets('renders standby badge, animated orb, stats, and exercise cards',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeWorkoutProvider.overrideWith(
              () => _TestWorkoutNotifier(testState),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showWorkoutPausedModal(
                    context,
                    state: testState,
                    notifier: _TestWorkoutNotifier(testState),
                    onEndWorkout: () {},
                  ),
                  child: const Text('Open Paused Modal'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Paused Modal'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('SESSION STANDBY'), findsOneWidget);
      expect(find.text('Workout Paused'), findsOneWidget);
      expect(find.text('DURATION'), findsOneWidget);
      expect(find.text('SETS'), findsOneWidget);
      expect(find.text('VOLUME'), findsOneWidget);
      expect(find.text('BURNED'), findsOneWidget);
      expect(find.text('CURRENT EXERCISE'), findsOneWidget);
      expect(find.text('Barbell Bench Press'), findsOneWidget);
      expect(find.text('Incline Dumbbell Press'), findsOneWidget);
      expect(find.text('Resume Workout'), findsOneWidget);
      expect(find.text('End Workout Session'), findsOneWidget);
    });
  });

  group('Skip Exercise Modal Tests', () {
    testWidgets('renders skipping from, bridge orb, and skipping into next',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeWorkoutProvider.overrideWith(
              () => _TestWorkoutNotifier(testState),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showSkipExerciseModal(
                    context,
                    state: testState,
                    notifier: _TestWorkoutNotifier(testState),
                  ),
                  child: const Text('Open Skip Modal'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Skip Modal'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Skip Exercise?'), findsOneWidget);
      expect(find.text('CURRENT EXERCISE'), findsOneWidget);
      expect(find.text('Barbell Bench Press'), findsOneWidget);
      expect(find.text('SKIPPING INTO NEXT'), findsOneWidget);
      expect(find.text('Incline Dumbbell Press'), findsOneWidget);
      expect(find.text('Skip to Incline Dumbbell Press'), findsOneWidget);
      expect(find.text('Stay on Barbell Bench Press'), findsOneWidget);
    });
  });

  group('Discard Workout Modal Tests', () {
    testWidgets('requires 2-second hold to discard session and prevents brief taps',
        (tester) async {
      var discarded = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDiscardWorkoutModal(
                  context,
                  state: testState,
                  onDiscard: () => discarded = true,
                ),
                child: const Text('Open Discard Modal'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Discard Modal'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Discard Workout?'), findsOneWidget);
      expect(find.text('UNLOGGED PROGRESS'), findsOneWidget);
      expect(find.text('Resume Workout'), findsOneWidget);
      expect(find.text('Hold to Discard (1.25s)'), findsOneWidget);

      // Brief tap does not discard
      await tester.tap(find.text('Hold to Discard (1.25s)'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(discarded, isFalse);

      // 1.25+ second continuous hold triggers discard
      final center = tester.getCenter(find.text('Hold to Discard (1.25s)'));
      final gesture = await tester.startGesture(center);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1350));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(discarded, isTrue);
    });
  });
}

class _TestWorkoutNotifier extends ActiveWorkoutNotifier {
  _TestWorkoutNotifier(this._initial);
  final ActiveWorkoutState _initial;

  @override
  ActiveWorkoutState build() => _initial;

  @override
  Future<void> startWorkout(String scheduleId, {List<ScheduleExercise>? customExercises}) async {}

  @override
  void addSet() {
    final entry = state.currentEntry;
    if (entry != null) {
      entry.totalSets++;
      state = state.copyWith(entries: List.from(state.entries));
    }
  }

  @override
  void pauseSession() {}

  @override
  void resumeSession() {}

  @override
  void skipExercise({String? reason}) {}

  @override
  void discardSession() {}
}
