import '../entities/schedule.dart';
import '../entities/schedule_exercise.dart';

abstract class IScheduleRepository {
  Future<List<Schedule>> getAllSchedules();
  Future<Schedule?> getScheduleById(String id);
  Future<List<ScheduleExercise>> getScheduleExercises(String scheduleId);
}
