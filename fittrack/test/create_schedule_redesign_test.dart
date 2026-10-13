import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fittrack/domain/entities/execution_step.dart';
import 'package:fittrack/domain/entities/exercise.dart';
import 'package:fittrack/domain/entities/form_cue.dart';
import 'package:fittrack/domain/entities/muscle_activation.dart';
import 'package:fittrack/domain/entities/schedule.dart';
import 'package:fittrack/domain/entities/schedule_exercise.dart';
import 'package:fittrack/domain/repositories/i_exercise_repository.dart';
import 'package:fittrack/domain/repositories/i_schedule_repository.dart';
import 'package:fittrack/presentation/providers/repository_providers.dart';
import 'package:fittrack/presentation/providers/schedule_editor_notifier.dart';
import 'package:fittrack/presentation/screens/create_schedule_screen.dart';
import 'package:fittrack/presentation/widgets/exercise_picker/add_exercise_picker_sheet.dart';

class _MockExerciseRepository implements IExerciseRepository {
  final List<Exercise> _exercises = [
    const Exercise(
      id: 'ex1',
      name: 'Barbell Bench Press',
      equipment: Equipment.barbell,
      movementClassification: MovementClassification.compound,
      mediaUrl: 'assets/images/dashboard/coaching_bench.webp',
    ),
    const Exercise(
      id: 'ex2',
      name: 'Incline Dumbbell Press',
      equipment: Equipment.dumbbell,
      movementClassification: MovementClassification.compound,
    ),
    const Exercise(
      id: 'ex3',
      name: 'Cable Flyes',
      equipment: Equipment.cable,
      movementClassification: MovementClassification.isolation,
    ),
    const Exercise(
      id: 'ex4',
      name: 'Barbell Overhead Press',
      equipment: Equipment.barbell,
      movementClassification: MovementClassification.compound,
    ),
    const Exercise(
      id: 'ex5',
      name: 'Dumbbell Lateral Raises',
      equipment: Equipment.dumbbell,
      movementClassification: MovementClassification.isolation,
    ),
    const Exercise(
      id: 'ex6',
      name: 'Triceps Cable Pushdowns',
      equipment: Equipment.cable,
      movementClassification: MovementClassification.isolation,
    ),
  ];

  @override
  Future<List<Exercise>> getAllExercises() async => _exercises;

  @override
  Future<Exercise?> getExerciseById(String id) async {
    final idx = _exercises.indexWhere((e) => e.id == id);
    return idx != -1 ? _exercises[idx] : null;
  }

  @override
  Future<List<ExecutionStep>> getExecutionSteps(String exerciseId) async => [];

  @override
  Future<List<FormCue>> getFormCues(String exerciseId) async => [];

  @override
  Future<List<MuscleActivation>> getMuscleActivations(String exerciseId) async => [];

  @override
  Future<void> saveExecutionSteps(String exerciseId, List<ExecutionStep> steps) async {}

  @override
  Future<void> saveExercise(Exercise exercise) async {}

  @override
  Future<void> saveFormCues(String exerciseId, List<FormCue> cues) async {}

  @override
  Future<void> saveMuscleActivations(String exerciseId, List<MuscleActivation> activations) async {}
}

class _MockScheduleRepository implements IScheduleRepository {
  final List<Schedule> created = [];

  @override
  Future<List<Schedule>> getAllSchedules() async => created;

  @override
  Future<Schedule?> getScheduleById(String id) async => null;

  @override
  Future<List<ScheduleExercise>> getScheduleExercises(String scheduleId) async => [];

  @override
  Future<void> saveSchedule(Schedule schedule, List<ScheduleExercise> exercises) async {
    created.add(schedule);
  }

  @override
  Future<List<Schedule>> getBookmarkedSchedules() async => [];

  @override
  Future<List<Schedule>> searchSchedules(String query, {String? category}) async => [];

  @override
  Future<void> toggleBookmark(String scheduleId, bool isFavorite) async {}

  @override
  Future<void> deleteSchedule(String id) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScheduleEditorNotifier Unit Tests', () {
    test('Initial state: no muscles selected by default, 0 weekdays, 0 exercises', () {
      final container = ProviderContainer(
        overrides: [
          scheduleRepositoryProvider.overrideWithValue(_MockScheduleRepository()),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(scheduleEditorProvider);
      expect(state.name, '');
      expect(state.description, '');
      expect(state.targetMuscles, isEmpty);
      expect(state.assignedWeekdays, isEmpty);
      expect(state.exercises, isEmpty);
      expect(state.isValid, isFalse);
      expect(state.validationMessage, 'Please enter a schedule name');
    });

    test('Target muscles: select up to 3 max', () {
      final container = ProviderContainer(
        overrides: [
          scheduleRepositoryProvider.overrideWithValue(_MockScheduleRepository()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(scheduleEditorProvider.notifier);

      expect(notifier.toggleMuscle('Chest'), isTrue);
      expect(notifier.toggleMuscle('Shoulders'), isTrue);
      expect(notifier.toggleMuscle('Triceps'), isTrue);
      // 4th muscle must be rejected
      expect(notifier.toggleMuscle('Back'), isFalse);

      final state = container.read(scheduleEditorProvider);
      expect(state.targetMuscles, ['Chest', 'Shoulders', 'Triceps']);

      // Untoggle Chest
      expect(notifier.toggleMuscle('Chest'), isTrue);
      expect(container.read(scheduleEditorProvider).targetMuscles, ['Shoulders', 'Triceps']);
    });

    test('Weekly schedule: assign up to 3 days max', () {
      final container = ProviderContainer(
        overrides: [
          scheduleRepositoryProvider.overrideWithValue(_MockScheduleRepository()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(scheduleEditorProvider.notifier);

      expect(notifier.toggleWeekday(1), isTrue); // Mon
      expect(notifier.toggleWeekday(3), isTrue); // Wed
      expect(notifier.toggleWeekday(5), isTrue); // Fri
      // 4th day must be rejected
      expect(notifier.toggleWeekday(7), isFalse);

      final state = container.read(scheduleEditorProvider);
      expect(state.assignedWeekdays, [1, 3, 5]);

      // Untoggle Mon
      expect(notifier.toggleWeekday(1), isTrue);
      expect(container.read(scheduleEditorProvider).assignedWeekdays, [3, 5]);
    });

    test('Exercises: enforces min 3 and max 12', () {
      final container = ProviderContainer(
        overrides: [
          scheduleRepositoryProvider.overrideWithValue(_MockScheduleRepository()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(scheduleEditorProvider.notifier);
      notifier.setName('Push Routine');
      notifier.toggleMuscle('Chest');

      // 2 exercises: invalid
      notifier.addExercises([
        ScheduleExerciseEntry(exerciseId: '1', exerciseName: 'Bench Press', equipment: 'Barbell', movementType: 'Compound'),
        ScheduleExerciseEntry(exerciseId: '2', exerciseName: 'Incline Press', equipment: 'Dumbbell', movementType: 'Compound'),
      ]);

      expect(container.read(scheduleEditorProvider).isValid, isFalse);
      expect(container.read(scheduleEditorProvider).validationMessage, contains('at least 3 exercises'));

      // 3 exercises: valid!
      notifier.addExercises([
        ScheduleExerciseEntry(exerciseId: '3', exerciseName: 'Cable Flyes', equipment: 'Cable', movementType: 'Isolation'),
      ]);

      expect(container.read(scheduleEditorProvider).isValid, isTrue);
      expect(container.read(scheduleEditorProvider).validationMessage, isNull);

      // Adding 10 more exercises: should be capped at 12
      final extra = List.generate(
        10,
        (i) => ScheduleExerciseEntry(
          exerciseId: 'ex_${i + 4}',
          exerciseName: 'Exercise ${i + 4}',
          equipment: 'Dumbbell',
          movementType: 'Isolation',
        ),
      );
      notifier.addExercises(extra);

      expect(container.read(scheduleEditorProvider).exercises.length, 12);
    });

    test('Exercises: rejects duplicate exercise IDs', () {
      final container = ProviderContainer(
        overrides: [
          scheduleRepositoryProvider.overrideWithValue(_MockScheduleRepository()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(scheduleEditorProvider.notifier);
      expect(
        notifier.addExercise(
          ScheduleExerciseEntry(
            exerciseId: 'ex1',
            exerciseName: 'Bench Press',
            equipment: 'Barbell',
            movementType: 'Compound',
          ),
        ),
        isTrue,
      );

      // Attempt duplicate addition
      expect(
        notifier.addExercise(
          ScheduleExerciseEntry(
            exerciseId: 'ex1',
            exerciseName: 'Bench Press',
            equipment: 'Barbell',
            movementType: 'Compound',
          ),
        ),
        isFalse,
      );
      expect(container.read(scheduleEditorProvider).exercises.length, 1);

      // Batch addition containing duplicates
      notifier.addExercises([
        ScheduleExerciseEntry(
          exerciseId: 'ex1',
          exerciseName: 'Bench Press',
          equipment: 'Barbell',
          movementType: 'Compound',
        ),
        ScheduleExerciseEntry(
          exerciseId: 'ex2',
          exerciseName: 'Incline Dumbbell Press',
          equipment: 'Dumbbell',
          movementType: 'Compound',
        ),
      ]);
      expect(container.read(scheduleEditorProvider).exercises.length, 2);
      expect(
        container.read(scheduleEditorProvider).exercises.map((e) => e.exerciseId).toList(),
        ['ex1', 'ex2'],
      );
    });

    test('Exercise parameter updates: sets, reps, weight by 2.5kg, rest by 15s', () {
      final container = ProviderContainer(
        overrides: [
          scheduleRepositoryProvider.overrideWithValue(_MockScheduleRepository()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(scheduleEditorProvider.notifier);
      notifier.addExercises([
        ScheduleExerciseEntry(
          exerciseId: '1',
          exerciseName: 'Bench Press',
          equipment: 'Barbell',
          movementType: 'Compound',
          targetSets: 3,
          targetReps: 10,
          targetWeightKg: 80.0,
          restDurationSeconds: 90,
        ),
      ]);

      // Update sets & reps
      notifier.updateExerciseParam(0, sets: 4, reps: 8);
      // Increment weight by 2.5kg
      notifier.updateExerciseParam(0, weightKg: 82.5);
      // Increment rest by 15s (90 -> 105)
      notifier.updateExerciseParam(0, restSeconds: 105);

      final entry = container.read(scheduleEditorProvider).exercises[0];
      expect(entry.targetSets, 4);
      expect(entry.targetReps, 8);
      expect(entry.targetWeightKg, 82.5);
      expect(entry.restDurationSeconds, 105);
      expect(entry.formattedRestTime, '1:45');
    });

    test('Exercise reorder adjusts positions properly', () {
      final container = ProviderContainer(
        overrides: [
          scheduleRepositoryProvider.overrideWithValue(_MockScheduleRepository()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(scheduleEditorProvider.notifier);
      notifier.addExercises([
        ScheduleExerciseEntry(exerciseId: '1', exerciseName: 'First', equipment: 'Barbell', movementType: 'Compound'),
        ScheduleExerciseEntry(exerciseId: '2', exerciseName: 'Second', equipment: 'Dumbbell', movementType: 'Compound'),
        ScheduleExerciseEntry(exerciseId: '3', exerciseName: 'Third', equipment: 'Cable', movementType: 'Isolation'),
      ]);

      // Move index 0 to index 2
      notifier.reorderExercises(0, 2);

      final ex = container.read(scheduleEditorProvider).exercises;
      expect(ex[0].exerciseName, 'Second');
      expect(ex[1].exerciseName, 'Third');
      expect(ex[2].exerciseName, 'First');
    });
  });

  group('AddExercisePickerSheet Widget Tests', () {
    testWidgets('Renders modal with search bar, chips, and allows up to 4 selections', (tester) async {
      final mockRepo = _MockExerciseRepository();
      List<ScheduleExerciseEntry>? addedResult;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exerciseRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AddExercisePickerSheet(
                currentExercisesCount: 0,
                onExercisesAdded: (selected) {
                  addedResult = selected;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Title & Search
      expect(find.text('Add exercises'), findsOneWidget);
      expect(find.text('Search exercises'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Chest'), findsOneWidget);

      // Verify exercises are rendered
      expect(find.text('Barbell Bench Press'), findsOneWidget);
      expect(find.text('Incline Dumbbell Press'), findsOneWidget);

      // Tap on Barbell Bench Press to select
      await tester.tap(find.text('Barbell Bench Press'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('1 selected'), findsOneWidget);
      expect(find.text('Add 1 exercise'), findsOneWidget);

      // Tap 3 more to reach 4 selected
      await tester.tap(find.text('Incline Dumbbell Press'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Cable Flyes'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Barbell Overhead Press'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('4 selected'), findsOneWidget);
      expect(find.text('Add 4 exercises'), findsOneWidget);

      // Attempting 5th selection: Dumbbell Lateral Raises
      await tester.drag(find.text('Incline Dumbbell Press'), const Offset(0, -250));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Dumbbell Lateral Raises'));
      await tester.pump(const Duration(milliseconds: 100));

      // Should still be 4 selected and show toast
      expect(find.text('4 selected'), findsOneWidget);
      expect(find.text('You can select up to 4 exercises at once'), findsOneWidget);

      // Tap "Add 4 exercises" footer button
      await tester.tap(find.text('Add 4 exercises'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(addedResult, isNotNull);
      expect(addedResult!.length, 4);
    });

    testWidgets('Respects max 12 total schedule limit when currentExercisesCount is 10', (tester) async {
      final mockRepo = _MockExerciseRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exerciseRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AddExercisePickerSheet(
                currentExercisesCount: 10, // Only 2 remaining allowed
                onExercisesAdded: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Select 1
      await tester.tap(find.text('Barbell Bench Press'));
      await tester.pump(const Duration(milliseconds: 100));
      // Select 2
      await tester.tap(find.text('Incline Dumbbell Press'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('2 selected'), findsOneWidget);

      // Attempt 3rd selection
      await tester.drag(find.text('Incline Dumbbell Press'), const Offset(0, -100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Cable Flyes'));
      await tester.pump(const Duration(milliseconds: 100));

      // Should block and inform that only 2 more can be added
      expect(find.text('2 selected'), findsOneWidget);
      expect(find.text('Only 2 more exercises can be added (12 max)'), findsOneWidget);
    });

    testWidgets('Grays out already added exercises and displays Added badge', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockExerciseRepo = _MockExerciseRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exerciseRepositoryProvider.overrideWithValue(mockExerciseRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AddExercisePickerSheet(
                currentExercisesCount: 1,
                existingExerciseIds: const {'ex1'},
                onExercisesAdded: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 'ex1' is 'Barbell Bench Press' and is already in schedule
      expect(find.text('Barbell Bench Press'), findsOneWidget);
      expect(find.text('Added'), findsOneWidget);

      // Tapping on already added item does not select it
      await tester.tap(find.text('Barbell Bench Press'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('0 selected'), findsOneWidget);
    });
  });

  group('CreateScheduleScreen UI & Integration Tests', () {
    testWidgets('Renders all redesigned sections and blocks save when invalid', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockScheduleRepo = _MockScheduleRepository();
      final mockExerciseRepo = _MockExerciseRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scheduleRepositoryProvider.overrideWithValue(mockScheduleRepo),
            exerciseRepositoryProvider.overrideWithValue(mockExerciseRepo),
          ],
          child: const MaterialApp(
            home: CreateScheduleScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Header
      expect(find.text('New Schedule'), findsOneWidget);
      expect(find.text('Hypertrophy split plan'), findsOneWidget);

      // Summary Strip
      expect(find.text('DURATION'), findsOneWidget);
      expect(find.text('SETS'), findsOneWidget);
      expect(find.text('ENERGY'), findsOneWidget);

      // Details card
      expect(find.text('SCHEDULE NAME'), findsOneWidget);
      expect(find.text('DESCRIPTION (OPTIONAL)'), findsOneWidget);

      // Target muscles
      expect(find.text('Target muscles'), findsOneWidget);
      expect(find.text('Chest'), findsOneWidget);
      expect(find.text('Shoulders'), findsOneWidget);

      // Weekly schedule
      expect(find.text('Weekly schedule'), findsOneWidget);

      // Save button
      expect(find.text('Save schedule'), findsOneWidget);

      // Tap Save without filling required fields
      await tester.tap(find.text('Save schedule'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Error toast should appear
      expect(find.text('Please enter a schedule name'), findsOneWidget);
    });

    testWidgets('Swipe to discard removes exercise card', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockScheduleRepo = _MockScheduleRepository();
      final mockExerciseRepo = _MockExerciseRepository();

      final container = ProviderContainer(
        overrides: [
          scheduleRepositoryProvider.overrideWithValue(mockScheduleRepo),
          exerciseRepositoryProvider.overrideWithValue(mockExerciseRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(scheduleEditorProvider.notifier);
      notifier.setName('Full Body');
      notifier.toggleMuscle('Chest');
      notifier.addExercises([
        ScheduleExerciseEntry(
          exerciseId: 'ex1',
          exerciseName: 'Barbell Bench Press',
          equipment: 'Barbell',
          movementType: 'Compound',
        ),
        ScheduleExerciseEntry(
          exerciseId: 'ex2',
          exerciseName: 'Incline Dumbbell Press',
          equipment: 'Dumbbell',
          movementType: 'Compound',
        ),
        ScheduleExerciseEntry(
          exerciseId: 'ex3',
          exerciseName: 'Cable Flyes',
          equipment: 'Cable',
          movementType: 'Isolation',
        ),
      ]);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: CreateScheduleScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Barbell Bench Press'), findsOneWidget);

      // Scroll exercise into clear view
      await tester.ensureVisible(find.text('Barbell Bench Press'));
      await tester.pumpAndSettle();

      // Swipe dismiss the first exercise
      await tester.drag(find.byType(Dismissible).first, const Offset(-500, 0), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Card should be dismissed and removed from state
      expect(container.read(scheduleEditorProvider).exercises.length, 2);
    });
  });
}
