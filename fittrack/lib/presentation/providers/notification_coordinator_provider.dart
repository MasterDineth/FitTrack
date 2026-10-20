import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/live_workout_snapshot.dart';
import '../../domain/entities/notification_payload.dart';
import '../../domain/services/live_notification_formatter.dart';
import '../../domain/services/notification_service.dart';
import '../../domain/services/reminder_planner.dart';
import '../router/app_router.dart';
import 'active_workout_provider.dart';
import 'auth_provider.dart';
import 'notification_permission_provider.dart';
import 'notification_service_provider.dart';
import 'notification_settings_provider.dart';
import 'notifications_provider.dart';
import 'repository_providers.dart';
import 'splash_provider.dart';
import 'user_profile_provider.dart';

part 'notification_coordinator_provider.g.dart';

/// Orchestrates all device notifications.
///
/// - Listens to [activeWorkoutProvider] to emit live notifications.
/// - Listens to [notificationSettingsProvider] to replan reminders.
/// - Registers the [ReceivePort] that routes background action buttons to the
///   real notifier methods (§2.5 of the spec).
/// - Handles deep-link navigation from the notification tap stream.
@Riverpod(keepAlive: true)
class NotificationCoordinator extends _$NotificationCoordinator {
  // Port name referenced by the background handler.
  static const _portName = 'ft_notification_actions';

  late final NotificationService _svc;
  final LiveNotificationFormatter _formatter = const LiveNotificationFormatter();
  final ReminderPlanner _planner = const ReminderPlanner();

  ReceivePort? _port;
  Timer? _snapshotDebounce;

  @override
  void build() {
    _svc = ref.read(notificationServiceProvider);

    // Register the IsolateNameServer port for background action forwarding.
    _registerActionsPort();

    // Watch active workout state changes.
    ref.listen(activeWorkoutProvider, (prev, next) {
      _onWorkoutStateChange(prev, next);
    });

    // Watch notification settings to replan reminders.
    ref.listen(notificationSettingsNotifierProvider, (prev, next) {
      _replannRemindersIfNeeded(prev, next);
    });

    // Listen to pending route changes for deep-link navigation (§2.6).
    ref.listen(pendingNotificationRouteProvider, (prev, nextPayload) {
      if (nextPayload != null) {
        _checkAndExecutePendingRoute(nextPayload);
      }
    });

    // When gating dependencies resolve, execute any pending navigation.
    void onGatingStateChange() {
      final pending = ref.read(pendingNotificationRouteProvider);
      if (pending != null) {
        _checkAndExecutePendingRoute(pending);
      }
    }

    ref.listen(splashDoneProvider, (_, _) => onGatingStateChange());
    ref.listen(authProvider, (_, _) => onGatingStateChange());
    ref.listen(userProfileProvider, (_, _) => onGatingStateChange());

    // Listen to the tap stream for deep-links.
    _svc.tapStream.listen(_handleTap);

    ref.onDispose(() {
      _port?.close();
      IsolateNameServer.removePortNameMapping(_portName);
      _snapshotDebounce?.cancel();
    });
  }

  // ── IsolateNameServer port ────────────────────────────────────────────────

  void _registerActionsPort() {
    _port?.close();
    IsolateNameServer.removePortNameMapping(_portName);
    _port = ReceivePort();
    IsolateNameServer.registerPortWithName(_port!.sendPort, _portName);
    _port!.listen(_handleBackgroundAction);
  }

  void _handleBackgroundAction(dynamic message) {
    if (message is! Map) return;
    final action = message['action'] as String? ?? '';
    final notifier = ref.read(activeWorkoutProvider.notifier);
    switch (action) {
      case LiveNotificationActionId.pause:
        notifier.pauseSession();
      case LiveNotificationActionId.resume:
        notifier.resumeSession();
      case LiveNotificationActionId.skipRest:
        notifier.skipRest();
      case LiveNotificationActionId.adjustRestMinus15:
        notifier.adjustRestTime(-15);
      case LiveNotificationActionId.adjustRestPlus15:
        notifier.adjustRestTime(15);
      case LiveNotificationActionId.completeSet:
        notifier.completeSet();
      case LiveNotificationActionId.open:
        final activeState = ref.read(activeWorkoutProvider);
        final scheduleId = activeState.schedule.id;
        if (scheduleId.isNotEmpty) {
          final router = ref.read(routerProvider);
          final currentLoc =
              router.routerDelegate.currentConfiguration.uri.toString();
          if (!currentLoc.contains('/workouts/active/$scheduleId')) {
            router.push('/workouts/active/$scheduleId');
          }
        }
      default:
        // Unknown action; ignore.
        break;
    }
  }

  // ── Workout state change ──────────────────────────────────────────────────

  void _onWorkoutStateChange(
      ActiveWorkoutState? prev, ActiveWorkoutState next) {
    final settings = ref.read(notificationSettingsNotifierProvider);

    // Master switch check.
    if (!settings.systemNotifications || !settings.liveWorkoutStatus) {
      _svc.clearLive();
      return;
    }

    // Handle session completion:
    if (next.phase == WorkoutPhase.finished) {
      _snapshotDebounce?.cancel();
      ref.read(liveSnapshotStoreProvider).clear();
      _svc.clearLive();
      if (next.lastSavedSessionId != null &&
          (prev?.lastSavedSessionId != next.lastSavedSessionId ||
              prev?.phase != WorkoutPhase.finished)) {
        _showCompletionNotification(next);
      }
      return;
    }

    if (next.phase == WorkoutPhase.discarded ||
        next.phase == WorkoutPhase.error) {
      _snapshotDebounce?.cancel();
      ref.read(liveSnapshotStoreProvider).clear();
      _svc.clearLive();
      return;
    }

    // Build snapshot from state.
    final snapshot = _snapshotFrom(next);
    if (snapshot == null) {
      _snapshotDebounce?.cancel();
      ref.read(liveSnapshotStoreProvider).clear();
      if (prev != null &&
          (prev.phase == WorkoutPhase.active ||
              prev.phase == WorkoutPhase.resting ||
              prev.phase == WorkoutPhase.paused)) {
        // Session ended — clear live notification.
        _svc.clearLive();
      }
      return;
    }

    // Debounce snapshot persistence.
    _snapshotDebounce?.cancel();
    _snapshotDebounce = Timer(const Duration(milliseconds: 250), () {
      ref.read(liveSnapshotStoreProvider).save(snapshot);
    });

    final spec = _formatter.build(
      snapshot: snapshot,
      showScheduleProgress: settings.showScheduleProgress,
      showSetProgress: settings.showSetProgress,
      showRestTimerControls: settings.showRestTimerControls,
      allowCompleteSetFromNotification: settings.allowCompleteSetFromNotification,
    );

    switch (spec.mode) {
      case LiveNotificationMode.workout:
        _svc.cancelRestEndAlert();
        _svc.showLive(spec);
      case LiveNotificationMode.rest:
        _svc.showLive(spec);
        if (snapshot.restEndsAt != null) {
          final workoutSpec = _formatter.build(
            snapshot: snapshot.copyWith(phase: 'active'),
            showScheduleProgress: settings.showScheduleProgress,
            showSetProgress: settings.showSetProgress,
            showRestTimerControls: settings.showRestTimerControls,
            allowCompleteSetFromNotification: settings.allowCompleteSetFromNotification,
          );
          _svc.scheduleRestEndAlert(
            snapshot: snapshot,
            workoutSpec: workoutSpec,
            scheduledAt: snapshot.restEndsAt!,
          );
        }
      case LiveNotificationMode.complete:
        _svc.clearLive();
        _showCompletionNotification(next);
    }
  }

  void _showCompletionNotification(ActiveWorkoutState state) {
    if (!ref.read(notificationSettingsNotifierProvider).workoutScheduleCompletion) return;
    final duration = state.elapsedSeconds ~/ 60;
    final sets = state.completedSetCount;
    final exercises = state.entries.length;
    final workoutName =
        state.schedule.name.isNotEmpty ? state.schedule.name : 'Workout';
    _svc.show(
      id: 1003,
      title: 'Workout complete · $workoutName',
      body: '$duration min · $sets sets · $exercises exercises',
      channelId: 'summaries',
      payload: NotificationPayload(
        type: NotificationPayloadType.workoutComplete,
        sessionId: state.lastSavedSessionId,
        scheduleId: state.schedule.id,
      ),
    );

    // Also push to in-app feed.
    ref.read(notificationFeedProvider.notifier).pushNotification(
          type: FtNotificationType.workoutComplete,
          title: 'Workout complete',
          body:
              '$workoutName · $duration min · $sets sets',
        );

    // Clear snapshot now that the session is finished.
    ref.read(liveSnapshotStoreProvider).clear();
  }

  // ── Snapshot builder ──────────────────────────────────────────────────────

  LiveWorkoutSnapshot? _snapshotFrom(ActiveWorkoutState state) {
    switch (state.phase) {
      case WorkoutPhase.loading:
      case WorkoutPhase.discarded:
      case WorkoutPhase.error:
        return null;
      case WorkoutPhase.finished:
        return null; // handled in _showCompletionNotification
      case WorkoutPhase.active:
      case WorkoutPhase.resting:
      case WorkoutPhase.paused:
        break;
    }

    final entry = state.currentEntry;
    final now = DateTime.now();

    // Compute finished exercises using domain helper.
    final completedByExercise = <String, int>{};
    final totalByExercise = <String, int>{};
    for (final e in state.entries) {
      totalByExercise[e.exerciseId] = e.totalSets;
    }
    for (final s in state.completedSets) {
      completedByExercise[s.exerciseId] =
          (completedByExercise[s.exerciseId] ?? 0) + 1;
    }
    final finished = computeFinishedExercises(
      totalExercises: state.entries.length,
      completedSetsByExercise: completedByExercise,
      totalSetsByExercise: totalByExercise,
      skippedExerciseIds: state.skippedExerciseIds,
    );

    return LiveWorkoutSnapshot(
      sessionId: state.lastSavedSessionId ?? '',
      scheduleId: state.schedule.id,
      scheduleName: state.schedule.name,
      totalExercises: state.entries.length,
      finishedExercises: finished,
      exerciseName: entry?.name ?? '',
      setNumber: state.currentSetIndex + 1,
      totalSets: entry?.totalSets ?? 1,
      phase: _phaseString(state.phase),
      sessionStartedAt: state.sessionStartedAt ?? now,
      pausedAccumulatedSeconds: state.pausedAccumulatedSeconds,
      pausedAt: state.phase == WorkoutPhase.paused ? now : null,
      restEndsAt: state.restEndsAt,
      restDurationSeconds: entry?.restDurationSeconds ?? 0,
      updatedAt: now,
    );
  }

  String _phaseString(WorkoutPhase phase) {
    switch (phase) {
      case WorkoutPhase.active:
        return 'active';
      case WorkoutPhase.resting:
        return 'resting';
      case WorkoutPhase.paused:
        return 'paused';
      case WorkoutPhase.finished:
        return 'finished';
      default:
        return 'active';
    }
  }

  // ── Reminder replanning ───────────────────────────────────────────────────

  void _replannRemindersIfNeeded(
    NotificationSettingsState? prev,
    NotificationSettingsState next,
  ) {
    if (prev == null) return;
    // Only replan if relevant fields changed.
    final changed = prev.routineWorkoutReminders != next.routineWorkoutReminders ||
        prev.reminderDays != next.reminderDays ||
        prev.reminderTime != next.reminderTime ||
        prev.skipIfTrainedToday != next.skipIfTrainedToday ||
        prev.hydrationReminders != next.hydrationReminders ||
        prev.hydrationInterval != next.hydrationInterval ||
        prev.weeklyRecap != next.weeklyRecap ||
        prev.quietHoursEnabled != next.quietHoursEnabled ||
        prev.quietHoursFrom != next.quietHoursFrom ||
        prev.quietHoursTo != next.quietHoursTo;

    if (changed) {
      planAndScheduleReminders(settings: next);
    }
  }

  /// Public: call on app start, resume, boot, timezone change, workout finish.
  void planAndScheduleReminders({NotificationSettingsState? settings}) {
    final NotificationSettingsState s =
        settings ?? ref.read(notificationSettingsNotifierProvider);
    final permission = ref.read(notificationPermissionProvider);
    if (permission.value != NotificationPermissionStatus.granted) return;

    // Cancel all existing reminder ranges before replanning.
    _svc.cancelRange(2000, 2099); // workout
    _svc.cancelRange(3000, 3199); // hydration
    _svc.cancel(4000); // weekly recap

    final reminderWeekdays = _parseReminderDays(s.reminderDays);
    final reminderMinutes = _parseTimeString(s.reminderTime);
    final hydrationHours = _parseHydrationInterval(s.hydrationInterval);

    // Quiet hours
    final quietStart = _parseTimeString(s.quietHoursFrom);
    final quietEnd = _parseTimeString(s.quietHoursTo);

    final reminders = _planner.plan(
      workoutRemindersEnabled: s.routineWorkoutReminders,
      reminderWeekdays: reminderWeekdays,
      reminderMinutesAfterMidnight: reminderMinutes,
      skipIfTrainedToday: s.skipIfTrainedToday,
      completedTodayScheduleId: null, // TODO: wire real value
      hydrationEnabled: s.hydrationReminders,
      hydrationIntervalHours: hydrationHours,
      hydrationStartHour: 8,
      hydrationEndHour: 20,
      weeklyRecapEnabled: s.weeklyRecap,
      weeklyRecapWeekday: 7, // Sunday by default
      weeklyRecapMinutes: 18 * 60, // 18:00
      quietHoursEnabled: s.quietHoursEnabled,
      quietStartMinutes: quietStart,
      quietEndMinutes: quietEnd,
      scheduleName: 'Your workout',
    );

    for (final reminder in reminders) {
      _svc.scheduleAt(
        id: reminder.id,
        title: reminder.title,
        body: reminder.body,
        channelId: _channelForType(reminder.type),
        scheduledAt: reminder.scheduledAt,
        payload: NotificationPayload(
          type: reminder.payloadType,
          scheduleId: reminder.scheduleId,
        ),
      );
    }
  }

  // ── Deep-link tap handling ────────────────────────────────────────────────

  void _handleTap(NotificationPayload payload) {
    ref.read(pendingNotificationRouteProvider.notifier).set(payload);
  }

  void _checkAndExecutePendingRoute(NotificationPayload payload) {
    final splashDone = ref.read(splashDoneProvider);
    final authState = ref.read(authProvider);
    final profile = ref.read(userProfileProvider);

    final isGated = !splashDone ||
        authState.isLoading ||
        authState.value == null ||
        !(profile.value?.isComplete ?? false);

    if (!isGated) {
      ref.read(pendingNotificationRouteProvider.notifier).clear();
      executeNavigation(payload);
    }
  }

  Future<void> executeNavigation(NotificationPayload payload) async {
    final router = ref.read(routerProvider);
    final context = rootNavigatorKey.currentContext;

    switch (payload.type) {
      case NotificationPayloadType.workoutComplete:
      case NotificationPayloadType.pr:
        final sessionId = payload.sessionId;
        router.go('/history');
        if (sessionId != null && sessionId.isNotEmpty) {
          final repo = ref.read(workoutSessionRepositoryProvider);
          final session = await repo.getSessionById(sessionId);
          if (session != null) {
            router.push('/history/detail/$sessionId');
          } else {
            if (context != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('That workout is no longer available'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        }
      case NotificationPayloadType.liveWorkout:
      case NotificationPayloadType.restOver:
        final activeState = ref.read(activeWorkoutProvider);
        final isActive = activeState.phase == WorkoutPhase.active ||
            activeState.phase == WorkoutPhase.resting ||
            activeState.phase == WorkoutPhase.paused;
        final scheduleId = (payload.scheduleId != null &&
                payload.scheduleId!.isNotEmpty)
            ? payload.scheduleId!
            : activeState.schedule.id;
        if (isActive && scheduleId.isNotEmpty) {
          final currentLoc =
              router.routerDelegate.currentConfiguration.uri.toString();
          if (!currentLoc.contains('/workouts/active/$scheduleId')) {
            router.push('/workouts/active/$scheduleId');
          }
        } else {
          router.go('/dashboard');
        }
      case NotificationPayloadType.workoutReminder:
        router.go('/workouts');
      case NotificationPayloadType.hydration:
        router.go('/dashboard');
      case NotificationPayloadType.weeklySummary:
        router.go('/history');
      case NotificationPayloadType.important:
        router.go('/settings/notifications');
      default:
        router.go('/dashboard');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Set<int> _parseReminderDays(List<String> days) {
    const map = {
      'Mon': 1,
      'Tue': 2,
      'Wed': 3,
      'Thu': 4,
      'Fri': 5,
      'Sat': 6,
      'Sun': 7,
    };
    return days.map((d) => map[d] ?? 0).where((d) => d > 0).toSet();
  }

  int _parseTimeString(String time) {
    // Parses "HH:MM" → minutes after midnight.
    final parts = time.split(':');
    if (parts.length != 2) return 0;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return h * 60 + m;
  }

  int _parseHydrationInterval(String interval) {
    // e.g. "2 hrs" → 2, "Every 2 hrs" → 2
    final cleaned = interval.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 2;
  }

  String _channelForType(String type) {
    switch (type) {
      case 'hydration':
        return 'hydration';
      case 'weekly_recap':
        return 'summaries';
      default:
        return 'reminders';
    }
  }
}

// ── Pending route provider ────────────────────────────────────────────────────

/// Holds the last notification payload that needs navigation.
/// The router / app shell reads this to navigate after gating resolves.
@Riverpod(keepAlive: true)
class PendingNotificationRoute
    extends _$PendingNotificationRoute {
  @override
  NotificationPayload? build() => null;

  void set(NotificationPayload? payload) => state = payload;
  void clear() => state = null;
}

/// Convenience alias so other files can import [pendingNotificationRouteProvider]
/// which is generated by build_runner from [PendingNotificationRoute].
// (No extra alias needed — build_runner generates `pendingNotificationRouteProvider`.)
