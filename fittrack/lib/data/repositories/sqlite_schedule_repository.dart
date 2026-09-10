import 'dart:convert';
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
    return maps.map((map) {
      final modMap = Map<String, dynamic>.from(map);
      modMap['isArchived'] = modMap['isArchived'] == 1;
      modMap['targetMuscles'] = List<String>.from(json.decode(modMap['targetMuscles'] as String));
      modMap['assignedWeekdays'] = List<int>.from(json.decode(modMap['assignedWeekdays'] as String));
      return Schedule.fromJson(modMap);
    }).toList();
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

    final modMap = Map<String, dynamic>.from(maps.first);
    modMap['isArchived'] = modMap['isArchived'] == 1;
    modMap['targetMuscles'] = List<String>.from(json.decode(modMap['targetMuscles'] as String));
    modMap['assignedWeekdays'] = List<int>.from(json.decode(modMap['assignedWeekdays'] as String));
    return Schedule.fromJson(modMap);
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
}
