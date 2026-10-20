import 'dart:convert';

/// Versioned payload attached to every device notification tap.
/// Parsed from the notification's payload JSON string.
/// Pure Dart — no Flutter imports.
class NotificationPayload {
  static const int _currentVersion = 1;

  const NotificationPayload({
    required this.type,
    this.sessionId,
    this.scheduleId,
  });

  /// Payload schema version; increment when fields are added/removed.
  final int version = _currentVersion;

  /// Notification type string; see [NotificationPayloadType] for constants.
  final String type;

  /// Optional workout session ID for history deep-links.
  final String? sessionId;

  /// Optional schedule ID to highlight a card on the Workouts screen.
  final String? scheduleId;

  // ── Serialisation ──────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
        'v': _currentVersion,
        'type': type,
        if (sessionId != null) 'sessionId': sessionId,
        if (scheduleId != null) 'scheduleId': scheduleId,
      };

  String encode() => jsonEncode(toMap());

  /// Returns null if [raw] is null, empty, or not valid JSON.
  static NotificationPayload? tryDecode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      // Accept v:1 payloads; ignore unknown versions gracefully.
      return NotificationPayload(
        type: map['type'] as String? ?? NotificationPayloadType.unknown,
        sessionId: map['sessionId'] as String?,
        scheduleId: map['scheduleId'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Canonical type strings for [NotificationPayload.type].
abstract final class NotificationPayloadType {
  static const String liveWorkout = 'live_workout';
  static const String restOver = 'rest_over';
  static const String workoutComplete = 'workout_complete';
  static const String workoutReminder = 'workout_reminder';
  static const String hydration = 'hydration';
  static const String weeklySummary = 'weekly_summary';
  static const String pr = 'pr';
  static const String important = 'important';
  static const String unknown = 'unknown';
}
