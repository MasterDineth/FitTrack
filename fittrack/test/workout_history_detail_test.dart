import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittrack/presentation/screens/workout_history_detail_screen.dart';

void main() {
  Widget createTestWidget({required Size screenSize}) {
    return ProviderScope(
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: screenSize,
            textScaler: const TextScaler.linear(1.0),
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
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    // Verify all 6 metric labels are rendered and visible
    expect(find.text('Duration'), findsOneWidget);
    expect(find.text('Calories'), findsOneWidget);
    expect(find.text('Sets'), findsAtLeastNWidgets(1));
    expect(find.text('Reps'), findsAtLeastNWidgets(1));
    expect(find.text('Volume'), findsAtLeastNWidgets(1));
    expect(find.text('Exercises'), findsOneWidget);

    // Verify metric values
    expect(find.text('380'), findsOneWidget);
    expect(find.text('21'), findsOneWidget);
    expect(find.text('189'), findsOneWidget);
    expect(find.text('6.8k kg'), findsOneWidget);
  });

  testWidgets(
      'WorkoutHistoryDetailScreen renders hero metrics without any overflow on narrow screen with larger text scale',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 640),
              textScaler: TextScaler.linear(1.15),
            ),
            child: const WorkoutHistoryDetailScreen(sessionId: 'mock_1_sch1'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    // Verify all labels and values rendered cleanly without overflowing
    expect(find.text('Duration'), findsOneWidget);
    expect(find.text('Calories'), findsOneWidget);
    expect(find.text('Sets'), findsAtLeastNWidgets(1));
    expect(find.text('Reps'), findsAtLeastNWidgets(1));
    expect(find.text('Volume'), findsAtLeastNWidgets(1));
    expect(find.text('Exercises'), findsOneWidget);
  });
}
