import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/services/notification_service.dart';
import 'notification_service_provider.dart';

part 'notification_permission_provider.g.dart';

/// Exposes the current notification permission status.
/// Refreshed on every call to [refresh] (typically on app resume).
@Riverpod(keepAlive: true)
class NotificationPermission extends _$NotificationPermission {
  @override
  Future<NotificationPermissionStatus> build() async {
    return _fetch();
  }

  Future<NotificationPermissionStatus> _fetch() async {
    try {
      final svc = ref.read(notificationServiceProvider);
      return await svc.permissionStatus();
    } catch (_) {
      return NotificationPermissionStatus.unknown;
    }
  }

  /// Re-check current permission (call on AppLifecycleState.resumed).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _fetch());
  }

  /// Ask the OS for permission. Shows the system dialog if not yet determined.
  Future<NotificationPermissionStatus> request() async {
    state = const AsyncLoading();
    try {
      final svc = ref.read(notificationServiceProvider);
      final result = await svc.requestPermission();
      state = AsyncData(result);
      return result;
    } catch (_) {
      state = const AsyncData(NotificationPermissionStatus.unknown);
      return NotificationPermissionStatus.unknown;
    }
  }

  bool get isGranted =>
      state.value == NotificationPermissionStatus.granted;
}
