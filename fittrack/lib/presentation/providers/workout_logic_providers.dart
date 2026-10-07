import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/schedule_exercise.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/repositories/i_schedule_repository.dart';
import '../../domain/repositories/i_workout_session_repository.dart';

part 'workout_logic_providers.g.dart';

/// Single keepAlive revision tracker that is bumped whenever a session is
/// saved, finished, or discarded so derived providers only re-evaluate then.
@Riverpod(keepAlive: true)
class SessionsRevisionNotifier extends _$SessionsRevisionNotifier {
  @override
  int build() => 0;

  void bump() {
    state = state + 1;
  }
}

/// Normalised selected month for the activity calendar (always Year, Month, 1).
@Riverpod(keepAlive: true)
class SelectedMonthNotifier extends _$SelectedMonthNotifier {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  void setMonth(DateTime month) {
    state = DateTime(month.year, month.month, 1);
  }

  void nextMonth() {
    state = DateTime(state.year, state.month + 1, 1);
  }

  void prevMonth() {
    state = DateTime(state.year, state.month - 1, 1);
  }
}

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
  ref.watch(sessionsRevisionProvider);

  final now = DateTime.now();
  // Midnight Monday of the current week (fixing time-of-day exclusions)
  final startOfWeek = DateTime(now.year, now.month, now.day - (now.weekday - 1));

  // Shared recents query: reads up to 5 recent sessions from recentWorkoutSessionsProvider
  final recentSessions = await ref.watch(recentWorkoutSessionsProvider(sessionRepo).future);
  final weekSessions = recentSessions.where((s) => !s.startTime.isBefore(startOfWeek)).toList();

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

/// Aggregates dashboard metrics for the current week and all-time
/// using indexed SQL aggregate queries.
///
/// Returns a map with keys:
/// - `daysTrainedThisWeek` ([int])
/// - `totalWorkoutsCompleted` ([int])
/// - `totalCaloriesBurned` ([int])
/// - `activeDatesThisMonth` ([List<DateTime>])
@riverpod
Future<Map<String, dynamic>> dashboardMetrics(
  Ref ref,
  IWorkoutSessionRepository sessionRepo,
) async {
  ref.watch(sessionsRevisionProvider);

  final now = DateTime.now();
  // Midnight Monday of current week (correctly includes all Monday sessions)
  final startOfWeek = DateTime(now.year, now.month, now.day - (now.weekday - 1));
  final endOfWeek = startOfWeek.add(const Duration(days: 7));
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 1);

  final metrics = await sessionRepo.getDashboardMetrics(
    startOfWeek: startOfWeek,
    endOfWeek: endOfWeek,
    startOfMonth: startOfMonth,
    endOfMonth: endOfMonth,
  );

  return metrics;
}

/// Returns the set of [DateTime]s in the currently selected month on which
/// a workout session was started, for rendering the monthly activity calendar.
///
/// Keyed only by normalized month via [selectedMonthNotifierProvider].
/// Reuses the dashboard aggregates query for the current month.
@riverpod
Future<List<DateTime>> calendarActivity(
  Ref ref,
  IWorkoutSessionRepository sessionRepo,
) async {
  ref.watch(sessionsRevisionProvider);
  final month = ref.watch(selectedMonthProvider);

  final now = DateTime.now();
  if (month.year == now.year && month.month == now.month) {
    final metrics = await ref.watch(dashboardMetricsProvider(sessionRepo).future);
    return (metrics['activeDatesThisMonth'] as List<DateTime>?) ?? const [];
  }

  final startOfMonth = DateTime(month.year, month.month, 1);
  final endOfMonth = DateTime(month.year, month.month + 1, 1);

  return await sessionRepo.getSessionStartDatesInRange(
    startInclusive: startOfMonth,
    endExclusive: endOfMonth,
  );
}

/// Returns up to 5 most recent workout sessions using an indexed LIMIT query.
@riverpod
Future<List<WorkoutSession>> recentWorkoutSessions(
  Ref ref,
  IWorkoutSessionRepository sessionRepo,
) async {
  ref.watch(sessionsRevisionProvider);
  return await sessionRepo.getRecentSessions(limit: 5);
}
