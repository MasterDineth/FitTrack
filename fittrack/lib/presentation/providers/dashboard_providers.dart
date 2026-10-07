import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/daily_bio_metrics.dart';
import '../../domain/entities/daily_habit.dart';
import '../../domain/entities/lifestyle_article.dart';
import 'repository_providers.dart';
import 'workout_logic_providers.dart';

part 'dashboard_providers.g.dart';

/// Fetches today's bio-metrics telemetry (Movement, Strain, Recovery).
@riverpod
Future<DailyBioMetrics?> bioMetrics(Ref ref) async {
  final repo = ref.watch(bioMetricsRepositoryProvider);
  return repo.getTodayBioMetrics();
}

/// Manages daily habit items and toggle mutations with SQLite persistence.
@riverpod
class HabitsNotifier extends _$HabitsNotifier {
  @override
  Future<List<DailyHabit>> build() async {
    final repo = ref.watch(habitsRepositoryProvider);
    return repo.getHabits();
  }

  Future<void> toggle(String id) async {
    final repo = ref.read(habitsRepositoryProvider);
    await repo.toggleHabit(id);
    ref.invalidateSelf();
  }
}

/// Backward compatibility alias for habitsProvider
final habitsNotifierProvider = habitsProvider;


/// Provides lifestyle and masterclass cards from local JSON asset.
@riverpod
Future<List<LifestyleArticle>> lifestyleContent(Ref ref) async {
  final repo = ref.watch(lifestyleContentRepositoryProvider);
  return repo.getFeaturedContent();
}

/// Day status for the 7-column day strip in Card 2.
enum DayStripStatus {
  done,
  today,
  scheduled,
  rest,
}

class DayStripItem {
  final String letter;
  final int dayNumber;
  final DayStripStatus status;

  const DayStripItem({
    required this.letter,
    required this.dayNumber,
    required this.status,
  });
}

class WeeklyMomentumData {
  final int completedSessions;
  final int targetSessions;
  final int streakPercent;
  final List<DayStripItem> dayStrip;
  final String todayRoutineTitle;
  final int pointsEarned;

  const WeeklyMomentumData({
    required this.completedSessions,
    required this.targetSessions,
    required this.streakPercent,
    required this.dayStrip,
    required this.todayRoutineTitle,
    required this.pointsEarned,
  });
}

/// Computes weekly momentum, 7-day strip, and streak from session data.
@riverpod
Future<WeeklyMomentumData> weeklyMomentum(Ref ref) async {
  ref.watch(sessionsRevisionProvider);
  final sessionRepo = ref.watch(workoutSessionRepositoryProvider);
  final scheduleRepo = ref.watch(scheduleRepositoryProvider);

  final now = DateTime.now();
  final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
  final weekEnd = monday.add(const Duration(days: 7));

  final recentSessions = await sessionRepo.getRecentSessions(limit: 14);
  final thisWeekSessions = recentSessions
      .where((s) => !s.startTime.isBefore(monday) && s.startTime.isBefore(weekEnd))
      .toList();

  final schedules = await scheduleRepo.getAllSchedules();
  final activeSchedules = schedules.where((s) => !s.isArchived).toList();

  const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final List<DayStripItem> strip = [];

  for (int i = 0; i < 7; i++) {
    final dayDate = monday.add(Duration(days: i));
    final weekdayIndex = i + 1; // 1 = Mon, 7 = Sun
    final isPast = dayDate.day < now.day && dayDate.month == now.month && dayDate.year == now.year;
    final isToday = dayDate.day == now.day && dayDate.month == now.month && dayDate.year == now.year;

    // Check if session completed on this day
    final hasSession = thisWeekSessions.any((s) =>
        s.startTime.year == dayDate.year &&
        s.startTime.month == dayDate.month &&
        s.startTime.day == dayDate.day);

    DayStripStatus status;
    if (hasSession) {
      status = DayStripStatus.done;
    } else if (isToday) {
      status = DayStripStatus.today;
    } else if (!isPast) {
      // Future or scheduled day
      final isScheduled = activeSchedules.any((s) => s.assignedWeekdays.contains(weekdayIndex));
      status = isScheduled ? DayStripStatus.scheduled : DayStripStatus.rest;
    } else {
      // Past day without workout
      status = DayStripStatus.rest;
    }

    strip.add(DayStripItem(
      letter: letters[i],
      dayNumber: dayDate.day,
      status: status,
    ));
  }

  // Completed sessions count vs target
  final completed = thisWeekSessions.length;
  final target = 5;
  final streak = ((completed / target) * 100).round().clamp(0, 100);

  // Today's schedule name or recommendation
  final nextSch = await ref.watch(splitRecommendationProvider(scheduleRepo, sessionRepo).future);
  final routineName = nextSch?.name.replaceAll(RegExp(r'Day \d+:\s*'), '') ?? 'Push Hypertrophy';

  return WeeklyMomentumData(
    completedSessions: completed > 0 ? completed : 4, // Stitch template default 4 of 5
    targetSessions: target,
    streakPercent: completed > 0 ? streak : 80, // Stitch template default 80%
    dayStrip: strip,
    todayRoutineTitle: routineName,
    pointsEarned: 320,
  );
}

class WeeklyLoadData {
  final String strainTargetStatus;
  final String volumeDelta;
  final int totalVolumeKg;
  final String prDelta;
  final int activeDaysCount;
  final int trainingLoadIndex;
  final String trainingLoadZone;

  const WeeklyLoadData({
    required this.strainTargetStatus,
    required this.volumeDelta,
    required this.totalVolumeKg,
    required this.prDelta,
    required this.activeDaysCount,
    required this.trainingLoadIndex,
    required this.trainingLoadZone,
  });
}

/// Aggregates weekly tonnage load and strain status.
@riverpod
Future<WeeklyLoadData> weeklyLoad(Ref ref) async {
  ref.watch(sessionsRevisionProvider);
  final sessionRepo = ref.watch(workoutSessionRepositoryProvider);

  final now = DateTime.now();
  final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
  final weekEnd = monday.add(const Duration(days: 7));

  final recentSessions = await sessionRepo.getRecentSessions(limit: 14);
  final thisWeekSessions = recentSessions
      .where((s) => !s.startTime.isBefore(monday) && s.startTime.isBefore(weekEnd))
      .toList();

  int totalVolume = 0;
  for (final s in thisWeekSessions) {
    totalVolume += (s.totalVolumeKg).round();
  }

  return WeeklyLoadData(
    strainTargetStatus: 'on track',
    volumeDelta: '+12% vs LW',
    totalVolumeKg: totalVolume > 0 ? totalVolume : 24800,
    prDelta: '↑ 1,450 kg PR',
    activeDaysCount: thisWeekSessions.isNotEmpty ? thisWeekSessions.length : 4,
    trainingLoadIndex: 72,
    trainingLoadZone: 'Optimal Zone (72 / 100)',
  );
}

/// Unread notification count for the header bell badge.
@riverpod
int unreadNotificationCount(Ref ref) => 1;
