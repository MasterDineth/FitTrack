import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/workout_session.dart';

part 'workout_history_provider.g.dart';

// ── Filter enum ───────────────────────────────────────────────────────────────

enum HistoryFilter { all, thisWeek, thisMonth }

// ── History state ─────────────────────────────────────────────────────────────

class WorkoutHistoryState {
  const WorkoutHistoryState({
    required this.allSessions,
    required this.filter,
  });

  final List<WorkoutSession> allSessions;
  final HistoryFilter filter;

  List<WorkoutSession> get filtered {
    final now = DateTime.now();
    switch (filter) {
      case HistoryFilter.all:
        return allSessions;
      case HistoryFilter.thisWeek:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final start =
            DateTime(weekStart.year, weekStart.month, weekStart.day);
        return allSessions
            .where((s) => s.startTime.isAfter(start))
            .toList();
      case HistoryFilter.thisMonth:
        final start = DateTime(now.year, now.month);
        return allSessions
            .where((s) => s.startTime.isAfter(start))
            .toList();
    }
  }

  int get totalWorkouts => filtered.length;

  int get totalMinutes =>
      filtered.fold(0, (sum, s) => sum + ((s.durationSeconds ?? 0) ~/ 60));

  int get totalCalories =>
      filtered.fold(0, (sum, s) => sum + (s.totalCalories ?? 0));
}

// ── Notifier ─────────────────────────────────────────────────────────────────

@riverpod
class WorkoutHistoryNotifier extends _$WorkoutHistoryNotifier {
  @override
  WorkoutHistoryState build() {
    return WorkoutHistoryState(
      allSessions: _mockSessions(),
      filter: HistoryFilter.all,
    );
  }

  void setFilter(HistoryFilter f) {
    state = WorkoutHistoryState(
      allSessions: state.allSessions,
      filter: f,
    );
  }

  /// Prepend a newly finished session (called from WorkoutSummaryScreen).
  void addSession(WorkoutSession session) {
    final updated = [session, ...state.allSessions];
    state = WorkoutHistoryState(
      allSessions: updated,
      filter: state.filter,
    );
  }

  // ── Rich mock data ─────────────────────────────────────────────────────────

  static List<WorkoutSession> _mockSessions() {
    final now = DateTime.now();
    final sessions = <WorkoutSession>[];

    // Helper to create a session N days ago
    WorkoutSession make({
      required int daysAgo,
      required String scheduleId,
      required String scheduleName,
      required int durationMinutes,
      required int calories,
      required int sets,
      required int reps,
      required double volumeKg,
      String intensity = 'Moderate',
      String? notes,
    }) {
      final start = now.subtract(Duration(days: daysAgo, hours: 8));
      return WorkoutSession(
        id: 'mock_${daysAgo}_$scheduleId',
        scheduleId: scheduleId,
        startTime: start,
        endTime: start.add(Duration(minutes: durationMinutes)),
        durationSeconds: durationMinutes * 60,
        totalCalories: calories,
        intensity: intensity,
        notes: notes,
        totalSets: sets,
        totalReps: reps,
        totalVolumeKg: volumeKg,
      );
    }

    // Two weeks of training, Day1/Day2/Day3 rotation
    final schedule = [
      (id: 'sch1', name: 'Day 1 – Chest, Shoulders & Triceps', dur: 48, cal: 380, sets: 21, reps: 189, vol: 6840.0, intensity: 'Intense'),
      (id: 'sch2', name: 'Day 2 – Back & Biceps', dur: 44, cal: 330, sets: 18, reps: 162, vol: 5920.0, intensity: 'Moderate'),
      (id: 'sch3', name: 'Day 3 – Legs & Posterior Chain', dur: 55, cal: 490, sets: 20, reps: 200, vol: 9800.0, intensity: 'Extreme'),
    ];

    final daysPattern = [1, 3, 5, 8, 10, 12, 14];
    for (var i = 0; i < daysPattern.length; i++) {
      final s = schedule[i % 3];
      sessions.add(make(
        daysAgo: daysPattern[i],
        scheduleId: s.id,
        scheduleName: s.name,
        durationMinutes: s.dur + (i % 3 == 0 ? 2 : -2),
        calories: s.cal,
        sets: s.sets,
        reps: s.reps,
        volumeKg: s.vol,
        intensity: s.intensity,
        notes: i == 0 ? 'Felt great — hit a new bench PR today!' : null,
      ));
    }

    // Sort newest first
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions;
  }
}

// ── Convenience provider: single session by id ────────────────────────────────

@riverpod
WorkoutSession? workoutSessionById(Ref ref, String id) {
  final state = ref.watch(workoutHistoryProvider);
  try {
    return state.allSessions.firstWhere((s) => s.id == id);
  } catch (_) {
    return null;
  }
}
