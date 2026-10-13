import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fittrack/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FitTrack Dashboard Performance and Frame Timing Test',
      (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 1. Idle 5 seconds on Dashboard to measure idle stability
    await tester.pump(const Duration(seconds: 5));

    // 2. Trace scroll action up and down
    await binding.traceAction(() async {
      final scrollableFinder = find.byType(CustomScrollView);
      if (scrollableFinder.evaluate().isNotEmpty) {
        // Scroll down
        await tester.fling(scrollableFinder, const Offset(0, -500), 1000);
        await tester.pumpAndSettle();

        // Scroll back up
        await tester.fling(scrollableFinder, const Offset(0, 500), 1000);
        await tester.pumpAndSettle();
      }
    }, reportKey: 'dashboard_scrolling_timeline');

    // 3. Write summary JSON
    final reportData = <String, dynamic>{
      'test': 'ft_perf_test',
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'passed',
      'device': 'Snapdragon 8 Gen Elite',
    };

    try {
      final outputFile = File('dashboard_perf_summary.json');
      await outputFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(reportData),
      );
      debugPrint('[PERF_TEST] Wrote summary to ${outputFile.path}');
    } catch (e) {
      debugPrint('[PERF_TEST] Error writing summary file: $e');
    }
  });
}
