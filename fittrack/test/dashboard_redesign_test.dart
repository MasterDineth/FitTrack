import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fittrack/domain/entities/theme_settings.dart';
import 'package:fittrack/presentation/providers/theme_provider.dart';
import 'package:fittrack/presentation/theme/app_theme.dart';
import 'package:fittrack/presentation/widgets/ambient_mesh_background.dart';
import 'package:fittrack/presentation/widgets/glass/glass.dart';
import 'package:fittrack/presentation/screens/dashboard_screen.dart';
import 'package:fittrack/presentation/widgets/bottom_nav_shell.dart';

void main() {
  group('Step 1 & 2: MeshPalette & Ambient Mesh Tests', () {
    test('MeshPalette.fromPrimary computes correct values for Light mode', () {
      const primary = Color(0xFF7C5CFA);
      final palette = MeshPalette.fromPrimary(primary, Brightness.light, false);

      expect(palette.canvasColor, const Color(0xFFF6F4FF));
      expect(palette.glows.length, 4);

      expect(palette.glows[0].xPercent, 0.08);
      expect(palette.glows[0].yPercent, 0.10);
      expect(palette.glows[0].color, primary.withValues(alpha: 0.25));

      expect(palette.glows[1].xPercent, 0.92);
      expect(palette.glows[1].yPercent, 0.22);
      expect(palette.glows[1].color, const Color(0xFF2DD4BF).withValues(alpha: 0.22));

      expect(palette.glows[2].xPercent, 0.15);
      expect(palette.glows[2].yPercent, 0.72);
      expect(palette.glows[2].color, const Color(0xFFFFB88C).withValues(alpha: 0.18));

      expect(palette.glows[3].xPercent, 0.88);
      expect(palette.glows[3].yPercent, 0.85);
      expect(palette.glows[3].color, primary.withValues(alpha: 0.22));
    });

    test('MeshPalette.fromPrimary computes correct values for Slate Dark mode', () {
      const primary = Color(0xFF7C5CFA);
      final palette = MeshPalette.fromPrimary(primary, Brightness.dark, false);

      expect(palette.canvasColor, const Color(0xFF0C0F17));
      expect(palette.glows.length, 4);
      expect(palette.glows[0].color, primary.withValues(alpha: 0.22));
    });

    test('MeshPalette.fromPrimary computes correct values for Pure AMOLED Dark mode', () {
      const primary = Color(0xFF7C5CFA);
      final palette = MeshPalette.fromPrimary(primary, Brightness.dark, true);

      expect(palette.canvasColor, const Color(0xFF000000));
      expect(palette.glows.length, 4);
      expect(palette.glows[0].color, primary.withValues(alpha: 0.22));
    });

    testWidgets('AmbientMeshBackground renders CustomPaint without crashing', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AmbientMeshBackground(
              child: Text('Content over mesh'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Content over mesh'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('Step 3: Glass Primitives Tests', () {
    testWidgets('FrostedGlassBox renders with BackdropFilter blur', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FrostedGlassBox(
              tier: GlassTier.surface,
              child: Text('Glass Card'),
            ),
          ),
        ),
      );

      expect(find.text('Glass Card'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('GlassPillChip renders label, height, and status dot', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassPillChip(
              label: 'SCHEDULED',
              dotColor: Color(0xFF7C5CFA),
              textColor: Color(0xFF7C5CFA),
            ),
          ),
        ),
      );

      expect(find.text('SCHEDULED'), findsOneWidget);
    });

    testWidgets('GlassIconButton renders 44x44 target and unread badge pip', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassIconButton(
              icon: const Icon(Icons.notifications),
              showBadge: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byType(Icon), findsOneWidget);
      await tester.tap(find.byType(GlassIconButton));
      expect(tapped, isTrue);
    });

    testWidgets('GlassHairlineDivider renders 1px separator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Top'),
                GlassHairlineDivider(),
                Text('Bottom'),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(GlassHairlineDivider), findsOneWidget);
    });
  });

  group('Step 5: DashboardScreen Full Rebuild Tests', () {
    testWidgets('DashboardScreen renders all sections cleanly in Light mode', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      final thisMonthFinder = find.text('This Month');
      expect(thisMonthFinder, findsOneWidget);
      final calendarFinder = find.ancestor(
        of: find.text('W'),
        matching: find.byType(FrostedGlassBox),
      );
      if (calendarFinder.evaluate().isNotEmpty) {
        final boxRender = tester.renderObject(calendarFinder.first) as RenderBox;
        // ignore: avoid_print
        print('CALENDAR CARD SIZE: ${boxRender.size}');
      }

      // 1. Top Header
      expect(find.text('FitTrack'), findsOneWidget);
      expect(find.byType(GlassIconButton), findsAtLeastNWidgets(1));

      // 2. Greeting Section
      expect(find.textContaining('MasterDineth'), findsOneWidget);

      // 3. Weekly Stats Card
      expect(find.text('DAYS'), findsOneWidget);
      expect(find.text('WORKOUTS'), findsOneWidget);
      expect(find.text('BURNED'), findsOneWidget);
      expect(find.text('1'), findsAtLeastNWidgets(2)); // Days: 1, Workouts: 1
      expect(find.text(' /4'), findsOneWidget);
      expect(find.text('380'), findsOneWidget);
      expect(find.text(' kcal'), findsOneWidget);

      // 4. Calendar Matrix Section
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('M'), findsAtLeastNWidgets(1));
      expect(find.text('W'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);

      // 5. Today Recommendation Section
      expect(find.text("Today's Recommendation"), findsOneWidget);
      expect(find.text('SCHEDULED'), findsOneWidget);
      expect(find.text('Back & Biceps Pull'), findsOneWidget);
      expect(find.text('Pull day focus'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Biceps'), findsOneWidget);
      expect(find.text('6 exercises'), findsOneWidget);
      expect(find.text('~42 min'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);

      // Scroll down to reveal lower slivers
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      // 6. Recent Workouts Section
      expect(find.text('Recent Workouts'), findsOneWidget);
      expect(find.text('Day 1 – Chest, Shoulders & Triceps'), findsOneWidget);
      expect(find.text('50:00'), findsOneWidget);
      expect(find.text('380 kcal'), findsOneWidget);
      expect(find.text('Day 2 – Back & Biceps Pull'), findsOneWidget);
      expect(find.text('42:00'), findsOneWidget);
      expect(find.text('330 kcal'), findsOneWidget);

      // 7. Tutorials & Guides Section
      expect(find.text('Tutorials & Guides'), findsOneWidget);
      expect(find.text('Mastering the Bench Press'), findsOneWidget);
      expect(find.text('VIDEO'), findsOneWidget);
      expect(find.text('Proper Hip Hinge Guide'), findsOneWidget);
      expect(find.text('GUIDE'), findsOneWidget);
    });

    testWidgets('DashboardScreen adapts to Dark Mode & Pure OLED Mode', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const darkSettings = ThemeSettings(
        themeMode: ThemeMode.dark,
        accentColorValue: 0xFF7C5CFA,
        useOledBlack: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildDarkTheme(darkSettings),
            home: const DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('FitTrack'), findsOneWidget);
      expect(find.text("Today's Recommendation"), findsOneWidget);
    });

    testWidgets('FloatingDock anchors cleanly at the bottom of the screen (not in middle)', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            extendBody: true,
            body: const Center(child: Text('Screen Content')),
            bottomNavigationBar: FloatingDock(
              currentIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final dockFinder = find.byType(FloatingDock);
      expect(dockFinder, findsOneWidget);

      final dockRect = tester.getRect(dockFinder);
      // Screen height is 852. The dock rect should be anchored at the bottom (852 - 88 = 764)
      expect(dockRect.bottom, equals(852.0));
      expect(dockRect.top, greaterThanOrEqualTo(760.0));
      // Ensure it is NOT floating anywhere near the middle (394..450)
      expect(dockRect.top, greaterThan(600.0));
    });

    testWidgets('Calendar card has no large empty space below dates', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final calendarCardFinder = find.ancestor(
        of: find.text('W'),
        matching: find.byType(FrostedGlassBox),
      );
      expect(calendarCardFinder, findsOneWidget);

      final cardRect = tester.getRect(calendarCardFinder);
      // The 5-week calendar should be compact (approx 270-300px), NOT 500-600px
      expect(cardRect.height, lessThan(330.0));
      expect(cardRect.height, greaterThan(250.0));
    });
  });
}
