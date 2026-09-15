import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/workout_history_provider.dart';
import '../../domain/entities/workout_session.dart';

class WorkoutHistoryDetailScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<WorkoutHistoryDetailScreen> createState() =>
      _WorkoutHistoryDetailScreenState();
}

class _WorkoutHistoryDetailScreenState
    extends ConsumerState<WorkoutHistoryDetailScreen> {
  /// Index of the currently expanded exercise card. Null = none.
  int? _expandedIndex = 0; // auto-expand first

  static const Color _bg = Color(0xFFf8fafc);

  @override
  Widget build(BuildContext context) {
    final session =
        ref.watch(workoutSessionByIdProvider(widget.sessionId));

    if (session == null) {
      return Scaffold(
        backgroundColor: _bg,
        body: const Center(child: Text('Session not found.')),
      );
    }

    // Build mock exercise breakdown from session data
    final exercises = _buildMockExercises(session);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ─────────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      size: 28,
                      color: Color(0xFF0f172a),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Workout Details',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0f172a),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.share_outlined,
                      size: 20,
                      color: Color(0xFF64748b),
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable body ──────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero summary card ─────────────────────────────────
                    _HeroCard(
                      session: session,
                      exerciseCount: exercises.length,
                    ),

                    const SizedBox(height: 16),

                    // ── Notes (if any) ────────────────────────────────────
                    if (session.notes != null &&
                        session.notes!.isNotEmpty) ...[
                      _NotesCard(notes: session.notes!),
                      const SizedBox(height: 16),
                    ],

                    // ── Exercises header ──────────────────────────────────
                    const Text(
                      'EXERCISES',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF94a3b8),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Accordion list ────────────────────────────────────
                    ...exercises.indexed.map((r) {
                      final idx = r.$1;
                      final ex = r.$2;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ExerciseAccordion(
                          exercise: ex,
                          index: idx,
                          isExpanded: _expandedIndex == idx,
                          onTap: ex.isSkipped
                              ? null
                              : () => setState(() {
                                    _expandedIndex =
                                        _expandedIndex == idx ? null : idx;
                                  }),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Creates mock exercise entries derived from the session for display.
  List<_MockExercise> _buildMockExercises(WorkoutSession session) {
    // Simulate exercises based on schedule type
    if (session.scheduleId.startsWith('sch1')) {
      return [
        _MockExercise(
          name: 'Barbell Bench Press',
          muscleTag: 'CHEST',
          sets: [
            _MockSet(1, 8, 100),
            _MockSet(2, 8, 102.5),
            _MockSet(3, 7, 102.5),
          ],
        ),
        _MockExercise(
          name: 'Incline DB Press',
          muscleTag: 'CHEST',
          sets: [
            _MockSet(1, 10, 32),
            _MockSet(2, 10, 32),
            _MockSet(3, 9, 32),
          ],
        ),
        _MockExercise(
          name: 'Cable Incline Flyes',
          muscleTag: 'CHEST',
          sets: [
            _MockSet(1, 12, 20),
            _MockSet(2, 12, 20),
            _MockSet(3, 10, 20),
          ],
        ),
        _MockExercise(
          name: 'Overhead Press',
          muscleTag: 'SHOULDERS',
          sets: [
            _MockSet(1, 8, 60),
            _MockSet(2, 8, 62.5),
            _MockSet(3, 7, 62.5),
          ],
        ),
        _MockExercise(
          name: 'Lateral Raises',
          muscleTag: 'SHOULDERS',
          isSkipped: true,
          sets: [],
        ),
        _MockExercise(
          name: 'Tricep Pushdowns',
          muscleTag: 'TRICEPS',
          sets: [
            _MockSet(1, 12, 35),
            _MockSet(2, 12, 35),
            _MockSet(3, 11, 35),
          ],
        ),
        _MockExercise(
          name: 'Skull Crushers',
          muscleTag: 'TRICEPS',
          sets: [
            _MockSet(1, 10, 25),
            _MockSet(2, 10, 27.5),
            _MockSet(3, 8, 27.5),
          ],
        ),
      ];
    } else if (session.scheduleId.startsWith('sch2')) {
      return [
        _MockExercise(
          name: 'Barbell Row',
          muscleTag: 'BACK',
          sets: [
            _MockSet(1, 8, 80),
            _MockSet(2, 8, 82.5),
            _MockSet(3, 7, 82.5),
          ],
        ),
        _MockExercise(
          name: 'Lat Pulldowns',
          muscleTag: 'BACK',
          sets: [
            _MockSet(1, 10, 65),
            _MockSet(2, 10, 67.5),
            _MockSet(3, 9, 67.5),
          ],
        ),
        _MockExercise(
          name: 'Cable Rows',
          muscleTag: 'BACK',
          sets: [
            _MockSet(1, 12, 55),
            _MockSet(2, 12, 55),
            _MockSet(3, 10, 55),
          ],
        ),
        _MockExercise(
          name: 'Barbell Curls',
          muscleTag: 'BICEPS',
          sets: [
            _MockSet(1, 10, 35),
            _MockSet(2, 10, 37.5),
            _MockSet(3, 8, 37.5),
          ],
        ),
        _MockExercise(
          name: 'Hammer Curls',
          muscleTag: 'BICEPS',
          sets: [
            _MockSet(1, 12, 16),
            _MockSet(2, 12, 16),
            _MockSet(3, 10, 16),
          ],
        ),
      ];
    } else {
      return [
        _MockExercise(
          name: 'Barbell Squats',
          muscleTag: 'QUADS',
          sets: [
            _MockSet(1, 8, 120),
            _MockSet(2, 8, 122.5),
            _MockSet(3, 6, 125),
          ],
        ),
        _MockExercise(
          name: 'Romanian Deadlifts',
          muscleTag: 'HAMSTRINGS',
          sets: [
            _MockSet(1, 10, 80),
            _MockSet(2, 10, 82.5),
            _MockSet(3, 9, 82.5),
          ],
        ),
        _MockExercise(
          name: 'Leg Press',
          muscleTag: 'QUADS',
          sets: [
            _MockSet(1, 12, 160),
            _MockSet(2, 12, 160),
            _MockSet(3, 10, 160),
          ],
        ),
        _MockExercise(
          name: 'Leg Curls',
          muscleTag: 'HAMSTRINGS',
          sets: [
            _MockSet(1, 12, 45),
            _MockSet(2, 12, 45),
            _MockSet(3, 10, 47.5),
          ],
        ),
        _MockExercise(
          name: 'Calf Raises',
          muscleTag: 'CALVES',
          sets: [
            _MockSet(1, 20, 40),
            _MockSet(2, 20, 40),
            _MockSet(3, 18, 40),
          ],
        ),
        _MockExercise(
          name: 'Hip Thrusts',
          muscleTag: 'GLUTES',
          sets: [
            _MockSet(1, 12, 80),
            _MockSet(2, 12, 80),
            _MockSet(3, 10, 80),
          ],
        ),
      ];
    }
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class _MockExercise {
  const _MockExercise({
    required this.name,
    required this.muscleTag,
    required this.sets,
    this.isSkipped = false,
  });

  final String name;
  final String muscleTag;
  final List<_MockSet> sets;
  final bool isSkipped;
}

class _MockSet {
  const _MockSet(this.number, this.reps, this.weightKg);

  final int number;
  final int reps;
  final double weightKg;

  double get volume => reps * weightKg;
}

// ── Hero Summary Card ─────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.session, this.exerciseCount});

  final WorkoutSession session;
  final int? exerciseCount;

  Color get _intensityColor {
    switch (session.intensity) {
      case 'Extreme':
        return const Color(0xFFef4444);
      case 'Intense':
        return const Color(0xFFf97316);
      case 'Easy':
        return const Color(0xFF22c55e);
      default:
        return const Color(0xFFf59e0b);
    }
  }

  Color get _intensityBg {
    switch (session.intensity) {
      case 'Extreme':
        return const Color(0xFFfef2f2);
      case 'Intense':
        return const Color(0xFFfff7ed);
      case 'Easy':
        return const Color(0xFFf0fdf4);
      default:
        return const Color(0xFFFFFBEB);
    }
  }

  String get _scheduleTitle {
    if (session.scheduleId.startsWith('sch1')) {
      return 'Day 1 – Chest, Shoulders & Triceps';
    } else if (session.scheduleId.startsWith('sch2')) {
      return 'Day 2 – Back & Biceps';
    } else if (session.scheduleId.startsWith('sch3')) {
      return 'Day 3 – Legs & Posterior Chain';
    }
    return session.scheduleId;
  }

  String _fmtDuration(int? s) {
    if (s == null) return '–';
    return '${s ~/ 60}m ${s % 60}s';
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('MMM d, yyyy').format(session.startTime);
    final timeStr = DateFormat('h:mm a').format(session.startTime);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFe2e8f0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top accent stripe
          Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF34d399), Color(0xFF0d9488), Color(0xFF00d68f)],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status + intensity badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf0fdf4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFbbf7d0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22c55e),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF166534),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (session.intensity != null)
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _intensityBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: _intensityColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '${session.intensity} Intensity',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _intensityColor,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  _scheduleTitle,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0f172a),
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '$dateStr · $timeStr',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFf1f5f9)),
                const SizedBox(height: 14),

                // 3×2 metrics grid
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _MiniMetric(
                          icon: Icons.timer_outlined,
                          iconColor: const Color(0xFF0d9488),
                          value: _fmtDuration(session.durationSeconds),
                          label: 'Duration',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MiniMetric(
                          icon: Icons.local_fire_department_rounded,
                          iconColor: const Color(0xFFef4444),
                          value: '${session.totalCalories ?? 0}',
                          label: 'Calories',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MiniMetric(
                          icon: Icons.fitness_center_rounded,
                          iconColor: const Color(0xFF00d68f),
                          value: '${session.totalSets}',
                          label: 'Sets',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _MiniMetric(
                          icon: Icons.repeat_rounded,
                          iconColor: const Color(0xFF8b5cf6),
                          value: '${session.totalReps}',
                          label: 'Reps',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MiniMetric(
                          icon: Icons.show_chart_rounded,
                          iconColor: const Color(0xFFf97316),
                          value: session.totalVolumeKg >= 1000
                              ? '${(session.totalVolumeKg / 1000).toStringAsFixed(1)}k kg'
                              : '${session.totalVolumeKg.toStringAsFixed(0)} kg',
                          label: 'Volume',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MiniMetric(
                          icon: Icons.format_list_bulleted_rounded,
                          iconColor: const Color(0xFF3b82f6),
                          value: exerciseCount != null ? '$exerciseCount' : '–',
                          label: 'Exercises',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 84),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFf8fafc),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFe2e8f0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 14),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0f172a),
                fontFeatures: [FontFeature.tabularFigures()],
              ),
              maxLines: 1,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Notes Card ────────────────────────────────────────────────────────────────

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFe2e8f0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notes_rounded,
                size: 16,
                color: Color(0xFF00d68f),
              ),
              const SizedBox(width: 6),
              const Text(
                'Session Notes',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF94a3b8),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notes,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1e293b),
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Exercise Accordion ────────────────────────────────────────────────────────

class _ExerciseAccordion extends StatelessWidget {
  const _ExerciseAccordion({
    required this.exercise,
    required this.index,
    required this.isExpanded,
    required this.onTap,
  });

  final _MockExercise exercise;
  final int index;
  final bool isExpanded;
  final VoidCallback? onTap;

  Color get _muscleColor {
    switch (exercise.muscleTag) {
      case 'CHEST':
        return const Color(0xFFef4444);
      case 'BACK':
        return const Color(0xFF3b82f6);
      case 'SHOULDERS':
        return const Color(0xFF8b5cf6);
      case 'BICEPS':
        return const Color(0xFFf97316);
      case 'TRICEPS':
        return const Color(0xFF06b6d4);
      case 'QUADS':
        return const Color(0xFF22c55e);
      case 'HAMSTRINGS':
        return const Color(0xFF84cc16);
      case 'CALVES':
        return const Color(0xFF10b981);
      case 'GLUTES':
        return const Color(0xFFec4899);
      default:
        return const Color(0xFF94a3b8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSkipped = exercise.isSkipped;
    final totalVolume =
        exercise.sets.fold(0.0, (s, e) => s + e.volume);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSkipped
            ? const Color(0xFFfafafa)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExpanded
              ? const Color(0xFF00d68f).withValues(alpha: 0.4)
              : const Color(0xFFe2e8f0),
          width: isExpanded ? 1.5 : 1,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: const Color(0xFF00d68f).withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Column(
        children: [
          // ── Header row ─────────────────────────────────────────────────
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Number badge
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSkipped
                          ? const Color(0xFFf1f5f9)
                          : const Color(0xFFf0fdf4),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: isSkipped
                              ? const Color(0xFF94a3b8)
                              : const Color(0xFF166534),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Name + muscle tag
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                exercise.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: isSkipped
                                      ? const Color(0xFF94a3b8)
                                      : const Color(0xFF0f172a),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Muscle tag chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSkipped
                                    ? const Color(0xFFf1f5f9)
                                    : _muscleColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                exercise.muscleTag,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: isSkipped
                                      ? const Color(0xFFcbd5e1)
                                      : _muscleColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        if (isSkipped)
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFfef3c7),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: const Color(0xFFFDE68A)),
                                ),
                                child: const Text(
                                  'Unlogged',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            '${exercise.sets.length} sets'
                            ' · ${totalVolume.toStringAsFixed(0)} kg total',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94a3b8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Chevron or lock
                  if (isSkipped)
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 16,
                      color: Color(0xFFcbd5e1),
                    )
                  else
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: Color(0xFF94a3b8),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Expanded set log ──────────────────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: isExpanded && !isSkipped
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _SetLogTable(sets: exercise.sets),
          ),
        ],
      ),
    );
  }
}

class _SetLogTable extends StatelessWidget {
  const _SetLogTable({required this.sets});

  final List<_MockSet> sets;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFf8fafc),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFe2e8f0)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
            child: Row(
              children: const [
                _ColHeader('Set', flex: 1),
                _ColHeader('Weight', flex: 2),
                _ColHeader('Reps', flex: 2),
                _ColHeader('Volume', flex: 2),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFe2e8f0)),
          // Rows
          ...sets.indexed.map((r) {
            final i = r.$1;
            final s = r.$2;
            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: i.isEven
                    ? Colors.white.withValues(alpha: 0.6)
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  _ColCell('${s.number}', flex: 1, bold: true),
                  _ColCell('${s.weightKg} kg', flex: 2),
                  _ColCell('${s.reps}', flex: 2),
                  _ColCell(
                    '${s.volume.toStringAsFixed(0)} kg',
                    flex: 2,
                    color: const Color(0xFF00d68f),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ColHeader extends StatelessWidget {
  const _ColHeader(this.text, {required this.flex});

  final String text;
  final int flex;

  @override
  Widget build(BuildContext context) => Expanded(
        flex: flex,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Color(0xFF94a3b8),
            letterSpacing: 0.5,
          ),
        ),
      );
}

class _ColCell extends StatelessWidget {
  const _ColCell(
    this.text, {
    required this.flex,
    this.bold = false,
    this.color = const Color(0xFF0f172a),
  });

  final String text;
  final int flex;
  final bool bold;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        flex: flex,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      );
}
