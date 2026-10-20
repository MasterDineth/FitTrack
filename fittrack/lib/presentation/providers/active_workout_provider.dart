import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/live_workout_snapshot.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/exercise_catalog.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/set_log.dart';
import '../../domain/entities/workout_session.dart';
import 'repository_providers.dart';
import 'schedules_provider.dart';
import 'workout_logic_providers.dart';
import 'notification_service_provider.dart';

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
  })  : liveWeightKg = scheduleExercise.targetWeightKg,
        liveReps = scheduleExercise.targetReps,
        totalSets = scheduleExercise.targetSets {
    for (int i = 0; i < totalSets; i++) {
      setWeights[i] = scheduleExercise.targetWeightKg;
      setReps[i] = scheduleExercise.targetReps;
    }
  }

  final ScheduleExercise scheduleExercise;
  final Exercise exercise;
  double liveWeightKg;
  int liveReps;
  int totalSets; // may grow if "+ Set" tapped
  final Map<int, double> setWeights = {};
  final Map<int, int> setReps = {};

  double weightForSet(int setIndex) =>
      setWeights[setIndex] ?? liveWeightKg;

  int repsForSet(int setIndex) =>
      setReps[setIndex] ?? liveReps;

  void setWeightForSet(int setIndex, double weight) {
    setWeights[setIndex] = weight;
    liveWeightKg = weight;
  }

  void setRepsForSet(int setIndex, int reps) {
    setReps[setIndex] = reps;
    liveReps = reps;
  }

  // Convenience getters
  String get exerciseId => exercise.id;
  String get name => exercise.name;
  int get targetReps => scheduleExercise.targetReps;
  double get targetWeightKg => scheduleExercise.targetWeightKg;
  int get restDurationSeconds => scheduleExercise.restDurationSeconds;
}

// ── State ─────────────────────────────────────────────────────────────────────

enum WorkoutPhase { loading, active, resting, paused, finished, discarded, error }

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
    this.skippedExerciseIds = const {},
    this.errorMessage,
    // ── Phase 2 additions ────────────────────────────────────────────────────
    this.lastSavedSessionId,
    this.sessionStartedAt,
    this.pausedAccumulatedSeconds = 0,
    this.pausedAt,
    this.restEndsAt,
  });

  final WorkoutPhase phase;
  final Schedule schedule;
  final List<LiveExerciseEntry> entries;
  final int currentExerciseIndex;
  final int currentSetIndex;
  final int elapsedSeconds;
  final int restRemainingSeconds;
  final List<CompletedSetEntry> completedSets;
  final Set<String> skippedExerciseIds;
  final String? errorMessage;

  // ── Phase 2 fields ─────────────────────────────────────────────────────────

  /// Session UUID, populated only after the DB write succeeds.
  final String? lastSavedSessionId;

  /// Wall-clock time the session started (not null while a session is live).
  final DateTime? sessionStartedAt;

  /// Seconds of paused time already accumulated (excluding the current pause
  /// segment if currently paused).
  final int pausedAccumulatedSeconds;

  /// When the current pause segment started (null if not paused).
  final DateTime? pausedAt;

  /// Absolute time the rest period ends (null when not resting).
  final DateTime? restEndsAt;

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

  String get formattedElapsed => elapsedFormatted;

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

  /// Past entries (completed or skipped).
  List<LiveExerciseEntry> get pastEntries =>
      currentExerciseIndex > 0
          ? entries.sublist(0, currentExerciseIndex)
          : [];

  bool isSkipped(String exerciseId) => skippedExerciseIds.contains(exerciseId);

  ActiveWorkoutState copyWith({
    WorkoutPhase? phase,
    Schedule? schedule,
    List<LiveExerciseEntry>? entries,
    int? currentExerciseIndex,
    int? currentSetIndex,
    int? elapsedSeconds,
    int? restRemainingSeconds,
    List<CompletedSetEntry>? completedSets,
    Set<String>? skippedExerciseIds,
    String? errorMessage,
    // Phase 2
    Object? lastSavedSessionId = _sentinel,
    Object? sessionStartedAt = _sentinel,
    int? pausedAccumulatedSeconds,
    Object? pausedAt = _sentinel,
    Object? restEndsAt = _sentinel,
  }) => ActiveWorkoutState(
    phase: phase ?? this.phase,
    schedule: schedule ?? this.schedule,
    entries: entries ?? this.entries,
    currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
    currentSetIndex: currentSetIndex ?? this.currentSetIndex,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    restRemainingSeconds: restRemainingSeconds ?? this.restRemainingSeconds,
    completedSets: completedSets ?? this.completedSets,
    skippedExerciseIds: skippedExerciseIds ?? this.skippedExerciseIds,
    errorMessage: errorMessage ?? this.errorMessage,
    lastSavedSessionId: lastSavedSessionId == _sentinel
        ? this.lastSavedSessionId
        : lastSavedSessionId as String?,
    sessionStartedAt: sessionStartedAt == _sentinel
        ? this.sessionStartedAt
        : sessionStartedAt as DateTime?,
    pausedAccumulatedSeconds:
        pausedAccumulatedSeconds ?? this.pausedAccumulatedSeconds,
    pausedAt: pausedAt == _sentinel ? this.pausedAt : pausedAt as DateTime?,
    restEndsAt:
        restEndsAt == _sentinel ? this.restEndsAt : restEndsAt as DateTime?,
  );
}

/// Sentinel used in [ActiveWorkoutState.copyWith] to distinguish null from
/// "keep existing value" for nullable fields.
const Object _sentinel = Object();

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

  Future<void> startWorkout(String scheduleId, {List<ScheduleExercise>? customExercises}) =>
      startSession(scheduleId, customExercises: customExercises);

  /// Restores an ongoing session from a persisted [LiveWorkoutSnapshot]
  /// after app cold restart.
  Future<void> restoreFromSnapshot(LiveWorkoutSnapshot snapshot) async {
    await startSession(snapshot.scheduleId);

    final now = DateTime.now();
    WorkoutPhase restoredPhase;
    switch (snapshot.phase) {
      case 'resting':
        restoredPhase = WorkoutPhase.resting;
      case 'paused':
        restoredPhase = WorkoutPhase.paused;
      default:
        restoredPhase = WorkoutPhase.active;
    }

    DateTime? effectiveRestEndsAt = snapshot.restEndsAt;
    int remainingRest = 0;
    if (restoredPhase == WorkoutPhase.resting && effectiveRestEndsAt != null) {
      if (effectiveRestEndsAt.isBefore(now)) {
        // Rest period finished while backgrounded -> advance to active
        restoredPhase = WorkoutPhase.active;
        effectiveRestEndsAt = null;
        remainingRest = 0;
      } else {
        remainingRest =
            effectiveRestEndsAt.difference(now).inSeconds.clamp(0, 600);
      }
    }

    final targetExerciseIndex = snapshot.finishedExercises.clamp(
      0,
      state.entries.isEmpty ? 0 : state.entries.length - 1,
    );
    final targetSetIndex = (snapshot.setNumber - 1).clamp(
      0,
      state.entries.isEmpty || targetExerciseIndex >= state.entries.length
          ? 0
          : (state.entries[targetExerciseIndex].totalSets - 1).clamp(0, 99),
    );

    state = state.copyWith(
      phase: restoredPhase,
      currentExerciseIndex: targetExerciseIndex,
      currentSetIndex: targetSetIndex,
      elapsedSeconds: snapshot.elapsedSecondsAt(now),
      restRemainingSeconds: remainingRest,
      restEndsAt: effectiveRestEndsAt,
      sessionStartedAt: snapshot.sessionStartedAt,
      pausedAccumulatedSeconds: snapshot.pausedAccumulatedSeconds,
      pausedAt: snapshot.pausedAt,
    );

    if (restoredPhase == WorkoutPhase.resting) {
      _startRestTimer();
    }
    if (restoredPhase != WorkoutPhase.paused) {
      _startStopwatch();
    }
  }

  Future<void> startSession(String scheduleId, {List<ScheduleExercise>? customExercises}) async {
    try {
      final scheduleRepo = ref.read(scheduleRepositoryProvider);
      final exerciseRepo = ref.read(exerciseRepositoryProvider);

      Schedule? schedule = await scheduleRepo.getScheduleById(scheduleId);
      List<ScheduleExercise> scheduleExercises = [];

      if (customExercises != null && customExercises.isNotEmpty) {
        scheduleExercises = List.from(customExercises);
      }

      if (schedule == null) {
        // Fallback: search schedulesProvider for predefined / in-memory schedules
        final schedulesState = ref.read(schedulesProvider);
        final ws = schedulesState.allSchedules
            .where((s) => s.id == scheduleId)
            .firstOrNull;
        if (ws != null) {
          schedule = Schedule(
            id: ws.id,
            name: ws.title,
            description: ws.description,
            targetMuscles: ws.targetMuscles.isNotEmpty
                ? ws.targetMuscles
                : [ws.focus],
            assignedWeekdays: List.generate(
              ws.daysPerWeek.clamp(1, 7),
              (i) => i + 1,
            ),
            orderIndex: 0,
          );
          if (scheduleExercises.isEmpty) {
            scheduleExercises = ws.exercises;
          }
        }
      } else if (scheduleExercises.isEmpty) {
        scheduleExercises =
            await scheduleRepo.getScheduleExercises(scheduleId);
      }

      if (schedule == null) {
        state = state.copyWith(
          phase: WorkoutPhase.error,
          errorMessage: 'Schedule not found.',
        );
        return;
      }

      if (scheduleExercises.isEmpty) {
        scheduleExercises = _fallbackScheduleExercises(schedule.id);
      }

      final entries = <LiveExerciseEntry>[];
      for (final se in scheduleExercises) {
        var exercise = await exerciseRepo.getExerciseById(se.exerciseId);
        exercise ??= Exercise(
          id: se.exerciseId,
          name: _resolveExerciseName(se.exerciseId),
          equipment: _resolveEquipment(se.exerciseId),
          movementClassification: MovementClassification.compound,
        );
        entries.add(LiveExerciseEntry(
          scheduleExercise: se,
          exercise: exercise,
        ));
      }

      final startTime = DateTime.now();
      _sessionStartTime = startTime;

      state = ActiveWorkoutState(
        phase: WorkoutPhase.active,
        schedule: schedule,
        entries: entries,
        currentExerciseIndex: 0,
        currentSetIndex: 0,
        elapsedSeconds: 0,
        restRemainingSeconds: 0,
        completedSets: const [],
        sessionStartedAt: startTime,
        pausedAccumulatedSeconds: 0,
      );

      _startStopwatch();
    } catch (e) {
      state = state.copyWith(
        phase: WorkoutPhase.error,
        errorMessage: e.toString(),
      );
    }
  }

  static List<ScheduleExercise> _fallbackScheduleExercises(String schedId) {
    return [
      ScheduleExercise(
        id: '${schedId}_ex1',
        scheduleId: schedId,
        exerciseId: 'ex_barbell_bench_press',
        sortOrder: 1,
        targetSets: 4,
        targetReps: 8,
        targetWeightKg: 80.0,
        restDurationSeconds: 120,
      ),
      ScheduleExercise(
        id: '${schedId}_ex2',
        scheduleId: schedId,
        exerciseId: 'ex_incline_dumbbell_press',
        sortOrder: 2,
        targetSets: 3,
        targetReps: 10,
        targetWeightKg: 28.0,
        restDurationSeconds: 90,
      ),
      ScheduleExercise(
        id: '${schedId}_ex3',
        scheduleId: schedId,
        exerciseId: 'ex_cable_flyes',
        sortOrder: 3,
        targetSets: 3,
        targetReps: 12,
        targetWeightKg: 15.0,
        restDurationSeconds: 60,
      ),
    ];
  }

  static String _resolveExerciseName(String exerciseId) {
    return ExerciseCatalog.resolveName(exerciseId);
  }

  static Equipment _resolveEquipment(String exerciseId) {
    final lower = exerciseId.toLowerCase();
    if (lower.contains('dumbbell') || lower.contains('db')) return Equipment.dumbbell;
    if (lower.contains('barbell') || lower.contains('bb')) return Equipment.barbell;
    if (lower.contains('cable')) return Equipment.cable;
    if (lower.contains('bodyweight') || lower.contains('push_up') || lower.contains('pull_up')) {
      return Equipment.bodyweight;
    }
    if (lower.contains('machine')) return Equipment.machine;
    return Equipment.barbell;
  }

  // ── Stopwatch ──────────────────────────────────────────────────────────────

  void _startStopwatch() {
    _stopwatchTimer?.cancel();
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase == WorkoutPhase.active ||
          state.phase == WorkoutPhase.resting) {
        // Derive elapsed from timestamps to avoid drift when backgrounded.
        final startedAt = state.sessionStartedAt;
        if (startedAt != null) {
          final raw = DateTime.now().difference(startedAt).inSeconds;
          final elapsed =
              (raw - state.pausedAccumulatedSeconds).clamp(0, 86400);
          state = state.copyWith(elapsedSeconds: elapsed);
        } else {
          state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
        }
      }
    });
  }

  void togglePause() {
    if (state.phase == WorkoutPhase.paused) {
      resumeSession();
    } else if (state.phase == WorkoutPhase.active ||
        state.phase == WorkoutPhase.resting) {
      pauseSession();
    }
  }

  // ── Weight / Reps adjustments ──────────────────────────────────────────────

  void adjustWeight(double delta) {
    final idx = state.currentExerciseIndex;
    if (idx >= state.entries.length) return;
    final entry = state.entries[idx];
    final currentSet = state.currentSetIndex;
    final currentWeight = entry.weightForSet(currentSet);
    final newWeight = (currentWeight + delta).clamp(0.0, 999.0);
    entry.setWeightForSet(currentSet, newWeight);
    state = state.copyWith(entries: List.from(state.entries));
  }

  void adjustReps(int delta) {
    final idx = state.currentExerciseIndex;
    if (idx >= state.entries.length) return;
    final entry = state.entries[idx];
    final currentSet = state.currentSetIndex;
    final currentReps = entry.repsForSet(currentSet);
    final newReps = (currentReps + delta).clamp(1, 999);
    entry.setRepsForSet(currentSet, newReps);
    state = state.copyWith(entries: List.from(state.entries));
  }

  void addSet() {
    final idx = state.currentExerciseIndex;
    if (idx >= state.entries.length) return;
    final entry = state.entries[idx];
    final newSetIndex = entry.totalSets;
    entry.totalSets++;
    final prevWeight = entry.weightForSet(newSetIndex - 1);
    final prevReps = entry.repsForSet(newSetIndex - 1);
    entry.setWeights[newSetIndex] = prevWeight;
    entry.setReps[newSetIndex] = prevReps;
    state = state.copyWith(entries: List.from(state.entries));
  }

  // ── Complete Set ───────────────────────────────────────────────────────────

  void completeSet() {
    final entry = state.currentEntry;
    if (entry == null) return;

    final currentSet = state.currentSetIndex;
    final actualWeight = entry.weightForSet(currentSet);
    final actualReps = entry.repsForSet(currentSet);

    final completed = CompletedSetEntry(
      scheduleExerciseId: entry.scheduleExercise.id,
      exerciseId: entry.exerciseId,
      setNumber: currentSet + 1,
      actualReps: actualReps,
      actualWeightKg: actualWeight,
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

    // Start rest timer — compute restEndsAt from absolute time.
    final restDuration = entry.restDurationSeconds;
    final restEndsAt = DateTime.now().add(Duration(seconds: restDuration));
    state = state.copyWith(
      phase: WorkoutPhase.resting,
      restRemainingSeconds: restDuration,
      completedSets: updatedSets,
      restEndsAt: restEndsAt,
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
      // Derive remaining from restEndsAt to avoid drift.
      final restEndsAt = state.restEndsAt;
      if (restEndsAt != null) {
        final remaining = restEndsAt.difference(DateTime.now()).inSeconds;
        if (remaining <= 0) {
          _restTimer?.cancel();
          _advanceAfterRest();
        } else {
          state = state.copyWith(restRemainingSeconds: remaining);
        }
      } else {
        final remaining = state.restRemainingSeconds - 1;
        if (remaining <= 0) {
          _restTimer?.cancel();
          _advanceAfterRest();
        } else {
          state = state.copyWith(restRemainingSeconds: remaining);
        }
      }
    });
  }

  void adjustRestTime(int deltaSeconds) {
    // Move restEndsAt by delta (clamp remaining to 0–600 s from now).
    final now = DateTime.now();
    final restEndsAt = state.restEndsAt ?? now;
    final newEnd = restEndsAt.add(Duration(seconds: deltaSeconds));
    final minEnd = now;
    final maxEnd = now.add(const Duration(seconds: 600));
    final clamped = newEnd.isBefore(minEnd)
        ? minEnd
        : newEnd.isAfter(maxEnd)
            ? maxEnd
            : newEnd;
    final newRemaining = clamped.difference(now).inSeconds.clamp(0, 600);
    state = state.copyWith(
      restRemainingSeconds: newRemaining,
      restEndsAt: clamped,
    );
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
      nextEntry.liveWeightKg = nextEntry.weightForSet(0);
      nextEntry.liveReps = nextEntry.repsForSet(0);

      state = state.copyWith(
        phase: WorkoutPhase.active,
        currentExerciseIndex: nextExerciseIndex,
        currentSetIndex: 0,
        restRemainingSeconds: 0,
        restEndsAt: null,
        entries: List.from(state.entries),
      );
    } else {
      final nextSet = state.currentSetIndex + 1;
      // Inherit previous set's weight if not yet set
      if (!entry.setWeights.containsKey(nextSet)) {
        entry.setWeights[nextSet] = entry.weightForSet(state.currentSetIndex);
      }
      entry.liveWeightKg = entry.weightForSet(nextSet);
      entry.liveReps = entry.repsForSet(nextSet);

      state = state.copyWith(
        phase: WorkoutPhase.active,
        currentSetIndex: nextSet,
        restRemainingSeconds: 0,
        restEndsAt: null,
        entries: List.from(state.entries),
      );
    }
  }

  // ── Skip Exercise ──────────────────────────────────────────────────────────

  void skipExercise({String? reason}) {
    _restTimer?.cancel();
    final entry = state.currentEntry;
    final updatedSkipped = Set<String>.from(state.skippedExerciseIds);
    if (entry != null) {
      if (reason != null) {
        _skipReasons[entry.exerciseId] = reason;
      }
      updatedSkipped.add(entry.exerciseId);
    }
    final nextIndex = state.currentExerciseIndex + 1;
    if (nextIndex >= state.entries.length) {
      _cancelTimers();
      state = state.copyWith(
        phase: WorkoutPhase.finished,
        skippedExerciseIds: updatedSkipped,
      );
      _persistSession(state.completedSets);
      return;
    }
    final nextEntry = state.entries[nextIndex];
    nextEntry.liveWeightKg = nextEntry.weightForSet(0);
    nextEntry.liveReps = nextEntry.repsForSet(0);

    state = state.copyWith(
      phase: WorkoutPhase.active,
      currentExerciseIndex: nextIndex,
      currentSetIndex: 0,
      restRemainingSeconds: 0,
      skippedExerciseIds: updatedSkipped,
      entries: List.from(state.entries),
    );
  }

  // ── Pause / Resume ─────────────────────────────────────────────────────────

  void pauseSession() {
    if (state.phase == WorkoutPhase.active ||
        state.phase == WorkoutPhase.resting) {
      _cancelTimers();
      state = state.copyWith(
        phase: WorkoutPhase.paused,
        pausedAt: DateTime.now(),
      );
    }
  }

  void resumeSession() {
    if (state.phase == WorkoutPhase.paused) {
      final now = DateTime.now();
      final pausedAt = state.pausedAt;
      final additionalPausedSecs =
          pausedAt != null ? now.difference(pausedAt).inSeconds : 0;
      final newAccumulated =
          (state.pausedAccumulatedSeconds + additionalPausedSecs).clamp(0, 86400);

      // Shift restEndsAt forward by the paused duration so the countdown is accurate.
      DateTime? newRestEndsAt = state.restEndsAt;
      if (newRestEndsAt != null && pausedAt != null) {
        newRestEndsAt =
            newRestEndsAt.add(Duration(seconds: now.difference(pausedAt).inSeconds));
      }

      // Determine which phase to restore
      final wasResting = newRestEndsAt != null &&
          newRestEndsAt.isAfter(now);

      state = state.copyWith(
        phase: wasResting ? WorkoutPhase.resting : WorkoutPhase.active,
        pausedAccumulatedSeconds: newAccumulated,
        pausedAt: null,
        restEndsAt: newRestEndsAt,
      );

      if (wasResting) {
        _startRestTimer();
      }
      _startStopwatch();
    }
  }

  // ── Stop / Finish Session ──────────────────────────────────────────────────

  /// Discards the current session, clearing progress without saving to history.
  void discardWorkout() => discardSession();

  /// Cancels timers and terminates the session immediately without saving to history.
  /// Only clears the progress of the current session.
  void discardSession() {
    _cancelTimers();
    _sessionStartTime = null;
    _skipReasons.clear();
    try {
      ref.read(liveSnapshotStoreProvider).clear();
      ref.read(notificationServiceProvider).clearLive();
    } catch (_) {}
    state = const ActiveWorkoutState(
      phase: WorkoutPhase.discarded,
      schedule: Schedule(
        id: '',
        name: '',
        description: '',
        targetMuscles: [],
        assignedWeekdays: [],
        orderIndex: 0,
      ),
      entries: [],
      elapsedSeconds: 0,
      restRemainingSeconds: 0,
      currentExerciseIndex: 0,
      currentSetIndex: 0,
      completedSets: [],
      skippedExerciseIds: {},
    );
    ref.read(sessionsRevisionProvider.notifier).bump();
  }

  /// Resets the active workout state completely to a clean, discarded state.
  void resetSession() {
    _cancelTimers();
    _sessionStartTime = null;
    _skipReasons.clear();
    try {
      ref.read(liveSnapshotStoreProvider).clear();
      ref.read(notificationServiceProvider).clearLive();
    } catch (_) {}
    state = const ActiveWorkoutState(
      phase: WorkoutPhase.discarded,
      schedule: Schedule(
        id: '',
        name: '',
        description: '',
        targetMuscles: [],
        assignedWeekdays: [],
        orderIndex: 0,
      ),
      entries: [],
      elapsedSeconds: 0,
      restRemainingSeconds: 0,
      currentExerciseIndex: 0,
      currentSetIndex: 0,
      completedSets: [],
      skippedExerciseIds: {},
    );
  }

  Future<void> stopSession() async {
    _cancelTimers();
    try {
      ref.read(liveSnapshotStoreProvider).clear();
      ref.read(notificationServiceProvider).clearLive();
    } catch (_) {}
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
      final startTime = _sessionStartTime ?? endTime;
      final duration = endTime
          .difference(startTime)
          .inSeconds;

      // Compute aggregate stats
      final totalReps = sets.fold(0, (sum, s) => sum + s.actualReps);
      final totalVolumeKg =
          sets.fold(0.0, (sum, s) => sum + s.actualWeightKg * s.actualReps);

      final session = WorkoutSession(
        id: sessionId,
        scheduleId: state.schedule.id,
        startTime: startTime,
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

      if (state.schedule.id.isNotEmpty) {
        try {
          await ref
              .read(scheduleRepositoryProvider)
              .incrementCompletionCount(state.schedule.id);
          ref.read(schedulesProvider.notifier).loadFromDatabase();
        } catch (_) {}
      }

      // Store the session ID in state so the completion notification can
      // deep-link to the correct history detail screen (§2.3 of the spec).
      state = state.copyWith(lastSavedSessionId: sessionId);

      ref.read(sessionsRevisionProvider.notifier).bump();
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
