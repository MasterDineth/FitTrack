import '../entities/workout_session.dart';
import '../entities/exercise_log.dart';
import '../entities/set_log.dart';

abstract class IWorkoutSessionRepository {
  Future<List<WorkoutSession>> getAllSessions();
  Future<WorkoutSession?> getSessionById(String id);
  Future<void> saveSession(WorkoutSession session);
  Future<void> saveExerciseLogs(List<ExerciseLog> logs);
  Future<void> saveSetLogs(List<SetLog> logs);
  Future<List<ExerciseLog>> getExerciseLogsForSession(String sessionId);
  Future<List<SetLog>> getSetLogsForSession(String sessionId);
  Future<List<SetLog>> getSetLogsForExerciseLog(String exerciseLogId);
  Future<List<WorkoutSession>> getSessionsForMonth(DateTime month);

  /// Returns aggregate weekly and all-time metrics using optimized SQL aggregates:
  /// - `daysTrainedThisWeek`: Distinct days trained between [startOfWeek] and [endOfWeek].
  /// - `totalWorkoutsCompleted`: All-time workouts with `endTime != null`.
  /// - `totalCaloriesBurned`: All-time sum of `totalCalories`.
  Future<Map<String, dynamic>> getDashboardMetrics({
    required DateTime startOfWeek,
    required DateTime endOfWeek,
    DateTime? startOfMonth,
    DateTime? endOfMonth,
  });

  /// Returns distinct start dates (normalized to day) of sessions started in the given range.
  Future<List<DateTime>> getSessionStartDatesInRange({
    required DateTime startInclusive,
    required DateTime endExclusive,
  });

  /// Returns sessions that started at or after [startInclusive], ordered by startTime.
  Future<List<WorkoutSession>> getSessionsSince(DateTime startInclusive);

  /// Returns the most recent sessions up to [limit], ordered by startTime DESC.
  Future<List<WorkoutSession>> getRecentSessions({int limit = 5});
}
