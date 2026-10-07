import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fittrack/presentation/screens/workouts_screen.dart';
import 'package:fittrack/presentation/screens/workout_search_screen.dart';

Widget _createTestApp({
  required Widget home,
  ThemeData? theme,
}) {
  return ProviderScope(
    child: MaterialApp(
      theme: theme ??
          ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF7C5CFA),
              primary: const Color(0xFF7C5CFA),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF6F4FF),
          ),
      home: home,
    ),
  );
}

Widget _createRouterTestApp({
  required GoRouter router,
}) {
  return ProviderScope(
    child: MaterialApp.router(
      routerConfig: router,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorkoutsScreen Redesign - Visual Elements & Sections', () {
    testWidgets('renders header, title, subtitle, bell, and avatar',
        (tester) async {
      tester.view.physicalSize = const Size(393, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_createTestApp(home: const WorkoutsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Workouts'), findsOneWidget);
      expect(
        find.text('Explore splits, routines & programs'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    });

    testWidgets('renders search bar and category filter chips row',
        (tester) async {
      tester.view.physicalSize = const Size(393, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_createTestApp(home: const WorkoutsScreen()));
      await tester.pumpAndSettle();

      expect(
        find.text('Search splits, goals or equipment...'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Hypertrophy'), findsWidgets);
      expect(find.text('Strength'), findsWidgets);
      expect(find.text('Beginner'), findsOneWidget);
    });

    testWidgets('renders Recommended for you section with profile badge',
        (tester) async {
      tester.view.physicalSize = const Size(393, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_createTestApp(home: const WorkoutsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Recommended for you'), findsOneWidget);
      expect(find.text('BASED ON PROFILE'), findsOneWidget);
      expect(find.text('Push-Pull-Legs Split'), findsWidgets);
      expect(find.text('View'), findsWidgets);
    });

    testWidgets('renders Bookmarked, My routines, and Browse all sections',
        (tester) async {
      tester.view.physicalSize = const Size(393, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_createTestApp(home: const WorkoutsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Bookmarked'), findsOneWidget);
      expect(find.text('See all'), findsOneWidget);
      expect(find.text('My routines'), findsOneWidget);
      expect(find.text('New routine'), findsOneWidget);
      expect(find.text('Browse all'), findsOneWidget);
      expect(find.text('Create Schedule'), findsOneWidget);
    });

    testWidgets('toggling bookmark reacts in state', (tester) async {
      tester.view.physicalSize = const Size(393, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_createTestApp(home: const WorkoutsScreen()));
      await tester.pumpAndSettle();

      // Find first bookmark icon in Recommended carousel
      final bookmarkFinders = find.byIcon(Icons.bookmark_rounded);
      expect(bookmarkFinders, findsWidgets);

      await tester.tap(bookmarkFinders.first);
      await tester.pumpAndSettle();
    });
  });

  group('WorkoutSearchScreen Redesign - Search & Feed', () {
    testWidgets('renders search bar, back button, and initial results',
        (tester) async {
      tester.view.physicalSize = const Size(393, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _createTestApp(home: const WorkoutSearchScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Search Workouts'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.text('Search Results'), findsOneWidget);
      expect(find.text('PROGRAM'), findsWidgets);
      expect(find.text('Featured Routine'), findsWidgets);
    });

    testWidgets('typing search query filters live results', (tester) async {
      tester.view.physicalSize = const Size(393, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _createTestApp(home: const WorkoutSearchScreen()),
      );
      await tester.pumpAndSettle();

      final inputFinder = find.byType(TextField);
      expect(inputFinder, findsOneWidget);

      await tester.enterText(inputFinder, 'Texas');
      await tester.pumpAndSettle();

      expect(find.text('Texas Method 3-Day'), findsOneWidget);
      expect(find.text('Push-Pull-Legs Split'), findsNothing);
    });

    testWidgets('shows empty state when no workouts match query',
        (tester) async {
      tester.view.physicalSize = const Size(393, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _createTestApp(home: const WorkoutSearchScreen()),
      );
      await tester.pumpAndSettle();

      final inputFinder = find.byType(TextField);
      await tester.enterText(inputFinder, 'xyz123nonexistentroutine');
      await tester.pumpAndSettle();

      expect(find.text('No workouts found'), findsOneWidget);
      expect(find.text('Clear Search & Filters'), findsOneWidget);

      // Tapping reset clears input
      await tester.tap(find.text('Clear Search & Filters'));
      await tester.pumpAndSettle();

      expect(find.text('Push-Pull-Legs Split'), findsOneWidget);
    });
  });

  group('Theme Adaptability - Dark & AMOLED Pure Dark', () {
    testWidgets('renders WorkoutsScreen cleanly in Dark Theme',
        (tester) async {
      tester.view.physicalSize = const Size(393, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final darkTheme = ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C5CFA),
          primary: const Color(0xFF7C5CFA),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0C0F17),
      );

      await tester.pumpWidget(
        _createTestApp(
          home: const WorkoutsScreen(),
          theme: darkTheme,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Workouts'), findsOneWidget);
    });

    testWidgets('renders WorkoutSearchScreen cleanly in AMOLED Pure Dark',
        (tester) async {
      tester.view.physicalSize = const Size(393, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final pureDarkTheme = ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2DD4BF),
          primary: const Color(0xFF2DD4BF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
      );

      await tester.pumpWidget(
        _createTestApp(
          home: const WorkoutSearchScreen(),
          theme: pureDarkTheme,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Search Workouts'), findsOneWidget);
    });
  });

  group('Navigation Bindings', () {
    testWidgets('tapping search bar navigates to /workouts/search',
        (tester) async {
      tester.view.physicalSize = const Size(393, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = GoRouter(
        initialLocation: '/workouts',
        routes: [
          GoRoute(
            path: '/workouts',
            builder: (_, _) => const WorkoutsScreen(),
            routes: [
              GoRoute(
                path: 'search',
                builder: (_, _) => const WorkoutSearchScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/workouts/detail',
            builder: (_, _) => const Scaffold(body: Text('Detail Screen')),
          ),
          GoRoute(
            path: '/workouts/create-schedule',
            builder: (_, _) =>
                const Scaffold(body: Text('Create Schedule Screen')),
          ),
          GoRoute(
            path: '/settings/notifications',
            builder: (_, _) =>
                const Scaffold(body: Text('Notifications Screen')),
          ),
          GoRoute(
            path: '/settings/profile',
            builder: (_, _) => const Scaffold(body: Text('Profile Screen')),
          ),
        ],
      );

      await tester.pumpWidget(_createRouterTestApp(router: router));
      await tester.pumpAndSettle();

      // Tap the search placeholder
      final searchFieldFinder =
          find.text('Search splits, goals or equipment...');
      expect(searchFieldFinder, findsOneWidget);

      await tester.tap(searchFieldFinder);
      await tester.pumpAndSettle();

      // Verify we arrived at Search Workouts
      expect(find.text('Search Workouts'), findsOneWidget);

      // Tap back button
      final backButton = find.byIcon(Icons.arrow_back_rounded);
      expect(backButton, findsOneWidget);

      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify we are back on Workouts library
      expect(find.text('Workouts'), findsOneWidget);
    });
  });
}
