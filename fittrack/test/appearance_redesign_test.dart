import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fittrack/presentation/providers/theme_provider.dart';
import 'package:fittrack/presentation/screens/settings/appearance_settings_screen.dart';
import 'package:fittrack/presentation/screens/settings/appearance/color_picker_modal.dart';

class _MockThemeNotifier extends ThemeNotifier {
  final ThemeSettings _initial;
  _MockThemeNotifier(this._initial);

  @override
  ThemeSettings build() => _initial;

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
  }

  @override
  Future<void> setAccentColor(Color color) async {
    state = state.copyWith(accentColorValue: color.toARGB32());
  }

  @override
  Future<void> setBlurIntensity(double value) async {
    state = state.copyWith(blurIntensity: value);
  }

  @override
  Future<void> toggleGlassTransparency(bool value) async {
    state = state.copyWith(enableGlassTransparency: value);
  }

  @override
  Future<void> toggleDynamicAccent(bool value) async {
    state = state.copyWith(useDynamicAccent: value);
  }

  @override
  Future<void> resetToDefaults() async {
    state = const ThemeSettings(
      themeMode: ThemeMode.system,
      accentColorValue: 0xFF7C5CFA,
      useDynamicAccent: false,
      useOledBlack: false,
      useHighContrast: false,
      autoDarkWorkout: true,
      keepScreenAwake: true,
      enableGlassTransparency: true,
      blurIntensity: 16.0,
    );
  }
}

void main() {
  group('Appearance Settings Redesign Tests', () {
    testWidgets('AppearanceSettingsScreen renders all Stitch sections and tokens',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [
          themeProvider.overrideWith(
            () => _MockThemeNotifier(
              const ThemeSettings(
                themeMode: ThemeMode.system,
                accentColorValue: 0xFF7C5CFA,
                enableGlassTransparency: true,
                blurIntensity: 16.0,
              ),
            ),
          ),
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
      await tester.pumpAndSettle();

      // 1. Header (Stitch lockup & Dashboard icons)
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('v3.4'), findsNothing);
      expect(
        find.text('Customize your visual theme, kinetic accents, and display ergonomics'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsNothing);

      // 2. Live Preview
      expect(find.text('LIVE PREVIEW'), findsOneWidget);
      expect(find.text('Real-time Canvas'), findsOneWidget);
      expect(find.text('Chest & Triceps'), findsOneWidget);
      expect(find.text('Hypertrophy Split · Push Day'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('68%'), findsOneWidget);
      expect(find.text('45 min'), findsOneWidget);
      expect(find.text('350 kcal'), findsOneWidget);
      expect(find.text('6 Exercises'), findsOneWidget);
      expect(find.text('Resume Set 3 of 4'), findsOneWidget);

      // 3. Theme Mode
      expect(find.text('THEME MODE'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);

      // 4. Dynamic Accent
      expect(find.text('Dynamic Accent'), findsOneWidget);
      expect(find.text('BETA'), findsOneWidget);

      // 5. Color Accent Palette
      expect(find.text('COLOR ACCENT'), findsOneWidget);
      expect(find.text('Electric Blue'), findsOneWidget);
      expect(find.text('Mint'), findsOneWidget);
      expect(find.text('Electric'), findsOneWidget);
      expect(find.text('Purple'), findsOneWidget);
      expect(find.text('Sunset'), findsOneWidget);
      expect(find.text('Emerald'), findsOneWidget);
      expect(find.text('Crimson'), findsOneWidget);
      expect(find.text('Cobalt'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);
      expect(find.text('Selected HEX: '), findsOneWidget);
      expect(find.text('#7C5CFA'), findsOneWidget);
      expect(find.text('Spectrum details'), findsOneWidget);

      // 6. Ergonomics & Accessibility
      expect(find.text('ERGONOMICS & ACCESSIBILITY'), findsOneWidget);
      expect(find.text('Frosted Glass Transparency'), findsOneWidget);
      expect(find.text('Blur Intensity'), findsOneWidget);
      expect(find.text('16px · Standard'), findsOneWidget);
      expect(find.text('Pure Black OLED Mode'), findsOneWidget);
      expect(find.text('High Contrast Text'), findsNothing);
      expect(find.text('Auto-Dark During Workouts'), findsOneWidget);
      expect(find.text('Keep Screen Awake'), findsOneWidget);

      // 7. Actions
      expect(find.text('Save Appearance Preferences'), findsOneWidget);
      expect(find.text('Reset to System Defaults'), findsOneWidget);
    });

    testWidgets('Tapping Theme Mode cards updates active mode',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [
          themeProvider.overrideWith(
            () => _MockThemeNotifier(
              const ThemeSettings(themeMode: ThemeMode.system),
            ),
          ),
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
      await tester.pumpAndSettle();

      // Tap Dark
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(container.read(themeProvider).themeMode, ThemeMode.dark);

      // Tap Light
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();
      expect(container.read(themeProvider).themeMode, ThemeMode.light);

      // Tap System
      await tester.tap(find.text('System'));
      await tester.pumpAndSettle();
      expect(container.read(themeProvider).themeMode, ThemeMode.system);
    });

    testWidgets('Tapping preset accent swatches updates color',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [
          themeProvider.overrideWith(
            () => _MockThemeNotifier(
              const ThemeSettings(accentColorValue: 0xFF7C5CFA),
            ),
          ),
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
      await tester.pumpAndSettle();

      // Tap Mint swatch
      await tester.tap(find.text('Mint'));
      await tester.pumpAndSettle();
      expect(container.read(themeProvider).accentColorValue, 0xFF10B981);

      // Tap Sunset swatch
      await tester.tap(find.text('Sunset'));
      await tester.pumpAndSettle();
      expect(container.read(themeProvider).accentColorValue, 0xFFF97316);
    });

    testWidgets('Tapping Reset to System Defaults restores defaults',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [
          themeProvider.overrideWith(
            () => _MockThemeNotifier(
              const ThemeSettings(
                themeMode: ThemeMode.dark,
                accentColorValue: 0xFFF97316,
                enableGlassTransparency: false,
                blurIntensity: 4.0,
              ),
            ),
          ),
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
      await tester.pumpAndSettle();

      // Tap Reset button
      await tester.tap(find.text('Reset to System Defaults'));
      await tester.pumpAndSettle();

      final state = container.read(themeProvider);
      expect(state.themeMode, ThemeMode.system);
      expect(state.accentColorValue, 0xFF7C5CFA); // Electric
      expect(state.enableGlassTransparency, isTrue);
      expect(state.blurIntensity, 16.0); // Standard
    });

    testWidgets('ColorPickerModal opens, switches modes, and applies color',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [
          themeProvider.overrideWith(
            () => _MockThemeNotifier(
              const ThemeSettings(accentColorValue: 0xFF7C5CFA),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => ColorPickerModal.show(context),
                  child: const Text('Open Modal'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open Modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Verify Modal Elements
      expect(find.text('Custom Accent'), findsOneWidget);
      expect(find.text('Configure theme tone & dynamic accents'), findsOneWidget);
      expect(find.text('Single'), findsOneWidget);
      expect(find.text('Gradient'), findsOneWidget);
      expect(find.text('ACTIVE SOLID COLOR'), findsOneWidget);
      expect(find.text('Hue Spectrum'), findsOneWidget);
      expect(find.text('Saturation & Vibrancy'), findsOneWidget);
      expect(find.text('PRESETS'), findsOneWidget);

      // Switch to Gradient Mode
      await tester.tap(find.text('Gradient'));
      await tester.pumpAndSettle();

      expect(find.text('STOP 1'), findsOneWidget);
      expect(find.text('STOP 2'), findsOneWidget);
      expect(find.text('Angle'), findsOneWidget);
      expect(find.text('135°'), findsOneWidget);

      // Switch back to Single Mode
      await tester.tap(find.text('Single'));
      await tester.pumpAndSettle();

      // Tap Apply Accent
      await tester.tap(find.text('Apply Accent'));
      await tester.pumpAndSettle();

      // Modal is dismissed
      expect(find.text('ACTIVE SOLID COLOR'), findsNothing);
    });
  });
}
