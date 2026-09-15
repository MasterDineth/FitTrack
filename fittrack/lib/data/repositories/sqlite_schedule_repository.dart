import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/schedule_exercise.dart';
import '../../domain/repositories/i_schedule_repository.dart';
import '../datasources/local/database_helper.dart';

class SqliteScheduleRepository implements IScheduleRepository {
  final DatabaseHelper _dbHelper;

  SqliteScheduleRepository(this._dbHelper);

  @override
  Future<List<Schedule>> getAllSchedules() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('schedules');
    return maps.map(_mapToSchedule).toList();
  }

  @override
  Future<Schedule?> getScheduleById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'schedules',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _mapToSchedule(maps.first);
  }

  @override
  Future<List<ScheduleExercise>> getScheduleExercises(String scheduleId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'schedule_exercises',
      where: 'scheduleId = ?',
      whereArgs: [scheduleId],
      orderBy: 'sortOrder ASC',
    );
    return maps.map((map) => ScheduleExercise.fromJson(map)).toList();
  }

  @override
  Future<void> saveSchedule(
    Schedule schedule,
    List<ScheduleExercise> exercises,
  ) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.insert(
        'schedules',
        {
          'id': schedule.id,
          'name': schedule.name,
          'description': schedule.description,
          'targetMuscles': json.encode(schedule.targetMuscles),
          'assignedWeekdays': json.encode(schedule.assignedWeekdays),
          'orderIndex': schedule.orderIndex,
          'isArchived': schedule.isArchived ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Delete stale schedule_exercises then re-insert
      await txn.delete(
        'schedule_exercises',
        where: 'scheduleId = ?',
        whereArgs: [schedule.id],
      );

      for (final ex in exercises) {
        await txn.insert(
          'schedule_exercises',
          ex.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<void> deleteSchedule(String scheduleId) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete(
        'schedule_exercises',
        where: 'scheduleId = ?',
        whereArgs: [scheduleId],
      );
      await txn.delete(
        'schedules',
        where: 'id = ?',
        whereArgs: [scheduleId],
      );
    });
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Schedule _mapToSchedule(Map<String, dynamic> map) {
    final modMap = Map<String, dynamic>.from(map);
    modMap['isArchived'] = modMap['isArchived'] == 1;
    modMap['targetMuscles'] =
        List<String>.from(json.decode(modMap['targetMuscles'] as String));
    modMap['assignedWeekdays'] =
        List<int>.from(json.decode(modMap['assignedWeekdays'] as String));
    return Schedule.fromJson(modMap);
  }
}
