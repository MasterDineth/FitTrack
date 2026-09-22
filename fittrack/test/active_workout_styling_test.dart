import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittrack/presentation/providers/active_workout_provider.dart';
import 'package:fittrack/presentation/widgets/active_rest_timer_view.dart';
import 'package:fittrack/presentation/screens/active_workout_screen.dart';
import 'package:fittrack/domain/entities/schedule.dart';
import 'package:fittrack/domain/entities/schedule_exercise.dart';
import 'package:fittrack/domain/entities/exercise.dart';

void main() {
  const testSchedule = Schedule(
    id: 's1',
    name: 'Day 1: Chest, Shoulders & Triceps',
    description: 'Push day routine',
    targetMuscles: ['Chest', 'Triceps'],
    assignedWeekdays: [1],
    orderIndex: 0,
  );

  const testExercise = Exercise(
    id: 'e1',
    name: 'Lateral Raises',
    equipment: Equipment.dumbbell,
    movementClassification: MovementClassification.isolation,
  );

  const testScheduleExercise = ScheduleExercise(
    id: 'se1',
    scheduleId: 's1',
    exerciseId: 'e1',
    sortOrder: 0,
    targetSets: 4,
    targetReps: 15,
    targetWeightKg: 10.0,
    restDurationSeconds: 60,
  );

  final liveEntry = LiveExerciseEntry(
    scheduleExercise: testScheduleExercise,
    exercise: testExercise,
  );

  testWidgets('ActiveRestTimerView has dark green border and glow effect',
      (WidgetTester tester) async {
    final restingState = ActiveWorkoutState(
      phase: WorkoutPhase.resting,
      schedule: testSchedule,
      entries: [liveEntry],
      currentExerciseIndex: 0,
      currentSetIndex: 0,
      elapsedSeconds: 112,
      restRemainingSeconds: 55,
      completedSets: [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeWorkoutProvider.overrideWith(
            () => _StaticWorkoutNotifier(restingState),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ActiveRestTimerView(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify circular card container has no border and has dark green glow
    final containerFinder = find.byWidgetPredicate((widget) {
      if (widget is Container && widget.decoration is BoxDecoration) {
        final dec = widget.decoration as BoxDecoration;
        if (dec.border == null && dec.boxShadow != null) {
          return dec.boxShadow!.any((s) => s.color == const Color(0xFF166534).withValues(alpha: 0.20));
        }
      }
      return false;
    });

    expect(containerFinder, findsOneWidget);

    final container = tester.widget<Container>(containerFinder);
    final dec = container.decoration as BoxDecoration;
    expect(dec.border, isNull);
    expect(
      dec.boxShadow!.any((s) => s.color == const Color(0xFF166534).withValues(alpha: 0.20)),
      isTrue,
    );
  });

  testWidgets('ActiveWorkoutScreen bottom stats bar has frosted glass BackdropFilter and glow',
      (WidgetTester tester) async {
    final activeState = ActiveWorkoutState(
      phase: WorkoutPhase.active,
      schedule: testSchedule,
      entries: [liveEntry],
      currentExerciseIndex: 0,
      currentSetIndex: 0,
      elapsedSeconds: 85,
      restRemainingSeconds: 0,
      completedSets: [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeWorkoutProvider.overrideWith(
            () => _StaticWorkoutNotifier(activeState),
          ),
        ],
        child: const MaterialApp(
          home: ActiveWorkoutScreen(scheduleId: 's1'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // Verify BackdropFilter with blur exists for the frosted glass footer
    final backdropFinder = find.byType(BackdropFilter);
    expect(backdropFinder, findsAtLeastNWidgets(1));

    // Verify the footer metrics are rendered clearly
    expect(find.text('DONE'), findsOneWidget);
    expect(find.text('KCAL'), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Stop Session'), findsOneWidget);

    // Verify the active workout card has no border and has dark green glow
    final activeCardContainer = find.byWidgetPredicate((widget) {
      if (widget is Container && widget.decoration is BoxDecoration) {
        final dec = widget.decoration as BoxDecoration;
        if (dec.border == null && dec.boxShadow != null) {
          return dec.boxShadow!.any(
            (s) => s.color == const Color(0xFF166534).withValues(alpha: 0.20),
          );
        }
      }
      return false;
    });

    expect(activeCardContainer, findsOneWidget);
  });
}

class _StaticWorkoutNotifier extends ActiveWorkoutNotifier {
  _StaticWorkoutNotifier(this._initialState);
  final ActiveWorkoutState _initialState;

  @override
  ActiveWorkoutState build() => _initialState;
}
