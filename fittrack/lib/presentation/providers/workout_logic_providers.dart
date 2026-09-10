import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/schedule_exercise.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/repositories/i_schedule_repository.dart';
import '../../domain/repositories/i_workout_session_repository.dart';

part 'workout_logic_providers.g.dart';

@riverpod
int durationCalculation(DurationCalculationRef ref, List<ScheduleExercise> exercises) {
  if (exercises.isEmpty) return 0;
  
  int totalDuration = 0;
  for (final ex in exercises) {
    if (ex.targetSets <= 0) continue;
    // Static formula: (sets * 60s) + (sets - 1) * restSeconds + 90s transition buffer
    totalDuration += (ex.targetSets * 60) + ((ex.targetSets - 1) * ex.restDurationSeconds) + 90;
  }
  return totalDuration;
}

@riverpod
Future<Schedule?> splitRecommendation(SplitRecommendationRef ref, IScheduleRepository scheduleRepo, IWorkoutSessionRepository sessionRepo) async {
  // Logic: Compare completed sessions this week against the Monday anchor. 
  // If 0 completed, recommend Day 1; if Day N was completed, recommend Day N+1; if all completed, return a Rest state (null).
  final sessions = await sessionRepo.getAllSessions();
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final weekSessions = sessions.where((s) {
    final sessionStart = s.startTime;
    return sessionStart.isAfter(startOfWeek) || sessionStart.isAtSameMomentAs(startOfWeek);
  }).toList();

  final schedules = await scheduleRepo.getAllSchedules();
  final unarchivedSchedules = schedules.where((s) => !s.isArchived).toList();
  unarchivedSchedules.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

  if (unarchivedSchedules.isEmpty) return null;

  if (weekSessions.isEmpty) {
    return unarchivedSchedules.first;
  }

  // Find the max orderIndex completed this week
  int maxCompletedIndex = 0;
  for (var session in weekSessions) {
    final sch = unarchivedSchedules.where((s) => s.id == session.scheduleId).firstOrNull;
    if (sch != null && sch.orderIndex > maxCompletedIndex) {
      maxCompletedIndex = sch.orderIndex;
    }
  }

  // Recommend next available
  final nextSchedule = unarchivedSchedules.where((s) => s.orderIndex > maxCompletedIndex).firstOrNull;
  return nextSchedule; // Returns null if all completed (Rest state)
}

@riverpod
Future<Map<String, dynamic>> dashboardMetrics(DashboardMetricsRef ref, IWorkoutSessionRepository sessionRepo) async {
  final sessions = await sessionRepo.getAllSessions();
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final weekSessions = sessions.where((s) {
    final sessionStart = s.startTime;
    return sessionStart.isAfter(startOfWeek) || sessionStart.isAtSameMomentAs(startOfWeek);
  }).toList();

  // Unique days trained this week
  final daysTrained = weekSessions.map((s) => s.startTime.weekday).toSet().length;
  
  // Total workouts completed
  final workoutsCompleted = sessions.where((s) => s.endTime != null).length;

  // Total calories
  int totalCalories = 0;
  for (var s in sessions) {
    totalCalories += (s.totalCalories ?? 0);
  }

  return {
    'daysTrainedThisWeek': daysTrained,
    'totalWorkoutsCompleted': workoutsCompleted,
    'totalCaloriesBurned': totalCalories,
  };
}

@riverpod
Future<List<DateTime>> calendarActivity(CalendarActivityRef ref, IWorkoutSessionRepository sessionRepo, DateTime month) async {
  final sessions = await sessionRepo.getAllSessions();
  
  final activeDates = sessions.where((s) {
    return s.startTime.year == month.year && s.startTime.month == month.month;
  }).map((s) => DateTime(s.startTime.year, s.startTime.month, s.startTime.day)).toSet().toList();
  
  return activeDates;
}
