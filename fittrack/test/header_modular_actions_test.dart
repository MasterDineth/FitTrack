import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:fittrack/presentation/providers/notifications_provider.dart';
import 'package:fittrack/presentation/screens/create_exercise/widgets/create_exercise_header.dart';
import 'package:fittrack/presentation/screens/create_schedule/widgets/create_schedule_header.dart';
import 'package:fittrack/presentation/screens/dashboard/widgets/dashboard_header.dart';
import 'package:fittrack/presentation/screens/settings/widgets/settings_header.dart';
import 'package:fittrack/presentation/screens/workout_detail/widgets/workout_detail_header.dart'
    as sched_detail;
import 'package:fittrack/presentation/screens/workout_history/widgets/workout_history_header.dart';
import 'package:fittrack/presentation/screens/workout_history_detail/widgets/workout_detail_header.dart'
    as hist_detail;
import 'package:fittrack/presentation/screens/workout_search_screen.dart';
import 'package:fittrack/presentation/screens/workouts_screen.dart';
import 'package:fittrack/presentation/widgets/glass_surface.dart';
import 'package:fittrack/presentation/widgets/header/header.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Task 3: FtHeaderTokens Constants', () {
    test('Tokens contain exact required specifications', () {
      expect(FtHeaderTokens.topPadding, equals(12.0));
      expect(FtHeaderTokens.horizontalMargin, equals(20.0));
      expect(FtHeaderTokens.bellVisualSize, equals(40.0));
      expect(FtHeaderTokens.avatarVisualSize, equals(36.0));
      expect(FtHeaderTokens.clusterGap, equals(8.0));
      expect(FtHeaderTokens.minTouchTarget, equals(48.0));
      expect(FtHeaderTokens.badgeSize, equals(8.0));
      expect(FtHeaderTokens.badgeRingWidth, equals(1.8));
    });
  });

  group('Task 3: FtNotificationBell Widget Tests', () {
    testWidgets('renders 40x40 visual footprint with >= 48x48 touch target',
        (tester) async {
      final container = ProviderContainer();
      container.read(notificationFeedProvider.notifier).clearAll();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: FtNotificationBell(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final bellFinder = find.byType(FtNotificationBell);
      expect(bellFinder, findsOneWidget);

      final bellSize = tester.getSize(bellFinder);
      expect(bellSize.width, greaterThanOrEqualTo(48.0));
      expect(bellSize.height, greaterThanOrEqualTo(48.0));

      // Visual GlassSurface is 40x40
      final glassFinder = find.descendant(
        of: bellFinder,
        matching: find.byType(GlassSurface),
      );
      expect(glassFinder, findsOneWidget);
      final glassSize = tester.getSize(glassFinder);
      expect(glassSize.width, equals(40.0));
      expect(glassSize.height, equals(40.0));

      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      expect(find.bySemanticsLabel('Notifications, 0 unread'), findsOneWidget);
    });

    testWidgets('renders unread badge dot when unread count > 0',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(notificationFeedProvider.notifier).clearAll();
      container.read(notificationFeedProvider.notifier).pushNotification(
            type: FtNotificationType.hydration,
            title: 'Water reminder',
            body: 'Drink 500ml',
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: FtNotificationBell(),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      expect(container.read(unreadNotificationCountProvider), equals(1));
      expect(find.bySemanticsLabel('Notifications, 1 unread'), findsOneWidget);
    });

    testWidgets('tapping bell opens notificationShadeProvider with origin',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topRight,
                child: FtNotificationBell(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(container.read(notificationShadeProvider).isOpen, isFalse);

      await tester.tap(find.byType(FtNotificationBell));
      await tester.pumpAndSettle();

      final shadeState = container.read(notificationShadeProvider);
      expect(shadeState.isOpen, isTrue);
      expect(shadeState.origin, isNotNull);
      // Origin should be near top right of screen
      expect(shadeState.origin!.dx, greaterThan(0));
      expect(shadeState.origin!.dy, greaterThan(0));
    });
  });

  group('Task 3: FtHeaderAvatar Widget Tests', () {
    testWidgets('renders 36x36 visual avatar with >= 48x48 touch target',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: FtHeaderAvatar(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final avatarFinder = find.byType(FtHeaderAvatar);
      expect(avatarFinder, findsOneWidget);

      final avatarSize = tester.getSize(avatarFinder);
      expect(avatarSize.width, greaterThanOrEqualTo(48.0));
      expect(avatarSize.height, greaterThanOrEqualTo(48.0));

      expect(find.bySemanticsLabel('Profile settings'), findsOneWidget);
    });

    testWidgets('tapping avatar navigates to /settings/profile',
        (tester) async {
      String? pushedRoute;
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: Center(child: FtHeaderAvatar()),
            ),
          ),
          GoRoute(
            path: '/settings/profile',
            builder: (context, state) {
              pushedRoute = '/settings/profile';
              return const Scaffold(body: Text('Profile Screen'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FtHeaderAvatar));
      await tester.pumpAndSettle();

      expect(pushedRoute, equals('/settings/profile'));
      expect(find.text('Profile Screen'), findsOneWidget);
    });
  });

  group('Task 3: FtHeaderActions Cluster Tests', () {
    testWidgets('renders bell and avatar by default', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: FtHeaderActions(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FtNotificationBell), findsOneWidget);
      expect(find.byType(FtHeaderAvatar), findsOneWidget);
    });

    testWidgets('supports showBell: false and showAvatar: false with extraActions',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: FtHeaderActions(
                  showBell: false,
                  showAvatar: false,
                  extraActions: [
                    Icon(Icons.more_vert_rounded),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FtNotificationBell), findsNothing);
      expect(find.byType(FtHeaderAvatar), findsNothing);
      expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
    });
  });

  group('Task 3: Screen Headers Migration Tests', () {
    testWidgets('WorkoutsScreen renders header with title, subtitle, bell and avatar',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: WorkoutsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Workouts'), findsOneWidget);
      expect(find.text('Explore splits, routines & programs'), findsOneWidget);
      expect(find.byType(FtNotificationBell), findsOneWidget);
      expect(find.byType(FtHeaderAvatar), findsOneWidget);
    });

    testWidgets('WorkoutHistoryHeader renders title, subtitle, bell and avatar',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
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
    });

    testWidgets('SettingsHeader renders title, subtitle, bell and avatar',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
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
    });

    testWidgets('CreateScheduleHeader renders back button, title, and actions',
        (tester) async {
      bool backTapped = false;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CreateScheduleHeader(
                onBackTap: () => backTapped = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('New Schedule'), findsOneWidget);
      expect(find.text('Hypertrophy split plan'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byType(FtNotificationBell), findsOneWidget);
      expect(find.byType(FtHeaderAvatar), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      expect(backTapped, isTrue);
    });

    testWidgets('CreateExerciseHeader renders back button, title, and actions',
        (tester) async {
      bool backTapped = false;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CreateExerciseHeader(
                onBackTap: () => backTapped = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create Exercise'), findsOneWidget);
      expect(find.text('Only a name is required'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byType(FtNotificationBell), findsOneWidget);
      expect(find.byType(FtHeaderAvatar), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      expect(backTapped, isTrue);
    });

    testWidgets('WorkoutSearchScreen renders back button, title, and actions',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: WorkoutSearchScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Search Workouts'), findsOneWidget);
      expect(find.byType(FtNotificationBell), findsOneWidget);
      expect(find.byType(FtHeaderAvatar), findsOneWidget);
    });

    testWidgets('History Detail Header renders back button, title, and actions',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: hist_detail.WorkoutDetailHeader(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Workout Details'), findsOneWidget);
      expect(find.text('Review completed sets, volume & records'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
      expect(find.byType(FtNotificationBell), findsOneWidget);
      expect(find.byType(FtHeaderAvatar), findsOneWidget);
    });

    testWidgets('WorkoutDetailHeader renders back button, title, and 3-dot menu only',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: sched_detail.WorkoutDetailHeader(onBackTap: () {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Workout Details'), findsOneWidget);
      expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
      expect(find.byType(FtNotificationBell), findsNothing);
      expect(find.byType(FtHeaderAvatar), findsNothing);
    });

    testWidgets('DashboardHeader renders brand lockup and far-right avatar',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DashboardHeader(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('FitTrack'), findsOneWidget);
      expect(find.byType(FtHeaderAvatar), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });
  });
}
