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
              body: GlassSurface(
                child: Text('Test Glass Card'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find BackdropFilter for 4px Subtle
      final subtleFilter = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
      final ImageFilter? subtleImageFilter = subtleFilter.filter;
      // In Flutter ImageFilter.toString() or inspection: verify blur is low
      expect(subtleImageFilter.toString(), contains('3.0'));

      // Find inner container decoration to verify high translucency at Subtle
      final subtleBoxes = tester.widgetList<Container>(find.descendant(
        of: find.byType(GlassSurface),
        matching: find.byType(Container),
      ));
      final Container subtleBox = subtleBoxes.firstWhere(
        (c) => c.decoration is BoxDecoration && (c.decoration as BoxDecoration).color != null,
      );
      final subtleColor = (subtleBox.decoration as BoxDecoration).color!;
      // At Subtle, alpha is significantly reduced (~0.27)
      expect(subtleColor.a, lessThan(0.35));

      // Now update to Intense (32px)
      await container.read(themeProvider.notifier).setBlurIntensity(32.0);
      await tester.pumpAndSettle();

      final intenseFilter = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
      final ImageFilter? intenseImageFilter = intenseFilter.filter;
      // Verify blur is heavy (at least 35px)
      expect(intenseImageFilter.toString(), contains('36.0'));

      // Verify fill opacity is dense frosted acrylic (~0.81)
      final intenseBoxes = tester.widgetList<Container>(find.descendant(
        of: find.byType(GlassSurface),
        matching: find.byType(Container),
      ));
      final Container intenseBox = intenseBoxes.firstWhere(
        (c) => c.decoration is BoxDecoration && (c.decoration as BoxDecoration).color != null,
      );
      final intenseColor = (intenseBox.decoration as BoxDecoration).color!;
      expect(intenseColor.a, greaterThan(0.75));

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
