import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fittrack/data/datasources/live_snapshot_store.dart';
import 'package:fittrack/domain/entities/live_workout_snapshot.dart';
import 'package:fittrack/domain/entities/notification_payload.dart';
import 'package:fittrack/domain/services/live_notification_formatter.dart';
import 'package:fittrack/domain/services/live_workout_reducer.dart';
import 'package:fittrack/domain/services/notification_service.dart';
import 'package:fittrack/domain/services/reminder_planner.dart';
import 'package:fittrack/presentation/widgets/modals/resume_workout_recovery_modal.dart';

void main() {
  group('LiveWorkoutSnapshot', () {
    test('progressFraction: 2 of 10 → 0.20', () {
      final snapshot = _makeSnapshot(finished: 2, total: 10);
      expect(snapshot.progressFraction, closeTo(0.20, 0.001));
    });

    test('progressPercent: 2 of 10 → "20%"', () {
      final snapshot = _makeSnapshot(finished: 2, total: 10);
      expect(snapshot.progressPercent, '20%');
    });

    test('progressFraction: skipped counts as finished', () {
      // 3 finished (including 1 skipped), 10 total.
      final snapshot = _makeSnapshot(finished: 3, total: 10);
      expect(snapshot.progressFraction, closeTo(0.30, 0.001));
    });

    test('JSON round-trip', () {
      final now = DateTime(2024, 6, 15, 10, 0);
      final original = LiveWorkoutSnapshot(
        sessionId: 'sess-123',
        scheduleId: 'sched-1',
        scheduleName: 'Push Day',
        totalExercises: 10,
        finishedExercises: 2,
        exerciseName: 'Bench Press',
        setNumber: 3,
        totalSets: 4,
        phase: 'active',
        sessionStartedAt: now,
        pausedAccumulatedSeconds: 60,
        restDurationSeconds: 90,
        updatedAt: now,
      );
      final json = original.toJson();
      final restored = LiveWorkoutSnapshot.fromJson(json);

      expect(restored.sessionId, original.sessionId);
      expect(restored.scheduleId, original.scheduleId);
      expect(restored.scheduleName, original.scheduleName);
      expect(restored.finishedExercises, original.finishedExercises);
      expect(restored.totalExercises, original.totalExercises);
      expect(restored.phase, original.phase);
      expect(restored.pausedAccumulatedSeconds, 60);
    });

    test('elapsedSecondsAt accounts for paused time', () {
      final startedAt = DateTime(2024, 6, 15, 10, 0);
      final now = DateTime(2024, 6, 15, 10, 5); // 5 min later
      final snapshot = _makeSnapshot(finished: 0, total: 5).copyWith(
        sessionStartedAt: startedAt,
        pausedAccumulatedSeconds: 60, // 1 min paused
      );
      // Should be 5*60 - 60 = 240 s
      expect(snapshot.elapsedSecondsAt(now), 240);
    });
  });

  group('NotificationPayload', () {
    test('encode/decode round-trip', () {
      final payload = NotificationPayload(
        type: NotificationPayloadType.workoutComplete,
        sessionId: 'sess-abc',
        scheduleId: 'sched-xyz',
      );
      final encoded = payload.encode();
      final decoded = NotificationPayload.tryDecode(encoded);

      expect(decoded, isNotNull);
      expect(decoded!.type, NotificationPayloadType.workoutComplete);
      expect(decoded.sessionId, 'sess-abc');
      expect(decoded.scheduleId, 'sched-xyz');
    });

    test('tryDecode returns null for null input', () {
      expect(NotificationPayload.tryDecode(null), isNull);
    });

    test('tryDecode returns null for invalid JSON', () {
      expect(NotificationPayload.tryDecode('{not valid json'), isNull);
    });

    test('tryDecode handles missing optional fields', () {
      final encoded = '{"v":1,"type":"hydration"}';
      final decoded = NotificationPayload.tryDecode(encoded);
      expect(decoded, isNotNull);
      expect(decoded!.sessionId, isNull);
      expect(decoded.scheduleId, isNull);
    });
  });

  group('LiveWorkoutReducer', () {
    final now = DateTime(2024, 6, 15, 10, 0);

    test('AdjustRest +15 clamps to max 600 s', () {
      final snapshot = _makeRestingSnapshot(
        restEndsAt: now.add(const Duration(seconds: 590)),
        now: now,
      );
      final result = LiveWorkoutReducer.apply(
        snapshot,
        const AdjustRestAction(15),
        now: now,
      );
      // 590 + 15 = 605 → clamped to 600 from now
      final remaining = result.restEndsAt!.difference(now).inSeconds;
      expect(remaining, 600);
    });

    test('AdjustRest -15 clamps to min 0 s', () {
      final snapshot = _makeRestingSnapshot(
        restEndsAt: now.add(const Duration(seconds: 10)),
        now: now,
      );
      final result = LiveWorkoutReducer.apply(
        snapshot,
        const AdjustRestAction(-15),
        now: now,
      );
      // 10 - 15 = -5 → clamped to 0 (now)
      final remaining = result.restEndsAt!.difference(now).inSeconds;
      expect(remaining, 0);
    });

    test('SkipRest transitions to active and clears restEndsAt', () {
      final snapshot = _makeRestingSnapshot(
        restEndsAt: now.add(const Duration(seconds: 60)),
        now: now,
      );
      final result = LiveWorkoutReducer.apply(
        snapshot,
        const SkipRestAction(),
        now: now,
      );
      expect(result.phase, 'active');
      expect(result.restEndsAt, isNull);
    });

    test('Pause records pausedAt', () {
      final snapshot = _makeSnapshot(finished: 1, total: 5);
      final result = LiveWorkoutReducer.apply(
        snapshot,
        const PauseAction(),
        now: now,
      );
      expect(result.phase, 'paused');
      expect(result.pausedAt, now);
    });

    test('Resume accumulates paused seconds and restores rest state', () {
      final pausedAt = now.subtract(const Duration(seconds: 30));
      final restEndsAt = now.add(const Duration(seconds: 60));
      final snapshot = LiveWorkoutSnapshot(
        sessionId: '',
        scheduleId: '',
        scheduleName: '',
        totalExercises: 5,
        finishedExercises: 1,
        exerciseName: '',
        setNumber: 1,
        totalSets: 3,
        phase: 'paused',
        sessionStartedAt: now.subtract(const Duration(minutes: 5)),
        pausedAccumulatedSeconds: 0,
        pausedAt: pausedAt,
        restEndsAt: restEndsAt,
        restDurationSeconds: 90,
        updatedAt: now,
      );
      final result = LiveWorkoutReducer.apply(
        snapshot,
        const ResumeAction(),
        now: now,
      );
      expect(result.phase, 'resting');
      expect(result.pausedAccumulatedSeconds, 30);
      expect(result.pausedAt, isNull);
      // restEndsAt should have been shifted forward by 30 s
      expect(result.restEndsAt!.difference(restEndsAt).inSeconds, 30);
    });
  });

  group('LiveNotificationFormatter', () {
    const formatter = LiveNotificationFormatter();
    final now = DateTime(2024, 6, 15, 10, 0);

    test('workout mode: title shows correct counts', () {
      final snapshot = _makeSnapshot(finished: 2, total: 10)
          .copyWith(exerciseName: 'Bench Press', setNumber: 3, totalSets: 4);
      final spec = formatter.build(
        snapshot: snapshot,
        showScheduleProgress: true,
        showSetProgress: true,
        showRestTimerControls: true,
        allowCompleteSetFromNotification: false,
        now: now,
      );
      expect(spec.mode, LiveNotificationMode.workout);
      expect(spec.title, contains('2 of 10'));
      expect(spec.title, contains('20%'));
      expect(spec.body, contains('Bench Press'));
      expect(spec.body, contains('Set 3 of 4'));
    });

    test('workout mode: showSetProgress false hides set info', () {
      final snapshot = _makeSnapshot(finished: 2, total: 10)
          .copyWith(exerciseName: 'Squat', setNumber: 2, totalSets: 3);
      final spec = formatter.build(
        snapshot: snapshot,
        showScheduleProgress: true,
        showSetProgress: false,
        showRestTimerControls: true,
        allowCompleteSetFromNotification: false,
        now: now,
      );
      expect(spec.body, 'Squat');
    });

    test('rest mode: shows countdown and controls', () {
      final restEndsAt = now.add(const Duration(seconds: 60));
      final snapshot = _makeRestingSnapshot(restEndsAt: restEndsAt, now: now)
          .copyWith(exerciseName: 'Deadlift', setNumber: 2, totalSets: 3);
      final spec = formatter.build(
        snapshot: snapshot,
        showScheduleProgress: true,
        showSetProgress: true,
        showRestTimerControls: true,
        allowCompleteSetFromNotification: false,
        now: now,
      );
      expect(spec.mode, LiveNotificationMode.rest);
      expect(spec.title, contains('Deadlift'));
      expect(spec.countdownEndsAt, restEndsAt);
      final actionIds =
          spec.actions.map((a) => a.id).toList();
      expect(actionIds, contains(LiveNotificationActionId.skipRest));
      expect(actionIds, contains(LiveNotificationActionId.adjustRestMinus15));
      expect(actionIds, contains(LiveNotificationActionId.adjustRestPlus15));
    });

    test('rest mode: showRestTimerControls false hides buttons', () {
      final restEndsAt = now.add(const Duration(seconds: 60));
      final snapshot = _makeRestingSnapshot(restEndsAt: restEndsAt, now: now);
      final spec = formatter.build(
        snapshot: snapshot,
        showScheduleProgress: true,
        showSetProgress: true,
        showRestTimerControls: false,
        allowCompleteSetFromNotification: false,
        now: now,
      );
      expect(spec.actions.isEmpty, isTrue);
    });
  });

  group('computeFinishedExercises', () {
    test('2 of 10 exercises fully done → 2', () {
      final result = computeFinishedExercises(
        totalExercises: 10,
        completedSetsByExercise: {'ex1': 3, 'ex2': 4},
        totalSetsByExercise: {
          'ex1': 3,
          'ex2': 4,
          for (int i = 3; i <= 10; i++) 'ex$i': 3
        },
        skippedExerciseIds: {},
      );
      expect(result, 2);
    });

    test('skipped exercise counts as finished', () {
      final result = computeFinishedExercises(
        totalExercises: 5,
        completedSetsByExercise: {'ex1': 3},
        totalSetsByExercise: {for (int i = 1; i <= 5; i++) 'ex$i': 3},
        skippedExerciseIds: {'ex2'},
      );
      // ex1 done (3/3), ex2 skipped → 2 finished
      expect(result, 2);
    });
  });

  group('ReminderPlanner', () {
    const planner = ReminderPlanner();
    final now = DateTime(2024, 6, 17, 10, 0); // Monday 10:00

    test('produces workout reminders for selected weekdays', () {
      final reminders = planner.plan(
        workoutRemindersEnabled: true,
        reminderWeekdays: {1, 3, 5}, // Mon, Wed, Fri
        reminderMinutesAfterMidnight: 18 * 60 + 30, // 18:30
        skipIfTrainedToday: false,
        completedTodayScheduleId: null,
        hydrationEnabled: false,
        hydrationIntervalHours: 2,
        hydrationStartHour: 8,
        hydrationEndHour: 20,
        weeklyRecapEnabled: false,
        weeklyRecapWeekday: 7,
        weeklyRecapMinutes: 18 * 60,
        quietHoursEnabled: false,
        quietStartMinutes: 0,
        quietEndMinutes: 0,
        scheduleName: 'Push Day',
        now: now,
      );
      final workoutReminders = reminders
          .where((r) => r.type == ReminderType.workoutReminder)
          .toList();
      expect(workoutReminders.isNotEmpty, isTrue);
      // All should be Mon, Wed, or Fri
      for (final r in workoutReminders) {
        expect([1, 3, 5], contains(r.scheduledAt.weekday));
        expect(r.scheduledAt.hour, 18);
        expect(r.scheduledAt.minute, 30);
      }
    });

    test('quiet hours suppress hydration reminders', () {
      final reminders = planner.plan(
        workoutRemindersEnabled: false,
        reminderWeekdays: {},
        reminderMinutesAfterMidnight: 0,
        skipIfTrainedToday: false,
        completedTodayScheduleId: null,
        hydrationEnabled: true,
        hydrationIntervalHours: 1,
        hydrationStartHour: 22, // inside quiet hours
        hydrationEndHour: 23,
        weeklyRecapEnabled: false,
        weeklyRecapWeekday: 7,
        weeklyRecapMinutes: 18 * 60,
        quietHoursEnabled: true,
        quietStartMinutes: 22 * 60, // 22:00
        quietEndMinutes: 6 * 60 + 30, // 06:30
        scheduleName: '',
        now: now,
      );
      final hydration =
          reminders.where((r) => r.type == ReminderType.hydration).toList();
      expect(hydration.isEmpty, isTrue);
    });

    test('skipIfTrainedToday suppresses today reminder', () {
      // now is Monday 10:00; reminder is at 18:30 — should be suppressed.
      final reminders = planner.plan(
        workoutRemindersEnabled: true,
        reminderWeekdays: {1}, // Monday only
        reminderMinutesAfterMidnight: 18 * 60 + 30,
        skipIfTrainedToday: true,
        completedTodayScheduleId: 'sched-1', // trained today
        hydrationEnabled: false,
        hydrationIntervalHours: 2,
        hydrationStartHour: 8,
        hydrationEndHour: 20,
        weeklyRecapEnabled: false,
        weeklyRecapWeekday: 7,
        weeklyRecapMinutes: 18 * 60,
        quietHoursEnabled: false,
        quietStartMinutes: 0,
        quietEndMinutes: 0,
        scheduleName: 'Push Day',
        now: now,
      );
      // Today's Monday reminder should be skipped; next one would be next Monday
      final todayReminders = reminders
          .where((r) =>
              r.type == ReminderType.workoutReminder &&
              r.scheduledAt.day == now.day &&
              r.scheduledAt.month == now.month)
          .toList();
      expect(todayReminders.isEmpty, isTrue);
    });

    test('reminder IDs are in workout range 2000–2099', () {
      final reminders = planner.plan(
        workoutRemindersEnabled: true,
        reminderWeekdays: {1, 2, 3, 4, 5, 6, 7},
        reminderMinutesAfterMidnight: 18 * 60,
        skipIfTrainedToday: false,
        completedTodayScheduleId: null,
        hydrationEnabled: false,
        hydrationIntervalHours: 2,
        hydrationStartHour: 8,
        hydrationEndHour: 20,
        weeklyRecapEnabled: false,
        weeklyRecapWeekday: 7,
        weeklyRecapMinutes: 18 * 60,
        quietHoursEnabled: false,
        quietStartMinutes: 0,
        quietEndMinutes: 0,
        scheduleName: 'Push Day',
        now: now,
      );
      for (final r in reminders.where((r) => r.type == ReminderType.workoutReminder)) {
        expect(r.id, greaterThanOrEqualTo(2000));
        expect(r.id, lessThanOrEqualTo(2099));
      }
    });
  });

  group('LiveSnapshotStore', () {
    test('save, load, and clear round-trip', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = LiveSnapshotStore(prefs);

      expect(store.load(), isNull);

      final snapshot = _makeSnapshot(finished: 2, total: 5);
      await store.save(snapshot);

      final loaded = store.load();
      expect(loaded, isNotNull);
      expect(loaded!.scheduleId, snapshot.scheduleId);
      expect(loaded.totalExercises, 5);
      expect(loaded.finishedExercises, 2);

      await store.clear();
      expect(store.load(), isNull);
    });

    test('stale snapshot (> 12 hours) is discarded', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = LiveSnapshotStore(prefs);

      final stale = _makeSnapshot(finished: 1, total: 3).copyWith(
        updatedAt: DateTime.now().subtract(const Duration(hours: 13)),
      );
      await store.save(stale);

      expect(store.load(), isNull);
      expect(store.hasSnapshot, isFalse);
    });
  });

  group('ResumeWorkoutRecoveryModal', () {
    testWidgets('renders recovery modal with snapshot metrics and triggers callbacks',
        (tester) async {
      final snapshot = _makeSnapshot(finished: 3, total: 8).copyWith(
        scheduleName: 'Leg Day Blast',
        exerciseName: 'Barbell Squat',
        setNumber: 2,
        totalSets: 4,
      );

      bool resumeTapped = false;
      bool discardTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showResumeWorkoutRecoveryModal(
                      context,
                      snapshot: snapshot,
                      onResume: () => resumeTapped = true,
                      onDiscard: () => discardTapped = true,
                    );
                  },
                  child: const Text('Open Modal'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Resume your workout?'), findsOneWidget);
      expect(find.text('Leg Day Blast'), findsOneWidget);
      expect(find.text('Resume Workout'), findsOneWidget);
      expect(find.text('Discard Workout'), findsOneWidget);

      // Tap Resume
      await tester.tap(find.text('Resume Workout'));
      await tester.pumpAndSettle();

      expect(resumeTapped, isTrue);
      expect(discardTapped, isFalse);
      expect(find.text('Resume your workout?'), findsNothing);
    });

    testWidgets('tapping Discard Workout triggers onDiscard callback',
        (tester) async {
      final snapshot = _makeSnapshot(finished: 1, total: 4);
      bool discardTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showResumeWorkoutRecoveryModal(
                      context,
                      snapshot: snapshot,
                      onResume: () {},
                      onDiscard: () => discardTapped = true,
                    );
                  },
                  child: const Text('Open Modal'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Discard Workout'));
      await tester.pumpAndSettle();

      expect(discardTapped, isTrue);
      expect(find.text('Resume your workout?'), findsNothing);
    });
  });

  group('NotificationService Fake & Launch Payload', () {
    test('getLaunchPayload returns expected payload', () async {
      final fake = FakeNotificationService();
      expect(await fake.getLaunchPayload(), isNull);

      fake.launchPayload = const NotificationPayload(
        type: NotificationPayloadType.workoutComplete,
        sessionId: 'sess-999',
      );

      final result = await fake.getLaunchPayload();
      expect(result, isNotNull);
      expect(result!.type, NotificationPayloadType.workoutComplete);
      expect(result.sessionId, 'sess-999');
    });
  });
}

class FakeNotificationService implements NotificationService {
  final List<LiveNotificationSpec> liveSpecs = [];
  final List<int> clearedLiveIds = [];
  final List<({int id, String title, String body, NotificationPayload payload})> shownNotifications = [];
  final List<({LiveNotificationSpec workoutSpec, DateTime scheduledAt})> scheduledRestEndAlerts = [];
  final StreamController<NotificationPayload> _tapStreamController = StreamController.broadcast();
  NotificationPayload? launchPayload;
  NotificationPermissionStatus currentPermission = NotificationPermissionStatus.granted;

  @override
  Stream<NotificationPayload> get tapStream => _tapStreamController.stream;

  @override
  Future<NotificationPayload?> getLaunchPayload() async => launchPayload;

  @override
  Future<void> init({required Future<void> Function(NotificationPayload payload) onTap}) async {}

  @override
  Future<NotificationPermissionStatus> permissionStatus() async => currentPermission;

  @override
  Future<NotificationPermissionStatus> requestPermission() async => currentPermission;

  @override
  Future<void> openSystemSettings() async {}

  @override
  Future<void> showLive(LiveNotificationSpec spec) async {
    liveSpecs.add(spec);
  }

  @override
  Future<void> clearLive() async {
    clearedLiveIds.add(1001);
  }

  @override
  Future<void> scheduleRestEndAlert({
    required LiveWorkoutSnapshot snapshot,
    required LiveNotificationSpec workoutSpec,
    required DateTime scheduledAt,
  }) async {
    scheduledRestEndAlerts.add((workoutSpec: workoutSpec, scheduledAt: scheduledAt));
  }

  @override
  Future<void> cancelRestEndAlert() async {}

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required NotificationPayload payload,
    String? largeIcon,
  }) async {
    shownNotifications.add((id: id, title: title, body: body, payload: payload));
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
  }) async {}

  @override
  Future<void> cancelRange(int startId, int endId) async {}

  @override
  Future<void> cancel(int id) async {}
}

// ── Helpers ───────────────────────────────────────────────────────────────────

LiveWorkoutSnapshot _makeSnapshot({
  required int finished,
  required int total,
  DateTime? now,
}) {
  final current = now ?? DateTime.now();
  return LiveWorkoutSnapshot(
    sessionId: 'sess-1',
    scheduleId: 'sched-1',
    scheduleName: 'Push Day',
    totalExercises: total,
    finishedExercises: finished,
    exerciseName: 'Bench Press',
    setNumber: 1,
    totalSets: 4,
    phase: 'active',
    sessionStartedAt: current,
    pausedAccumulatedSeconds: 0,
    restDurationSeconds: 90,
    updatedAt: current,
  );
}

LiveWorkoutSnapshot _makeRestingSnapshot({
  required DateTime restEndsAt,
  required DateTime now,
}) {
  return LiveWorkoutSnapshot(
    sessionId: 'sess-1',
    scheduleId: 'sched-1',
    scheduleName: 'Push Day',
    totalExercises: 5,
    finishedExercises: 1,
    exerciseName: 'Deadlift',
    setNumber: 2,
    totalSets: 3,
    phase: 'resting',
    sessionStartedAt: now.subtract(const Duration(minutes: 5)),
    pausedAccumulatedSeconds: 0,
    restEndsAt: restEndsAt,
    restDurationSeconds: 90,
    updatedAt: now,
  );
}
