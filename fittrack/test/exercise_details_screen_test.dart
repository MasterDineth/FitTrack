import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:fittrack/domain/entities/execution_step.dart';
import 'package:fittrack/domain/entities/exercise.dart';
import 'package:fittrack/domain/entities/form_cue.dart';
import 'package:fittrack/domain/entities/muscle_activation.dart';
import 'package:fittrack/domain/repositories/i_exercise_repository.dart';
import 'package:fittrack/presentation/providers/repository_providers.dart';
import 'package:fittrack/presentation/screens/exercise_details/exercise_details_screen.dart';

class _FakeExerciseRepository implements IExerciseRepository {
  _FakeExerciseRepository({
    this.exercise,
    this.steps = const [],
    this.cues = const [],
    this.activations = const [],
  });

  Exercise? exercise;
  List<ExecutionStep> steps;
  List<FormCue> cues;
  List<MuscleActivation> activations;

  @override
  Future<List<Exercise>> getAllExercises() async =>
      exercise == null ? [] : [exercise!];

  @override
  Future<Exercise?> getExerciseById(String id) async => exercise;

  @override
  Future<List<ExecutionStep>> getExecutionSteps(String exerciseId) async =>
      steps;

  @override
  Future<List<FormCue>> getFormCues(String exerciseId) async => cues;

  @override
  Future<List<MuscleActivation>> getMuscleActivations(
    String exerciseId,
  ) async =>
      activations;

  @override
  Future<void> saveExercise(Exercise exercise) async {}

  @override
  Future<void> saveExecutionSteps(
    String exerciseId,
    List<ExecutionStep> steps,
  ) async {}

  @override
  Future<void> saveFormCues(
    String exerciseId,
    List<FormCue> cues,
  ) async {}

  @override
  Future<void> saveMuscleActivations(
    String exerciseId,
    List<MuscleActivation> activations,
  ) async {}
}

Exercise _buildExercise({
  String name = 'Incline Dumbbell Hammer Press',
  String? description = 'Neutral wrist torque for the upper chest.',
  String? youtubeUrl = 'https://youtu.be/abc123',
  String? mediaUrl,
}) {
  return Exercise(
    id: 'ex_test',
    name: name,
    equipment: Equipment.dumbbell,
    movementClassification: MovementClassification.compound,
    mediaUrl: mediaUrl,
    youtubeUrl: youtubeUrl,
    biomechanicsNotes: description,
    isCustom: true,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpScreen(
    WidgetTester tester,
    _FakeExerciseRepository repo,
  ) async {
    tester.view.physicalSize = const Size(1200, 7200);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const _WorkoutStub(),
        ),
        GoRoute(
          path: '/workouts/guide/:exerciseId',
          builder: (context, state) => ExerciseDetailsScreen(
            exerciseId: state.pathParameters['exerciseId']!,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          exerciseRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5F3BDC)),
          ),
        ),
      ),
    );

    router.push('/workouts/guide/ex_test');
    await tester.pumpAndSettle();
  }

  group('ExerciseDetailsScreen', () {
    testWidgets('renders every recorded detail', (tester) async {
      final repo = _FakeExerciseRepository(
        exercise: _buildExercise(),
        steps: const [
          ExecutionStep(
            id: 's1',
            exerciseId: 'ex_test',
            stepNumber: 1,
            title: 'Stance & Grip',
            instructions: 'Set the bench at 30 degrees and grip with neutral palms.',
          ),
          ExecutionStep(
            id: 's2',
            exerciseId: 'ex_test',
            stepNumber: 2,
            title: 'Inhale & Descent',
            instructions: 'Tuck the elbows to 45 degrees and lower under control.',
          ),
        ],
        cues: const [
          FormCue(
            id: 'c1',
            exerciseId: 'ex_test',
            isPositive: true,
            description: 'Bend the weights inward to protect the shoulder.',
          ),
          FormCue(
            id: 'c2',
            exerciseId: 'ex_test',
            isPositive: false,
            description: 'Do not flare the elbows away from the torso.',
          ),
        ],
        activations: const [
          MuscleActivation(
            id: 'm1',
            exerciseId: 'ex_test',
            muscleName: 'Chest',
            role: MuscleRole.agonist,
            intensityPercentage: 70,
          ),
          MuscleActivation(
            id: 'm2',
            exerciseId: 'ex_test',
            muscleName: 'Upper Chest',
            role: MuscleRole.synergist,
            intensityPercentage: 55,
          ),
          MuscleActivation(
            id: 'm3',
            exerciseId: 'ex_test',
            muscleName: 'Front Delts',
            role: MuscleRole.stabilizer,
            intensityPercentage: 35,
          ),
        ],
      );

      await pumpScreen(tester, repo);

      // Identity
      expect(find.text('Exercise Details'), findsOneWidget);
      expect(find.text('Incline Dumbbell Hammer Press'), findsWidgets);
      expect(find.text('Neutral wrist torque for the upper chest.'), findsOneWidget);

      // Metadata badges
      expect(find.text('Dumbbell'), findsWidgets);
      expect(find.text('Compound'), findsWidgets);

      // Media + video
      expect(find.text('Watch video guide'), findsOneWidget);

      // Quick specs
      expect(find.text('PRIMARY TARGET'), findsOneWidget);
      expect(find.text('EQUIPMENT'), findsOneWidget);
      expect(find.text('MOVEMENT'), findsOneWidget);

      // Sections
      expect(find.text('Execution Steps'), findsOneWidget);
      expect(find.text('Stance & Grip'), findsOneWidget);
      expect(find.text('2 steps'), findsWidgets);

      expect(find.text('Form Cues'), findsOneWidget);
      expect(find.text('Bend the weights inward to protect the shoulder.'), findsOneWidget);
      expect(find.text('DO'), findsOneWidget);
      expect(find.text("DON'T"), findsOneWidget);

      expect(find.text('Muscles Worked'), findsOneWidget);
      expect(find.text('3 groups'), findsOneWidget);
      expect(find.text('70%'), findsWidgets);
      expect(find.text('55%'), findsOneWidget);
      expect(find.text('35%'), findsOneWidget);

      // Bottom action
      expect(find.text('Back to workout'), findsOneWidget);
      expect(find.text('Add to Workout'), findsNothing);
      expect(find.text('Edit'), findsNothing);
    });

    testWidgets('omits sections that have no recorded data', (tester) async {
      final repo = _FakeExerciseRepository(
        exercise: _buildExercise(
          description: null,
          youtubeUrl: null,
        ),
      );

      await pumpScreen(tester, repo);

      // Name still renders.
      expect(find.text('Incline Dumbbell Hammer Press'), findsWidgets);

      // Empty fields are hidden entirely.
      expect(find.text('Watch video guide'), findsNothing);
      expect(find.text('Execution Steps'), findsNothing);
      expect(find.text('Form Cues'), findsNothing);
      expect(find.text('Muscles Worked'), findsNothing);
      expect(find.text('Neutral wrist torque for the upper chest.'), findsNothing);

      // The quick spec strip keeps the always-present tiles.
      expect(find.text('EQUIPMENT'), findsOneWidget);
      expect(find.text('MOVEMENT'), findsOneWidget);
      expect(find.text('PRIMARY TARGET'), findsNothing);
    });

    testWidgets('shows a friendly error instead of a raw exception', (
      tester,
    ) async {
      final repo = _FakeExerciseRepository();

      await pumpScreen(tester, repo);

      expect(
        find.text('We could not load this exercise right now.'),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('shows a loading state while the exercise is fetched', (
      tester,
    ) async {
      final repo = _FakeExerciseRepository(exercise: _buildExercise());

      tester.view.physicalSize = const Size(1200, 7200);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (context, state) => const _WorkoutStub()),
          GoRoute(
            path: '/workouts/guide/:exerciseId',
            builder: (context, state) => ExerciseDetailsScreen(
              exerciseId: state.pathParameters['exerciseId']!,
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exerciseRepositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme:
                  ColorScheme.fromSeed(seedColor: const Color(0xFF5F3BDC)),
            ),
          ),
        ),
      );

      router.push('/workouts/guide/ex_test');
      await tester.pump();

      expect(find.text('Loading exercise details…'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('Loading exercise details…'), findsNothing);
      expect(find.text('Incline Dumbbell Hammer Press'), findsWidgets);
    });

    testWidgets('the dock action returns to the previous route', (
      tester,
    ) async {
      final repo = _FakeExerciseRepository(exercise: _buildExercise());

      await pumpScreen(tester, repo);

      await tester.tap(find.text('Back to workout'));
      await tester.pumpAndSettle();

      expect(find.byType(_WorkoutStub), findsOneWidget);
    });
  });
}

class _WorkoutStub extends StatelessWidget {
  const _WorkoutStub();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Active workout')));
  }
}
