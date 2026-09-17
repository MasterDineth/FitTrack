import 'package:flutter/material.dart';

import '../../providers/active_workout_provider.dart';

/// Shows a full-screen paused overlay on top of the active workout.
/// Call [showWorkoutPausedModal] from [ActiveWorkoutScreen].
void showWorkoutPausedModal(
  BuildContext context, {
  required ActiveWorkoutState state,
  required ActiveWorkoutNotifier notifier,
  required VoidCallback onEndWorkout,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Paused',
    barrierColor: Colors.black.withValues(alpha: 0.65),
    transitionDuration: const Duration(milliseconds: 260),
    transitionBuilder: (ctx, anim, _, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: FadeTransition(opacity: anim, child: child),
      );
    },
    pageBuilder: (ctx, _, _) => _WorkoutPausedModal(
      state: state,
      notifier: notifier,
      onEndWorkout: onEndWorkout,
    ),
  );
}

class _WorkoutPausedModal extends StatelessWidget {
  const _WorkoutPausedModal({
    required this.state,
    required this.notifier,
    required this.onEndWorkout,
  });

  final ActiveWorkoutState state;
  final ActiveWorkoutNotifier notifier;
  final VoidCallback onEndWorkout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final completedExercises = state.entries
        .where(
          (e) => state.completedSets.any((s) => s.exerciseId == e.exerciseId),
        )
        .length;
    final totalExercises = state.entries.length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Top bar ──────────────────────────────────────────────────
              Row(
                children: [
                  // Paused badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'PAUSED',
                          style: TextStyle(
                            color: Colors.amber.shade800,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    state.elapsedFormatted,
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Pause icon ────────────────────────────────────────────────
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.25),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.pause_rounded,
                  size: 44,
                  color: Colors.amber,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Workout Paused',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Take your time. Your session is safely preserved.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 28),

              // ── Stats row ────────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 18, horizontal: 8),
                child: Row(
                  children: [
                    _StatCell(
                      icon: Icons.timer_outlined,
                      iconColor: colorScheme.primary,
                      label: 'Duration',
                      value: state.elapsedFormatted,
                    ),
                    _divider(colorScheme.outlineVariant),
                    _StatCell(
                      icon: Icons.fitness_center_rounded,
                      iconColor: colorScheme.primary,
                      label: 'Exercises',
                      value: '$completedExercises/$totalExercises',
                    ),
                    _divider(colorScheme.outlineVariant),
                    _StatCell(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: Colors.orange,
                      label: 'Calories',
                      value: '${state.estimatedCalories}',
                    ),
                    _divider(colorScheme.outlineVariant),
                    _StatCell(
                      icon: Icons.repeat_rounded,
                      iconColor: Colors.purple,
                      label: 'Sets',
                      value: '${state.completedSetCount}',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Upcoming queue (compact) ──────────────────────────────────
              if (state.upcomingEntries.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'COMING UP',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...state.upcomingEntries.take(3).indexed.map((r) {
                  final idx = r.$1;
                  final e = r.$2;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${state.currentExerciseIndex + idx + 2}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  '${e.totalSets} sets × ${e.targetReps} reps',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
              ],

              const Spacer(),

              // ── Action buttons ────────────────────────────────────────────
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  notifier.resumeSession();
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 22),
                label: const Text(
                  'Resume Workout',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onEndWorkout();
                },
                icon: const Icon(Icons.stop_circle_outlined, size: 18),
                label: const Text(
                  'End Workout',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error.withValues(alpha: 0.4)),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider(Color color) => Container(
        width: 1,
        height: 40,
        color: color,
      );
}

// ── Reusable stat cell ────────────────────────────────────────────────────────

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: colorScheme.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
