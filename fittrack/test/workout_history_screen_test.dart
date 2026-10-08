import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittrack/presentation/screens/workout_history_screen.dart';

void main() {
  Widget createTestWidget({required Size screenSize, double textScale = 1.0}) {
    return ProviderScope(
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: screenSize,
            textScaler: TextScaler.linear(textScale),
          ),
          child: const WorkoutHistoryScreen(),
        ),
      ),
    );
  }

  testWidgets(
      'WorkoutHistoryScreen renders all redesigned sections without overflow on standard screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(screenSize: const Size(390, 844)));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    // Verify Header
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Track your past sessions & milestones'), findsOneWidget);

    // Verify Telemetry Stack Header & Content
    expect(find.text('MONTHLY METRICS & TELEMETRY'), findsOneWidget);
    expect(find.text('Volume & Muscle Load'), findsOneWidget);
    expect(find.text('VOLUME LIFTED'), findsOneWidget);
    expect(find.text('ACTIVE STREAK'), findsOneWidget);
    expect(find.text('16'), findsOneWidget);

    // Verify Category Filter Chips
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Push'), findsOneWidget);
    expect(find.text('Pull'), findsOneWidget);
    expect(find.text('Legs'), findsOneWidget);
    expect(find.text('★ PRs only'), findsOneWidget);

    // Verify Month Navigator
    expect(find.text('SEPTEMBER 2026'), findsOneWidget);
    expect(find.text('7 sessions'), findsOneWidget);

    // Verify first session is expanded by default with Repeat Workout and View Details
    expect(find.text('Repeat Workout'), findsOneWidget);
    expect(find.text('View Details'), findsOneWidget);

    // Filter by Push
    await tester.tap(find.text('Push'));
    await tester.pumpAndSettle();

    // Verify filter changed state
    expect(tester.takeException(), isNull);

    // Filter back to All
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'WorkoutHistoryScreen telemetry stack navigates across Calorie and Milestones cards',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(screenSize: const Size(390, 844)));
    await tester.pump();
    await tester.pumpAndSettle();

    // Initially on Card 0: Volume & Muscle Load
    expect(find.text('Volume & Muscle Load'), findsOneWidget);

    // Tap next button on carousel indicator
    final nextBtn = find.bySemanticsLabel('Next metric card');
    expect(nextBtn, findsOneWidget);
    await tester.tap(nextBtn);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    // Now on Card 1: Calorie & Output Dynamics
    expect(find.text('Calorie & Output Dynamics'), findsOneWidget);
    expect(find.text('TOTAL BURN'), findsOneWidget);
    expect(find.text('Bars'), findsOneWidget);
    expect(find.text('Ring'), findsOneWidget);

    // Toggle to Ring view
    await tester.tap(find.text('Ring'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.text('86%'), findsOneWidget);
    expect(find.text('GOAL'), findsOneWidget);

    // Toggle back to Bars view
    await tester.tap(find.text('Bars'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Tap next button again -> Card 2: Milestones & Strength Index
    await tester.tap(nextBtn);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('Milestones & Strength Index'), findsOneWidget);
    expect(find.text('BENCH PRESS'), findsOneWidget);
    expect(find.text('DEADLIFT'), findsOneWidget);
    expect(find.text('BACK SQUAT'), findsOneWidget);
    expect(find.text('Muscle Readiness Score'), findsOneWidget);
  });

  testWidgets(
      'WorkoutHistoryScreen renders without any overflow on narrow screen with larger text scale',
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

    // Verify basic presence
    expect(find.text('History'), findsOneWidget);
    expect(find.text('SEPTEMBER 2026'), findsOneWidget);
  });
}
