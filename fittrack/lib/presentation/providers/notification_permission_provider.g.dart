// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_permission_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Exposes the current notification permission status.
/// Refreshed on every call to [refresh] (typically on app resume).

@ProviderFor(NotificationPermission)
final notificationPermissionProvider = NotificationPermissionProvider._();

/// Exposes the current notification permission status.
/// Refreshed on every call to [refresh] (typically on app resume).
final class NotificationPermissionProvider
    extends
        $AsyncNotifierProvider<
          NotificationPermission,
          NotificationPermissionStatus
        > {
  /// Exposes the current notification permission status.
  /// Refreshed on every call to [refresh] (typically on app resume).
  NotificationPermissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPermissionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPermissionHash();

  @$internal
  @override
  NotificationPermission create() => NotificationPermission();
}

String _$notificationPermissionHash() =>
    r'808587eae088994fce76af96ed47d516e1c66f7a';

/// Exposes the current notification permission status.
/// Refreshed on every call to [refresh] (typically on app resume).

abstract class _$NotificationPermission
    extends $AsyncNotifier<NotificationPermissionStatus> {
  FutureOr<NotificationPermissionStatus> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<NotificationPermissionStatus>,
              NotificationPermissionStatus
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<NotificationPermissionStatus>,
                NotificationPermissionStatus
              >,
              AsyncValue<NotificationPermissionStatus>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
