/// Domain entity: a serialisable point-in-time snapshot of an active workout
/// session. Written to [LiveSnapshotStore] on every material change so the
/// system notification, background isolate and app UI always show the same
/// truth.
///
/// JSON round-trip is intentional (the data layer uses it for SharedPrefs
/// persistence). No Flutter imports permitted in this file.
class LiveWorkoutSnapshot {
  const LiveWorkoutSnapshot({
    required this.sessionId,
    required this.scheduleId,
    required this.scheduleName,
    required this.totalExercises,
    required this.finishedExercises,
    required this.exerciseName,
    required this.setNumber,
    required this.totalSets,
    required this.phase,
    required this.sessionStartedAt,
    required this.pausedAccumulatedSeconds,
    required this.restDurationSeconds,
    required this.updatedAt,
    this.pausedAt,
    this.restEndsAt,
  });

  /// Stable UUID for the in-progress session (set when persistence succeeds).
  final String sessionId;
  final String scheduleId;
  final String scheduleName;

  /// Total number of exercises in the schedule.
  final int totalExercises;

  /// Exercises where all sets are logged *or* the exercise was skipped.
  final int finishedExercises;

  final String exerciseName;

  /// 1-based set number within the current exercise.
  final int setNumber;

  /// Total sets for the current exercise.
  final int totalSets;

  /// Mirrors [WorkoutPhase] as a plain string so there are no Flutter deps.
  final String phase;

  /// Wall-clock time when the session actually started.
  final DateTime sessionStartedAt;

  /// Seconds already accumulated in paused segments before the last resume.
  final int pausedAccumulatedSeconds;

  /// When was the session paused (null if not currently paused).
  final DateTime? pausedAt;

  /// When the rest period ends (null when not resting).
  final DateTime? restEndsAt;

  /// Nominal rest duration for the current exercise, in seconds.
  final int restDurationSeconds;

  /// Monotonic update time; used to detect stale snapshots on cold start.
  final DateTime updatedAt;

  // ── Derived helpers ────────────────────────────────────────────────────────

  /// 0.0 – 1.0 progress fraction.
  double get progressFraction =>
      totalExercises == 0 ? 0 : finishedExercises / totalExercises;

  /// Human-readable percentage string (e.g. "20%").
  String get progressPercent =>
      '${(progressFraction * 100).round()}%';

  /// Title shown in the live notification's workout mode.
  String get liveNotificationTitle =>
      '$scheduleName · $finishedExercises of $totalExercises exercises';

  /// Elapsed seconds accounting for paused time (call when not paused).
  int elapsedSecondsAt(DateTime now) {
    final raw = now.difference(sessionStartedAt).inSeconds;
    return (raw - pausedAccumulatedSeconds).clamp(0, 86400);
  }

  // ── Serialisation ──────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'scheduleId': scheduleId,
        'scheduleName': scheduleName,
        'totalExercises': totalExercises,
        'finishedExercises': finishedExercises,
        'exerciseName': exerciseName,
        'setNumber': setNumber,
        'totalSets': totalSets,
        'phase': phase,
        'sessionStartedAt': sessionStartedAt.toIso8601String(),
        'pausedAccumulatedSeconds': pausedAccumulatedSeconds,
        if (pausedAt != null) 'pausedAt': pausedAt!.toIso8601String(),
        if (restEndsAt != null) 'restEndsAt': restEndsAt!.toIso8601String(),
        'restDurationSeconds': restDurationSeconds,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory LiveWorkoutSnapshot.fromJson(Map<String, dynamic> json) {
    return LiveWorkoutSnapshot(
      sessionId: json['sessionId'] as String? ?? '',
      scheduleId: json['scheduleId'] as String? ?? '',
      scheduleName: json['scheduleName'] as String? ?? '',
      totalExercises: json['totalExercises'] as int? ?? 0,
      finishedExercises: json['finishedExercises'] as int? ?? 0,
      exerciseName: json['exerciseName'] as String? ?? '',
      setNumber: json['setNumber'] as int? ?? 1,
      totalSets: json['totalSets'] as int? ?? 1,
      phase: json['phase'] as String? ?? 'active',
      sessionStartedAt: DateTime.parse(
          json['sessionStartedAt'] as String? ?? DateTime.now().toIso8601String()),
      pausedAccumulatedSeconds: json['pausedAccumulatedSeconds'] as int? ?? 0,
      pausedAt: json['pausedAt'] != null
          ? DateTime.parse(json['pausedAt'] as String)
          : null,
      restEndsAt: json['restEndsAt'] != null
          ? DateTime.parse(json['restEndsAt'] as String)
          : null,
      restDurationSeconds: json['restDurationSeconds'] as int? ?? 0,
      updatedAt: DateTime.parse(
          json['updatedAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  LiveWorkoutSnapshot copyWith({
    String? sessionId,
    String? scheduleId,
    String? scheduleName,
    int? totalExercises,
    int? finishedExercises,
    String? exerciseName,
    int? setNumber,
    int? totalSets,
    String? phase,
    DateTime? sessionStartedAt,
    int? pausedAccumulatedSeconds,
    DateTime? pausedAt,
    DateTime? restEndsAt,
    int? restDurationSeconds,
    DateTime? updatedAt,
    bool clearPausedAt = false,
    bool clearRestEndsAt = false,
  }) {
    return LiveWorkoutSnapshot(
      sessionId: sessionId ?? this.sessionId,
      scheduleId: scheduleId ?? this.scheduleId,
      scheduleName: scheduleName ?? this.scheduleName,
      totalExercises: totalExercises ?? this.totalExercises,
      finishedExercises: finishedExercises ?? this.finishedExercises,
      exerciseName: exerciseName ?? this.exerciseName,
      setNumber: setNumber ?? this.setNumber,
      totalSets: totalSets ?? this.totalSets,
      phase: phase ?? this.phase,
      sessionStartedAt: sessionStartedAt ?? this.sessionStartedAt,
      pausedAccumulatedSeconds:
          pausedAccumulatedSeconds ?? this.pausedAccumulatedSeconds,
      pausedAt: clearPausedAt ? null : (pausedAt ?? this.pausedAt),
      restEndsAt: clearRestEndsAt ? null : (restEndsAt ?? this.restEndsAt),
      restDurationSeconds: restDurationSeconds ?? this.restDurationSeconds,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
