import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/presentation/providers/active_workout_provider.dart';
import 'package:fittrack/presentation/widgets/modals/discard_workout_modal.dart';
import 'package:fittrack/presentation/widgets/modals/save_session_modal.dart';
import 'package:fittrack/presentation/widgets/modals/leave_without_saving_modal.dart';
import 'package:fittrack/domain/entities/schedule.dart';
import 'package:fittrack/domain/entities/schedule_exercise.dart';
import 'package:fittrack/domain/entities/exercise.dart';

void main() {
  const testSchedule = Schedule(
    id: 's1',
    name: 'Day 1: Chest & Triceps',
    description: 'Push day routine',
    targetMuscles: ['Chest', 'Triceps'],
    assignedWeekdays: [1],
    orderIndex: 0,
  );

  const testExercise = Exercise(
    id: 'e1',
    name: 'Bench Press',
    equipment: Equipment.barbell,
    movementClassification: MovementClassification.compound,
  );

  const testScheduleExercise = ScheduleExercise(
    id: 'se1',
    scheduleId: 's1',
    exerciseId: 'e1',
    sortOrder: 0,
    targetSets: 3,
    targetReps: 10,
    targetWeightKg: 60.0,
    restDurationSeconds: 60,
  );

  final liveEntry = LiveExerciseEntry(
    scheduleExercise: testScheduleExercise,
    exercise: testExercise,
  );

  final testState = ActiveWorkoutState(
    phase: WorkoutPhase.active,
    schedule: testSchedule,
    entries: [liveEntry],
    currentExerciseIndex: 0,
    currentSetIndex: 0,
    elapsedSeconds: 124, // 02:04
    restRemainingSeconds: 0,
    completedSets: [],
  );

  testWidgets('DiscardWorkoutModal renders elements correctly',
      (WidgetTester tester) async {
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
              child: const Text('Open Modal'),
            ),
          ),
        ),
      ),
    );

    // Open modal
    await tester.tap(find.text('Open Modal'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Warning headline, telemetry, and buttons
    expect(find.text('Discard Workout?'), findsOneWidget);
    expect(find.text('UNLOGGED PROGRESS'), findsOneWidget);
    expect(find.text('02:04'), findsOneWidget);
    expect(find.text('Resume Workout'), findsOneWidget);
    expect(find.text('Hold to Discard (1.25s)'), findsOneWidget);

    // Tapping briefly should NOT discard (requires 1.25-second hold)
    await tester.tap(find.text('Hold to Discard (1.25s)'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(discarded, isFalse);

    // Long press and hold for 1.35 seconds to discard
    final center = tester.getCenter(find.text('Hold to Discard (1.25s)'));
    final gesture = await tester.startGesture(center);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1350));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(discarded, isTrue);
  });

  testWidgets('SaveSessionModal renders elements correctly',
      (WidgetTester tester) async {
    var saved = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showSaveSessionModal(
                context,
                state: testState,
                onSave: () async => saved = true,
              ),
              child: const Text('Open Modal'),
            ),
          ),
        ),
      ),
    );

    // Open modal
    await tester.tap(find.text('Open Modal'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify title, stats, buttons
    expect(find.text('Save this session?'), findsOneWidget);
    expect(find.text('SESSION PROGRESS'), findsOneWidget);
    expect(find.text('02:04'), findsOneWidget);
    expect(find.text('Yes, Save It'), findsOneWidget);
    expect(find.text('Keep Training'), findsOneWidget);

    // Tap Yes, Save It
    await tester.tap(find.text('Yes, Save It'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(saved, isTrue);
  });

  testWidgets('LeaveWithoutSavingModal renders elements correctly',
      (WidgetTester tester) async {
    bool? userLeft;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                userLeft = await showLeaveWithoutSavingModal(context);
              },
              child: const Text('Open Modal'),
            ),
          ),
        ),
      ),
    );

    // Open modal
    await tester.tap(find.text('Open Modal'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify badge, title, subtitle, buttons
    expect(find.text('UNSAVED SUMMARY'), findsOneWidget);
    expect(find.text('Leave without saving?'), findsOneWidget);
    expect(find.text('Stay on Summary'), findsOneWidget);
    expect(find.text('Leave without Saving'), findsOneWidget);

    // Tap Leave
    await tester.tap(find.text('Leave without Saving'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(userLeft, isTrue);
  });
}
