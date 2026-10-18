import 'dart:async';
import 'dart:ui';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../router/app_router.dart';

part 'notifications_provider.g.dart';

/// Notification category types across FitTrack.
enum FtNotificationType {
  hydration,
  pr,
  strain,
  habit,
}

/// Immutable notification model representing an in-app alert or feed entry.
class FtNotificationItem {
  final String id;
  final FtNotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;

  const FtNotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FtNotificationItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          title == other.title &&
          body == other.body &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      id.hashCode ^
      type.hashCode ^
      title.hashCode ^
      body.hashCode ^
      timestamp.hashCode;
}

/// Global state controlling Notification Shade overlay visibility and opening anchor origin.
class NotificationShadeState {
  final bool isOpen;
  final Offset? origin; // Global center of the bell icon that triggered open

  const NotificationShadeState({
    this.isOpen = false,
    this.origin,
  });

  NotificationShadeState copyWith({
    bool? isOpen,
    Offset? origin,
    bool clearOrigin = false,
  }) {
    return NotificationShadeState(
      isOpen: isOpen ?? this.isOpen,
      origin: clearOrigin ? null : (origin ?? this.origin),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationShadeState &&
          runtimeType == other.runtimeType &&
          isOpen == other.isOpen &&
          origin == other.origin;

  @override
  int get hashCode => isOpen.hashCode ^ (origin?.hashCode ?? 0);
}

/// Manages the active notification item for the in-header Dynamic Island morph.
/// Drives the 2.0s auto-collapse countdown (Timer). Cancel timer in ref.onDispose.
/// Cleared on user dismissal or shade open.
@Riverpod(keepAlive: true)
class NotificationIsland extends _$NotificationIsland {
  Timer? _autoCollapseTimer;

  @override
  FtNotificationItem? build() {
    ref.onDispose(() {
      _autoCollapseTimer?.cancel();
    });
    return null;
  }

  void show(FtNotificationItem item) {
    _autoCollapseTimer?.cancel();
    state = item;
    _autoCollapseTimer = Timer(const Duration(milliseconds: 2000), () {
      collapse();
    });
  }

  void collapse() {
    _autoCollapseTimer?.cancel();
    if (state != null) {
      state = null;
    }
  }

  void clear() => collapse();
}

/// Manages global shade visibility and opening anchor origin.
@Riverpod(keepAlive: true)
class NotificationShade extends _$NotificationShade {
  @override
  NotificationShadeState build() {
    return const NotificationShadeState();
  }

  void open({Offset? origin}) {
    ref.read(notificationIslandProvider.notifier).collapse();
    state = NotificationShadeState(
      isOpen: true,
      origin: origin,
    );
  }

  void close() {
    if (state.isOpen) {
      state = state.copyWith(isOpen: false);
    }
  }

  void toggle({Offset? origin}) {
    if (state.isOpen) {
      close();
    } else {
      open(origin: origin);
    }
  }
}

/// Holds loggedWaterLiters (defaults to 1.8L), cleanly separating hydration telemetry from notifications.
@Riverpod(keepAlive: true)
class HydrationProgress extends _$HydrationProgress {
  @override
  double build() {
    return 1.8;
  }

  void setLiters(double liters) {
    state = liters.clamp(0.0, 2.5);
  }

  void addLiters(double liters) {
    state = (state + liters).clamp(0.0, 2.5);
  }

  void reset() {
    state = 1.8;
  }
}

bool _isRouteSuppressed(Ref ref) {
  try {
    if (!ref.exists(routerProvider)) {
      return false;
    }
    final router = ref.read(routerProvider);
    final path = router.routerDelegate.currentConfiguration.uri.path;
    if (path == '/splash' ||
        path == '/welcome' ||
        path == '/auth' ||
        path.startsWith('/workouts/active') ||
        path.startsWith('/workout/execute')) {
      return true;
    }
    return false;
  } catch (_) {
    return false;
  }
}

/// Holds all active notification items.
/// Methods: push(...), dismiss(id), clearAll(), resetDemo().
@Riverpod(keepAlive: true)
class NotificationFeed extends _$NotificationFeed {
  static List<FtNotificationItem> defaultItems() {
    final now = DateTime.now();
    return [
      FtNotificationItem(
        id: 'notif_1',
        type: FtNotificationType.hydration,
        title: 'Hydration check:',
        body: '1.8L / 2.5L logged today',
        timestamp: now.subtract(const Duration(minutes: 2)),
      ),
      FtNotificationItem(
        id: 'notif_2',
        type: FtNotificationType.habit,
        title: 'Recovery optimal:',
        body: '92% readiness after 7h 48m sleep',
        timestamp: now.subtract(const Duration(minutes: 18)),
      ),
      FtNotificationItem(
        id: 'notif_3',
        type: FtNotificationType.pr,
        title: 'New Bench PR:',
        body: '85 kg x 8 reps completed',
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      FtNotificationItem(
        id: 'notif_4',
        type: FtNotificationType.strain,
        title: 'Daily Strain:',
        body: '12.4 logged (Goal 14.5)',
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
    ];
  }

  @override
  List<FtNotificationItem> build() {
    return defaultItems();
  }

  /// Pushes a new notification item.
  /// If shade is open, appends to feed without closing shade or expanding island.
  /// If current route is suppressed, updates feed without expanding island.
  /// Otherwise, expands island for 2.0s.
  void push(FtNotificationItem item) {
    state = [item, ...state];

    final isShadeOpen = ref.read(notificationShadeProvider).isOpen;
    if (isShadeOpen) {
      return;
    }

    if (_isRouteSuppressed(ref)) {
      return;
    }

    ref.read(notificationIslandProvider.notifier).show(item);
  }

  void pushNotification({
    required FtNotificationType type,
    required String title,
    required String body,
    String? id,
    DateTime? timestamp,
  }) {
    final newItem = FtNotificationItem(
      id: id ?? 'notif_${DateTime.now().microsecondsSinceEpoch}',
      type: type,
      title: title,
      body: body,
      timestamp: timestamp ?? DateTime.now(),
    );
    push(newItem);
  }

  void pushPreset(FtNotificationType type) {
    switch (type) {
      case FtNotificationType.hydration:
        ref.read(hydrationProgressProvider.notifier).addLiters(0.25);
        final currentWater = ref.read(hydrationProgressProvider);
        pushNotification(
          type: FtNotificationType.hydration,
          title: 'Hydration check:',
          body: '${currentWater.toStringAsFixed(2)}L / 2.5L logged (+250ml)',
        );
      case FtNotificationType.pr:
        pushNotification(
          type: FtNotificationType.pr,
          title: 'New PR Unlocked:',
          body: 'Barbell Bench Press 85 kg x 8 reps',
        );
      case FtNotificationType.strain:
        pushNotification(
          type: FtNotificationType.strain,
          title: 'Strain Alert:',
          body: 'Day strain reached 13.8 / 14.5',
        );
      case FtNotificationType.habit:
        pushNotification(
          type: FtNotificationType.habit,
          title: 'Habit Reminder:',
          body: 'Post-workout 35g Whey + 5g Creatine due',
        );
    }
  }

  void dismiss(String id) {
    state = state.where((item) => item.id != id).toList();
    if (ref.read(notificationIslandProvider)?.id == id) {
      ref.read(notificationIslandProvider.notifier).collapse();
    }
  }

  void dismissItem(String id) => dismiss(id);

  void clearAll() {
    state = const [];
    ref.read(notificationIslandProvider.notifier).collapse();
  }

  void resetDemo() {
    ref.read(notificationIslandProvider.notifier).collapse();
    ref.read(hydrationProgressProvider.notifier).reset();
    state = defaultItems();
  }

  void resetDemoItems() => resetDemo();
}

/// Unread notification count for header bell badges.
@Riverpod(keepAlive: true)
int unreadNotificationCount(Ref ref) {
  return ref.watch(notificationFeedProvider).length;
}
