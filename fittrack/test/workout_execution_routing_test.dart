import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fittrack/domain/entities/exercise.dart';
import 'package:fittrack/domain/entities/execution_step.dart';
import 'package:fittrack/domain/entities/form_cue.dart';
import 'package:fittrack/domain/entities/muscle_activation.dart';
import 'package:fittrack/domain/entities/schedule.dart';
import 'package:fittrack/domain/repositories/i_exercise_repository.dart';
import 'package:fittrack/domain/repositories/i_schedule_repository.dart';
import 'package:fittrack/presentation/providers/active_workout_provider.dart';
import 'package:fittrack/presentation/providers/repository_providers.dart';
import 'package:fittrack/presentation/providers/schedules_provider.dart';
import 'package:fittrack/presentation/screens/workout_detail_screen.dart';

class FakeScheduleRepository implements IScheduleRepository {
  final Map<String, Schedule> schedules = {};
  final Map<String, List<ScheduleExercise>> scheduleExercises = {};

  @override
  Future<List<Schedule>> getAllSchedules() async => schedules.values.toList();

  @override
  Future<Schedule?> getScheduleById(String id) async => schedules[id];

  @override
  Future<List<ScheduleExercise>> getScheduleExercises(String scheduleId) async =>
      scheduleExercises[scheduleId] ?? [];

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
}

class FakeExerciseRepository implements IExerciseRepository {
  final Map<String, Exercise> exercises = {};

  @override
  Future<List<Exercise>> getAllExercises() async => exercises.values.toList();

  @override
  Future<Exercise?> getExerciseById(String id) async => exercises[id];

  @override
  Future<void> saveExercise(Exercise exercise) async {
    exercises[exercise.id] = exercise;
  }

  @override
  Future<List<MuscleActivation>> getMuscleActivations(
    String exerciseId,
  ) async =>
      [];

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
  late FakeScheduleRepository fakeScheduleRepo;
  late FakeExerciseRepository fakeExerciseRepo;

  setUp(() {
    fakeScheduleRepo = FakeScheduleRepository();
    fakeExerciseRepo = FakeExerciseRepository();

    // Seed a standard database schedule (like Dashboard provides)
    fakeScheduleRepo.schedules['sch1'] = const Schedule(
      id: 'sch1',
      name: 'Day 1: Chest, Shoulders & Triceps',
      description: 'Push day routine',
      targetMuscles: ['Chest', 'Shoulders', 'Triceps'],
      assignedWeekdays: [1, 4],
      orderIndex: 1,
    );
    fakeScheduleRepo.scheduleExercises['sch1'] = [
      const ScheduleExercise(
        id: 'se1',
        scheduleId: 'sch1',
        exerciseId: 'ex1',
        sortOrder: 1,
        targetSets: 3,
        targetReps: 8,
        targetWeightKg: 60.0,
        restDurationSeconds: 120,
      ),
    ];
    fakeExerciseRepo.exercises['ex1'] = const Exercise(
      id: 'ex1',
      name: 'BB Bench Press',
      equipment: Equipment.barbell,
      movementClassification: MovementClassification.compound,
    );
  });

  group('ActiveWorkoutNotifier State Hydration & Cleanup', () {
    test('startWorkout successfully hydrates SQLite database schedule',
        () async {
      final container = ProviderContainer(
        overrides: [
          scheduleRepositoryProvider.overrideWithValue(fakeScheduleRepo),
          exerciseRepositoryProvider.overrideWithValue(fakeExerciseRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(activeWorkoutProvider.notifier);
      await notifier.startWorkout('sch1');

      final state = container.read(activeWorkoutProvider);
      expect(state.phase, equals(WorkoutPhase.active));
      expect(state.schedule.id, equals('sch1'));
      expect(state.entries.length, equals(1));
      expect(state.entries.first.name, equals('BB Bench Press'));
      expect(state.errorMessage, isNull);
    });

    test(
        'startWorkout successfully hydrates in-memory schedule from Workouts tab (sched_ppl_hypertrophy)',
        () async {
      final container = ProviderContainer(
        overrides: [
          // fakeScheduleRepo does NOT have sched_ppl_hypertrophy in SQLite
          scheduleRepositoryProvider.overrideWithValue(fakeScheduleRepo),
          exerciseRepositoryProvider.overrideWithValue(fakeExerciseRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(activeWorkoutProvider.notifier);
      // sched_ppl_hypertrophy is defined in schedulesProvider initial seeds
      await notifier.startWorkout('sched_ppl_hypertrophy');

      final state = container.read(activeWorkoutProvider);
      expect(state.phase, equals(WorkoutPhase.active));
      expect(state.schedule.id, equals('sched_ppl_hypertrophy'));
      expect(state.schedule.name, equals('Push-Pull-Legs Split'));
      // Entries should be populated even if individual exercises were not in SQLite
      expect(state.entries.isNotEmpty, isTrue);
      expect(state.entries.first.name.toLowerCase(), contains('bench press'));
      expect(state.errorMessage, isNull);
    });

    test(
        'discardSession clears session progress without invalidating schedule and allows clean restart',
        () async {
      final container = ProviderContainer(
        overrides: [
          scheduleRepositoryProvider.overrideWithValue(fakeScheduleRepo),
          exerciseRepositoryProvider.overrideWithValue(fakeExerciseRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(activeWorkoutProvider.notifier);
      await notifier.startWorkout('sch1');

      // Simulate some progress
      notifier.completeSet();

      var state = container.read(activeWorkoutProvider);
      expect(state.completedSets.length, equals(1));

      // Discard session
      notifier.discardSession();

      state = container.read(activeWorkoutProvider);
      // Progress is cleared
      expect(state.completedSets, isEmpty);
      expect(state.elapsedSeconds, equals(0));
      expect(state.restRemainingSeconds, equals(0));
      expect(state.currentExerciseIndex, equals(0));
      expect(state.currentSetIndex, equals(0));
      // Phase is loading (ready for fresh session)
      expect(state.phase, equals(WorkoutPhase.loading));

      // Restarting the workout should work cleanly without any forced redirect
      await notifier.startWorkout('sch1');
      state = container.read(activeWorkoutProvider);
      expect(state.phase, equals(WorkoutPhase.active));
      expect(state.completedSets, isEmpty);
      expect(state.elapsedSeconds, equals(0));
    });
  });

  group('WorkoutDetailScreen Start Button Hydration', () {
    testWidgets(
        'tapping Start Workout calls startWorkout on activeWorkoutProvider',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          scheduleRepositoryProvider.overrideWithValue(fakeScheduleRepo),
          exerciseRepositoryProvider.overrideWithValue(fakeExerciseRepo),
        ],
      );
      addTearDown(container.dispose);

      final ws = container
          .read(schedulesProvider)
          .allSchedules
          .firstWhere((s) => s.id == 'sched_ppl_hypertrophy');

      final router = GoRouter(
        initialLocation: '/detail',
        routes: [
          GoRoute(
            path: '/detail',
            builder: (_, _) => WorkoutDetailScreen(
              scheduleId: ws.id,
              workoutSchedule: ws,
            ),
          ),
          GoRoute(
            path: '/workouts/active/:scheduleId',
            builder: (_, state) =>
                Text('Active: ${state.pathParameters['scheduleId']}'),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final startButtonFinder = find.text('Start Workout');
      expect(startButtonFinder, findsOneWidget);

      await tester.tap(startButtonFinder);
      await tester.pump();

      // Verify activeWorkoutProvider state was updated
      final activeState = container.read(activeWorkoutProvider);
      expect(activeState.schedule.id, equals('sched_ppl_hypertrophy'));
      expect(activeState.phase, equals(WorkoutPhase.active));

      // Clean up timer before finishing test
      container.read(activeWorkoutProvider.notifier).discardSession();
    });

    testWidgets(
        'discarding in ActiveWorkoutScreen cleans session and returns without dashboard redirect',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          scheduleRepositoryProvider.overrideWithValue(fakeScheduleRepo),
          exerciseRepositoryProvider.overrideWithValue(fakeExerciseRepo),
        ],
      );
      addTearDown(container.dispose);

      // Start workout first
      await container
          .read(activeWorkoutProvider.notifier)
          .startWorkout('sch1');

      // Now discard
      container.read(activeWorkoutProvider.notifier).discardSession();

      final state = container.read(activeWorkoutProvider);
      expect(state.phase, equals(WorkoutPhase.loading));
      expect(state.completedSets, isEmpty);
      expect(state.elapsedSeconds, equals(0));

      // Re-start again immediately
      await container
          .read(activeWorkoutProvider.notifier)
          .startWorkout('sch1');

      final restartedState = container.read(activeWorkoutProvider);
      expect(restartedState.phase, equals(WorkoutPhase.active));
      expect(restartedState.schedule.id, equals('sch1'));

      container.read(activeWorkoutProvider.notifier).discardSession();
    });
  });
}
