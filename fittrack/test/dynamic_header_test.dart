import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/presentation/providers/notifications_provider.dart';
import 'package:fittrack/presentation/screens/create_exercise/widgets/create_exercise_header.dart';
import 'package:fittrack/presentation/screens/create_schedule/widgets/create_schedule_header.dart';
import 'package:fittrack/presentation/screens/dashboard/widgets/dashboard_header.dart';
import 'package:fittrack/presentation/screens/settings/widgets/settings_header.dart';
import 'package:fittrack/presentation/screens/workout_history/widgets/workout_history_header.dart';
import 'package:fittrack/presentation/screens/workout_history_detail/widgets/workout_detail_header.dart'
    as hist_detail;
import 'package:fittrack/presentation/screens/workout_search_screen.dart';
import 'package:fittrack/presentation/screens/workouts_screen.dart';
import 'package:fittrack/presentation/widgets/header/header.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Task 4: FtDynamicHeader Core & Motion Tests', () {
    testWidgets('renders leftChild, trailing avatar, and collapsed bell in resting state',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 393,
                  child: FtDynamicHeader(
                    leftChild: Text('Test Title'),
                    trailing: FtHeaderAvatar(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byType(FtHeaderAvatar), findsOneWidget);
      expect(find.byType(FtNotificationBell), findsOneWidget);

      // Verify exact 8.0dp spacing between bell and avatar
      final bellRect = tester.getRect(find.byType(FtNotificationBell));
      final avatarRect = tester.getRect(find.byType(FtHeaderAvatar));
      final gap = avatarRect.left - bellRect.right;
      expect(gap, equals(8.0));
    });

    testWidgets('notification arrival expands dynamic island and fades leftChild & avatar',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 393,
                  child: FtDynamicHeader(
                    leftChild: Text('Visible Title'),
                    trailing: FtHeaderAvatar(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Trigger notification
      container.read(notificationIslandProvider.notifier).show(
            FtNotificationItem(
              id: 'island_motion_1',
              type: FtNotificationType.pr,
              title: 'New PR Logged',
              body: 'Bench Press 100kg reached',
              timestamp: DateTime.now(),
            ),
          );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Island content is rendered
      expect(find.text('New PR Logged '), findsOneWidget);
      expect(find.text('Bench Press 100kg reached'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_active_rounded), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Left child and avatar are faded out (opacity 0.0)
      final leftOpacityFinder = find.ancestor(
        of: find.text('Visible Title'),
        matching: find.byType(AnimatedOpacity),
      );
      final leftOpacityWidget =
          tester.widget<AnimatedOpacity>(leftOpacityFinder.first);
      expect(leftOpacityWidget.opacity, equals(0.0));

      final avatarOpacityFinder = find.ancestor(
        of: find.byType(FtHeaderAvatar),
        matching: find.byType(AnimatedOpacity),
      );
      final avatarOpacityWidget =
          tester.widget<AnimatedOpacity>(avatarOpacityFinder.first);
      expect(avatarOpacityWidget.opacity, equals(0.0));

      // Auto-collapse after 2.0s
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();
      expect(find.byType(FtNotificationBell), findsOneWidget);
    });

    testWidgets('manual dismiss button tap collapses island immediately without opening shade',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 393,
                  child: FtDynamicHeader(
                    leftChild: Text('Sample Title'),
                    trailing: FtHeaderAvatar(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      container.read(notificationIslandProvider.notifier).show(
            FtNotificationItem(
              id: 'island_dismiss_tap',
              type: FtNotificationType.hydration,
              title: 'Hydration Target',
              body: 'Drink 250ml water',
              timestamp: DateTime.now(),
            ),
          );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Dismiss button is present
      final dismissFinder = find.byIcon(Icons.close_rounded);
      expect(dismissFinder, findsOneWidget);

      // Tap dismiss
      await tester.tap(dismissFinder);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(container.read(notificationIslandProvider), isNull);
      expect(container.read(notificationShadeProvider).isOpen, isFalse);
      expect(find.byType(FtNotificationBell), findsOneWidget);
    });

    testWidgets('swipe-up on expanded island collapses island immediately',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 393,
                  child: FtDynamicHeader(
                    leftChild: Text('Swipe Title'),
                    trailing: FtHeaderAvatar(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      container.read(notificationIslandProvider.notifier).show(
            FtNotificationItem(
              id: 'island_swipe_test',
              type: FtNotificationType.strain,
              title: 'Strain Alert',
              body: 'Daily strain optimal',
              timestamp: DateTime.now(),
            ),
          );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Fling/swipe up on the expanded island
      await tester.fling(
        find.text('Strain Alert '),
        const Offset(0, -300),
        1000.0,
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(container.read(notificationIslandProvider), isNull);
      expect(container.read(notificationShadeProvider).isOpen, isFalse);
    });

    testWidgets('tapping expanded island body opens global notification shade',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 393,
                  child: FtDynamicHeader(
                    leftChild: Text('Body Tap Title'),
                    trailing: FtHeaderAvatar(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      container.read(notificationIslandProvider.notifier).show(
            FtNotificationItem(
              id: 'island_body_tap',
              type: FtNotificationType.habit,
              title: 'System Notice',
              body: 'Battery optimization enabled',
              timestamp: DateTime.now(),
            ),
          );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Tap on title text (inside island body)
      await tester.tap(find.text('System Notice '));
      await tester.pumpAndSettle();

      expect(container.read(notificationShadeProvider).isOpen, isTrue);
    });

    testWidgets('honors MediaQuery.disableAnimationsOf without throwing',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: true),
              child: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 393,
                    child: FtDynamicHeader(
                      leftChild: Text('Reduced Motion'),
                      trailing: FtHeaderAvatar(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      container.read(notificationIslandProvider.notifier).show(
            FtNotificationItem(
              id: 'reduced_motion_item',
              type: FtNotificationType.habit,
              title: 'Streak Active',
              body: '5 days in a row',
              timestamp: DateTime.now(),
            ),
          );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Streak Active '), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();
      expect(find.byType(FtNotificationBell), findsOneWidget);
    });
  });

  group('Task 4: Universal Screen Migration Tests', () {
    testWidgets('DashboardHeader works seamlessly with FtDynamicHeader and expands on notification',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 393,
                  child: DashboardHeader(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('FitTrack'), findsOneWidget);
      expect(find.byType(FtNotificationBell), findsOneWidget);
      expect(find.byType(FtHeaderAvatar), findsOneWidget);

      container.read(notificationIslandProvider.notifier).show(
            FtNotificationItem(
              id: 'dash_island_test',
              type: FtNotificationType.hydration,
              title: 'Hydration Target',
              body: 'Drink 250ml water',
              timestamp: DateTime.now(),
            ),
          );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Hydration Target '), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();
      expect(find.byType(FtNotificationBell), findsOneWidget);
    });

    testWidgets('WorkoutsScreen header works seamlessly with FtDynamicHeader and expands on notification',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: WorkoutsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Workouts'), findsOneWidget);
      expect(find.text('Explore splits, routines & programs'), findsOneWidget);
      expect(find.byType(FtNotificationBell), findsOneWidget);
      expect(find.byType(FtHeaderAvatar), findsOneWidget);

      container.read(notificationIslandProvider.notifier).show(
            FtNotificationItem(
              id: 'workouts_island_test',
              type: FtNotificationType.pr,
              title: 'Personal Record',
              body: 'Squat 140kg achieved',
              timestamp: DateTime.now(),
            ),
          );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Personal Record '), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();
      expect(find.byType(FtNotificationBell), findsOneWidget);
    });

    testWidgets('WorkoutHistoryHeader works seamlessly with FtDynamicHeader and expands on notification',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: WorkoutHistoryHeader(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('History'), findsOneWidget);
      expect(find.text('Track your past sessions & milestones'), findsOneWidget);
      expect(find.byType(FtNotificationBell), findsOneWidget);
      expect(find.byType(FtHeaderAvatar), findsOneWidget);

      container.read(notificationIslandProvider.notifier).show(
            FtNotificationItem(
              id: 'history_island_test',
              type: FtNotificationType.strain,
              title: 'Peak Strain',
              body: 'Target achieved',
              timestamp: DateTime.now(),
            ),
          );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Peak Strain '), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();
      expect(find.byType(FtNotificationBell), findsOneWidget);
    });

    testWidgets('SettingsHeader works seamlessly with FtDynamicHeader and expands on notification',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: SettingsHeader(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(
        find.text('Manage your account, preferences & hardware'),
        findsOneWidget,
      );
      expect(find.byType(FtNotificationBell), findsOneWidget);
      expect(find.byType(FtHeaderAvatar), findsOneWidget);

      container.read(notificationIslandProvider.notifier).show(
            FtNotificationItem(
              id: 'settings_island_test',
              type: FtNotificationType.habit,
              title: 'Sync Done',
              body: 'Cloud synced',
              timestamp: DateTime.now(),
            ),
          );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Sync Done '), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();
      expect(find.byType(FtNotificationBell), findsOneWidget);
    });

    testWidgets('CreateScheduleHeader works seamlessly with FtDynamicHeader and expands on notification',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: CreateScheduleHeader(onBackTap: () {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('New Schedule'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byType(FtNotificationBell), findsOneWidget);
      expect(find.byType(FtHeaderAvatar), findsOneWidget);

      container.read(notificationIslandProvider.notifier).show(
            FtNotificationItem(
              id: 'schedule_island_test',
              type: FtNotificationType.habit,
              title: 'Streak Logged',
              body: '3 weeks consistent',
              timestamp: DateTime.now(),
            ),
          );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Streak Logged '), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();
      expect(find.byType(FtNotificationBell), findsOneWidget);
    });

    testWidgets('CreateExerciseHeader works seamlessly with FtDynamicHeader and expands on notification',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: CreateExerciseHeader(onBackTap: () {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create Exercise'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byType(FtNotificationBell), findsOneWidget);
      expect(find.byType(FtHeaderAvatar), findsOneWidget);

      container.read(notificationIslandProvider.notifier).show(
            FtNotificationItem(
              id: 'exercise_island_test',
              type: FtNotificationType.hydration,
              title: 'Hydration Target',
              body: 'Drink water',
              timestamp: DateTime.now(),
            ),
          );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Hydration Target '), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();
      expect(find.byType(FtNotificationBell), findsOneWidget);
    });

    testWidgets('WorkoutSearchScreen header works seamlessly with FtDynamicHeader and expands on notification',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: WorkoutSearchScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Search Workouts'), findsOneWidget);
      expect(find.byType(FtNotificationBell), findsOneWidget);
      expect(find.byType(FtHeaderAvatar), findsOneWidget);

      container.read(notificationIslandProvider.notifier).show(
            FtNotificationItem(
              id: 'search_island_test',
              type: FtNotificationType.pr,
              title: 'PR Target',
              body: 'Deadlift PR',
              timestamp: DateTime.now(),
            ),
          );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('PR Target '), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();
      expect(find.byType(FtNotificationBell), findsOneWidget);
    });

    testWidgets('History Detail Header works seamlessly with FtDynamicHeader and expands on notification',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: hist_detail.WorkoutDetailHeader(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Workout Details'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
      expect(find.byType(FtNotificationBell), findsOneWidget);
      expect(find.byType(FtHeaderAvatar), findsOneWidget);

      container.read(notificationIslandProvider.notifier).show(
            FtNotificationItem(
              id: 'hist_detail_island_test',
              type: FtNotificationType.habit,
              title: 'Session Saved',
              body: 'Details updated',
              timestamp: DateTime.now(),
            ),
          );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Session Saved '), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();
      expect(find.byType(FtNotificationBell), findsOneWidget);
    });
  });
}
