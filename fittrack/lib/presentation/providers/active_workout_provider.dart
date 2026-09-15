import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/schedule.dart';
import '../../domain/entities/schedule_exercise.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/set_log.dart';
import '../../domain/entities/workout_session.dart';
import 'repository_providers.dart';

part 'active_workout_provider.g.dart';

// ── Completed set snapshot ────────────────────────────────────────────────────

class CompletedSetEntry {
  const CompletedSetEntry({
    required this.scheduleExerciseId,
    required this.exerciseId,
    required this.setNumber,
    required this.actualReps,
    required this.actualWeightKg,
    required this.targetReps,
    required this.targetWeightKg,
    required this.restDurationSeconds,
    required this.completedAt,
  });

  final String scheduleExerciseId;
  final String exerciseId;
  final int setNumber;
  final int actualReps;
  final double actualWeightKg;
  final int targetReps;
  final double targetWeightKg;
  final int restDurationSeconds;
  final DateTime completedAt;
}

// ── Mutable per-exercise entry ────────────────────────────────────────────────

class LiveExerciseEntry {
  LiveExerciseEntry({
    required this.scheduleExercise,
    required this.exercise,
    int? currentWeight,
    int? currentReps,
    int? extraSets,
  })  : liveWeightKg =
            scheduleExercise.targetWeightKg,
        liveReps = scheduleExercise.targetReps,
        totalSets = scheduleExercise.targetSets;

  final ScheduleExercise scheduleExercise;
  final Exercise exercise;
  double liveWeightKg;
  int liveReps;
  int totalSets; // may grow if "+ Set" tapped

  // Convenience getters
  String get exerciseId => exercise.id;
  String get name => exercise.name;
  int get targetReps => scheduleExercise.targetReps;
  double get targetWeightKg => scheduleExercise.targetWeightKg;
  int get restDurationSeconds => scheduleExercise.restDurationSeconds;
}

// ── State ─────────────────────────────────────────────────────────────────────

enum WorkoutPhase { loading, active, resting, paused, finished, error }

class ActiveWorkoutState {
  const ActiveWorkoutState({
    required this.phase,
    required this.schedule,
    required this.entries,
    required this.currentExerciseIndex,
    required this.currentSetIndex,
    required this.elapsedSeconds,
    required this.restRemainingSeconds,
    required this.completedSets,
    this.errorMessage,
  });

  final WorkoutPhase phase;
  final Schedule schedule;
  final List<LiveExerciseEntry> entries;
  final int currentExerciseIndex;
  final int currentSetIndex;
  final int elapsedSeconds;
  final int restRemainingSeconds;
  final List<CompletedSetEntry> completedSets;
  final String? errorMessage;

  // ── Computed ───────────────────────────────────────────────────────────────

  LiveExerciseEntry? get currentEntry =>
      currentExerciseIndex < entries.length
          ? entries[currentExerciseIndex]
          : null;

  int get totalSetCount =>
      entries.fold(0, (s, e) => s + e.totalSets);

  int get completedSetCount => completedSets.length;

  /// Rough: ~8 kcal/min of lifting at moderate intensity.
  int get estimatedCalories => ((elapsedSeconds / 60) * 8).round();

  String get elapsedFormatted {
    final m = elapsedSeconds ~/ 60;
    final s = elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get restRemainingFormatted {
    final m = restRemainingSeconds ~/ 60;
    final s = restRemainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool get isResting => phase == WorkoutPhase.resting;

  /// Upcoming entries (excluding current).
  List<LiveExerciseEntry> get upcomingEntries =>
      currentExerciseIndex + 1 < entries.length
          ? entries.sublist(currentExerciseIndex + 1)
          : [];

  ActiveWorkoutState copyWith({
    WorkoutPhase? phase,
    Schedule? schedule,
    List<LiveExerciseEntry>? entries,
    int? currentExerciseIndex,
    int? currentSetIndex,
    int? elapsedSeconds,
    int? restRemainingSeconds,
    List<CompletedSetEntry>? completedSets,
    String? errorMessage,
  }) => ActiveWorkoutState(
    phase: phase ?? this.phase,
    schedule: schedule ?? this.schedule,
    entries: entries ?? this.entries,
    currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
    currentSetIndex: currentSetIndex ?? this.currentSetIndex,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    restRemainingSeconds: restRemainingSeconds ?? this.restRemainingSeconds,
    completedSets: completedSets ?? this.completedSets,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
class ActiveWorkoutNotifier extends _$ActiveWorkoutNotifier {
  static const _uuid = Uuid();
  Timer? _stopwatchTimer;
  Timer? _restTimer;
  DateTime? _sessionStartTime;
  final Map<String, String> _skipReasons = {};

  @override
  ActiveWorkoutState build() {
    ref.onDispose(_cancelTimers);
    // Placeholder state — caller must invoke startSession().
    return ActiveWorkoutState(
      phase: WorkoutPhase.loading,
      schedule: const Schedule(
        id: '',
        name: '',
        description: '',
        targetMuscles: [],
        assignedWeekdays: [],
        orderIndex: 0,
      ),
      entries: const [],
      currentExerciseIndex: 0,
      currentSetIndex: 0,
      elapsedSeconds: 0,
      restRemainingSeconds: 0,
      completedSets: const [],
    );
  }

  // ── Session Lifecycle ──────────────────────────────────────────────────────

  Future<void> startSession(String scheduleId) async {
    try {
      final scheduleRepo = ref.read(scheduleRepositoryProvider);
      final exerciseRepo = ref.read(exerciseRepositoryProvider);

      final schedule = await scheduleRepo.getScheduleById(scheduleId);
      if (schedule == null) {
        state = state.copyWith(
          phase: WorkoutPhase.error,
          errorMessage: 'Schedule not found.',
        );
        return;
      }

      final scheduleExercises =
          await scheduleRepo.getScheduleExercises(scheduleId);

      final entries = <LiveExerciseEntry>[];
      for (final se in scheduleExercises) {
        final exercise = await exerciseRepo.getExerciseById(se.exerciseId);
        if (exercise != null) {
          entries.add(LiveExerciseEntry(
            scheduleExercise: se,
            exercise: exercise,
          ));
        }
      }

      _sessionStartTime = DateTime.now();

      state = ActiveWorkoutState(
        phase: WorkoutPhase.active,
        schedule: schedule,
        entries: entries,
        currentExerciseIndex: 0,
        currentSetIndex: 0,
        elapsedSeconds: 0,
        restRemainingSeconds: 0,
        completedSets: const [],
      );

      _startStopwatch();
    } catch (e) {
      state = state.copyWith(
        phase: WorkoutPhase.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Stopwatch ──────────────────────────────────────────────────────────────

  void _startStopwatch() {
    _stopwatchTimer?.cancel();
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase == WorkoutPhase.active ||
          state.phase == WorkoutPhase.resting) {
        state =
            state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      }
    });
  }

  void togglePause() {
    if (state.phase == WorkoutPhase.paused) {
      state = state.copyWith(phase: WorkoutPhase.active);
      _startStopwatch();
    } else if (state.phase == WorkoutPhase.active ||
        state.phase == WorkoutPhase.resting) {
      _cancelTimers();
      state = state.copyWith(phase: WorkoutPhase.paused);
    }
  }

  // ── Weight / Reps adjustments ──────────────────────────────────────────────

  void adjustWeight(double delta) {
    final idx = state.currentExerciseIndex;
    if (idx >= state.entries.length) return;
    final entry = state.entries[idx];
    entry.liveWeightKg =
        (entry.liveWeightKg + delta).clamp(0, 999);
    state = state.copyWith(entries: List.from(state.entries));
  }

  void adjustReps(int delta) {
    final idx = state.currentExerciseIndex;
    if (idx >= state.entries.length) return;
    final entry = state.entries[idx];
    entry.liveReps = (entry.liveReps + delta).clamp(1, 999);
    state = state.copyWith(entries: List.from(state.entries));
  }

  void addSet() {
    final idx = state.currentExerciseIndex;
    if (idx >= state.entries.length) return;
    state.entries[idx].totalSets++;
    state = state.copyWith(entries: List.from(state.entries));
  }

  // ── Complete Set ───────────────────────────────────────────────────────────

  void completeSet() {
    final entry = state.currentEntry;
    if (entry == null) return;

    final completed = CompletedSetEntry(
      scheduleExerciseId: entry.scheduleExercise.id,
      exerciseId: entry.exerciseId,
      setNumber: state.currentSetIndex + 1,
      actualReps: entry.liveReps,
      actualWeightKg: entry.liveWeightKg,
      targetReps: entry.targetReps,
      targetWeightKg: entry.targetWeightKg,
      restDurationSeconds: entry.restDurationSeconds,
      completedAt: DateTime.now(),
    );

    final updatedSets = [...state.completedSets, completed];

    // Is this the last set for the last exercise?
    final isLastSetOfExercise =
        state.currentSetIndex + 1 >= entry.totalSets;
    final isLastExercise =
        state.currentExerciseIndex + 1 >= state.entries.length;

    if (isLastSetOfExercise && isLastExercise) {
      // Session done — skip rest and go straight to save
      _cancelTimers();
      state = state.copyWith(
        phase: WorkoutPhase.finished,
        completedSets: updatedSets,
      );
      _persistSession(updatedSets);
      return;
    }

    // Start rest timer
    state = state.copyWith(
      phase: WorkoutPhase.resting,
      restRemainingSeconds: entry.restDurationSeconds,
      completedSets: updatedSets,
    );

    _startRestTimer();
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != WorkoutPhase.resting) {
        _restTimer?.cancel();
        return;
      }
      final remaining = state.restRemainingSeconds - 1;
      if (remaining <= 0) {
        _restTimer?.cancel();
        _advanceAfterRest();
      } else {
        state = state.copyWith(restRemainingSeconds: remaining);
      }
    });
  }

  void adjustRestTime(int deltaSeconds) {
    final newVal =
        (state.restRemainingSeconds + deltaSeconds).clamp(0, 600);
    state = state.copyWith(restRemainingSeconds: newVal);
  }

  void skipRest() {
    _restTimer?.cancel();
    _advanceAfterRest();
  }

  void _advanceAfterRest() {
    final entry = state.currentEntry;
    if (entry == null) return;

    final isLastSetOfExercise =
        state.currentSetIndex + 1 >= entry.totalSets;

    if (isLastSetOfExercise) {
      // Move to next exercise
      final nextExerciseIndex = state.currentExerciseIndex + 1;
      if (nextExerciseIndex >= state.entries.length) {
        // All done
        _cancelTimers();
        state = state.copyWith(phase: WorkoutPhase.finished);
        _persistSession(state.completedSets);
        return;
      }
      // Reset live values to new exercise defaults
      final nextEntry = state.entries[nextExerciseIndex];
      nextEntry.liveWeightKg = nextEntry.targetWeightKg;
      nextEntry.liveReps = nextEntry.targetReps;

      state = state.copyWith(
        phase: WorkoutPhase.active,
        currentExerciseIndex: nextExerciseIndex,
        currentSetIndex: 0,
        restRemainingSeconds: 0,
        entries: List.from(state.entries),
      );
    } else {
      state = state.copyWith(
        phase: WorkoutPhase.active,
        currentSetIndex: state.currentSetIndex + 1,
        restRemainingSeconds: 0,
      );
    }
  }

  // ── Skip Exercise ──────────────────────────────────────────────────────────

  void skipExercise({String? reason}) {
    _restTimer?.cancel();
    final entry = state.currentEntry;
    if (entry != null && reason != null) {
      // Record the skip reason keyed by exerciseId
      _skipReasons[entry.exerciseId] = reason;
    }
    final nextIndex = state.currentExerciseIndex + 1;
    if (nextIndex >= state.entries.length) {
      _cancelTimers();
      state = state.copyWith(phase: WorkoutPhase.finished);
      _persistSession(state.completedSets);
      return;
    }
    final nextEntry = state.entries[nextIndex];
    nextEntry.liveWeightKg = nextEntry.targetWeightKg;
    nextEntry.liveReps = nextEntry.targetReps;

    state = state.copyWith(
      phase: WorkoutPhase.active,
      currentExerciseIndex: nextIndex,
      currentSetIndex: 0,
      restRemainingSeconds: 0,
      entries: List.from(state.entries),
    );
  }

  // ── Pause / Resume ─────────────────────────────────────────────────────────

  void pauseSession() {
    if (state.phase == WorkoutPhase.active ||
        state.phase == WorkoutPhase.resting) {
      _cancelTimers();
      state = state.copyWith(phase: WorkoutPhase.paused);
    }
  }

  void resumeSession() {
    if (state.phase == WorkoutPhase.paused) {
      if (state.isResting) {
        state = state.copyWith(phase: WorkoutPhase.resting);
        _startRestTimer();
      } else {
        state = state.copyWith(phase: WorkoutPhase.active);
      }
      _startStopwatch();
    }
  }

  // ── Stop / Finish Session ──────────────────────────────────────────────────

  Future<void> stopSession() async {
    _cancelTimers();
    state = state.copyWith(phase: WorkoutPhase.finished);
    await _persistSession(state.completedSets);
  }

  /// Called from summary screen once user has entered notes/intensity.
  Future<void> finishSession({
    String? notes,
    String? intensity,
  }) async {
    _cancelTimers();
    // Mark all remaining unstarted exercises as skipped
    for (var i = state.currentExerciseIndex; i < state.entries.length; i++) {
      final exId = state.entries[i].exerciseId;
      // Don't overwrite an existing explicit skip reason
      if (!_skipReasons.containsKey(exId) &&
          !state.completedSets.any((s) => s.exerciseId == exId)) {
        _skipReasons[exId] = 'Session ended early';
      }
    }
    state = state.copyWith(phase: WorkoutPhase.finished);
    await _persistSession(
      state.completedSets,
      notes: notes,
      intensity: intensity,
    );
  }

  // ── SQLite Persistence ─────────────────────────────────────────────────────

  Future<void> _persistSession(
    List<CompletedSetEntry> sets, {
    String? notes,
    String? intensity,
  }) async {
    try {
      final repo = ref.read(workoutSessionRepositoryProvider);
      final sessionId = _uuid.v4();
      final endTime = DateTime.now();
      final duration = endTime
          .difference(_sessionStartTime ?? endTime)
          .inSeconds;

      // Compute aggregate stats
      final totalReps = sets.fold(0, (sum, s) => sum + s.actualReps);
      final totalVolumeKg =
          sets.fold(0.0, (sum, s) => sum + s.actualWeightKg * s.actualReps);

      final session = WorkoutSession(
        id: sessionId,
        scheduleId: state.schedule.id,
        startTime: _sessionStartTime ?? endTime,
        endTime: endTime,
        durationSeconds: duration,
        totalCalories: state.estimatedCalories,
        notes: notes,
        intensity: intensity,
        totalSets: sets.length,
        totalReps: totalReps,
        totalVolumeKg: totalVolumeKg,
      );

      await repo.saveSession(session);

      // Group sets by exerciseId (in order of first appearance)
      final exerciseOrder = <String>[];
      for (final s in sets) {
        if (!exerciseOrder.contains(s.exerciseId)) {
          exerciseOrder.add(s.exerciseId);
        }
      }
      // Also include exercises that were fully skipped (no sets completed)
      for (final skippedId in _skipReasons.keys) {
        if (!exerciseOrder.contains(skippedId)) {
          exerciseOrder.add(skippedId);
        }
      }

      final exerciseLogs = <ExerciseLog>[];
      for (var i = 0; i < exerciseOrder.length; i++) {
        final exId = exerciseOrder[i];
        final wasSkipped = _skipReasons.containsKey(exId);
        exerciseLogs.add(ExerciseLog(
          id: _uuid.v4(),
          sessionId: sessionId,
          exerciseId: exId,
          orderIndex: i,
          isSkipped: wasSkipped,
          skipReason: wasSkipped ? _skipReasons[exId] : null,
        ));
      }
      await repo.saveExerciseLogs(exerciseLogs);

      final setLogs = <SetLog>[];
      for (final s in sets) {
        final logId = exerciseLogs
            .firstWhere((l) => l.exerciseId == s.exerciseId)
            .id;
        setLogs.add(SetLog(
          id: _uuid.v4(),
          exerciseLogId: logId,
          setNumber: s.setNumber,
          actualReps: s.actualReps,
          targetReps: s.targetReps,
          actualWeightKg: s.actualWeightKg,
          targetWeightKg: s.targetWeightKg,
          isCompleted: true,
          restDurationSeconds: s.restDurationSeconds,
        ));
      }
      await repo.saveSetLogs(setLogs);
    } catch (_) {
      // Silently swallow — data is already in memory if needed
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _cancelTimers() {
    _stopwatchTimer?.cancel();
    _stopwatchTimer = null;
    _restTimer?.cancel();
    _restTimer = null;
  }
}
