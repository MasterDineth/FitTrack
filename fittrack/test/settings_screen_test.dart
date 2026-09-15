import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/presentation/screens/settings_screen.dart';
import 'package:fittrack/presentation/screens/settings/settings_subscreens.dart';

void main() {
  testWidgets('SettingsScreen renders all sections, badges, and tiles correctly',
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
    expect(find.text('Search settings...'), findsOneWidget);
    expect(find.text('⌘K'), findsOneWidget);

    // 2. Profile Card
    expect(find.text('Dineth'), findsOneWidget);
    expect(find.text('PRO LIFTER'), findsOneWidget);
    expect(find.text('@dineth.fit'), findsOneWidget);
    expect(find.text('Manage Account'), findsOneWidget);

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

    // 5. Badges
    expect(find.text('Biometrics On'), findsOneWidget);
    expect(find.text('Enabled'), findsOneWidget);

    // 6. Log Out Button
    expect(find.text('Log Out'), findsOneWidget);
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
      const MaterialApp(
        home: ProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Profile & Account Management'), findsOneWidget);
  });
}

