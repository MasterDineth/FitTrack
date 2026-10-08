import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fittrack/domain/entities/daily_habit.dart';
import 'package:fittrack/domain/repositories/i_habits_repository.dart';
import 'package:fittrack/presentation/providers/repository_providers.dart';
import 'package:fittrack/presentation/widgets/animated_glass_dock.dart';
import 'package:fittrack/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:fittrack/presentation/screens/dashboard/widgets/telemetry_stack.dart';
import 'package:fittrack/presentation/screens/dashboard/widgets/dashboard_greeting.dart';
import 'package:fittrack/presentation/screens/dashboard/widgets/habits_recovery_section.dart';
import 'package:fittrack/presentation/screens/dashboard/widgets/featured_workout_card.dart';
import 'package:fittrack/presentation/screens/dashboard/widgets/weekly_streak_log_section.dart';

class _TestHabitsRepository implements IHabitsRepository {
  List<DailyHabit> habits = [
    const DailyHabit(
      id: 'habit-1',
      title: 'Morning Hydration (1L)',
      subtitle: 'Completed at 7:45 AM',
      isCompleted: true,
      status: HabitChipStatus.done,
      orderIndex: 0,
    ),
    const DailyHabit(
      id: 'habit-2',
      title: 'Target Protein Synthesis',
      subtitle: '35g remaining for dinner',
      isCompleted: false,
      status: HabitChipStatus.pending,
      orderIndex: 1,
    ),
  ];

  @override
  Future<List<DailyHabit>> getHabits() async => List.of(habits);

  @override
  Future<void> toggleHabit(String id) async {
    final idx = habits.indexWhere((h) => h.id == id);
    if (idx != -1) {
      final h = habits[idx];
      final next = !h.isCompleted;
      habits[idx] = h.copyWith(
        isCompleted: next,
        status: next ? HabitChipStatus.done : HabitChipStatus.pending,
      );
    }
  }
}

void main() {
  group('TelemetryStack Carousel & Wrapping Tests', () {
    testWidgets('TelemetryStack displays cards, wraps indices 0 -> 1 -> 2 -> 0, and handles dots', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TelemetryStack(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 700));

      // Card 0: Bio-Metrics Balance is initially active
      expect(find.text('Bio-Metrics Balance'), findsOneWidget);
      expect(find.text('DAILY TELEMETRY & PROGRESS'), findsOneWidget);

      // Tap Next card button
      final nextFinder = find.bySemanticsLabel('Next card');
      expect(nextFinder, findsOneWidget);

      await tester.tap(nextFinder);
      await tester.pump(const Duration(milliseconds: 350));

      // Card 1: Weekly Momentum is active
      expect(find.text('Weekly Momentum'), findsOneWidget);
      expect(find.textContaining('sessions complete'), findsOneWidget);

      // Tap Next card button again
      await tester.tap(nextFinder);
      await tester.pump(const Duration(milliseconds: 350));

      // Card 2: Weekly Load & Volume is active
      expect(find.text('Weekly Load & Volume'), findsOneWidget);

      // Tap Next card button again -> wraps back to Card 0
      await tester.tap(nextFinder);
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Bio-Metrics Balance'), findsOneWidget);

      // Tap Previous card button -> wraps to Card 2
      final prevFinder = find.bySemanticsLabel('Previous card');
      expect(prevFinder, findsOneWidget);

      await tester.tap(prevFinder);
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Weekly Load & Volume'), findsOneWidget);

      // Tap previous again to go back to 1
      await tester.tap(prevFinder);
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('Weekly Momentum'), findsOneWidget);
    });
  });

  group('AnimatedGlassDock Navigation Tests', () {
    testWidgets('AnimatedGlassDock renders all tabs and triggers onTap callback with index', (tester) async {
      int selectedTab = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (context, setState) {
                return AnimatedGlassDock(
                  currentIndex: selectedTab,
                  onTap: (index) {
                    setState(() {
                      selectedTab = index;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Active tab (Dashboard) displays its label
      expect(find.text('Dashboard'), findsOneWidget);

      // Initial tab is Dashboard (0)
      expect(selectedTab, 0);

      // Tap 'Workouts' tab icon
      await tester.tap(find.byIcon(Icons.fitness_center_outlined));
      await tester.pump(const Duration(milliseconds: 100));

      // Callback invoked with index 1
      expect(selectedTab, 1);

      // Re-pump widget to trigger didUpdateWidget animation
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (context, setState) {
                return AnimatedGlassDock(
                  currentIndex: selectedTab,
                  onTap: (index) {
                    setState(() {
                      selectedTab = index;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('Workouts'), findsOneWidget);

      // Tap 'Settings' tab icon
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pump(const Duration(milliseconds: 100));
      expect(selectedTab, 3);

      // Tap 'History' tab icon
      await tester.tap(find.byIcon(Icons.schedule_outlined));
      await tester.pump(const Duration(milliseconds: 100));
      expect(selectedTab, 2);
    });
  });

  group('DashboardScreen Rebuild Integration Tests', () {
    testWidgets('DashboardScreen renders complete Stitch layout cleanly without errors', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: ProviderScope(
            overrides: [
              habitsRepositoryProvider.overrideWithValue(_TestHabitsRepository()),
            ],
            child: const MaterialApp(
              home: DashboardScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);

      // 1. Header Row
      expect(find.text('FitTrack'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);

      // 2. Greeting Section
      expect(find.text('READY TO PEAK'), findsOneWidget);
      expect(find.textContaining('Good '), findsOneWidget);
      expect(find.byType(DashboardGreeting), findsOneWidget);

      // 3. Telemetry Stack
      expect(find.text('DAILY TELEMETRY & PROGRESS'), findsOneWidget);
      expect(find.text('Bio-Metrics Balance'), findsOneWidget);

      // 4. Featured Workout Card
      expect(find.byType(FeaturedWorkoutCard), findsOneWidget);
      expect(find.text('Featured Workout'), findsOneWidget);

      // 5. Habits & Recovery Section (scroll to reveal)
      await tester.scrollUntilVisible(find.text('Habits & Recovery'), 200);
      expect(find.text('Habits & Recovery'), findsOneWidget);
      expect(find.textContaining('of 2 complete'), findsOneWidget);
      expect(find.text('Morning Hydration (1L)'), findsOneWidget);

      // 6. Lifestyle & Masterclass Section (scroll to reveal)
      await tester.scrollUntilVisible(find.text('Lifestyle & Masterclass'), 200);
      expect(find.text('Lifestyle & Masterclass'), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);

      // 7. Weekly Streak & Recent Sessions Section (scroll to reveal)
      await tester.scrollUntilVisible(find.text('Weekly Streak & Log'), 200);
      expect(find.text('Weekly Streak & Log'), findsOneWidget);
      expect(find.text('See all'), findsOneWidget);
    });

    testWidgets('HabitsRecoverySection toggles habit state on tap', (tester) async {
      final testRepo = _TestHabitsRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsRepositoryProvider.overrideWithValue(testRepo),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: HabitsRecoverySection(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Find Morning Hydration habit item
      final hydrationFinder = find.text('Morning Hydration (1L)');
      expect(hydrationFinder, findsOneWidget);

      // Tap to toggle
      await tester.tap(hydrationFinder);
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
    });

    testWidgets('DashboardScreen adapts cleanly to Slate Dark Mode and Pure OLED Dark Mode', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // 1. Slate Dark Mode
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: ProviderScope(
            overrides: [
              habitsRepositoryProvider.overrideWithValue(_TestHabitsRepository()),
            ],
            child: MaterialApp(
              theme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: const Color(0xFF0C0A18),
              ),
              home: const DashboardScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
      expect(find.text('FitTrack'), findsOneWidget);
      expect(find.text('Bio-Metrics Balance'), findsOneWidget);

      // 2. Pure OLED Dark Mode
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: ProviderScope(
            overrides: [
              habitsRepositoryProvider.overrideWithValue(_TestHabitsRepository()),
            ],
            child: MaterialApp(
              theme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: const Color(0xFF000000),
              ),
              home: const DashboardScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
      expect(find.text('FitTrack'), findsOneWidget);
      expect(find.text('Bio-Metrics Balance'), findsOneWidget);
    });

    testWidgets('AnimatedGlassDock renders luminous pill and handles dark theme styling', (tester) async {
      int activeIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (context, setState) {
                return AnimatedGlassDock(
                  currentIndex: activeIndex,
                  onTap: (index) {
                    setState(() => activeIndex = index);
                  },
                );
              },
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Active tab Dashboard is rendered
      expect(find.text('Dashboard'), findsOneWidget);

      // Switch to Workouts (1)
      await tester.tap(find.byIcon(Icons.fitness_center_outlined));
      await tester.pump(const Duration(milliseconds: 100));
      expect(activeIndex, 1);
    });

    testWidgets('DashboardScreen layout bounds last section neatly above dock', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: ProviderScope(
            overrides: [
              habitsRepositoryProvider.overrideWithValue(_TestHabitsRepository()),
            ],
            child: MaterialApp(
              home: Scaffold(
                extendBody: true,
                body: const DashboardScreen(),
                bottomNavigationBar: AnimatedGlassDock(
                  currentIndex: 0,
                  onTap: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
      await tester.pumpAndSettle();

      final streakFinder = find.byType(WeeklyStreakLogSection);
      expect(streakFinder, findsOneWidget);
      final box = tester.renderObject<RenderBox>(streakFinder);
      final pos = box.localToGlobal(Offset.zero);
      // The WeeklyStreakLogSection should be visible and cleanly bounded above dock
      expect(pos.dy, greaterThan(0));
      expect(pos.dy + box.size.height, lessThanOrEqualTo(852));
    });
  });
}
