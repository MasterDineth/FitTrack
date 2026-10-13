import '../../domain/entities/daily_habit.dart';
import '../../domain/repositories/i_habits_repository.dart';
import '../datasources/local/database_helper.dart';

class HabitsRepositoryImpl implements IHabitsRepository {
  final DatabaseHelper _dbHelper;
  List<DailyHabit>? _inMemoryHabits;

  HabitsRepositoryImpl({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  static const _defaultHabits = [
    DailyHabit(
      id: 'habit-1',
      title: 'Morning Hydration (1L)',
      subtitle: 'Completed at 7:45 AM',
      isCompleted: true,
      status: HabitChipStatus.done,
      orderIndex: 0,
    ),
    DailyHabit(
      id: 'habit-2',
      title: 'Target Protein Synthesis',
      subtitle: '35g remaining for dinner',
      isCompleted: false,
      status: HabitChipStatus.pending,
      orderIndex: 1,
    ),
    DailyHabit(
      id: 'habit-3',
      title: 'Sleep Protocol (8h target)',
      subtitle: 'Wind-down routine at 10:30 PM',
      isCompleted: false,
      status: HabitChipStatus.tonight,
      orderIndex: 2,
    ),
  ];

  @override
  Future<List<DailyHabit>> getHabits() async {
    _inMemoryHabits ??= List.of(_defaultHabits);
    try {
      final db = await _dbHelper.database.timeout(const Duration(milliseconds: 250));
      final results = await db.query(
        'daily_habits',
        orderBy: 'orderIndex ASC',
      );

      if (results.isEmpty) {
        return _inMemoryHabits!;
      }

      final dbHabits = results.map((map) {
        final isCompleted = (map['isCompleted'] as int? ?? 0) == 1;
        final statusStr = map['status'] as String? ?? 'pending';
        final status = switch (statusStr) {
          'done' => HabitChipStatus.done,
          'tonight' => HabitChipStatus.tonight,
          _ => HabitChipStatus.pending,
        };

        return DailyHabit(
          id: map['id'] as String,
          title: map['title'] as String,
          subtitle: map['subtitle'] as String,
          isCompleted: isCompleted,
          status: isCompleted ? HabitChipStatus.done : status,
          orderIndex: map['orderIndex'] as int? ?? 0,
        );
      }).toList();
      _inMemoryHabits = dbHabits;
      return dbHabits;
    } catch (_) {
      return _inMemoryHabits!;
    }
  }

  @override
  Future<void> toggleHabit(String id) async {
    if (_inMemoryHabits != null) {
      final index = _inMemoryHabits!.indexWhere((h) => h.id == id);
      if (index != -1) {
        final h = _inMemoryHabits![index];
        final nextDone = !h.isCompleted;
        _inMemoryHabits![index] = h.copyWith(
          isCompleted: nextDone,
          status: nextDone ? HabitChipStatus.done : HabitChipStatus.pending,
        );
      }
    }

    try {
      final db = await _dbHelper.database.timeout(const Duration(milliseconds: 250));
      final results = await db.query(
        'daily_habits',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (results.isNotEmpty) {
        final current = (results.first['isCompleted'] as int? ?? 0) == 1;
        final newCompleted = !current;
        final newStatus = newCompleted ? 'done' : 'pending';

        await db.update(
          'daily_habits',
          {
            'isCompleted': newCompleted ? 1 : 0,
            'status': newStatus,
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    } catch (_) {
      // In-memory or test fallback
    }
  }
}
