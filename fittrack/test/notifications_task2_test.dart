import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/presentation/providers/notifications_provider.dart';
import 'package:fittrack/presentation/widgets/notifications/global_notification_shade_host.dart';

void main() {
  group('Task 2: Centralized Notifications Unit Tests', () {
    test('notificationFeedProvider starts with default demo items', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final items = container.read(notificationFeedProvider);
      expect(items, isNotEmpty);
      expect(items.length, greaterThanOrEqualTo(3));
      expect(container.read(unreadNotificationCountProvider), items.length);
    });

    test('notificationFeedProvider push adds an item to the top of feed', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialCount = container.read(notificationFeedProvider).length;

      final newItem = FtNotificationItem(
        id: 'custom_test_1',
        type: FtNotificationType.pr,
        title: 'New PR Hit!',
        body: 'Bench Press: 100kg x 5 reps',
        timestamp: DateTime.now(),
      );

      container.read(notificationFeedProvider.notifier).push(newItem);

      final updatedFeed = container.read(notificationFeedProvider);
      expect(updatedFeed.length, initialCount + 1);
      expect(updatedFeed.first.id, 'custom_test_1');
      expect(container.read(unreadNotificationCountProvider), initialCount + 1);
    });

    test('notificationFeedProvider dismiss removes item by id', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final items = container.read(notificationFeedProvider);
      final idToRemove = items.first.id;

      container.read(notificationFeedProvider.notifier).dismiss(idToRemove);

      final updatedFeed = container.read(notificationFeedProvider);
      expect(updatedFeed.any((item) => item.id == idToRemove), isFalse);
    });

    test('notificationFeedProvider clearAll empties the feed and resets unread count', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(notificationFeedProvider.notifier).clearAll();

      expect(container.read(notificationFeedProvider), isEmpty);
      expect(container.read(unreadNotificationCountProvider), 0);
    });

    test('notificationFeedProvider resetDemo restores initial items', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(notificationFeedProvider.notifier).clearAll();
      expect(container.read(notificationFeedProvider), isEmpty);

      container.read(notificationFeedProvider.notifier).resetDemo();
      expect(container.read(notificationFeedProvider).length, 4);
      expect(container.read(unreadNotificationCountProvider), 4);
    });

    test('notificationIslandProvider sets active item and auto-collapses after 2.0s', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final item = FtNotificationItem(
        id: 'island_test_1',
        type: FtNotificationType.hydration,
        title: 'Hydration Target',
        body: 'Time to drink 250ml water',
        timestamp: DateTime.now(),
      );

      container.read(notificationIslandProvider.notifier).show(item);
      expect(container.read(notificationIslandProvider)?.id, 'island_test_1');

      // Fast-forward 2.0 seconds
      await Future.delayed(const Duration(milliseconds: 2050));
      expect(container.read(notificationIslandProvider), isNull);
    });

    test('notificationIslandProvider collapses immediately on collapse()', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final item = FtNotificationItem(
        id: 'island_dismiss_test',
        type: FtNotificationType.strain,
        title: 'High Strain',
        body: 'Strain reached 14.5',
        timestamp: DateTime.now(),
      );

      container.read(notificationIslandProvider.notifier).show(item);
      expect(container.read(notificationIslandProvider)?.id, 'island_dismiss_test');

      container.read(notificationIslandProvider.notifier).collapse();
      expect(container.read(notificationIslandProvider), isNull);
    });

    test('notificationShadeProvider open, close, and toggle with origin', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final shadeNotifier = container.read(notificationShadeProvider.notifier);
      expect(container.read(notificationShadeProvider).isOpen, isFalse);

      const testOrigin = Offset(120, 48);
      shadeNotifier.open(origin: testOrigin);
      expect(container.read(notificationShadeProvider).isOpen, isTrue);
      expect(container.read(notificationShadeProvider).origin, testOrigin);

      shadeNotifier.close();
      expect(container.read(notificationShadeProvider).isOpen, isFalse);

      // Toggle
      shadeNotifier.toggle(origin: testOrigin);
      expect(container.read(notificationShadeProvider).isOpen, isTrue);
      expect(container.read(notificationShadeProvider).origin, testOrigin);

      shadeNotifier.toggle();
      expect(container.read(notificationShadeProvider).isOpen, isFalse);
    });

    test('Opening shade automatically collapses notification island', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final item = FtNotificationItem(
        id: 'island_shade_collapse',
        type: FtNotificationType.habit,
        title: 'Habit Reminder',
        body: 'Log protein intake',
        timestamp: DateTime.now(),
      );

      container.read(notificationIslandProvider.notifier).show(item);
      expect(container.read(notificationIslandProvider), isNotNull);

      container.read(notificationShadeProvider.notifier).open();
      expect(container.read(notificationIslandProvider), isNull);
    });

    test('Pushing notification while shade is open does NOT trigger island expansion', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Open shade
      container.read(notificationShadeProvider.notifier).open();

      final item = FtNotificationItem(
        id: 'open_shade_item',
        type: FtNotificationType.pr,
        title: 'While Shade Open',
        body: 'Added to feed only',
        timestamp: DateTime.now(),
      );

      container.read(notificationFeedProvider.notifier).push(item);

      // Item was added to feed
      expect(container.read(notificationFeedProvider).first.id, 'open_shade_item');
      // Island was NOT triggered
      expect(container.read(notificationIslandProvider), isNull);
    });

    test('hydrationProgressProvider starts at 1.8L and updates correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(hydrationProgressProvider), 1.8);

      container.read(hydrationProgressProvider.notifier).addLiters(0.25);
      expect(container.read(hydrationProgressProvider), 2.05);

      container.read(hydrationProgressProvider.notifier).reset();
      expect(container.read(hydrationProgressProvider), 1.8);
    });
  });

  group('Task 2: GlobalNotificationShadeHost & Back Navigation', () {
    testWidgets('GlobalNotificationShadeHost intercepts Android back gesture when shade is open', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            builder: (context, child) => GlobalNotificationShadeHost(
              child: child ?? const SizedBox.shrink(),
            ),
            home: const Scaffold(
              body: Center(child: Text('Home Screen')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final element = tester.element(find.text('Home Screen'));
      final container = ProviderScope.containerOf(element);

      // Initially shade is closed
      expect(container.read(notificationShadeProvider).isOpen, isFalse);

      // Back button when closed is NOT intercepted (returns false)
      final handledWhenClosed = await tester.binding.handlePopRoute();
      expect(handledWhenClosed, isFalse);

      // Open shade
      container.read(notificationShadeProvider.notifier).open();
      await tester.pumpAndSettle();
      expect(container.read(notificationShadeProvider).isOpen, isTrue);

      // Back button when open IS intercepted (returns true) and closes shade
      final handledWhenOpen = await tester.binding.handlePopRoute();
      expect(handledWhenOpen, isTrue);
      await tester.pumpAndSettle();

      // Shade state should now be closed
      expect(container.read(notificationShadeProvider).isOpen, isFalse);
    });

    testWidgets('GlobalNotificationShadeHost renders child and mounts shade with transparent Material', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            builder: (context, child) => GlobalNotificationShadeHost(
              child: child ?? const SizedBox.shrink(),
            ),
            home: const Scaffold(
              body: Center(child: Text('Underlying Screen Content')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Underlying Screen Content'), findsOneWidget);

      // Verify Material transparency is present in GlobalNotificationShadeHost
      final materialFinder = find.byWidgetPredicate(
        (w) => w is Material && w.type == MaterialType.transparency,
      );
      expect(materialFinder, findsOneWidget);
    });
  });
}
