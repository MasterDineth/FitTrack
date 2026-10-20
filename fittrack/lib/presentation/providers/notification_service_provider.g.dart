// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Singleton [LiveSnapshotStore] backed by the pre-loaded [SharedPreferences].

@ProviderFor(liveSnapshotStore)
final liveSnapshotStoreProvider = LiveSnapshotStoreProvider._();

/// Singleton [LiveSnapshotStore] backed by the pre-loaded [SharedPreferences].

final class LiveSnapshotStoreProvider
    extends
        $FunctionalProvider<
          LiveSnapshotStore,
          LiveSnapshotStore,
          LiveSnapshotStore
        >
    with $Provider<LiveSnapshotStore> {
  /// Singleton [LiveSnapshotStore] backed by the pre-loaded [SharedPreferences].
  LiveSnapshotStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveSnapshotStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveSnapshotStoreHash();

  @$internal
  @override
  $ProviderElement<LiveSnapshotStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LiveSnapshotStore create(Ref ref) {
    return liveSnapshotStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LiveSnapshotStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LiveSnapshotStore>(value),
    );
  }
}

String _$liveSnapshotStoreHash() => r'fee1cb890f7eba5d51d079ee87e4dd3f886fff74';

/// Singleton [NotificationService]. Initialised lazily; call [init] once from
/// the app bootstrap (see [main]).

@ProviderFor(notificationService)
final notificationServiceProvider = NotificationServiceProvider._();

/// Singleton [NotificationService]. Initialised lazily; call [init] once from
/// the app bootstrap (see [main]).

final class NotificationServiceProvider
    extends
        $FunctionalProvider<
          NotificationService,
          NotificationService,
          NotificationService
        >
    with $Provider<NotificationService> {
  /// Singleton [NotificationService]. Initialised lazily; call [init] once from
  /// the app bootstrap (see [main]).
  NotificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationServiceHash();

  @$internal
  @override
  $ProviderElement<NotificationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationService create(Ref ref) {
    return notificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationService>(value),
    );
  }
}

String _$notificationServiceHash() =>
    r'445de4d12e27916d07943435c5c5a66cb7fc0205';
