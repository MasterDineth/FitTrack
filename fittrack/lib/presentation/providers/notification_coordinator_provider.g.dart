// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_coordinator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Orchestrates all device notifications.
///
/// - Listens to [activeWorkoutProvider] to emit live notifications.
/// - Listens to [notificationSettingsProvider] to replan reminders.
/// - Registers the [ReceivePort] that routes background action buttons to the
///   real notifier methods (§2.5 of the spec).
/// - Handles deep-link navigation from the notification tap stream.

@ProviderFor(NotificationCoordinator)
final notificationCoordinatorProvider = NotificationCoordinatorProvider._();

/// Orchestrates all device notifications.
///
/// - Listens to [activeWorkoutProvider] to emit live notifications.
/// - Listens to [notificationSettingsProvider] to replan reminders.
/// - Registers the [ReceivePort] that routes background action buttons to the
///   real notifier methods (§2.5 of the spec).
/// - Handles deep-link navigation from the notification tap stream.
final class NotificationCoordinatorProvider
    extends $NotifierProvider<NotificationCoordinator, void> {
  /// Orchestrates all device notifications.
  ///
  /// - Listens to [activeWorkoutProvider] to emit live notifications.
  /// - Listens to [notificationSettingsProvider] to replan reminders.
  /// - Registers the [ReceivePort] that routes background action buttons to the
  ///   real notifier methods (§2.5 of the spec).
  /// - Handles deep-link navigation from the notification tap stream.
  NotificationCoordinatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationCoordinatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationCoordinatorHash();

  @$internal
  @override
  NotificationCoordinator create() => NotificationCoordinator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$notificationCoordinatorHash() =>
    r'de07f36f1954b11b0a75d2da16431fdc9c5aa336';

/// Orchestrates all device notifications.
///
/// - Listens to [activeWorkoutProvider] to emit live notifications.
/// - Listens to [notificationSettingsProvider] to replan reminders.
/// - Registers the [ReceivePort] that routes background action buttons to the
///   real notifier methods (§2.5 of the spec).
/// - Handles deep-link navigation from the notification tap stream.

abstract class _$NotificationCoordinator extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Holds the last notification payload that needs navigation.
/// The router / app shell reads this to navigate after gating resolves.

@ProviderFor(PendingNotificationRoute)
final pendingNotificationRouteProvider = PendingNotificationRouteProvider._();

/// Holds the last notification payload that needs navigation.
/// The router / app shell reads this to navigate after gating resolves.
final class PendingNotificationRouteProvider
    extends $NotifierProvider<PendingNotificationRoute, NotificationPayload?> {
  /// Holds the last notification payload that needs navigation.
  /// The router / app shell reads this to navigate after gating resolves.
  PendingNotificationRouteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingNotificationRouteProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingNotificationRouteHash();

  @$internal
  @override
  PendingNotificationRoute create() => PendingNotificationRoute();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationPayload? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationPayload?>(value),
    );
  }
}

String _$pendingNotificationRouteHash() =>
    r'83f9239aac77e42d7095919f9a3d649266dc1ba0';

/// Holds the last notification payload that needs navigation.
/// The router / app shell reads this to navigate after gating resolves.

abstract class _$PendingNotificationRoute
    extends $Notifier<NotificationPayload?> {
  NotificationPayload? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<NotificationPayload?, NotificationPayload?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NotificationPayload?, NotificationPayload?>,
              NotificationPayload?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
