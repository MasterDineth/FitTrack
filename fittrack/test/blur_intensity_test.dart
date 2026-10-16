import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittrack/presentation/providers/theme_provider.dart';
import 'package:fittrack/presentation/screens/settings/appearance_settings_screen.dart';
import 'package:fittrack/presentation/widgets/animated_glass_dock.dart';
import 'package:fittrack/presentation/widgets/glass_surface.dart';

void main() {
  group('Blur Intensity Dynamic Scaling Tests', () {
    testWidgets('GlassSurface scales blur sigma and fill opacity between Subtle (4px) and Intense (32px)',
        (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          themeProvider.overrideWith(() => _FakeThemeNotifier(
                const ThemeSettings(
                  enableGlassTransparency: true,
                  blurIntensity: 4.0, // Subtle
                ),
              )),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  GlassSurface(
                    backdrop: GlassBackdrop.live,
                    child: Text('Test Live Glass Card'),
                  ),
                  GlassSurface(
                    // Default flat surface
                    child: Text('Test Flat Glass Card'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Only the live surface has a BackdropFilter
      expect(find.byType(BackdropFilter), findsOneWidget);

      // Find BackdropFilter for 4px Subtle
      final subtleFilter =
          tester.widget<BackdropFilter>(find.byType(BackdropFilter));
      final ImageFilter? subtleImageFilter = subtleFilter.filter;
      // In Flutter ImageFilter.toString() or inspection: verify blur is low
      expect(subtleImageFilter.toString(), contains('3.0'));

      // Find live and flat container decorations to verify high translucency at Subtle
      final liveCards = find.widgetWithText(GlassSurface, 'Test Live Glass Card');
      final flatCards = find.widgetWithText(GlassSurface, 'Test Flat Glass Card');

      final subtleLiveBoxes = tester.widgetList<Container>(find.descendant(
        of: liveCards,
        matching: find.byType(Container),
      ));
      final Container subtleLiveBox = subtleLiveBoxes.firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).color != null,
      );
      final subtleColor = (subtleLiveBox.decoration as BoxDecoration).color!;
      expect(subtleColor.a, lessThan(0.35));

      final subtleFlatBoxes = tester.widgetList<Container>(find.descendant(
        of: flatCards,
        matching: find.byType(Container),
      ));
      final Container subtleFlatBox = subtleFlatBoxes.firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).color != null,
      );
      final subtleFlatColor = (subtleFlatBox.decoration as BoxDecoration).color!;
      expect(subtleFlatColor.a, lessThan(0.35));

      // Now update to Intense (32px)
      await container.read(themeProvider.notifier).setBlurIntensity(32.0);
      await tester.pumpAndSettle();

      // Still only the live surface has a BackdropFilter
      expect(find.byType(BackdropFilter), findsOneWidget);

      final intenseFilter =
          tester.widget<BackdropFilter>(find.byType(BackdropFilter));
      final ImageFilter? intenseImageFilter = intenseFilter.filter;
      // Verify blur is heavy (at least 35px)
      expect(intenseImageFilter.toString(), contains('36.0'));

      // Verify fill opacity is dense frosted acrylic (~0.81) for both live and flat
      final intenseLiveBoxes = tester.widgetList<Container>(find.descendant(
        of: liveCards,
        matching: find.byType(Container),
      ));
      final Container intenseLiveBox = intenseLiveBoxes.firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).color != null,
      );
      final intenseColor = (intenseLiveBox.decoration as BoxDecoration).color!;
      expect(intenseColor.a, greaterThan(0.75));

      final intenseFlatBoxes = tester.widgetList<Container>(find.descendant(
        of: flatCards,
        matching: find.byType(Container),
      ));
      final Container intenseFlatBox = intenseFlatBoxes.firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).color != null,
      );
      final intenseFlatColor = (intenseFlatBox.decoration as BoxDecoration).color!;
      // Flat surface fill alpha also scales to dense acrylic following the slider
      expect(intenseFlatColor.a, greaterThan(0.75));
      expect(intenseFlatColor.a, equals(intenseColor.a));

      // Check distinct difference between Subtle and Intense opacity
      expect(intenseColor.a, greaterThan(subtleColor.a * 2.0));
    });

    testWidgets('AnimatedGlassDock scales blur sigma and dockFill opacity with blurIntensity',
        (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          themeProvider.overrideWith(() => _FakeThemeNotifier(
                const ThemeSettings(
                  enableGlassTransparency: true,
                  blurIntensity: 4.0, // Subtle
                ),
              )),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: AnimatedGlassDock(
                currentIndex: 0,
                onTap: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final subtleFilter = tester.widget<BackdropFilter>(find.descendant(
        of: find.byType(AnimatedGlassDock),
        matching: find.byType(BackdropFilter),
      ));
      expect(subtleFilter.filter.toString(), contains('4.0'));

      // Update to Intense (32px)
      await container.read(themeProvider.notifier).setBlurIntensity(32.0);
      await tester.pumpAndSettle();

      final intenseFilter = tester.widget<BackdropFilter>(find.descendant(
        of: find.byType(AnimatedGlassDock),
        matching: find.byType(BackdropFilter),
      ));
      expect(intenseFilter.filter.toString(), contains('42.0'));
    });

    testWidgets('AppearanceSettingsScreen renders Live Frosted Glass Swatch & interactive preset buttons',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeNotifier = _FakeThemeNotifier(
        const ThemeSettings(
          enableGlassTransparency: true,
          blurIntensity: 16.0,
        ),
      );

      final container = ProviderContainer(
        overrides: [
          themeProvider.overrideWith(() => fakeNotifier),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: AppearanceSettingsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Verify the Swatch and Presets are rendered
      expect(find.text('Frosted Glass Preview'), findsWidgets);
      expect(find.text('FITTRACK ACTIVE TELEMETRY 8,420 STEPS'), findsOneWidget);
      expect(find.text('Subtle'), findsOneWidget);
      expect(find.text('Standard'), findsOneWidget);
      expect(find.text('Intense'), findsOneWidget);

      // Tap Subtle (4px) preset button
      await tester.tap(find.text('Subtle'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(container.read(themeProvider).blurIntensity, 4.0);
      expect(find.text('4px · Subtle'), findsOneWidget);

      // Tap Intense (32px) preset button
      await tester.tap(find.text('Intense'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(container.read(themeProvider).blurIntensity, 32.0);
      expect(find.text('32px · Intense'), findsOneWidget);

      // Tap Standard (16px) preset button
      await tester.tap(find.text('Standard'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(container.read(themeProvider).blurIntensity, 16.0);
      expect(find.text('16px · Standard'), findsOneWidget);
    });
  });
}

class _FakeThemeNotifier extends ThemeNotifier {
  final ThemeSettings _initial;
  _FakeThemeNotifier(this._initial);

  @override
  ThemeSettings build() => _initial;

  @override
  Future<void> setBlurIntensity(double value) async {
    state = state.copyWith(blurIntensity: value);
  }

  @override
  Future<void> toggleGlassTransparency(bool value) async {
    state = state.copyWith(enableGlassTransparency: value);
  }
}
