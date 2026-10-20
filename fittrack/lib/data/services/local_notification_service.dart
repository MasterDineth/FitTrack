import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:app_settings/app_settings.dart';

import '../../domain/entities/live_workout_snapshot.dart';
import '../../domain/entities/notification_payload.dart';
import '../../domain/services/live_notification_formatter.dart';
import '../../domain/services/notification_service.dart';

// ── Notification IDs ──────────────────────────────────────────────────────────

const _kLiveWorkoutId = 1001;
const _kRestEndAlertId = 1002;

// ── Channel IDs ───────────────────────────────────────────────────────────────

const _kChannelLiveWorkout = 'live_workout';
const _kChannelRestAlerts = 'rest_alerts';
const _kChannelReminders = 'reminders';
const _kChannelHydration = 'hydration';
const _kChannelSummaries = 'summaries';
const _kChannelAchievements = 'achievements';
const _kChannelImportant = 'important';

// ── Background handler ────────────────────────────────────────────────────────

/// Top-level handler for notification action button taps that run in a
/// background isolate. See §2.5 of the spec.
@pragma('vm:entry-point')
void _onNotificationActionReceived(NotificationResponse response) {
  // Try to route the action to the main isolate via IsolateNameServer.
  final port =
      IsolateNameServer.lookupPortByName('ft_notification_actions');
  if (port != null) {
    port.send({
      'action': response.actionId ?? '',
      'payload': response.payload ?? '',
      'notificationId': response.id,
    });
    return;
  }
  // Engine gone path: load snapshot, reduce, reschedule.
  // This is handled asynchronously; we fire-and-forget to stay within the
  // plugin's background handler contract (must be synchronous or very brief).
  // Full persistence / reschedule is handled by the coordinator on next launch.
}

@pragma('vm:entry-point')
void _onNotificationReceived(NotificationResponse response) {
  // Foreground taps — forwarded to the main isolate via tapStreamController.
  _tapStreamController?.add(response);
}

// Shared controller for foreground tap events; set during init.
StreamController<NotificationResponse>? _tapStreamController;

// ── Implementation ────────────────────────────────────────────────────────────

class LocalNotificationService implements NotificationService {
  LocalNotificationService([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
        _payloadController = StreamController<NotificationPayload>.broadcast();

  final FlutterLocalNotificationsPlugin _plugin;
  final StreamController<NotificationPayload> _payloadController;
  Future<void> Function(NotificationPayload)? _onTapCallback;

  static const MethodChannel _liveChannel =
      MethodChannel('com.example.fittrack/live_notification');

  @override
  Stream<NotificationPayload> get tapStream => _payloadController.stream;

  @override
  Future<void> init({
    required Future<void> Function(NotificationPayload payload) onTap,
  }) async {
    _onTapCallback = onTap;

    _tapStreamController ??= StreamController<NotificationResponse>.broadcast();
    _tapStreamController!.stream.listen(_routeResponse);

    if (defaultTargetPlatform == TargetPlatform.android) {
      _liveChannel.setMethodCallHandler((call) async {
        if (call.method == 'onAction') {
          final action = call.arguments?['action'] as String?;
          if (action != null) {
            final port =
                IsolateNameServer.lookupPortByName('ft_notification_actions');
            if (port != null) {
              port.send({'action': action});
            }
          }
        } else if (call.method == 'onNavigate') {
          final route = call.arguments?['route'] as String?;
          if (route != null) {
            final scheduleId = route.startsWith('/workouts/active/')
                ? route.substring('/workouts/active/'.length)
                : null;
            final payload = NotificationPayload(
              type: NotificationPayloadType.liveWorkout,
              scheduleId: scheduleId,
            );
            _payloadController.add(payload);
            _onTapCallback?.call(payload);
          }
        }
      });
    }

    const androidInit = AndroidInitializationSettings('@drawable/ic_stat_fittrack');
    const initSettings = InitializationSettings(android: androidInit);

    try {
      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationReceived,
        onDidReceiveBackgroundNotificationResponse: _onNotificationActionReceived,
      );

      await _createChannels();
    } catch (_) {}
  }

  void _routeResponse(NotificationResponse response) {
    final payload = NotificationPayload.tryDecode(response.payload);
    if (payload != null) {
      _payloadController.add(payload);
      _onTapCallback?.call(payload);
    }
  }

  Future<void> _createChannels() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
      _kChannelLiveWorkout,
      'Live Workout',
      description: 'Ongoing workout progress and live timer',
      importance: Importance.defaultImportance,
      playSound: false,
      enableVibration: false,
      enableLights: false,
    ));

    await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
      _kChannelRestAlerts,
      'Rest Timer Alerts',
      description: 'Alerts when rest period ends',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    ));

    await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
      _kChannelReminders,
      'Workout Reminders',
      description: 'Scheduled workout reminders',
      importance: Importance.defaultImportance,
      playSound: true,
    ));

    await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
      _kChannelHydration,
      'Hydration',
      description: 'Water intake reminders',
      importance: Importance.defaultImportance,
      playSound: false,
      enableVibration: false,
    ));

    await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
      _kChannelSummaries,
      'Workout Summaries',
      description: 'Post-workout and weekly recap notifications',
      importance: Importance.defaultImportance,
      playSound: true,
    ));

    await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
      _kChannelAchievements,
      'Achievements',
      description: 'Personal records and streaks',
      importance: Importance.defaultImportance,
      playSound: true,
    ));

    await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
      _kChannelImportant,
      'Important Alerts',
      description: 'Critical app alerts (cannot be disabled)',
      importance: Importance.high,
      playSound: true,
    ));
  }

  // ── Permission ────────────────────────────────────────────────────────────

  @override
  Future<NotificationPermissionStatus> permissionStatus() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return NotificationPermissionStatus.unknown;

    final granted = await androidPlugin.areNotificationsEnabled();
    if (granted == null) return NotificationPermissionStatus.unknown;
    return granted
        ? NotificationPermissionStatus.granted
        : NotificationPermissionStatus.denied;
  }

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return NotificationPermissionStatus.unknown;

    final granted = await androidPlugin.requestNotificationsPermission();
    if (granted == null) return NotificationPermissionStatus.unknown;
    return granted
        ? NotificationPermissionStatus.granted
        : NotificationPermissionStatus.denied;
  }

  @override
  Future<void> openSystemSettings() async {
    await AppSettings.openAppSettings(type: AppSettingsType.notification);
  }

  // ── Live notification ─────────────────────────────────────────────────────

  @override
  Future<void> showLive(LiveNotificationSpec spec) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        final isRest = spec.mode == LiveNotificationMode.rest;
        final isPaused = spec.chronometer == null && !isRest;

        final data = <String, dynamic>{
          'scheduleName': spec.scheduleName ?? 'Workout',
          'scheduleId': spec.scheduleId ?? '',
          'mode': isRest ? 'rest' : 'workout',
          'title': spec.title,
          'subtitle': spec.body,
          'workoutProgress': (spec.progressFraction * 100).round(),
          'restRemainingSeconds': spec.restRemainingSeconds ?? 0,
          'restTotalSeconds': spec.restTotalSeconds ?? 45,
          'chronometerBase': isRest
              ? (spec.countdownEndsAt?.millisecondsSinceEpoch ?? 0)
              : (spec.chronometer?.millisecondsSinceEpoch ?? 0),
          'isCountDown': isRest,
          'isPaused': isPaused,
        };

        await _liveChannel.invokeMethod('startLive', data);
        return;
      } catch (_) {
        // Fallback to standard local notifications if native service fails
      }
    }

    try {
      final details = _buildLiveDetails(spec);
      await _plugin.show(
        _kLiveWorkoutId,
        spec.title,
        spec.body,
        details,
        payload: NotificationPayload(
          type: spec.mode == LiveNotificationMode.rest
              ? NotificationPayloadType.restOver
              : NotificationPayloadType.liveWorkout,
          scheduleId: spec.scheduleId,
          sessionId: spec.sessionId,
        ).encode(),
      );
    } catch (_) {}
  }

  NotificationDetails _buildLiveDetails(LiveNotificationSpec spec) {
    final isRest = spec.mode == LiveNotificationMode.rest;
    final isPaused = spec.chronometer == null && !isRest;
    final subText = isRest
        ? 'Rest Timer'
        : (isPaused ? 'Paused' : 'Live Workout');

    final androidActions = spec.actions
        .map((a) => AndroidNotificationAction(
              a.id,
              a.label,
              showsUserInterface: a.id == LiveNotificationActionId.open,
            ))
        .toList();

    AndroidNotificationDetails androidDetails;

    if (isRest && spec.countdownEndsAt != null) {
      // Countdown chronometer
      androidDetails = AndroidNotificationDetails(
        _kChannelLiveWorkout,
        'Live Workout',
        channelDescription: 'Ongoing workout progress notification',
        icon: 'ic_stat_fittrack',
        color: const Color(0xFF5F3BDC),
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        onlyAlertOnce: true,
        showWhen: true,
        usesChronometer: true,
        chronometerCountDown: true,
        when: spec.countdownEndsAt!.millisecondsSinceEpoch,
        actions: androidActions,
        showProgress: spec.showProgressBar,
        maxProgress: 100,
        progress: (spec.progressFraction * 100).round(),
        indeterminate: false,
        subText: subText,
        category: AndroidNotificationCategory.workout,
        visibility: NotificationVisibility.public,
        styleInformation: BigTextStyleInformation(
          spec.body,
          contentTitle: spec.title,
          summaryText: subText,
        ),
      );
    } else {
      // Count-up chronometer for workout mode
      final hasChronometer = spec.chronometer != null;
      final chronometerBase = spec.chronometer?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch;
      androidDetails = AndroidNotificationDetails(
        _kChannelLiveWorkout,
        'Live Workout',
        channelDescription: 'Ongoing workout progress notification',
        icon: 'ic_stat_fittrack',
        color: const Color(0xFF5F3BDC),
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        onlyAlertOnce: true,
        showWhen: hasChronometer,
        usesChronometer: hasChronometer,
        chronometerCountDown: false,
        when: hasChronometer ? chronometerBase : null,
        actions: androidActions,
        showProgress: spec.showProgressBar,
        maxProgress: 100,
        progress: (spec.progressFraction * 100).round(),
        indeterminate: false,
        subText: subText,
        category: AndroidNotificationCategory.workout,
        visibility: NotificationVisibility.public,
        styleInformation: BigTextStyleInformation(
          spec.body,
          contentTitle: spec.title,
          summaryText: subText,
        ),
      );
    }

    return NotificationDetails(android: androidDetails);
  }

  @override
  Future<void> clearLive() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        await _liveChannel.invokeMethod('stopLive');
      } catch (_) {}
    }
    try {
      await _plugin.cancel(_kLiveWorkoutId);
      await cancelRestEndAlert();
    } catch (_) {}
  }

  @override
  Future<void> scheduleRestEndAlert({
    required LiveWorkoutSnapshot snapshot,
    required LiveNotificationSpec workoutSpec,
    required DateTime scheduledAt,
  }) async {
    try {
      final tzScheduledAt =
          tz.TZDateTime.from(scheduledAt, tz.local);

      // The rest-end alert replaces the live notification at the scheduled time.
      final androidDetails = AndroidNotificationDetails(
        _kChannelRestAlerts,
        'Rest Timer Alerts',
        channelDescription: 'Alerts when rest period ends',
        icon: 'ic_stat_fittrack',
        color: const Color(0xFF5F3BDC),
        importance: Importance.high,
        priority: Priority.high,
        ongoing: false,
        onlyAlertOnce: false,
        playSound: true,
        enableVibration: true,
        subText: 'Rest Timer',
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        styleInformation: BigTextStyleInformation(
          workoutSpec.body,
          contentTitle: workoutSpec.title,
          summaryText: 'Rest Timer',
        ),
      );

      await _plugin.zonedSchedule(
        _kRestEndAlertId,
        workoutSpec.title,
        workoutSpec.body,
        tzScheduledAt,
        NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: NotificationPayload(
          type: NotificationPayloadType.restOver,
          scheduleId: snapshot.scheduleId,
          sessionId: snapshot.sessionId,
        ).encode(),
      );
    } catch (_) {}
  }

  @override
  Future<void> cancelRestEndAlert() async {
    try {
      await _plugin.cancel(_kRestEndAlertId);
    } catch (_) {}
  }

  // ── One-off / reminders ───────────────────────────────────────────────────

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required NotificationPayload payload,
    String? largeIcon,
  }) async {
    try {
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId,
          icon: 'ic_stat_fittrack',
          color: const Color(0xFF5F3BDC),
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          playSound: true,
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
          ),
        ),
      );
      await _plugin.show(id, title, body, details, payload: payload.encode());
    } catch (_) {}
  }

  @override
  Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required DateTime scheduledAt,
    required NotificationPayload payload,
    bool exact = true,
  }) async {
    try {
      final tzScheduledAt = tz.TZDateTime.from(scheduledAt, tz.local);
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId,
          icon: 'ic_stat_fittrack',
          color: const Color(0xFF5F3BDC),
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          playSound: true,
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
          ),
        ),
      );
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledAt,
        details,
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload.encode(),
      );
    } catch (_) {}
  }

  @override
  Future<void> cancelRange(int startId, int endId) async {
    try {
      for (int id = startId; id <= endId; id++) {
        await _plugin.cancel(id);
      }
    } catch (_) {}
  }

  @override
  Future<void> cancel(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (_) {}
  }

  // ── Cold-start details ────────────────────────────────────────────────────

  /// Returns the payload from the notification that launched the app (if any).
  @override
  Future<NotificationPayload?> getLaunchPayload() async {
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details == null || !details.didNotificationLaunchApp) return null;
      return NotificationPayload.tryDecode(details.notificationResponse?.payload);
    } catch (_) {
      return null;
    }
  }
}
