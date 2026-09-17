import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/schedule_exercise.dart';
import '../../domain/repositories/i_schedule_repository.dart';
import '../../domain/repositories/i_workout_session_repository.dart';

part 'workout_logic_providers.g.dart';

/// Estimates the total duration (in seconds) for a workout given its exercises.
///
/// Uses: sets * 60s + (sets - 1) * restSeconds + 90s transition buffer.
@riverpod
int durationCalculation(Ref ref, List<ScheduleExercise> exercises) {
  if (exercises.isEmpty) return 0;

  int totalDuration = 0;
  for (final ex in exercises) {
    if (ex.targetSets <= 0) continue;
    totalDuration +=
        (ex.targetSets * 60) + ((ex.targetSets - 1) * ex.restDurationSeconds) + 90;
  }
  return totalDuration;
}

/// Recommends the next [Schedule] to perform based on sessions completed
/// so far this week.
///
/// Returns `null` when all scheduled workouts have been completed
/// (i.e. a rest state).
@riverpod
Future<Schedule?> splitRecommendation(
  Ref ref,
  IScheduleRepository scheduleRepo,
  IWorkoutSessionRepository sessionRepo,
) async {
  final sessions = await sessionRepo.getAllSessions();
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

  final weekSessions = sessions.where((s) {
    final sessionStart = s.startTime;
    return sessionStart.isAfter(startOfWeek) ||
        sessionStart.isAtSameMomentAs(startOfWeek);
  }).toList();

  final schedules = await scheduleRepo.getAllSchedules();
  final unarchivedSchedules =
      schedules.where((s) => !s.isArchived).toList()
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

  if (unarchivedSchedules.isEmpty) return null;
  if (weekSessions.isEmpty) return unarchivedSchedules.first;

  // Find the highest orderIndex completed this week
  int maxCompletedIndex = 0;
  for (final session in weekSessions) {
    final sch = unarchivedSchedules
        .where((s) => s.id == session.scheduleId)
        .firstOrNull;
    if (sch != null && sch.orderIndex > maxCompletedIndex) {
      maxCompletedIndex = sch.orderIndex;
    }
  }

  final nextSchedule = unarchivedSchedules
      .where((s) => s.orderIndex > maxCompletedIndex)
      .firstOrNull;

  return nextSchedule; // null → rest state
}

/// Aggregates dashboard metrics for the current week and all-time.
///
/// Returns a map with keys:
/// - `daysTrainedThisWeek` ([int])
/// - `totalWorkoutsCompleted` ([int])
/// - `totalCaloriesBurned` ([int])
@riverpod
Future<Map<String, dynamic>> dashboardMetrics(
  Ref ref,
  IWorkoutSessionRepository sessionRepo,
) async {
  final sessions = await sessionRepo.getAllSessions();
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

  final weekSessions = sessions.where((s) {
    final sessionStart = s.startTime;
    return sessionStart.isAfter(startOfWeek) ||
        sessionStart.isAtSameMomentAs(startOfWeek);
  }).toList();

  final daysTrained = weekSessions.map((s) => s.startTime.weekday).toSet().length;
  final workoutsCompleted = sessions.where((s) => s.endTime != null).length;

  int totalCalories = 0;
  for (final s in sessions) {
    totalCalories += (s.totalCalories ?? 0);
  }

  return {
    'daysTrainedThisWeek': daysTrained,
    'totalWorkoutsCompleted': workoutsCompleted,
    'totalCaloriesBurned': totalCalories,
  };
}

/// Returns the set of [DateTime]s in [month] on which a workout session
/// was started, for rendering the monthly activity calendar.
@riverpod
Future<List<DateTime>> calendarActivity(
  Ref ref,
  IWorkoutSessionRepository sessionRepo,
  DateTime month,
) async {
  final sessions = await sessionRepo.getAllSessions();

  final activeDates = sessions
      .where((s) =>
          s.startTime.year == month.year && s.startTime.month == month.month)
      .map((s) =>
          DateTime(s.startTime.year, s.startTime.month, s.startTime.day))
      .toSet()
      .toList();

  return activeDates;
}
