import '../entities/daily_habit.dart';

abstract interface class IHabitsRepository {
  Future<List<DailyHabit>> getHabits();
  Future<void> toggleHabit(String id);
}
