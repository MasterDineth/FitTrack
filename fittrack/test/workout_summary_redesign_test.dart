import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fittrack/domain/entities/schedule.dart';
import 'package:fittrack/domain/entities/schedule_exercise.dart';
import 'package:fittrack/domain/entities/exercise.dart';
import 'package:fittrack/presentation/providers/active_workout_provider.dart';
import 'package:fittrack/presentation/screens/workout_summary/workout_summary_screen.dart';
import 'package:fittrack/presentation/screens/workout_summary/widgets/workout_summary_bento_grid.dart';
import 'package:fittrack/presentation/screens/workout_summary/widgets/workout_summary_header.dart';
import 'package:fittrack/presentation/screens/workout_summary/widgets/workout_summary_hero_card.dart';
import 'package:fittrack/presentation/screens/workout_summary/widgets/workout_summary_muscle_breakdown.dart';
import 'package:fittrack/presentation/screens/workout_summary/widgets/workout_summary_notes_card.dart';
import 'package:fittrack/presentation/screens/workout_summary/widgets/workout_summary_rpe_card.dart';
import 'package:fittrack/presentation/screens/workout_summary/widgets/workout_summary_bottom_dock.dart';

class _TestWorkoutNotifier extends ActiveWorkoutNotifier {
  _TestWorkoutNotifier(this._initialState);
  final ActiveWorkoutState _initialState;

  @override
  ActiveWorkoutState build() => _initialState;
}

void main() {
  const testSchedule = Schedule(
    id: 'sched_summary_test',
    name: 'Day 1 – Chest, Shoulders & Triceps',
    description: 'Hypertrophy push routine',
    targetMuscles: ['Chest', 'Shoulders', 'Triceps'],
    assignedWeekdays: [1, 3, 5],
    orderIndex: 0,
  );

  final testExercise1 = const Exercise(
    id: 'ex1',
    name: 'BB Bench Press',
    equipment: Equipment.barbell,
    movementClassification: MovementClassification.compound,
  );

  final testExercise2 = const Exercise(
    id: 'ex2',
    name: 'Incline DB Press',
    equipment: Equipment.dumbbell,
    movementClassification: MovementClassification.compound,
  );

  final testEntry1 = LiveExerciseEntry(
    scheduleExercise: const ScheduleExercise(
      id: 'se1',
      scheduleId: 'sched_summary_test',
      exerciseId: 'ex1',
      sortOrder: 1,
      targetSets: 3,
      targetReps: 10,
      targetWeightKg: 80.0,
      restDurationSeconds: 90,
    ),
    exercise: testExercise1,
  );

  final testEntry2 = LiveExerciseEntry(
    scheduleExercise: const ScheduleExercise(
      id: 'se2',
      scheduleId: 'sched_summary_test',
      exerciseId: 'ex2',
      sortOrder: 2,
      targetSets: 3,
      targetReps: 10,
      targetWeightKg: 30.0,
      restDurationSeconds: 90,
    ),
    exercise: testExercise2,
  );

  final completedSets = [
    CompletedSetEntry(
      scheduleExerciseId: 'se1',
      exerciseId: 'ex1',
      setNumber: 1,
      actualReps: 10,
      actualWeightKg: 80.0,
      targetReps: 10,
      targetWeightKg: 80.0,
      restDurationSeconds: 90,
      completedAt: DateTime.now(),
    ),
    CompletedSetEntry(
      scheduleExerciseId: 'se1',
      exerciseId: 'ex1',
      setNumber: 2,
      actualReps: 10,
      actualWeightKg: 80.0,
      targetReps: 10,
      targetWeightKg: 80.0,
      restDurationSeconds: 90,
      completedAt: DateTime.now(),
    ),
    CompletedSetEntry(
      scheduleExerciseId: 'se2',
      exerciseId: 'ex2',
      setNumber: 1,
      actualReps: 10,
      actualWeightKg: 30.0,
      targetReps: 10,
      targetWeightKg: 30.0,
      restDurationSeconds: 90,
      completedAt: DateTime.now(),
    ),
  ];

  final testState = ActiveWorkoutState(
    phase: WorkoutPhase.finished,
    schedule: testSchedule,
    entries: [testEntry1, testEntry2],
    currentExerciseIndex: 1,
    currentSetIndex: 2,
    elapsedSeconds: 3000, // 50 mins
    restRemainingSeconds: 0,
    completedSets: completedSets,
  );

  group('WorkoutSummaryScreen Redesign Tests', () {
    testWidgets('renders all redesigned sections without overflow on standard screen',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeWorkoutProvider.overrideWith(
              () => _TestWorkoutNotifier(testState),
            ),
          ],
          child: const MaterialApp(
            home: WorkoutSummaryScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // 1. Header
      expect(find.byType(WorkoutSummaryHeader), findsOneWidget);
      expect(find.text('Workout Summary'), findsOneWidget);
      expect(find.text('Review completed sets, volume & records'), findsOneWidget);

      // 2. Hero Card
      expect(find.byType(WorkoutSummaryHeroCard), findsOneWidget);
      expect(find.text('COMPLETED WORKOUT'), findsOneWidget);
      expect(find.text('Day 1 – Chest, Shoulders & Triceps'), findsOneWidget);
      expect(find.text('100% Completed'), findsOneWidget);

      // 3. Bento Grid
      expect(find.byType(WorkoutSummaryBentoGrid), findsOneWidget);
      expect(find.text('DURATION'), findsOneWidget);
      expect(find.text('VOLUME'), findsOneWidget);
      expect(find.text('TOTAL SETS'), findsOneWidget);
      expect(find.text('ENERGY'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);

      // 4. Muscle Volume Breakdown
      expect(find.byType(WorkoutSummaryMuscleBreakdown), findsOneWidget);
      expect(find.text('Muscle Volume Breakdown'), findsOneWidget);
      expect(find.text('Volume distribution by group'), findsOneWidget);

      // 5. RPE Card
      expect(find.byType(WorkoutSummaryRpeCard), findsOneWidget);
      expect(find.text('Perceived Exertion (RPE)'), findsOneWidget);
      expect(find.text('MODERATE'), findsOneWidget);
      expect(find.text('BRISK'), findsOneWidget);
      expect(find.text('HARD'), findsOneWidget);
      expect(find.text('1 IN TANK'), findsOneWidget);
      expect(find.text('MAX OUT'), findsOneWidget);

      // 6. Notes Card
      expect(find.byType(WorkoutSummaryNotesCard), findsOneWidget);
      expect(find.text('Lifter Reflection & Notes'), findsOneWidget);

      // 7. Sticky Bottom Dock
      expect(find.byType(WorkoutSummaryBottomDock), findsOneWidget);
      expect(find.text('Save & Complete Session'), findsOneWidget);
    });

    testWidgets('RPE selection updates selected rating and intensity chip',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeWorkoutProvider.overrideWith(
              () => _TestWorkoutNotifier(testState),
            ),
          ],
          child: const MaterialApp(
            home: WorkoutSummaryScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Initial default is RPE 9.0 · Intense
      expect(find.text('RPE 9.0'), findsOneWidget);
      expect(find.text('Intense'), findsOneWidget);

      // Tap RPE 7 (Brisk)
      final rpe7Finder = find.descendant(
        of: find.byType(WorkoutSummaryRpeCard),
        matching: find.text('7'),
      );
      await tester.scrollUntilVisible(
        rpe7Finder,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(rpe7Finder);
      await tester.pumpAndSettle();

      expect(find.text('RPE 7.0'), findsOneWidget);
      expect(find.text('Moderate'), findsOneWidget);

      // Tap RPE 10 (Max Out)
      final rpe10Finder = find.descendant(
        of: find.byType(WorkoutSummaryRpeCard),
        matching: find.text('10'),
      );
      await tester.scrollUntilVisible(
        rpe10Finder,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(rpe10Finder);
      await tester.pumpAndSettle();

      expect(find.text('RPE 10.0'), findsOneWidget);
      expect(find.text('Extreme'), findsOneWidget);
    });
  });
}
