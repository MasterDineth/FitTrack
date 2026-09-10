import '../entities/workout_session.dart';
import '../entities/exercise_log.dart';
import '../entities/set_log.dart';

abstract class IWorkoutSessionRepository {
  Future<List<WorkoutSession>> getAllSessions();
  Future<void> saveSession(WorkoutSession session);
  Future<void> saveExerciseLogs(List<ExerciseLog> logs);
  Future<void> saveSetLogs(List<SetLog> logs);
}
