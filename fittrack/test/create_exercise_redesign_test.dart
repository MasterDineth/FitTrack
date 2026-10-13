import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fittrack/domain/entities/execution_step.dart';
import 'package:fittrack/domain/entities/exercise.dart';
import 'package:fittrack/domain/entities/form_cue.dart';
import 'package:fittrack/domain/entities/muscle_activation.dart';
import 'package:fittrack/domain/repositories/i_exercise_repository.dart';
import 'package:fittrack/presentation/providers/custom_exercise_notifier.dart';
import 'package:fittrack/presentation/providers/repository_providers.dart';
import 'package:fittrack/presentation/screens/create_exercise/widgets/exercise_discard_dialog.dart';
import 'package:fittrack/presentation/screens/create_exercise/widgets/exercise_execution_steps_card.dart';
import 'package:fittrack/presentation/screens/create_exercise/widgets/exercise_form_cues_card.dart';
import 'package:fittrack/presentation/screens/create_exercise/widgets/exercise_muscles_worked_card.dart';
import 'package:fittrack/presentation/screens/create_exercise_screen.dart';
import 'package:fittrack/presentation/widgets/modals/add_form_cue_dialog.dart';
import 'package:fittrack/presentation/widgets/modals/add_muscle_picker_sheet.dart';

class _FakeExerciseRepository implements IExerciseRepository {
  final List<Exercise> savedExercises = [];
  final Map<String, List<ExecutionStep>> savedSteps = {};
  final Map<String, List<FormCue>> savedCues = {};
  final Map<String, List<MuscleActivation>> savedActivations = {};

  @override
  Future<List<Exercise>> getAllExercises() async => savedExercises;

  @override
  Future<Exercise?> getExerciseById(String id) async {
    return savedExercises.cast<Exercise?>().firstWhere(
          (e) => e?.id == id,
          orElse: () => null,
        );
  }

  @override
  Future<List<ExecutionStep>> getExecutionSteps(String exerciseId) async {
    return savedSteps[exerciseId] ?? [];
  }

  @override
  Future<List<FormCue>> getFormCues(String exerciseId) async {
    return savedCues[exerciseId] ?? [];
  }

  @override
  Future<List<MuscleActivation>> getMuscleActivations(String exerciseId) async {
    return savedActivations[exerciseId] ?? [];
  }

  @override
  Future<void> saveExercise(Exercise exercise) async {
    savedExercises.add(exercise);
  }

  @override
  Future<void> saveExecutionSteps(
    String exerciseId,
    List<ExecutionStep> steps,
  ) async {
    savedSteps[exerciseId] = steps;
  }

  @override
  Future<void> saveFormCues(String exerciseId, List<FormCue> cues) async {
    savedCues[exerciseId] = cues;
  }

  @override
  Future<void> saveMuscleActivations(
    String exerciseId,
    List<MuscleActivation> activations,
  ) async {
    savedActivations[exerciseId] = activations;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CustomExerciseNotifier Unit Tests', () {
    late ProviderContainer container;
    late _FakeExerciseRepository fakeRepo;

    setUp(() {
      fakeRepo = _FakeExerciseRepository();
      container = ProviderContainer(
        overrides: [
          exerciseRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state is clean and invalid (no title)', () {
      final state = container.read(customExerciseProvider);
      expect(state.title, isEmpty);
      expect(state.isValid, isFalse);
      expect(state.hasChanges, isFalse);
      expect(state.executionSteps, isEmpty);
      expect(state.formCues, isEmpty);
      expect(state.muscleActivations, isEmpty);
    });

    test('Setting title marks state valid and hasChanges true', () {
      final notifier = container.read(customExerciseProvider.notifier);
      notifier.setTitle('Incline Hammer Press');

      final state = container.read(customExerciseProvider);
      expect(state.title, 'Incline Hammer Press');
      expect(state.isValid, isTrue);
      expect(state.hasChanges, isTrue);
    });

    test('Execution steps are capped at 3 maximum', () {
      final notifier = container.read(customExerciseProvider.notifier);
      notifier.addExecutionStep();
      notifier.addExecutionStep();
      notifier.addExecutionStep();
      notifier.addExecutionStep(); // 4th attempt

      final state = container.read(customExerciseProvider);
      expect(state.executionSteps.length, 3);

      notifier.updateExecutionStep(0, title: 'Step 1', instructions: 'Desc 1');
      expect(container.read(customExerciseProvider).executionSteps[0].title, 'Step 1');

      notifier.removeExecutionStep(0);
      expect(container.read(customExerciseProvider).executionSteps.length, 2);
    });

    test('Form cues are capped at 3 maximum', () {
      final notifier = container.read(customExerciseProvider.notifier);
      notifier.addFormCue(FormCueDraft(isPositive: true, description: 'Cue 1'));
      notifier.addFormCue(FormCueDraft(isPositive: false, description: 'Cue 2'));
      notifier.addFormCue(FormCueDraft(isPositive: true, description: 'Cue 3'));
      notifier.addFormCue(FormCueDraft(isPositive: false, description: 'Cue 4')); // 4th attempt

      final state = container.read(customExerciseProvider);
      expect(state.formCues.length, 3);

      notifier.removeFormCue(1);
      expect(container.read(customExerciseProvider).formCues.length, 2);
    });

    test('Muscle activations are capped at 3 maximum and intensity updates', () {
      final notifier = container.read(customExerciseProvider.notifier);
      notifier.addMuscleActivation(
        MuscleActivationDraft(
          muscleName: 'Chest',
          role: MuscleRole.agonist,
          intensityPercentage: 70,
        ),
      );
      notifier.addMuscleActivation(
        MuscleActivationDraft(
          muscleName: 'Triceps',
          role: MuscleRole.synergist,
          intensityPercentage: 40,
        ),
      );
      notifier.addMuscleActivation(
        MuscleActivationDraft(
          muscleName: 'Front deltoid',
          role: MuscleRole.synergist,
          intensityPercentage: 35,
        ),
      );
      notifier.addMuscleActivation(
        MuscleActivationDraft(
          muscleName: 'Lats',
          role: MuscleRole.stabilizer,
          intensityPercentage: 20,
        ),
      ); // 4th attempt

      final state = container.read(customExerciseProvider);
      expect(state.muscleActivations.length, 3);

      notifier.updateMuscleActivationIntensity(0, 85);
      expect(container.read(customExerciseProvider).muscleActivations[0].intensityPercentage, 85);

      notifier.removeMuscleActivation(0);
      expect(container.read(customExerciseProvider).muscleActivations.length, 2);
    });

    test('Reset clears all drafts back to pristine state', () {
      final notifier = container.read(customExerciseProvider.notifier);
      notifier.setTitle('Test Exercise');
      notifier.setMediaPath('/path/to/img.png');
      notifier.addExecutionStep();
      expect(container.read(customExerciseProvider).hasChanges, isTrue);

      notifier.reset();
      final state = container.read(customExerciseProvider);
      expect(state.title, isEmpty);
      expect(state.mediaPath, isNull);
      expect(state.hasChanges, isFalse);
    });

    test('save() persists exercise, steps, cues, and muscle activations in repository', () async {
      final notifier = container.read(customExerciseProvider.notifier);
      notifier.setTitle('Dumbbell Bench Press');
      notifier.setEquipment(Equipment.dumbbell);
      notifier.setMovementClassification(MovementClassification.compound);
      notifier.setMediaPath('/path/cover.jpg');
      notifier.setYoutubeUrl('https://youtu.be/test');
      notifier.addExecutionStep();
      notifier.updateExecutionStep(0, title: 'Setup', instructions: 'Sit on bench');
      notifier.addFormCue(FormCueDraft(isPositive: true, description: 'Pinch scapulae'));
      notifier.addMuscleActivation(
        MuscleActivationDraft(
          muscleName: 'Chest',
          role: MuscleRole.agonist,
          intensityPercentage: 75,
        ),
      );

      final success = await notifier.save();
      expect(success, isTrue);

      expect(fakeRepo.savedExercises.length, 1);
      final savedEx = fakeRepo.savedExercises.first;
      expect(savedEx.name, 'Dumbbell Bench Press');
      expect(savedEx.equipment, Equipment.dumbbell);
      expect(savedEx.movementClassification, MovementClassification.compound);
      expect(savedEx.mediaUrl, '/path/cover.jpg');
      expect(savedEx.youtubeUrl, 'https://youtu.be/test');

      expect(fakeRepo.savedSteps[savedEx.id]?.length, 1);
      expect(fakeRepo.savedSteps[savedEx.id]?.first.title, 'Setup');

      expect(fakeRepo.savedCues[savedEx.id]?.length, 1);
      expect(fakeRepo.savedCues[savedEx.id]?.first.isPositive, isTrue);

      expect(fakeRepo.savedActivations[savedEx.id]?.length, 1);
      expect(fakeRepo.savedActivations[savedEx.id]?.first.muscleName, 'Chest');
    });
  });

  group('AddFormCueDialog Widget Tests', () {
    testWidgets('Renders classification tabs, textarea, character counter, and buttons', (tester) async {
      tester.view.physicalSize = const Size(393, 884);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddFormCueDialog(),
          ),
        ),
      );

      expect(find.text('Add Form Cue'), findsNWidgets(2)); // Title and button
      expect(find.text('CUE CLASSIFICATION'), findsOneWidget);
      expect(find.text('Correct Technique'), findsOneWidget);
      expect(find.text('DO'), findsOneWidget);
      expect(find.text("DON'T"), findsOneWidget);
      expect(find.text('INSTRUCTION TEXT'), findsOneWidget);
      expect(find.text('0 / 120'), findsOneWidget);

      // Tap DON'T tab
      await tester.tap(find.text("DON'T"));
      await tester.pumpAndSettle();
      expect(find.text('Common Fault / Risk'), findsOneWidget);

      // Enter text
      await tester.enterText(find.byType(TextField), 'Keep elbows tucked');
      await tester.pumpAndSettle();
      expect(find.text('18 / 120'), findsOneWidget);

      // Tap Clear
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();
      expect(find.text('0 / 120'), findsOneWidget);
    });

    testWidgets('Submitting with text returns FormCueDraft', (tester) async {
      tester.view.physicalSize = const Size(393, 884);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      FormCueDraft? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await AddFormCueDialog.show(context);
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Drive through heels');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Form Cue').last);
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result?.isPositive, isTrue);
      expect(result?.description, 'Drive through heels');
    });
  });

  group('AddMusclePickerSheet Widget Tests', () {
    testWidgets('Renders search, category chips, muscles list, and configuration panel', (tester) async {
      tester.view.physicalSize = const Size(393, 884);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddMusclePickerSheet(currentCount: 0),
          ),
        ),
      );

      expect(find.text('Add muscle'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Chest'), findsWidgets);
      expect(find.text('Shoulders'), findsOneWidget);
      expect(find.text('ROLE'), findsOneWidget);
      expect(find.text('Prime mover'), findsWidgets);
      expect(find.text('ACTIVATION'), findsOneWidget);

      // Tap Shoulders category chip
      await tester.tap(find.text('Shoulders'));
      await tester.pumpAndSettle();

      expect(find.text('Front deltoid'), findsOneWidget);
      expect(find.text('Side deltoid'), findsOneWidget);
      expect(find.text('Rear deltoid'), findsOneWidget);

      // Select Side deltoid
      await tester.tap(find.text('Side deltoid'));
      await tester.pumpAndSettle();

      expect(find.text('Side deltoid'), findsWidgets);
      expect(find.text('Add Side deltoid'), findsOneWidget);
    });

    testWidgets('Steppers increment and decrement activation percentage', (tester) async {
      tester.view.physicalSize = const Size(393, 884);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddMusclePickerSheet(currentCount: 0),
          ),
        ),
      );

      // Default is 70%
      expect(find.text('70%'), findsWidgets);

      // Decrement (-)
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pumpAndSettle();
      expect(find.text('65%'), findsWidgets);

      // Increment (+) twice
      await tester.tap(find.byIcon(Icons.add_rounded).first);
      await tester.pumpAndSettle();
      expect(find.text('70%'), findsWidgets);

      await tester.tap(find.byIcon(Icons.add_rounded).first);
      await tester.pumpAndSettle();
      expect(find.text('75%'), findsWidgets);
      expect(find.text('Maximum recruitment'), findsOneWidget);
    });

    testWidgets('Enforces maximum 3 muscles cap banner', (tester) async {
      tester.view.physicalSize = const Size(393, 884);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddMusclePickerSheet(currentCount: 3),
          ),
        ),
      );

      expect(find.text('3 of 3 max'), findsOneWidget);
      expect(find.text('Max 3 muscles reached'), findsOneWidget);
    });
  });

  group('ExerciseDiscardDialog Widget Tests', () {
    testWidgets('Keep editing returns false and Discard returns true', (tester) async {
      tester.view.physicalSize = const Size(393, 884);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool? discardResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    discardResult = await ExerciseDiscardDialog.show(context);
                  },
                  child: const Text('Show Discard'),
                );
              },
            ),
          ),
        ),
      );

      // 1. Test Keep editing
      await tester.tap(find.text('Show Discard'));
      await tester.pumpAndSettle();

      expect(find.text('Discard exercise?'), findsOneWidget);
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();

      expect(discardResult, isFalse);

      // 2. Test Discard
      await tester.tap(find.text('Show Discard'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect(discardResult, isTrue);
    });
  });

  group('CreateExerciseScreen Full Integration Tests', () {
    testWidgets('Renders all cards and sections cleanly in Light mode', (tester) async {
      tester.view.physicalSize = const Size(393, 884);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeRepo = _FakeExerciseRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exerciseRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: CreateExerciseScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Create Exercise'), findsOneWidget);
      expect(find.text('Only a name is required'), findsOneWidget);
      expect(find.text('Basics'), findsOneWidget);
      expect(find.text('Media'), findsOneWidget);
      expect(find.text('Save exercise'), findsOneWidget);

      // Scroll down progressively to verify sliver items as they enter viewport
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(find.byType(ExerciseExecutionStepsCard), findsOneWidget);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.byType(ExerciseFormCuesCard), findsOneWidget);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.byType(ExerciseMusclesWorkedCard), findsOneWidget);
    });

    testWidgets('Tapping Save with empty name shows validation snackbar', (tester) async {
      tester.view.physicalSize = const Size(393, 884);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeRepo = _FakeExerciseRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exerciseRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: CreateExerciseScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Save exercise'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter an exercise name'), findsOneWidget);
    });
  });
}
