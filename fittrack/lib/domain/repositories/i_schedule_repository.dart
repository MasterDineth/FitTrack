import '../entities/schedule.dart';
import '../entities/schedule_exercise.dart';

abstract class IScheduleRepository {
  Future<List<Schedule>> getAllSchedules();
  Future<Schedule?> getScheduleById(String id);
  Future<List<ScheduleExercise>> getScheduleExercises(String scheduleId);

  /// Persists a [Schedule] and its associated [exercises] atomically.
  /// Uses insert-or-replace semantics so it handles both create and update.
  Future<void> saveSchedule(Schedule schedule, List<ScheduleExercise> exercises);

  /// Removes a schedule and its associated schedule_exercises rows.
  Future<void> deleteSchedule(String scheduleId);
}
