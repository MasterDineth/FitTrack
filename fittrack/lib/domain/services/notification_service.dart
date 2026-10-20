import '../entities/live_workout_snapshot.dart';
import '../entities/notification_payload.dart';
import '../services/live_notification_formatter.dart';

/// Abstract notification service contract.
/// The only file allowed to import [flutter_local_notifications] is the
/// concrete implementation [LocalNotificationService] in the data layer.
abstract class NotificationService {
  /// Initialise the plugin, request runtime permissions if needed,
  /// and set up notification channels. Must be called once from [main].
  Future<void> init({
    required Future<void> Function(NotificationPayload payload) onTap,
  });

  /// Current Android / iOS permission status.
  Future<NotificationPermissionStatus> permissionStatus();

  /// Ask the OS for the POST_NOTIFICATIONS permission.
  /// Returns the new status after the request.
  Future<NotificationPermissionStatus> requestPermission();

  /// Opens the app's system notification settings page.
  Future<void> openSystemSettings();

  // ── Live workout notification ─────────────────────────────────────────────

  /// Show or update the live workout notification.
  Future<void> showLive(LiveNotificationSpec spec);

  /// Remove the live notification (id 1001).
  Future<void> clearLive();

  /// Schedule an exact alarm at [scheduledAt] to flip the live
  /// notification from rest mode back to workout mode.
  /// Pass null to cancel any pending alert.
  Future<void> scheduleRestEndAlert({
    required LiveWorkoutSnapshot snapshot,
    required LiveNotificationSpec workoutSpec,
    required DateTime scheduledAt,
  });

  /// Cancel the scheduled rest-end alert.
  Future<void> cancelRestEndAlert();

  // ── One-off / reminder notifications ─────────────────────────────────────

  /// Show an immediate one-off notification.
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required NotificationPayload payload,
    String? largeIcon,
  });

  /// Schedule a future notification.
  Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required DateTime scheduledAt,
    required NotificationPayload payload,
    bool exact = true,
  });

  /// Cancel notifications in [idRange] (inclusive start, inclusive end).
  Future<void> cancelRange(int startId, int endId);

  /// Cancel a single notification by ID.
  Future<void> cancel(int id);

  // ── Stream & Launch ────────────────────────────────────────────────────────

  /// Emits a [NotificationPayload] each time the user taps a notification
  /// while the app is in the foreground.
  Stream<NotificationPayload> get tapStream;

  /// Returns the launch payload if the app was launched by tapping a notification.
  Future<NotificationPayload?> getLaunchPayload();
}

// ── Status enum ──────────────────────────────────────────────────────────────

enum NotificationPermissionStatus { granted, denied, blocked, unknown }
