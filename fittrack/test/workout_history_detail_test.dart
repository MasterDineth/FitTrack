import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittrack/presentation/screens/workout_history_detail_screen.dart';
import 'package:fittrack/presentation/providers/workout_history_provider.dart';
import 'package:fittrack/domain/entities/workout_session.dart';
import 'package:fittrack/domain/entities/schedule.dart';
import 'package:fittrack/domain/entities/exercise.dart';
import 'package:fittrack/domain/entities/exercise_log.dart';
import 'package:fittrack/domain/entities/set_log.dart';

void main() {
  final testSession = WorkoutSession(
    id: 'mock_1_sch1',
    scheduleId: 'sch1',
    startTime: DateTime(2026, 9, 30, 13, 27),
    endTime: DateTime(2026, 9, 30, 14, 17),
    durationSeconds: 3000,
    totalCalories: 380,
    notes: 'Felt great — hit a new bench PR today!',
    intensity: 'Intense Session',
    totalSets: 18,
    totalReps: 173,
    totalVolumeKg: 7601.0,
  );

  final testSchedule = const Schedule(
    id: 'sch1',
    name: 'Day 1 – Chest, Shoulders & Triceps',
    description: 'High mechanical tension',
    targetMuscles: ['Chest', 'Shoulders', 'Triceps'],
    assignedWeekdays: [1, 4],
    orderIndex: 1,
    focus: 'Hypertrophy Focus',
  );

  final testBenchEx = const Exercise(
    id: 'ex1',
    name: 'Barbell Bench Press',
    equipment: Equipment.barbell,
    movementClassification: MovementClassification.compound,
  );

  final testItems = [
    ExerciseDetailLogItem(
      log: const ExerciseLog(
        id: 'log1',
        sessionId: 'mock_1_sch1',
        exerciseId: 'ex1',
        orderIndex: 0,
      ),
      exercise: testBenchEx,
      sets: const [
        SetLog(
          id: 's1',
          exerciseLogId: 'log1',
          setNumber: 1,
          actualReps: 8,
          targetReps: 8,
          actualWeightKg: 100.0,
          targetWeightKg: 100.0,
          isCompleted: true,
          restDurationSeconds: 90,
        ),
        SetLog(
          id: 's2',
          exerciseLogId: 'log1',
          setNumber: 2,
          actualReps: 8,
          targetReps: 8,
          actualWeightKg: 102.5,
          targetWeightKg: 102.5,
          isCompleted: true,
          restDurationSeconds: 90,
        ),
      ],
      totalVolumeKg: 1620.0,
      hasPr: true,
    ),
  ];

  final testDetailData = WorkoutSessionDetailData(
    session: testSession,
    schedule: testSchedule,
    exercises: testItems,
    muscleVolumePercentages: {
      'Chest': 52.0,
      'Triceps': 29.0,
      'Shoulders': 19.0,
    },
    completedExercisesCount: 6,
    totalExercisesCount: 7,
    hasNotes: true,
  );

  Widget createTestWidget({required Size screenSize, double textScale = 1.0}) {
    return ProviderScope(
      overrides: [
        workoutSessionDetailProvider('mock_1_sch1').overrideWith(
          (ref) => Future.value(testDetailData),
        ),
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: screenSize,
            textScaler: TextScaler.linear(textScale),
          ),
          child: const WorkoutHistoryDetailScreen(sessionId: 'mock_1_sch1'),
        ),
      ),
    );
  }

  testWidgets(
      'WorkoutHistoryDetailScreen renders hero metrics without any overflow on standard screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(screenSize: const Size(390, 844)));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    // Verify all 6 metric labels are rendered and visible
    expect(find.text('DURATION'), findsOneWidget);
    expect(find.text('VOLUME'), findsOneWidget);
    expect(find.text('ENERGY'), findsOneWidget);
    expect(find.text('SETS'), findsAtLeastNWidgets(1));
    expect(find.text('REPS'), findsAtLeastNWidgets(1));
    expect(find.text('EXERCISES'), findsOneWidget);

    // Verify metric values
    expect(find.text('50'), findsOneWidget);
    expect(find.text('7,601'), findsOneWidget);
    expect(find.text('380'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('173'), findsOneWidget);

    // Verify Repeat Workout button
    expect(find.text('Repeat workout'), findsOneWidget);

    // Scroll down to exercises section
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text('Barbell Bench Press'), findsOneWidget);
    expect(find.text('Volume by muscle'), findsOneWidget);

    // Verify Set Table header & PR badge
    expect(find.text('SET'), findsOneWidget);
    expect(find.text('PR'), findsOneWidget);
    expect(find.text('COLLAPSE ALL'), findsOneWidget);

    // Tap COLLAPSE ALL -> items collapse, toggle becomes EXPAND ALL
    await tester.tap(find.text('COLLAPSE ALL'));
    await tester.pumpAndSettle();
    expect(find.text('EXPAND ALL'), findsOneWidget);
    expect(find.text('SET'), findsNothing);

    // Tap EXPAND ALL -> items expand, toggle becomes COLLAPSE ALL
    await tester.tap(find.text('EXPAND ALL'));
    await tester.pumpAndSettle();
    expect(find.text('COLLAPSE ALL'), findsOneWidget);
    expect(find.text('SET'), findsOneWidget);
  });

  testWidgets(
      'WorkoutHistoryDetailScreen renders hero metrics without any overflow on narrow screen with larger text scale',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(
      screenSize: const Size(320, 640),
      textScale: 1.15,
    ));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    // Verify all labels and values rendered cleanly without overflowing
    expect(find.text('DURATION'), findsOneWidget);
    expect(find.text('VOLUME'), findsOneWidget);
    expect(find.text('ENERGY'), findsOneWidget);
    expect(find.text('SETS'), findsAtLeastNWidgets(1));
    expect(find.text('REPS'), findsAtLeastNWidgets(1));
    expect(find.text('EXERCISES'), findsOneWidget);
  });
}
