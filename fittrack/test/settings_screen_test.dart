import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittrack/presentation/screens/settings_screen.dart';
import 'package:fittrack/presentation/screens/settings/settings_subscreens.dart';

void main() {
  testWidgets('SettingsScreen renders all sections, Stitch preview badges, and tiles correctly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Header & Search
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Manage your account, preferences & hardware'), findsOneWidget);
    expect(find.text('Search settings...'), findsOneWidget);
    expect(find.text('⌘K'), findsOneWidget);

    // 2. Profile Card matching Stitch (MasterDineth / Dineth, @dineth.fit, Advanced Lifter)
    expect(find.text('Dineth'), findsOneWidget);
    expect(find.text('@dineth.fit'), findsOneWidget);
    expect(find.text('Advanced Lifter'), findsOneWidget);

    // 3. Section Headers
    expect(find.text('ACCOUNT & SECURITY'), findsOneWidget);
    expect(find.text('WORKOUT & TIMERS'), findsOneWidget);
    expect(find.text('APP PREFERENCES'), findsOneWidget);
    expect(find.text('SUPPORT & ABOUT'), findsOneWidget);

    // 4. Section Items & Subtitles
    expect(find.text('Account Details'), findsOneWidget);
    expect(find.text('Security & Privacy'), findsOneWidget);
    expect(find.text('Password & Authentication'), findsOneWidget);
    expect(find.text('Workout Preferences'), findsOneWidget);
    expect(find.text('Units & Equipment'), findsOneWidget);
    expect(find.text('Appearance & Display'), findsOneWidget);
    expect(find.text('Notifications & Reminders'), findsOneWidget);
    expect(find.text('Data & Integrations'), findsOneWidget);
    expect(find.text('Help Center & FAQs'), findsOneWidget);
    expect(find.text('Share & Rate FitTrack'), findsOneWidget);
    expect(find.text('About FitTrack'), findsOneWidget);

    // 5. Quick Preview Badges matching Stitch design (On, 1:30, Metric, System, Synced, v1.4.2)
    expect(find.text('On'), findsAtLeastNWidgets(1));
    expect(find.text('1:30'), findsOneWidget);
    expect(find.text('Metric'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Synced'), findsOneWidget);
    expect(find.text('v1.4.2'), findsOneWidget);

    // 6. Log Out Button
    expect(find.text('Log Out'), findsOneWidget);
  });

  testWidgets('Search query filters settings tiles dynamically',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Enter search text 'appearance'
    await tester.enterText(find.byType(TextField), 'appearance');
    await tester.pumpAndSettle();

    // Matches Appearance & Display, while hiding other unrelated tiles
    expect(find.text('Appearance & Display'), findsOneWidget);
    expect(find.text('Account Details'), findsNothing);
    expect(find.text('Workout Preferences'), findsNothing);

    // Clear search
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // Restores all tiles
    expect(find.text('Account Details'), findsOneWidget);
    expect(find.text('Workout Preferences'), findsOneWidget);
  });

  testWidgets('Tapping Log Out displays confirmation dialog',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final logoutTextFinder = find.text('Log Out');
    expect(logoutTextFinder, findsOneWidget);
    await tester.tap(logoutTextFinder);
    await tester.pumpAndSettle();

    expect(
      find.text('Are you sure you want to log out of your FitTrack account?'),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);

    // Cancel dismissal
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(
      find.text('Are you sure you want to log out of your FitTrack account?'),
      findsNothing,
    );
  });

  testWidgets('Tapping Share & Rate FitTrack opens blurred rating modal',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final rateTileFinder = find.text('Share & Rate FitTrack');
    expect(rateTileFinder, findsOneWidget);
    await tester.tap(rateTileFinder);
    await tester.pumpAndSettle();

    // Verify modal elements
    expect(find.text('Enjoying FitTrack?'), findsOneWidget);
    expect(find.text('Rate on App Store'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsWidgets);

    // Tap action button and verify dismissal
    await tester.tap(find.text('Rate on App Store'));
    await tester.pumpAndSettle();
    expect(find.text('Enjoying FitTrack?'), findsNothing);
  });

  testWidgets('Settings placeholder sub-screens render title and content',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Dineth'), findsAtLeastNWidgets(1));
  });
}
