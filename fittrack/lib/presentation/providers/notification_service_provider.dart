import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'shared_preferences_provider.dart';
import '../../data/datasources/live_snapshot_store.dart';
import '../../data/services/local_notification_service.dart';
import '../../domain/services/notification_service.dart';

part 'notification_service_provider.g.dart';

/// Singleton [LiveSnapshotStore] backed by the pre-loaded [SharedPreferences].
@Riverpod(keepAlive: true)
LiveSnapshotStore liveSnapshotStore(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LiveSnapshotStore(prefs);
}

/// Singleton [NotificationService]. Initialised lazily; call [init] once from
/// the app bootstrap (see [main]).
@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  return LocalNotificationService();
}
