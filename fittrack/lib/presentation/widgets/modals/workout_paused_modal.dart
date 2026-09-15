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

  static const Color _mint = Color(0xFF00d68f);
  static const Color _dark = Color(0xFF0f172a);
  static const Color _bg = Color(0xFFf7f9fb);

  @override
  Widget build(BuildContext context) {
    final completedExercises = state.entries
        .where(
          (e) => state.completedSets.any((s) => s.exerciseId == e.exerciseId),
        )
        .length;
    final totalExercises = state.entries.length;

    return Scaffold(
      backgroundColor: _bg,
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
                      color: const Color(0xFFfef3c7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFfde68a)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFf59e0b),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'PAUSED',
                          style: TextStyle(
                            color: Color(0xFF92400e),
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
                      color: _dark.withValues(alpha: 0.5),
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
                  color: const Color(0xFFfef3c7),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFf59e0b).withValues(alpha: 0.25),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.pause_rounded,
                  size: 44,
                  color: Color(0xFFf59e0b),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Workout Paused',
                style: TextStyle(
                  color: _dark,
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
                  color: _dark.withValues(alpha: 0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 28),

              // ── Stats row ────────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFe2e8f0)),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 18, horizontal: 8),
                child: Row(
                  children: [
                    _StatCell(
                      icon: Icons.timer_outlined,
                      iconColor: const Color(0xFF0d9488),
                      label: 'Duration',
                      value: state.elapsedFormatted,
                    ),
                    _divider(),
                    _StatCell(
                      icon: Icons.fitness_center_rounded,
                      iconColor: _mint,
                      label: 'Exercises',
                      value: '$completedExercises/$totalExercises',
                    ),
                    _divider(),
                    _StatCell(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: const Color(0xFFf97316),
                      label: 'Calories',
                      value: '${state.estimatedCalories}',
                    ),
                    _divider(),
                    _StatCell(
                      icon: Icons.repeat_rounded,
                      iconColor: const Color(0xFF8b5cf6),
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
                      color: _dark.withValues(alpha: 0.4),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFe2e8f0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFFf1f5f9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${state.currentExerciseIndex + idx + 2}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  color: Color(0xFF475569),
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: Color(0xFF1e293b),
                                  ),
                                ),
                                Text(
                                  '${e.totalSets} sets × ${e.targetReps} reps',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94a3b8),
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
                  backgroundColor: _mint,
                  foregroundColor: _dark,
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
                  foregroundColor: const Color(0xFFef4444),
                  side: const BorderSide(color: Color(0xFFfecaca)),
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

  Widget _divider() => Container(
        width: 1,
        height: 40,
        color: const Color(0xFFf1f5f9),
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
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: Color(0xFF0f172a),
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94a3b8),
            ),
          ),
        ],
      ),
    );
  }
}
