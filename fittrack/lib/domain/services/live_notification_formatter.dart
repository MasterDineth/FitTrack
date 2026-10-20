import '../entities/live_workout_snapshot.dart';

/// Notification spec that both the live device notification and the in-app
/// preview widget render. Creating from a [LiveWorkoutSnapshot] via
/// [LiveNotificationFormatter] ensures the two can never disagree.
///
/// Pure Dart — no Flutter imports.
class LiveNotificationSpec {
  const LiveNotificationSpec({
    required this.mode,
    required this.title,
    required this.body,
    required this.progressFraction,
    this.chronometer,
    this.countdownEndsAt,
    this.actions = const [],
    this.showProgressBar = true,
  });

  final LiveNotificationMode mode;
  final String title;
  final String body;

  /// 0.0 – 1.0 exercise progress fraction (finished / total).
  final double progressFraction;

  /// For workout mode: when the chronometer started (counts up).
  /// Null when counting up is not applicable.
  final DateTime? chronometer;

  /// For rest mode: when the countdown reaches zero.
  final DateTime? countdownEndsAt;

  final List<LiveNotificationAction> actions;

  /// Whether to render the progress bar (controlled by [showScheduleProgress]).
  final bool showProgressBar;
}

enum LiveNotificationMode { workout, rest, complete }

/// A button that can appear in a live notification or the in-app preview.
class LiveNotificationAction {
  const LiveNotificationAction({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;
}

/// Action IDs mirrored in the background handler.
abstract final class LiveNotificationActionId {
  static const String pause = 'pause';
  static const String resume = 'resume';
  static const String open = 'open';
  static const String completeSet = 'complete_set';
  static const String skipRest = 'skip_rest';
  static const String adjustRestMinus15 = 'rest_minus_15';
  static const String adjustRestPlus15 = 'rest_plus_15';
}

/// Builds a [LiveNotificationSpec] from a [LiveWorkoutSnapshot] and relevant
/// settings flags. Pure Dart — no Flutter imports, trivially unit-testable.
class LiveNotificationFormatter {
  const LiveNotificationFormatter();

  LiveNotificationSpec build({
    required LiveWorkoutSnapshot snapshot,
    required bool showScheduleProgress,
    required bool showSetProgress,
    required bool showRestTimerControls,
    required bool allowCompleteSetFromNotification,
    DateTime? now,
  }) {
    final effectiveNow = now ?? DateTime.now();
    final mode = _modeFrom(snapshot.phase);

    switch (mode) {
      case LiveNotificationMode.workout:
        return _buildWorkout(
          snapshot: snapshot,
          now: effectiveNow,
          showScheduleProgress: showScheduleProgress,
          showSetProgress: showSetProgress,
          allowCompleteSetFromNotification: allowCompleteSetFromNotification,
        );
      case LiveNotificationMode.rest:
        return _buildRest(
          snapshot: snapshot,
          showScheduleProgress: showScheduleProgress,
          showSetProgress: showSetProgress,
          showRestTimerControls: showRestTimerControls,
        );
      case LiveNotificationMode.complete:
        return const LiveNotificationSpec(
          mode: LiveNotificationMode.complete,
          title: 'Workout complete',
          body: '',
          progressFraction: 1,
          showProgressBar: false,
        );
    }
  }

  LiveNotificationSpec _buildWorkout({
    required LiveWorkoutSnapshot snapshot,
    required DateTime now,
    required bool showScheduleProgress,
    required bool showSetProgress,
    required bool allowCompleteSetFromNotification,
  }) {
    final pct = (snapshot.progressFraction * 100).round();
    final title =
        '${snapshot.finishedExercises} of ${snapshot.totalExercises} exercises · $pct%';
    final body = showSetProgress
        ? '${snapshot.exerciseName} · Set ${snapshot.setNumber} of ${snapshot.totalSets}'
        : snapshot.exerciseName;

    final actions = <LiveNotificationAction>[
      const LiveNotificationAction(
          id: LiveNotificationActionId.pause, label: 'Pause'),
      const LiveNotificationAction(
          id: LiveNotificationActionId.open, label: 'Open'),
      if (allowCompleteSetFromNotification)
        const LiveNotificationAction(
            id: LiveNotificationActionId.completeSet, label: 'Complete set'),
    ];

    return LiveNotificationSpec(
      mode: LiveNotificationMode.workout,
      title: title,
      body: body,
      progressFraction: snapshot.progressFraction,
      chronometer: snapshot.sessionStartedAt.add(
          Duration(seconds: snapshot.pausedAccumulatedSeconds)),
      actions: actions,
      showProgressBar: showScheduleProgress,
    );
  }

  LiveNotificationSpec _buildRest({
    required LiveWorkoutSnapshot snapshot,
    required bool showScheduleProgress,
    required bool showSetProgress,
    required bool showRestTimerControls,
  }) {
    final title = 'Rest · ${snapshot.exerciseName}';
    // The next set to be performed is setNumber (1-based, already advanced)
    final body = showSetProgress
        ? 'Next: Set ${snapshot.setNumber} of ${snapshot.totalSets}'
        : 'Rest';

    final actions = <LiveNotificationAction>[
      if (showRestTimerControls) ...[
        const LiveNotificationAction(
            id: LiveNotificationActionId.adjustRestMinus15, label: '−15s'),
        const LiveNotificationAction(
            id: LiveNotificationActionId.skipRest, label: 'Skip rest'),
        const LiveNotificationAction(
            id: LiveNotificationActionId.adjustRestPlus15, label: '+15s'),
      ],
    ];

    return LiveNotificationSpec(
      mode: LiveNotificationMode.rest,
      title: title,
      body: body,
      progressFraction: snapshot.progressFraction,
      countdownEndsAt: snapshot.restEndsAt,
      actions: actions,
      showProgressBar: showScheduleProgress,
    );
  }

  LiveNotificationMode _modeFrom(String phase) {
    switch (phase) {
      case 'resting':
        return LiveNotificationMode.rest;
      case 'finished':
        return LiveNotificationMode.complete;
      default:
        return LiveNotificationMode.workout;
    }
  }
}

/// Computes the number of finished exercises for progress display.
///
/// An exercise counts as "finished" when either:
///   * all of its sets have been logged (appear in [completedSetsByExercise]), or
///   * it appears in [skippedExerciseIds].
///
/// [totalExercises] is the full exercise count for the schedule.
int computeFinishedExercises({
  required int totalExercises,
  required Map<String, int> completedSetsByExercise,
  required Map<String, int> totalSetsByExercise,
  required Set<String> skippedExerciseIds,
}) {
  int finished = 0;
  for (final id in totalSetsByExercise.keys) {
    if (skippedExerciseIds.contains(id)) {
      finished++;
    } else {
      final done = completedSetsByExercise[id] ?? 0;
      final total = totalSetsByExercise[id] ?? 0;
      if (total > 0 && done >= total) finished++;
    }
  }
  return finished;
}
