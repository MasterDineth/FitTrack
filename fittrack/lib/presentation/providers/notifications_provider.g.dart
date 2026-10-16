// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the active notification item for the in-header Dynamic Island morph.
/// Drives the 3.2s auto-collapse countdown (Timer). Cancel timer in ref.onDispose.
/// Cleared on user dismissal or shade open.

@ProviderFor(NotificationIsland)
final notificationIslandProvider = NotificationIslandProvider._();

/// Manages the active notification item for the in-header Dynamic Island morph.
/// Drives the 3.2s auto-collapse countdown (Timer). Cancel timer in ref.onDispose.
/// Cleared on user dismissal or shade open.
final class NotificationIslandProvider
    extends $NotifierProvider<NotificationIsland, FtNotificationItem?> {
  /// Manages the active notification item for the in-header Dynamic Island morph.
  /// Drives the 3.2s auto-collapse countdown (Timer). Cancel timer in ref.onDispose.
  /// Cleared on user dismissal or shade open.
  NotificationIslandProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationIslandProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationIslandHash();

  @$internal
  @override
  NotificationIsland create() => NotificationIsland();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FtNotificationItem? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FtNotificationItem?>(value),
    );
  }
}

String _$notificationIslandHash() =>
    r'685a711ec54e3048ff87fdf03f1d9e3e2acd86d8';

/// Manages the active notification item for the in-header Dynamic Island morph.
/// Drives the 3.2s auto-collapse countdown (Timer). Cancel timer in ref.onDispose.
/// Cleared on user dismissal or shade open.

abstract class _$NotificationIsland extends $Notifier<FtNotificationItem?> {
  FtNotificationItem? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FtNotificationItem?, FtNotificationItem?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FtNotificationItem?, FtNotificationItem?>,
              FtNotificationItem?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Manages global shade visibility and opening anchor origin.

@ProviderFor(NotificationShade)
final notificationShadeProvider = NotificationShadeProvider._();

/// Manages global shade visibility and opening anchor origin.
final class NotificationShadeProvider
    extends $NotifierProvider<NotificationShade, NotificationShadeState> {
  /// Manages global shade visibility and opening anchor origin.
  NotificationShadeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationShadeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationShadeHash();

  @$internal
  @override
  NotificationShade create() => NotificationShade();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationShadeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationShadeState>(value),
    );
  }
}

String _$notificationShadeHash() => r'd0aa58d962d259ad5ae13ee0ae6704264d2d4239';

/// Manages global shade visibility and opening anchor origin.

abstract class _$NotificationShade extends $Notifier<NotificationShadeState> {
  NotificationShadeState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<NotificationShadeState, NotificationShadeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NotificationShadeState, NotificationShadeState>,
              NotificationShadeState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Holds loggedWaterLiters (defaults to 1.8L), cleanly separating hydration telemetry from notifications.

@ProviderFor(HydrationProgress)
final hydrationProgressProvider = HydrationProgressProvider._();

/// Holds loggedWaterLiters (defaults to 1.8L), cleanly separating hydration telemetry from notifications.
final class HydrationProgressProvider
    extends $NotifierProvider<HydrationProgress, double> {
  /// Holds loggedWaterLiters (defaults to 1.8L), cleanly separating hydration telemetry from notifications.
  HydrationProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hydrationProgressProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hydrationProgressHash();

  @$internal
  @override
  HydrationProgress create() => HydrationProgress();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$hydrationProgressHash() => r'c903c1c82d32ed60b86777cecb3678de0f5cc618';

/// Holds loggedWaterLiters (defaults to 1.8L), cleanly separating hydration telemetry from notifications.

abstract class _$HydrationProgress extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Holds all active notification items.
/// Methods: push(...), dismiss(id), clearAll(), resetDemo().

@ProviderFor(NotificationFeed)
final notificationFeedProvider = NotificationFeedProvider._();

/// Holds all active notification items.
/// Methods: push(...), dismiss(id), clearAll(), resetDemo().
final class NotificationFeedProvider
    extends $NotifierProvider<NotificationFeed, List<FtNotificationItem>> {
  /// Holds all active notification items.
  /// Methods: push(...), dismiss(id), clearAll(), resetDemo().
  NotificationFeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationFeedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationFeedHash();

  @$internal
  @override
  NotificationFeed create() => NotificationFeed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<FtNotificationItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<FtNotificationItem>>(value),
    );
  }
}

String _$notificationFeedHash() => r'898a3a4feeaa9606ce25c19ed6d72bb5a55b6a15';

/// Holds all active notification items.
/// Methods: push(...), dismiss(id), clearAll(), resetDemo().

abstract class _$NotificationFeed extends $Notifier<List<FtNotificationItem>> {
  List<FtNotificationItem> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<List<FtNotificationItem>, List<FtNotificationItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<FtNotificationItem>, List<FtNotificationItem>>,
              List<FtNotificationItem>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Unread notification count for header bell badges.

@ProviderFor(unreadNotificationCount)
final unreadNotificationCountProvider = UnreadNotificationCountProvider._();

/// Unread notification count for header bell badges.

final class UnreadNotificationCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Unread notification count for header bell badges.
  UnreadNotificationCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadNotificationCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadNotificationCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return unreadNotificationCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$unreadNotificationCountHash() =>
    r'13a6be41ca1b2ba6ff5bdc737bba664c48bd1e05';
