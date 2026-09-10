import 'package:sqflite/sqflite.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/set_log.dart';
import '../../domain/repositories/i_workout_session_repository.dart';
import '../datasources/local/database_helper.dart';

class SqliteWorkoutSessionRepository implements IWorkoutSessionRepository {
  final DatabaseHelper _dbHelper;

  SqliteWorkoutSessionRepository(this._dbHelper);

  @override
  Future<List<WorkoutSession>> getAllSessions() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_sessions',
      orderBy: 'startTime DESC',
    );
    return maps.map((map) {
      final modMap = Map<String, dynamic>.from(map);
      modMap['startTime'] = DateTime.parse(modMap['startTime'] as String).toIso8601String();
      if (modMap['endTime'] != null) {
        modMap['endTime'] = DateTime.parse(modMap['endTime'] as String).toIso8601String();
      }
      return WorkoutSession.fromJson(modMap);
    }).toList();
  }

  @override
  Future<void> saveSession(WorkoutSession session) async {
    final db = await _dbHelper.database;
    final map = session.toJson();
    map['startTime'] = session.startTime.toIso8601String();
    if (session.endTime != null) {
      map['endTime'] = session.endTime!.toIso8601String();
    }
    await db.insert('workout_sessions', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> saveExerciseLogs(List<ExerciseLog> logs) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (var log in logs) {
      final map = log.toJson();
      map['isSkipped'] = log.isSkipped ? 1 : 0;
      batch.insert('exercise_logs', map, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> saveSetLogs(List<SetLog> logs) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (var log in logs) {
      final map = log.toJson();
      map['isCompleted'] = log.isCompleted ? 1 : 0;
      batch.insert('set_logs', map, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}
