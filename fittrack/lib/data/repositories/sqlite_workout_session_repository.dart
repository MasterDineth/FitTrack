import 'package:flutter/foundation.dart';
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
    return maps.map((map) => WorkoutSession.fromJson(map)).toList();
  }

  @override
  Future<Map<String, dynamic>> getDashboardMetrics({
    required DateTime startOfWeek,
    required DateTime endOfWeek,
    DateTime? startOfMonth,
    DateTime? endOfMonth,
  }) async {
    debugPrint('[SQL_QUERY] getDashboardMetrics (aggregates query)');
    final db = await _dbHelper.database;
    final sMonth = startOfMonth ?? DateTime(startOfWeek.year, startOfWeek.month, 1);
    final eMonth = endOfMonth ?? DateTime(startOfWeek.year, startOfWeek.month + 1, 1);

    final result = await db.rawQuery(
      'SELECT '
      '  COUNT(DISTINCT CASE WHEN startTime >= ? AND startTime < ? THEN substr(startTime, 1, 10) END) as daysTrained, '
      '  COUNT(CASE WHEN endTime IS NOT NULL THEN 1 END) as workoutsCompleted, '
      '  COALESCE(SUM(totalCalories), 0) as totalCalories, '
      '  GROUP_CONCAT(DISTINCT CASE WHEN startTime >= ? AND startTime < ? THEN substr(startTime, 1, 10) END) as monthDates '
      'FROM workout_sessions',
      [
        startOfWeek.toIso8601String(),
        endOfWeek.toIso8601String(),
        sMonth.toIso8601String(),
        eMonth.toIso8601String(),
      ],
    );

    if (result.isEmpty) {
      return {
        'daysTrainedThisWeek': 0,
        'totalWorkoutsCompleted': 0,
        'totalCaloriesBurned': 0,
        'activeDatesThisMonth': <DateTime>[],
      };
    }

    final row = result.first;
    final monthDatesStr = row['monthDates'] as String?;
    final activeDates = monthDatesStr != null && monthDatesStr.isNotEmpty
        ? monthDatesStr.split(',').map((s) => DateTime.parse(s)).toList()
        : <DateTime>[];

    return {
      'daysTrainedThisWeek': (row['daysTrained'] as int?) ?? 0,
      'totalWorkoutsCompleted': (row['workoutsCompleted'] as int?) ?? 0,
      'totalCaloriesBurned': (row['totalCalories'] as int?) ?? 0,
      'activeDatesThisMonth': activeDates,
    };
  }

  @override
  Future<List<DateTime>> getSessionStartDatesInRange({
    required DateTime startInclusive,
    required DateTime endExclusive,
  }) async {
    debugPrint('[SQL_QUERY] getSessionStartDatesInRange (range query)');
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT substr(startTime, 1, 10) as dayStr '
      'FROM workout_sessions '
      'WHERE startTime >= ? AND startTime < ? '
      'ORDER BY startTime ASC',
      [startInclusive.toIso8601String(), endExclusive.toIso8601String()],
    );

    return maps.map((m) {
      final str = m['dayStr'] as String;
      return DateTime.parse(str);
    }).toList();
  }

  @override
  Future<List<WorkoutSession>> getSessionsSince(DateTime startInclusive) async {
    debugPrint('[SQL_QUERY] getSessionsSince');
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_sessions',
      where: 'startTime >= ?',
      whereArgs: [startInclusive.toIso8601String()],
      orderBy: 'startTime ASC',
    );
    return maps.map((map) => WorkoutSession.fromJson(map)).toList();
  }

  @override
  Future<List<WorkoutSession>> getRecentSessions({int limit = 5}) async {
    debugPrint('[SQL_QUERY] getRecentSessions (recents query)');
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_sessions',
      orderBy: 'startTime DESC',
      limit: limit,
    );
    return maps.map((map) => WorkoutSession.fromJson(map)).toList();
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
      // Store skipReason in the snake_case column name
      map['skip_reason'] = log.skipReason;
      // Remove the Freezed-generated camelCase key if present
      map.remove('skipReason');
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

  @override
  Future<WorkoutSession?> getSessionById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_sessions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return WorkoutSession.fromJson(maps.first);
  }

  @override
  Future<List<ExerciseLog>> getExerciseLogsForSession(String sessionId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercise_logs',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'orderIndex ASC',
    );
    return maps.map((map) {
      final copy = Map<String, dynamic>.from(map);
      copy['isSkipped'] = (copy['isSkipped'] == 1 || copy['isSkipped'] == true);
      if (copy.containsKey('skip_reason')) {
        copy['skipReason'] = copy['skip_reason'];
      }
      return ExerciseLog.fromJson(copy);
    }).toList();
  }

  @override
  Future<List<SetLog>> getSetLogsForSession(String sessionId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT sl.* 
      FROM set_logs sl
      INNER JOIN exercise_logs el ON sl.exerciseLogId = el.id
      WHERE el.sessionId = ?
      ORDER BY el.orderIndex ASC, sl.setNumber ASC
    ''', [sessionId]);
    return maps.map((map) {
      final copy = Map<String, dynamic>.from(map);
      copy['isCompleted'] = (copy['isCompleted'] == 1 || copy['isCompleted'] == true);
      return SetLog.fromJson(copy);
    }).toList();
  }

  @override
  Future<List<SetLog>> getSetLogsForExerciseLog(String exerciseLogId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'set_logs',
      where: 'exerciseLogId = ?',
      whereArgs: [exerciseLogId],
      orderBy: 'setNumber ASC',
    );
    return maps.map((map) {
      final copy = Map<String, dynamic>.from(map);
      copy['isCompleted'] = (copy['isCompleted'] == 1 || copy['isCompleted'] == true);
      return SetLog.fromJson(copy);
    }).toList();
  }

  @override
  Future<List<WorkoutSession>> getSessionsForMonth(DateTime month) async {
    final db = await _dbHelper.database;
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 1);

    final List<Map<String, dynamic>> maps = await db.query(
      'workout_sessions',
      where: 'startTime >= ? AND startTime < ?',
      whereArgs: [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()],
      orderBy: 'startTime DESC',
    );
    return maps.map((map) => WorkoutSession.fromJson(map)).toList();
  }
}
