import '../entities/live_workout_snapshot.dart';

/// Pure Dart reducer for applying notification-action events to a
/// [LiveWorkoutSnapshot] without touching Flutter or the plugin. The
/// background isolate uses this to update the snapshot when the main Dart
/// engine is not running.
abstract final class LiveWorkoutReducer {
  const LiveWorkoutReducer._();

  /// Apply [action] to [snapshot] and return the updated snapshot.
  /// [now] is injected for deterministic unit tests.
  static LiveWorkoutSnapshot apply(
    LiveWorkoutSnapshot snapshot,
    LiveWorkoutAction action, {
    required DateTime now,
  }) {
    switch (action) {
      case AdjustRestAction(:final deltaSec):
        return _adjustRest(snapshot, deltaSec, now);
      case SkipRestAction():
        return _skipRest(snapshot, now);
      case PauseAction():
        return _pause(snapshot, now);
      case ResumeAction():
        return _resume(snapshot, now);
      case CompleteSetAction():
        return _completeSet(snapshot, now);
      case AdvanceAfterRestAction():
        return _advanceAfterRest(snapshot, now);
    }
  }

  static LiveWorkoutSnapshot _adjustRest(
      LiveWorkoutSnapshot s, int deltaSec, DateTime now) {
    final current = s.restEndsAt;
    if (current == null) return s;
    final newEnd = current.add(Duration(seconds: deltaSec));
    // Clamp so remaining is 0–600 s from now.
    final minEnd = now;
    final maxEnd = now.add(const Duration(seconds: 600));
    final clamped = newEnd.isBefore(minEnd)
        ? minEnd
        : newEnd.isAfter(maxEnd)
            ? maxEnd
            : newEnd;
    return s.copyWith(restEndsAt: clamped, updatedAt: now);
  }

  static LiveWorkoutSnapshot _skipRest(LiveWorkoutSnapshot s, DateTime now) {
    // Advance to workout phase; caller advances set/exercise index separately.
    return s.copyWith(
      phase: 'active',
      clearRestEndsAt: true,
      updatedAt: now,
    );
  }

  static LiveWorkoutSnapshot _pause(LiveWorkoutSnapshot s, DateTime now) {
    if (s.phase == 'paused') return s;
    return s.copyWith(
      phase: 'paused',
      pausedAt: now,
      updatedAt: now,
    );
  }

  static LiveWorkoutSnapshot _resume(LiveWorkoutSnapshot s, DateTime now) {
    if (s.phase != 'paused') return s;
    final pausedAt = s.pausedAt;
    final additionalPaused =
        pausedAt != null ? now.difference(pausedAt).inSeconds : 0;
    final newAccumulated =
        (s.pausedAccumulatedSeconds + additionalPaused).clamp(0, 86400);

    // If we were resting when paused, shift restEndsAt forward by the paused
    // duration so the countdown resumes correctly.
    DateTime? newRestEndsAt = s.restEndsAt;
    if (s.restEndsAt != null && pausedAt != null) {
      newRestEndsAt =
          s.restEndsAt!.add(Duration(seconds: now.difference(pausedAt).inSeconds));
    }

    return s.copyWith(
      phase: s.restEndsAt != null ? 'resting' : 'active',
      pausedAccumulatedSeconds: newAccumulated,
      clearPausedAt: true,
      restEndsAt: newRestEndsAt,
      updatedAt: now,
    );
  }

  static LiveWorkoutSnapshot _completeSet(LiveWorkoutSnapshot s, DateTime now) {
    // Set completeSet advances to rest phase.
    // The rest end is computed from restDurationSeconds.
    final restEndsAt = now.add(Duration(seconds: s.restDurationSeconds));
    return s.copyWith(
      phase: 'resting',
      restEndsAt: restEndsAt,
      updatedAt: now,
    );
  }

  static LiveWorkoutSnapshot _advanceAfterRest(
      LiveWorkoutSnapshot s, DateTime now) {
    // Called when rest timer expires; advance to workout phase.
    return s.copyWith(
      phase: 'active',
      clearRestEndsAt: true,
      updatedAt: now,
    );
  }
}

// ── Action types ──────────────────────────────────────────────────────────────

sealed class LiveWorkoutAction {
  const LiveWorkoutAction();
}

class AdjustRestAction extends LiveWorkoutAction {
  const AdjustRestAction(this.deltaSec);
  final int deltaSec;
}

class SkipRestAction extends LiveWorkoutAction {
  const SkipRestAction();
}

class PauseAction extends LiveWorkoutAction {
  const PauseAction();
}

class ResumeAction extends LiveWorkoutAction {
  const ResumeAction();
}

class CompleteSetAction extends LiveWorkoutAction {
  const CompleteSetAction();
}

class AdvanceAfterRestAction extends LiveWorkoutAction {
  const AdvanceAfterRestAction();
}
