/// Reminder planner — pure Dart, no Flutter imports.
///
/// Takes notification settings and schedule metadata and returns the next
/// N days of scheduled reminder occurrences. The coordinator uses this to
/// call [NotificationService.scheduleAt] in one place.
library;

/// A single planned reminder returned by [ReminderPlanner].
class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.type,
    required this.scheduledAt,
    required this.title,
    required this.body,
    required this.payloadType,
    this.scheduleId,
  });

  /// Unique notification ID (stable across replanning).
  final int id;

  /// One of [ReminderType] constants.
  final String type;

  final DateTime scheduledAt;
  final String title;
  final String body;

  /// Payload type string for deep-link routing.
  final String payloadType;
  final String? scheduleId;
}

abstract final class ReminderType {
  static const String workoutReminder = 'workout_reminder';
  static const String hydration = 'hydration';
  static const String weeklyRecap = 'weekly_recap';
}

/// ID ranges per spec (§2.7):
///  workout: 2000–2099, hydration: 3000–3199, weekly recap: 4000.
abstract final class ReminderIdRange {
  static const int workoutBase = 2000;
  static const int hydrationBase = 3000;
  static const int weeklyRecapBase = 4000;
}

class ReminderPlanner {
  const ReminderPlanner();

  /// [reminderWeekdays] – ISO weekday set (1=Mon … 7=Sun).
  /// [reminderMinutesAfterMidnight] – minutes past midnight for workout reminders.
  /// [skipIfTrainedToday] – if true and [completedTodayScheduleId] is non-null, skip today.
  /// [hydrationIntervalHours] – e.g. 2 for every 2 hours.
  /// [hydrationStartHour] / [hydrationEndHour] – window (0–23).
  /// [weeklyRecapEnabled] / [weeklyRecapWeekday] / [weeklyRecapMinutes].
  /// [quietStartMinutes] / [quietEndMinutes] – quiet hours (minutes after midnight, can wrap midnight).
  /// [quietHoursEnabled] – suppresses non-live reminders in quiet window.
  /// [windowDays] – how many days ahead to plan.
  /// [now] – injectable for tests.
  List<PlannedReminder> plan({
    required bool workoutRemindersEnabled,
    required Set<int> reminderWeekdays,
    required int reminderMinutesAfterMidnight,
    required bool skipIfTrainedToday,
    required String? completedTodayScheduleId,
    required bool hydrationEnabled,
    required int hydrationIntervalHours,
    required int hydrationStartHour,
    required int hydrationEndHour,
    required bool weeklyRecapEnabled,
    required int weeklyRecapWeekday,
    required int weeklyRecapMinutes,
    required bool quietHoursEnabled,
    required int quietStartMinutes,
    required int quietEndMinutes,
    required String scheduleName,
    String? scheduleId,
    int windowDays = 14,
    DateTime? now,
  }) {
    final effectiveNow = now ?? DateTime.now();
    final reminders = <PlannedReminder>[];

    if (workoutRemindersEnabled && reminderWeekdays.isNotEmpty) {
      reminders.addAll(_planWorkoutReminders(
        effectiveNow: effectiveNow,
        weekdays: reminderWeekdays,
        minutesAfterMidnight: reminderMinutesAfterMidnight,
        skipIfTrainedToday: skipIfTrainedToday,
        completedToday: completedTodayScheduleId != null,
        quietHoursEnabled: quietHoursEnabled,
        quietStartMinutes: quietStartMinutes,
        quietEndMinutes: quietEndMinutes,
        windowDays: windowDays,
        scheduleName: scheduleName,
        scheduleId: scheduleId,
      ));
    }

    if (hydrationEnabled && hydrationIntervalHours > 0) {
      reminders.addAll(_planHydrationReminders(
        effectiveNow: effectiveNow,
        intervalHours: hydrationIntervalHours,
        startHour: hydrationStartHour,
        endHour: hydrationEndHour,
        quietHoursEnabled: quietHoursEnabled,
        quietStartMinutes: quietStartMinutes,
        quietEndMinutes: quietEndMinutes,
        windowDays: windowDays,
      ));
    }

    if (weeklyRecapEnabled) {
      reminders.addAll(_planWeeklyRecap(
        effectiveNow: effectiveNow,
        weekday: weeklyRecapWeekday,
        minutesAfterMidnight: weeklyRecapMinutes,
        quietHoursEnabled: quietHoursEnabled,
        quietStartMinutes: quietStartMinutes,
        quietEndMinutes: quietEndMinutes,
        windowDays: windowDays,
      ));
    }

    return reminders;
  }

  // ── Workout reminders ────────────────────────────────────────────────────

  List<PlannedReminder> _planWorkoutReminders({
    required DateTime effectiveNow,
    required Set<int> weekdays,
    required int minutesAfterMidnight,
    required bool skipIfTrainedToday,
    required bool completedToday,
    required bool quietHoursEnabled,
    required int quietStartMinutes,
    required int quietEndMinutes,
    required int windowDays,
    required String scheduleName,
    String? scheduleId,
  }) {
    final result = <PlannedReminder>[];
    int idOffset = 0;
    for (int day = 0; day < windowDays && idOffset < 100; day++) {
      final date = effectiveNow.add(Duration(days: day));
      final weekday = date.weekday; // 1=Mon … 7=Sun
      if (!weekdays.contains(weekday)) continue;

      final scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
      ).add(Duration(minutes: minutesAfterMidnight));

      if (scheduledAt.isBefore(effectiveNow)) continue;
      if (skipIfTrainedToday && completedToday && _sameDay(date, effectiveNow)) {
        continue;
      }
      if (quietHoursEnabled &&
          _isInQuietHours(scheduledAt, quietStartMinutes, quietEndMinutes)) {
        continue;
      }

      result.add(PlannedReminder(
        id: ReminderIdRange.workoutBase + idOffset,
        type: ReminderType.workoutReminder,
        scheduledAt: scheduledAt,
        title: 'Time to train 💪',
        body: scheduleName.isNotEmpty ? scheduleName : 'Your workout is ready',
        payloadType: 'workout_reminder',
        scheduleId: scheduleId,
      ));
      idOffset++;
    }
    return result;
  }

  // ── Hydration reminders ──────────────────────────────────────────────────

  List<PlannedReminder> _planHydrationReminders({
    required DateTime effectiveNow,
    required int intervalHours,
    required int startHour,
    required int endHour,
    required bool quietHoursEnabled,
    required int quietStartMinutes,
    required int quietEndMinutes,
    required int windowDays,
  }) {
    final result = <PlannedReminder>[];
    int idOffset = 0;

    for (int day = 0; day < windowDays && idOffset < 200; day++) {
      final date = effectiveNow.add(Duration(days: day));
      for (int h = startHour; h < endHour && idOffset < 200; h += intervalHours) {
        final scheduledAt = DateTime(date.year, date.month, date.day, h);
        if (scheduledAt.isBefore(effectiveNow)) continue;
        if (quietHoursEnabled &&
            _isInQuietHours(scheduledAt, quietStartMinutes, quietEndMinutes)) {
          continue;
        }
        result.add(PlannedReminder(
          id: ReminderIdRange.hydrationBase + idOffset,
          type: ReminderType.hydration,
          scheduledAt: scheduledAt,
          title: 'Hydration check 💧',
          body: 'Time to drink some water',
          payloadType: 'hydration',
        ));
        idOffset++;
      }
    }
    return result;
  }

  // ── Weekly recap ─────────────────────────────────────────────────────────

  List<PlannedReminder> _planWeeklyRecap({
    required DateTime effectiveNow,
    required int weekday,
    required int minutesAfterMidnight,
    required bool quietHoursEnabled,
    required int quietStartMinutes,
    required int quietEndMinutes,
    required int windowDays,
  }) {
    final result = <PlannedReminder>[];
    for (int day = 0; day < windowDays; day++) {
      final date = effectiveNow.add(Duration(days: day));
      if (date.weekday != weekday) continue;
      final scheduledAt = DateTime(date.year, date.month, date.day)
          .add(Duration(minutes: minutesAfterMidnight));
      if (scheduledAt.isBefore(effectiveNow)) continue;
      if (quietHoursEnabled &&
          _isInQuietHours(scheduledAt, quietStartMinutes, quietEndMinutes)) {
        continue;
      }
      result.add(PlannedReminder(
        id: ReminderIdRange.weeklyRecapBase,
        type: ReminderType.weeklyRecap,
        scheduledAt: scheduledAt,
        title: 'Weekly recap 📊',
        body: "Here's your week at a glance",
        payloadType: 'weekly_summary',
      ));
      break; // Only one recap per 14-day window
    }
    return result;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Returns true if [t] falls within the quiet-hours window.
  /// [startMinutes] and [endMinutes] are minutes after midnight.
  /// Wraps midnight (e.g. start=1320=22:00, end=390=06:30).
  bool _isInQuietHours(DateTime t, int startMinutes, int endMinutes) {
    final minuteOfDay = t.hour * 60 + t.minute;
    if (startMinutes < endMinutes) {
      // Does not wrap midnight
      return minuteOfDay >= startMinutes && minuteOfDay < endMinutes;
    } else {
      // Wraps midnight (e.g. 22:00 to 06:30)
      return minuteOfDay >= startMinutes || minuteOfDay < endMinutes;
    }
  }
}
