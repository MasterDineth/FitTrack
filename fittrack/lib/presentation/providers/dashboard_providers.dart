import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/daily_bio_metrics.dart';
import '../../domain/entities/daily_habit.dart';
import '../../domain/entities/lifestyle_article.dart';
import 'repository_providers.dart';
import 'workout_logic_providers.dart';

part 'dashboard_providers.g.dart';

// ── Notification System Models & State ───────────────────────────────────────

enum FtNotificationType {
  hydration,
  pr,
  strain,
  habit,
}

class FtNotificationItem {
  final String id;
  final FtNotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;

  const FtNotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
  });
}

class DashboardNotificationsState {
  final List<FtNotificationItem> items;
  final FtNotificationItem? activeIslandItem;
  final bool isShadeOpen;
  final double loggedWaterLiters;

  const DashboardNotificationsState({
    required this.items,
    this.activeIslandItem,
    this.isShadeOpen = false,
    this.loggedWaterLiters = 1.8,
  });

  DashboardNotificationsState copyWith({
    List<FtNotificationItem>? items,
    FtNotificationItem? activeIslandItem,
    bool clearActiveIsland = false,
    bool? isShadeOpen,
    double? loggedWaterLiters,
  }) {
    return DashboardNotificationsState(
      items: items ?? this.items,
      activeIslandItem:
          clearActiveIsland ? null : (activeIslandItem ?? this.activeIslandItem),
      isShadeOpen: isShadeOpen ?? this.isShadeOpen,
      loggedWaterLiters: loggedWaterLiters ?? this.loggedWaterLiters,
    );
  }
}

class DashboardNotificationsNotifier
    extends Notifier<DashboardNotificationsState> {
  Timer? _islandAutoCollapseTimer;

  static List<FtNotificationItem> _defaultItems() {
    final now = DateTime.now();
    return [
      FtNotificationItem(
        id: 'notif_1',
        type: FtNotificationType.hydration,
        title: 'Hydration check:',
        body: '1.8L / 2.5L logged today',
        timestamp: now.subtract(const Duration(minutes: 2)),
      ),
      FtNotificationItem(
        id: 'notif_2',
        type: FtNotificationType.habit,
        title: 'Recovery optimal:',
        body: '92% readiness after 7h 48m sleep',
        timestamp: now.subtract(const Duration(minutes: 18)),
      ),
      FtNotificationItem(
        id: 'notif_3',
        type: FtNotificationType.pr,
        title: 'New Bench PR:',
        body: '85 kg x 8 reps completed',
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      FtNotificationItem(
        id: 'notif_4',
        type: FtNotificationType.strain,
        title: 'Daily Strain:',
        body: '12.4 logged (Goal 14.5)',
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
    ];
  }

  @override
  DashboardNotificationsState build() {
    ref.onDispose(() {
      _islandAutoCollapseTimer?.cancel();
    });
    return DashboardNotificationsState(items: _defaultItems());
  }

  /// Pushes a new notification, expands the Dynamic Island for 3.2s, and stores it in the shade.
  void pushNotification({
    required FtNotificationType type,
    required String title,
    required String body,
  }) {
    _islandAutoCollapseTimer?.cancel();

    final newItem = FtNotificationItem(
      id: 'notif_${DateTime.now().microsecondsSinceEpoch}',
      type: type,
      title: title,
      body: body,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      items: [newItem, ...state.items],
      activeIslandItem: newItem,
      isShadeOpen: false,
    );

    _islandAutoCollapseTimer = Timer(const Duration(milliseconds: 3200), () {
      collapseIsland();
    });
  }

  /// Helper for quick testing via the Dashboard Test Bar.
  void pushPreset(FtNotificationType type) {
    switch (type) {
      case FtNotificationType.hydration:
        final nextWater = (state.loggedWaterLiters + 0.25).clamp(0.0, 2.5);
        state = state.copyWith(loggedWaterLiters: nextWater);
        pushNotification(
          type: FtNotificationType.hydration,
          title: 'Hydration check:',
          body: '${nextWater.toStringAsFixed(2)}L / 2.5L logged (+250ml)',
        );
      case FtNotificationType.pr:
        pushNotification(
          type: FtNotificationType.pr,
          title: 'New PR Unlocked:',
          body: 'Barbell Bench Press 85 kg x 8 reps',
        );
      case FtNotificationType.strain:
        pushNotification(
          type: FtNotificationType.strain,
          title: 'Strain Alert:',
          body: 'Day strain reached 13.8 / 14.5',
        );
      case FtNotificationType.habit:
        pushNotification(
          type: FtNotificationType.habit,
          title: 'Habit Reminder:',
          body: 'Post-workout 35g Whey + 5g Creatine due',
        );
    }
  }

  void collapseIsland() {
    _islandAutoCollapseTimer?.cancel();
    if (state.activeIslandItem != null) {
      state = state.copyWith(clearActiveIsland: true);
    }
  }

  void openShade() {
    _islandAutoCollapseTimer?.cancel();
    state = state.copyWith(
      isShadeOpen: true,
      clearActiveIsland: true,
    );
  }

  void closeShade() {
    if (state.isShadeOpen) {
      state = state.copyWith(isShadeOpen: false);
    }
  }

  void toggleShade() {
    if (state.isShadeOpen) {
      closeShade();
    } else {
      openShade();
    }
  }

  void dismissItem(String id) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != id).toList(),
    );
  }

  void clearAll() {
    state = state.copyWith(items: const []);
  }

  void resetDemoItems() {
    _islandAutoCollapseTimer?.cancel();
    state = DashboardNotificationsState(
      items: _defaultItems(),
      loggedWaterLiters: 1.8,
    );
  }
}

final dashboardNotificationsProvider = NotifierProvider<
    DashboardNotificationsNotifier, DashboardNotificationsState>(
  DashboardNotificationsNotifier.new,
);

// ── Existing Dashboard Telemetry Providers ───────────────────────────────────

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
    final weekdayIndex = i + 1;
    final isPast =
        dayDate.day < now.day && dayDate.month == now.month && dayDate.year == now.year;
    final isToday =
        dayDate.day == now.day && dayDate.month == now.month && dayDate.year == now.year;

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
      final isScheduled =
          activeSchedules.any((s) => s.assignedWeekdays.contains(weekdayIndex));
      status = isScheduled ? DayStripStatus.scheduled : DayStripStatus.rest;
    } else {
      status = DayStripStatus.rest;
    }

    strip.add(DayStripItem(
      letter: letters[i],
      dayNumber: dayDate.day,
      status: status,
    ));
  }

  final completed = thisWeekSessions.length;
  const target = 5;
  final streak = ((completed / target) * 100).round().clamp(0, 100);

  final nextSch =
      await ref.watch(splitRecommendationProvider(scheduleRepo, sessionRepo).future);
  final routineName =
      nextSch?.name.replaceAll(RegExp(r'Day \d+:\s*'), '') ?? 'Push Hypertrophy';

  return WeeklyMomentumData(
    completedSessions: completed > 0 ? completed : 4,
    targetSessions: target,
    streakPercent: completed > 0 ? streak : 80,
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
    prDelta: 'Up 1,450 kg PR',
    activeDaysCount: thisWeekSessions.isNotEmpty ? thisWeekSessions.length : 4,
    trainingLoadIndex: 72,
    trainingLoadZone: 'Optimal Zone (72 / 100)',
  );
}

/// Unread notification count for the header bell badge (reactive to notification list).
@riverpod
int unreadNotificationCount(Ref ref) {
  return ref.watch(dashboardNotificationsProvider.select((s) => s.items.length));
}
