import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/presentation/providers/theme_provider.dart';
import 'package:fittrack/presentation/theme/ft_glass.dart';
import 'package:fittrack/presentation/theme/glass_tokens.dart';
import 'package:fittrack/presentation/widgets/glass/frosted_glass_box.dart';
import 'package:fittrack/presentation/widgets/glass_surface.dart';

void main() {
  group('GlassSurface Backdrop Policy Tests', () {
    testWidgets(
        'default glass1 and glass2 are flat (0 BackdropFilter), glassFloating is live (1 BackdropFilter)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  GlassSurface(
                    tier: FtGlassTier.glass1,
                    child: Text('Glass 1'),
                  ),
                  GlassSurface(
                    tier: FtGlassTier.glass2,
                    child: Text('Glass 2'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Flat surfaces do not allocate BackdropFilters
      expect(find.byType(BackdropFilter), findsNothing);

      // Now pump glassFloating
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GlassSurface(
                tier: FtGlassTier.glassFloating,
                child: Text('Floating Glass'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets(
        'glass1 with backdrop: GlassBackdrop.live creates 1 BackdropFilter',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GlassSurface(
                tier: FtGlassTier.glass1,
                backdrop: GlassBackdrop.live,
                child: Text('Live Glass 1'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets(
        'BackdropFilter is 0 for any tier when Appearance transparency is off',
        (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          themeProvider.overrideWith(
            () => _FakeThemeNotifier(
              const ThemeSettings(
                enableGlassTransparency: false,
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
            home: Scaffold(
              body: Column(
                children: [
                  GlassSurface(
                    tier: FtGlassTier.glass1,
                    backdrop: GlassBackdrop.live,
                    child: Text('Live 1'),
                  ),
                  GlassSurface(
                    tier: FtGlassTier.glassFloating,
                    child: Text('Floating'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Zero BackdropFilter when transparency is off
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('enableBlur: false resolves to flat even if tier is glassFloating',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GlassSurface(
                tier: FtGlassTier.glassFloating,
                enableBlur: false,
                child: Text('Floating but disabled blur'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('flat surface fill alpha still follows blurIntensity slider',
        (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          themeProvider.overrideWith(
            () => _FakeThemeNotifier(
              const ThemeSettings(
                enableGlassTransparency: true,
                blurIntensity: 4.0, // Subtle
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
            home: Scaffold(
              body: GlassSurface(
                tier: FtGlassTier.glass1, // flat by default
                child: Text('Flat Glass Card'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify no BackdropFilter
      expect(find.byType(BackdropFilter), findsNothing);

      // Verify Subtle fill alpha
      final subtleBoxes = tester.widgetList<Container>(find.descendant(
        of: find.byType(GlassSurface),
        matching: find.byType(Container),
      ));
      final Container subtleBox = subtleBoxes.firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).color != null,
      );
      final subtleColor = (subtleBox.decoration as BoxDecoration).color!;
      expect(subtleColor.a, lessThan(0.35));

      // Update to Intense (32px)
      await container.read(themeProvider.notifier).setBlurIntensity(32.0);
      await tester.pumpAndSettle();

      // Verify no BackdropFilter remains
      expect(find.byType(BackdropFilter), findsNothing);

      // Verify Intense fill alpha
      final intenseBoxes = tester.widgetList<Container>(find.descendant(
        of: find.byType(GlassSurface),
        matching: find.byType(Container),
      ));
      final Container intenseBox = intenseBoxes.firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).color != null,
      );
      final intenseColor = (intenseBox.decoration as BoxDecoration).color!;
      expect(intenseColor.a, greaterThan(0.75));
    });
  });

  group('FrostedGlassBox Policy Mirrored Tests', () {
    testWidgets(
        'default surface is flat (0 BackdropFilter), floating is live (1 BackdropFilter)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FrostedGlassBox(
                tier: GlassTier.surface,
                child: Text('Surface'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BackdropFilter), findsNothing);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FrostedGlassBox(
                tier: GlassTier.floating,
                child: Text('Floating'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('FrostedGlassBox with backdrop: GlassBackdrop.live is live',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FrostedGlassBox(
                tier: GlassTier.surface,
                backdrop: GlassBackdrop.live,
                child: Text('Live Surface'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BackdropFilter), findsOneWidget);
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
