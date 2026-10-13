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
    final List<Map<String, dynamic>> maps =
        await db.query('schedules', orderBy: 'orderIndex ASC');
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
          'isFavorite': schedule.isFavorite ? 1 : 0,
          'focus': schedule.focus,
          'experience': schedule.experience,
          'equipment': schedule.equipment,
          'durationWeeks': schedule.durationWeeks,
          'daysPerWeek': schedule.daysPerWeek,
          'estimatedMinutes': schedule.estimatedMinutes,
          'isCustom': schedule.isCustom ? 1 : 0,
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

  @override
  Future<void> toggleBookmark(String scheduleId, bool isFavorite) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.update(
        'schedules',
        {'isFavorite': isFavorite ? 1 : 0},
        where: 'id = ?',
        whereArgs: [scheduleId],
      );

      if (isFavorite) {
        await txn.insert(
          'bookmarked_items',
          {
            'id': scheduleId,
            'createdAt': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        await txn.delete(
          'bookmarked_items',
          where: 'id = ?',
          whereArgs: [scheduleId],
        );
      }
    });
  }

  @override
  Future<List<Schedule>> getBookmarkedSchedules() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'schedules',
      where: 'isFavorite = 1 AND isArchived = 0',
      orderBy: 'orderIndex ASC',
    );
    return maps.map(_mapToSchedule).toList();
  }

  @override
  Future<List<Schedule>> searchSchedules(String query, {String? category}) async {
    final all = await getAllSchedules();
    final q = query.trim().toLowerCase();
    final cat = (category != null && category != 'All') ? category.toLowerCase() : null;

    return all.where((s) {
      if (s.isArchived) return false;
      if (cat != null) {
        final matchesCat = s.focus.toLowerCase() == cat ||
            s.experience.toLowerCase() == cat ||
            s.equipment.toLowerCase() == cat;
        if (!matchesCat) return false;
      }
      if (q.isNotEmpty) {
        final matchesQuery = s.name.toLowerCase().contains(q) ||
            s.description.toLowerCase().contains(q) ||
            s.focus.toLowerCase().contains(q) ||
            s.experience.toLowerCase().contains(q) ||
            s.equipment.toLowerCase().contains(q) ||
            s.targetMuscles.any((m) => m.toLowerCase().contains(q));
        if (!matchesQuery) return false;
      }
      return true;
    }).toList();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Schedule _mapToSchedule(Map<String, dynamic> map) {
    final modMap = Map<String, dynamic>.from(map);
    modMap['isArchived'] = modMap['isArchived'] == 1;
    modMap['isFavorite'] = modMap['isFavorite'] == 1;
    modMap['isCustom'] = modMap['isCustom'] == 1;
    modMap['focus'] = modMap['focus'] as String? ?? 'Hypertrophy';
    modMap['experience'] = modMap['experience'] as String? ?? 'Intermediate';
    modMap['equipment'] = modMap['equipment'] as String? ?? 'Full Gym';
    modMap['durationWeeks'] = modMap['durationWeeks'] as int? ?? 8;
    modMap['daysPerWeek'] = modMap['daysPerWeek'] as int? ?? 4;
    modMap['estimatedMinutes'] = modMap['estimatedMinutes'] as int? ?? 45;
    modMap['targetMuscles'] =
        List<String>.from(json.decode(modMap['targetMuscles'] as String));
    modMap['assignedWeekdays'] =
        List<int>.from(json.decode(modMap['assignedWeekdays'] as String));
    return Schedule.fromJson(modMap);
  }
}
