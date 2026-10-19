import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittrack/presentation/providers/theme_provider.dart';
import 'package:fittrack/presentation/widgets/glass_surface.dart';
import 'package:fittrack/presentation/widgets/modals/selection_modal.dart';
import 'package:fittrack/presentation/widgets/modals/text_input_modal.dart';
import 'package:fittrack/presentation/widgets/modals/dob_picker_modal.dart';
import 'package:fittrack/presentation/widgets/modals/discard_changes_dialog.dart';
import 'package:fittrack/presentation/screens/profile/widgets/profile_action_dock.dart';
import 'package:fittrack/presentation/screens/settings/account_details/widgets/account_floating_dock.dart';

void main() {
  group('Modals and Docks Frosted Glass Theme Compliance Tests', () {
    testWidgets('SelectionModal respects enableGlassTransparency toggle and blurIntensity scaling',
        (WidgetTester tester) async {
      // 1. Test with enableGlassTransparency: true and Subtle (4px)
      final container = ProviderContainer(
        overrides: [
          themeProvider.overrideWith(() => _FakeThemeNotifier(
                const ThemeSettings(
                  enableGlassTransparency: true,
                  blurIntensity: 4.0,
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
              body: SelectionModal(
                title: 'Select Experience Level',
                subtitle: 'Choose your lifting experience tier',
                options: ['Beginner', 'Intermediate', 'Advanced', 'Elite'],
                selectedOption: 'Intermediate',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // GlassSurface is rendered
      expect(find.byType(GlassSurface), findsOneWidget);
      expect(find.text('Select Experience Level'), findsOneWidget);

      // Verify live BackdropFilter exists with Subtle sigma (~3.0)
      final subtleFilters = tester.widgetList<BackdropFilter>(find.byType(BackdropFilter));
      expect(subtleFilters, isNotEmpty);
      expect(subtleFilters.first.filter.toString(), contains('3.0'));

      // 2. Change to Intense (32px)
      await container.read(themeProvider.notifier).setBlurIntensity(32.0);
      await tester.pumpAndSettle();

      final intenseFilters = tester.widgetList<BackdropFilter>(find.byType(BackdropFilter));
      expect(intenseFilters, isNotEmpty);
      expect(intenseFilters.first.filter.toString(), contains('36.0'));

      // 3. Toggle transparency OFF
      await container.read(themeProvider.notifier).toggleGlassTransparency(false);
      await tester.pumpAndSettle();

      // Live BackdropFilter is removed when glass transparency is OFF
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('TextInputModal respects enableGlassTransparency toggle and blurIntensity scaling',
        (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          themeProvider.overrideWith(() => _FakeThemeNotifier(
                const ThemeSettings(
                  enableGlassTransparency: true,
                  blurIntensity: 4.0,
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
              body: TextInputModal(
                title: 'Update Body Weight',
                subtitle: 'Enter your current scale weight in kg',
                initialValue: '82.0',
                keyboardType: TextInputType.number,
                suffixText: 'kg',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GlassSurface), findsOneWidget);
      expect(find.text('Update Body Weight'), findsOneWidget);

      // Verify live BackdropFilter with 3.0 sigma
      final filter = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
      expect(filter.filter.toString(), contains('3.0'));

      // Toggle transparency OFF
      await container.read(themeProvider.notifier).toggleGlassTransparency(false);
      await tester.pumpAndSettle();

      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('DobPickerModal respects enableGlassTransparency and renders GlassSurface',
        (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          themeProvider.overrideWith(() => _FakeThemeNotifier(
                const ThemeSettings(
                  enableGlassTransparency: true,
                  blurIntensity: 16.0,
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
              body: DobPickerModal(
                initialDate: DateTime(2002, 10, 14),
                maxYear: 2026,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GlassSurface), findsOneWidget);
      expect(find.text('Select Date of Birth'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);

      // Toggle transparency OFF
      await container.read(themeProvider.notifier).toggleGlassTransparency(false);
      await tester.pumpAndSettle();

      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('ProfileActionDock follows enableGlassTransparency and blurIntensity',
        (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          themeProvider.overrideWith(() => _FakeThemeNotifier(
                const ThemeSettings(
                  enableGlassTransparency: true,
                  blurIntensity: 4.0,
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
              body: ProfileActionDock(
                isVisible: true,
                onSave: () {},
                onDiscard: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GlassSurface), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
      expect(find.text('Discard changes'), findsOneWidget);

      // Live BackdropFilter is present
      final subtleFilter = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
      expect(subtleFilter.filter.toString(), contains('3.0'));

      // Scale to Intense (32px)
      await container.read(themeProvider.notifier).setBlurIntensity(32.0);
      await tester.pumpAndSettle();

      final intenseFilter = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
      expect(intenseFilter.filter.toString(), contains('36.0'));

      // Toggle transparency OFF
      await container.read(themeProvider.notifier).toggleGlassTransparency(false);
      await tester.pumpAndSettle();

      // No BackdropFilter when transparency is turned off
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('AccountFloatingDock follows enableGlassTransparency and blurIntensity',
        (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          themeProvider.overrideWith(() => _FakeThemeNotifier(
                const ThemeSettings(
                  enableGlassTransparency: true,
                  blurIntensity: 4.0,
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
              body: AccountFloatingDock(
                isVisible: true,
                onSave: () {},
                onDiscard: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GlassSurface), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
      expect(find.text('Discard changes'), findsOneWidget);

      final subtleFilter = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
      expect(subtleFilter.filter.toString(), contains('3.0'));

      // Toggle transparency OFF
      await container.read(themeProvider.notifier).toggleGlassTransparency(false);
      await tester.pumpAndSettle();

      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('DiscardChangesDialog renders GlassSurface and adapts to theme settings',
        (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          themeProvider.overrideWith(() => _FakeThemeNotifier(
                const ThemeSettings(
                  enableGlassTransparency: true,
                  blurIntensity: 16.0,
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
              body: DiscardChangesDialog(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GlassSurface), findsOneWidget);
      expect(find.text('Discard changes?'), findsOneWidget);
      expect(find.text('Keep editing'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);
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
