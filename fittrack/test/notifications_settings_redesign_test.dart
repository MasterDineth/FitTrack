import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fittrack/presentation/providers/notifications_provider.dart';
import 'package:fittrack/presentation/providers/shared_preferences_provider.dart';
import 'package:fittrack/presentation/screens/settings/notifications_settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget buildTestApp({ProviderContainer? container}) {
    final app = const MaterialApp(
      home: NotificationsSettingsScreen(),
    );

    if (container != null) {
      return UncontrolledProviderScope(
        container: container,
        child: app,
      );
    }

    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: app,
    );
  }

  group('NotificationsSettingsScreen Redesign - Comprehensive UI Tests', () {
    testWidgets('renders Category A header, title, subtitle, and notification bell',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Live workout, reminders & alerts'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('top notification status card toggles between allowed and blocked',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Starts in allowed mode
      expect(find.text('Device notifications are on'), findsOneWidget);
      expect(
        find.text('Live workout, reminders and summaries can reach you.'),
        findsOneWidget,
      );
      expect(find.text('Enable'), findsNothing);

      // Tap 'Blocked' in simulation bar
      await tester.tap(find.text('Blocked'));
      await tester.pumpAndSettle();

      expect(find.text('Notifications are blocked'), findsOneWidget);
      expect(find.text('Enable'), findsOneWidget);

      // Tap 'Enable' to re-allow
      await tester.tap(find.text('Enable'));
      await tester.pumpAndSettle();

      expect(find.text('Device notifications are on'), findsOneWidget);
    });

    testWidgets(
        'live notification preview switches between Workout, Rest, and Done modes',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // In Workout mode
      expect(find.text('FitTrack · Push Day'), findsOneWidget);
      expect(find.text('2 of 10 exercises · 20%'), findsOneWidget);
      expect(find.text('Bench press · Set 3 of 4'), findsOneWidget);
      expect(find.text('Pause'), findsOneWidget);
      expect(find.text('Complete set'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);

      // Tapping Pause toggles to Resume
      await tester.tap(find.text('Pause'));
      await tester.pump();
      expect(find.text('Resume'), findsOneWidget);

      await tester.tap(find.text('Resume'));
      await tester.pump();
      expect(find.text('Pause'), findsOneWidget);

      // Switch to Rest mode
      await tester.tap(find.text('Rest').first);
      await tester.pumpAndSettle();

      expect(find.text('Rest · 0:45 left'), findsOneWidget);
      expect(find.text('−15s'), findsOneWidget);
      expect(find.text('Skip rest'), findsOneWidget);
      expect(find.text('+15s'), findsOneWidget);

      // Switch to Done mode
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('Workout complete'), findsOneWidget);
      expect(find.text('52 min · 24 sets · 10 exercises'), findsOneWidget);
      expect(find.text('View summary'), findsOneWidget);
      expect(find.text('Dismiss'), findsOneWidget);
    });

    testWidgets(
        'dynamic island preview displays Banner, Live, and Rest modes and 1s, 2s, 3s timer',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Starts in Banner mode
      expect(find.text('New bench PR'), findsOneWidget);
      expect(find.text('85 kg × 8 reps'), findsOneWidget);
      expect(find.text('+5kg'), findsOneWidget);

      // Tap 'Live' in Dynamic Island segmented bar
      final liveButton = find.widgetWithText(GestureDetector, 'Live').first;
      await tester.ensureVisible(liveButton);
      await tester.pumpAndSettle();
      await tester.tap(liveButton);
      await tester.pumpAndSettle();

      expect(find.text('Push Day · 2 of 10'), findsOneWidget);
      expect(find.text('2/10'), findsOneWidget);

      // Tap 'Rest' in Dynamic Island segmented bar
      final restButtons = find.text('Rest');
      await tester.ensureVisible(restButtons.at(1));
      await tester.pumpAndSettle();
      await tester.tap(restButtons.at(1));
      await tester.pumpAndSettle();

      expect(find.text('Rest · 0:45 left'), findsWidgets);
      expect(find.text('Skip'), findsOneWidget);

      // Check banner stay duration segmented options: 1s, 2s, 3s
      expect(find.text('1s'), findsOneWidget);
      expect(find.text('2s'), findsOneWidget);
      expect(find.text('3s'), findsOneWidget);

      // Tap 3s
      final btn3s = find.text('3s');
      await tester.ensureVisible(btn3s);
      await tester.pumpAndSettle();
      await tester.tap(btn3s);
      await tester.pumpAndSettle();
    });

    testWidgets(
        'device notifications expandable cards render and repeat day chips work',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Check section header
      expect(find.text('DEVICE NOTIFICATIONS'), findsOneWidget);
      expect(find.text('Live workout'), findsOneWidget);
      expect(find.text('Workout reminders'), findsOneWidget);
      expect(find.text('Water reminders'), findsOneWidget);
      expect(find.text('Summaries'), findsOneWidget);
      expect(find.text('Achievements'), findsOneWidget);
      expect(find.text('Important alerts'), findsOneWidget);

      // Expand Workout Reminders
      final workoutReminders = find.text('Workout reminders');
      await tester.ensureVisible(workoutReminders);
      await tester.pumpAndSettle();
      await tester.tap(workoutReminders);
      await tester.pumpAndSettle();

      expect(find.text('REPEAT DAYS'), findsOneWidget);
      expect(find.text('Remind me at'), findsOneWidget);
      expect(find.text('Skip if I already trained today'), findsOneWidget);

      // Important alerts is locked always on
      final importantAlerts = find.text('Important alerts');
      await tester.ensureVisible(importantAlerts);
      await tester.pumpAndSettle();
      await tester.tap(importantAlerts);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    });

    testWidgets(
        'Quiet hours, sound toggles, and send test notification action trigger feedback',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      await tester.pumpWidget(buildTestApp(container: container));
      await tester.pumpAndSettle();

      expect(find.text('QUIET HOURS'), findsOneWidget);
      expect(find.text('Quiet hours'), findsOneWidget);
      expect(find.text('FEEL AND SOUND'), findsOneWidget);
      expect(find.text('Haptic feedback'), findsOneWidget);
      expect(find.text('Sounds and timer countdown beeps'), findsOneWidget);

      // Check system settings button before sending test notification
      final sysBtn = find.text('System settings');
      await tester.ensureVisible(sysBtn);
      await tester.pumpAndSettle();
      expect(sysBtn, findsOneWidget);
      await tester.tap(sysBtn);
      await tester.pump();

      // Send test notification button - scrolls to top
      final sendBtn = find.text('Send test notification');
      await tester.ensureVisible(sendBtn);
      await tester.pumpAndSettle();
      expect(sendBtn, findsOneWidget);
      await tester.tap(sendBtn);
      await tester.pump();

      // Verifies notification island receives an active item
      final islandItem = container.read(notificationIslandProvider);
      expect(islandItem, isNotNull);
      expect(islandItem!.title, contains('New bench PR'));

      // Wait for scroll animation to settle at top
      await tester.pumpAndSettle();
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      expect(scrollable.position.pixels, equals(0.0));

      // Drain pending notification island auto-collapse timer (2 seconds)
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });
  });
}
