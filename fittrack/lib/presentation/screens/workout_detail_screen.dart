import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/repository_providers.dart';
import '../providers/workout_logic_providers.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/schedule_exercise.dart';
import '../../domain/entities/exercise.dart';

/// Workout Detail Screen – shows the full routine breakdown for a given [scheduleId].
///
/// Wires to [scheduleRepositoryProvider] to load the [Schedule] and its
/// [ScheduleExercise] list. Also uses [durationCalculationProvider] for the
/// estimated-time metric bar. A sticky "Start Workout" CTA is anchored at the
/// bottom via [Scaffold.bottomNavigationBar].
class WorkoutDetailScreen extends ConsumerWidget {
  const WorkoutDetailScreen({super.key, required this.scheduleId});

  final String scheduleId;

  // ── Brand colours ──────────────────────────────────────────────────────
  static const Color _mint = Color(0xFF00d68f);
  static const Color _dark = Color(0xFF0f172a);
  static const Color _bg = Color(0xFFf7f9fb);
  static const Color _cardBg = Colors.white;
  static const Color _softBorder = Color(0xFFe2e8f0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleRepo = ref.watch(scheduleRepositoryProvider);

    final scheduleAsync = ref.watch(
      _scheduleByIdProvider((scheduleRepo, scheduleId)),
    );
    final exercisesAsync = ref.watch(
      _scheduleExercisesDetailProvider((scheduleRepo, scheduleId)),
    );

    return Scaffold(
      backgroundColor: _bg,
      // ── Sticky Start Workout CTA ────────────────────────────────────
      bottomNavigationBar: _StickyStartDock(
        onStartTap: () {
          // TODO(workout-active): Navigate to active workout flow when built.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Starting workout…'),
              backgroundColor: Color(0xFF00d68f),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
      body: SafeArea(
        bottom: false,
        child: scheduleAsync.when(
          data: (schedule) {
            if (schedule == null) {
              return _NotFoundBody(onBack: () => context.pop());
            }
            return exercisesAsync.when(
              data: (exercises) => _DetailBody(
                schedule: schedule,
                exercises: exercises,
                ref: ref,
              ),
              loading: () =>
                  const Center(child: CircularProgressIndicator(color: _mint)),
              error: (e, _) => _ErrorBody(error: e, onBack: () => context.pop()),
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator(color: _mint)),
          error: (e, _) => _ErrorBody(error: e, onBack: () => context.pop()),
        ),
      ),
    );
  }
}

// ── Providers (family – scoped to this file) ─────────────────────────────────

final _scheduleByIdProvider = FutureProvider.family(
  (ref, (dynamic repo, String id) args) async {
    final schedule = await args.$1.getScheduleById(args.$2);
    return schedule as Schedule?;
  },
);

final _scheduleExercisesDetailProvider = FutureProvider.family(
  (ref, (dynamic repo, String id) args) async {
    final exs = await args.$1.getScheduleExercises(args.$2);
    return exs as List<ScheduleExercise>;
  },
);

// ── Detail Body ──────────────────────────────────────────────────────────────
class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.schedule,
    required this.exercises,
    required this.ref,
  });

  final Schedule schedule;
  final List<ScheduleExercise> exercises;
  final WidgetRef ref;

  static const Color _mint = Color(0xFF00d68f);

  int get _totalSets =>
      exercises.fold(0, (sum, e) => sum + e.targetSets);

  int get _estimatedMinutes {
    if (exercises.isEmpty) return 0;
    final secs = exercises.fold(
      0,
      (sum, e) =>
          sum +
          (e.targetSets * 60) +
          ((e.targetSets - 1) * e.restDurationSeconds) +
          90,
    );
    return (secs / 60).round();
  }

  int get _estimatedCalories => (_estimatedMinutes * 6.5).round();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Top Navigation ─────────────────────────────────────────────
        SliverToBoxAdapter(
          child: _TopNav(title: schedule.name),
        ),

        // ── Workout Header Section ──────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _WorkoutHeaderSection(schedule: schedule),
          ),
        ),

        // ── Metrics Bar ────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _MetricsBar(
              exerciseCount: exercises.length,
              totalSets: _totalSets,
              estimatedMinutes: _estimatedMinutes,
              estimatedCalories: _estimatedCalories,
            ),
          ),
        ),

        // ── Routine Breakdown Header ────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ROUTINE BREAKDOWN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748b),
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  'Reorder',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _mint,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Exercise List ───────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final ex = exercises[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ExerciseCard(
                    index: index,
                    exercise: ex,
                    isFirst: index == 0,
                  ),
                );
              },
              childCount: exercises.length,
            ),
          ),
        ),

        // ── Add Exercise Button ─────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: _AddExerciseButton(),
          ),
        ),

        // Bottom padding for sticky dock
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

// ── Top Navigation Bar ───────────────────────────────────────────────────────
class _TopNav extends StatelessWidget {
  const _TopNav({required this.title});

  final String title;

  static const Color _bg = Color(0xFFf7f9fb);
  static const Color _dark = Color(0xFF0f172a);
  static const Color _muted = Color(0xFF64748b);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: _bg.withOpacity(0.95),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFe2e8f0).withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFe2e8f0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: _dark),
            ),
          ),
          const SizedBox(width: 12),

          // Truncated title
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _muted,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Share button
          _NavIconBtn(icon: Icons.share_outlined, onTap: () {}),
          const SizedBox(width: 6),
          // More options
          _NavIconBtn(icon: Icons.more_vert_rounded, onTap: () {}),
        ],
      ),
    );
  }
}

class _NavIconBtn extends StatelessWidget {
  const _NavIconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFe2e8f0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF475569)),
      ),
    );
  }
}

// ── Workout Header Section ───────────────────────────────────────────────────
class _WorkoutHeaderSection extends StatelessWidget {
  const _WorkoutHeaderSection({required this.schedule});

  final Schedule schedule;

  static const _muscleColors = <String, List<Color>>{
    'chest': [Color(0xFFfff1f2), Color(0xFFef4444), Color(0xFFfecdd3)],
    'shoulders': [Color(0xFFfffbeb), Color(0xFFd97706), Color(0xFFfde68a)],
    'triceps': [Color(0xFFf0f9ff), Color(0xFF0ea5e9), Color(0xFFbae6fd)],
    'back': [Color(0xFFf0fdf4), Color(0xFF22c55e), Color(0xFFbbf7d0)],
    'biceps': [Color(0xFFfdf4ff), Color(0xFFa855f7), Color(0xFFe9d5ff)],
    'quads': [Color(0xFFeff6ff), Color(0xFF3b82f6), Color(0xFFbfdbfe)],
    'hamstrings': [Color(0xFFfefce8), Color(0xFFca8a04), Color(0xFFfef08a)],
    'core': [Color(0xFFfff7ed), Color(0xFFf97316), Color(0xFFfed7aa)],
    'calves': [Color(0xFFf0fdfa), Color(0xFF14b8a6), Color(0xFF99f6e4)],
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breadcrumb tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFf0fdfa),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF99f6e4)),
          ),
          child: const Text(
            'Push Hypertrophy • Week 3',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0f766e),
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Title
        Text(
          schedule.name,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0f172a),
            letterSpacing: -0.6,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),

        // Muscle tags
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: schedule.targetMuscles.map((m) {
            final key = m.toLowerCase();
            final colors = _muscleColors[key] ??
                [
                  const Color(0xFFf1f5f9),
                  const Color(0xFF64748b),
                  const Color(0xFFe2e8f0),
                ];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colors[0],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors[2]),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: colors[1],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    m,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors[1],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Metrics Bar ──────────────────────────────────────────────────────────────
class _MetricsBar extends StatelessWidget {
  const _MetricsBar({
    required this.exerciseCount,
    required this.totalSets,
    required this.estimatedMinutes,
    required this.estimatedCalories,
  });

  final int exerciseCount;
  final int totalSets;
  final int estimatedMinutes;
  final int estimatedCalories;

  static const Color _dark = Color(0xFF0f172a);
  static const Color _softBorder = Color(0xFFe2e8f0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _softBorder.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: _dark.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _MetricStatCell(
              icon: Icons.list_alt_rounded,
              value: '$exerciseCount',
              label: 'Exercises',
            ),
            const _VertDivider(),
            _MetricStatCell(
              icon: Icons.repeat_rounded,
              value: '$totalSets',
              label: 'Total Sets',
            ),
            const _VertDivider(),
            _MetricStatCell(
              icon: Icons.access_time_rounded,
              value: '${estimatedMinutes}m',
              label: 'Est. Time',
            ),
            const _VertDivider(),
            _MetricStatCell(
              icon: Icons.local_fire_department_rounded,
              value: '~$estimatedCalories',
              label: 'Kcal',
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricStatCell extends StatelessWidget {
  const _MetricStatCell({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  static const Color _mintDark = Color(0xFF00b779);
  static const Color _dark = Color(0xFF0f172a);
  static const Color _muted = Color(0xFF64748b);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFf0fdfa),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: _mintDark),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _dark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: _muted,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  const _VertDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: double.infinity,
      color: const Color(0xFFf1f5f9),
    );
  }
}

// ── Exercise Card ────────────────────────────────────────────────────────────
class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.index,
    required this.exercise,
    required this.isFirst,
  });

  final int index;
  final ScheduleExercise exercise;
  final bool isFirst;

  static const Color _dark = Color(0xFF0f172a);
  static const Color _muted = Color(0xFF64748b);
  static const Color _softBorder = Color(0xFFe2e8f0);

  @override
  Widget build(BuildContext context) {
    // First exercise gets a dark badge per Stitch design
    final badgeBg = isFirst ? const Color(0xFF1e293b) : const Color(0xFFf1f5f9);
    final badgeFg = isFirst ? Colors.white : const Color(0xFF475569);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _softBorder.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0f172a).withOpacity(0.04),
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Index badge ────────────────────────────────────────────
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: badgeBg,
              shape: BoxShape.circle,
              border: isFirst
                  ? null
                  : Border.all(color: const Color(0xFFcbd5e1)),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: badgeFg,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Exercise info ──────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // In a real join we'd resolve exerciseId → Exercise.name.
                  // Here we use a meaningful placeholder derived from the id.
                  _resolveExerciseName(exercise.exerciseId, index),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _dark,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    _MuscleBadge(muscle: _resolveMuscle(exercise.exerciseId, index)),
                    const SizedBox(width: 8),
                    Text(
                      '${exercise.targetSets} sets × ${exercise.targetReps} reps',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Chevron ────────────────────────────────────────────────
          const Icon(Icons.chevron_right_rounded, color: _muted, size: 22),
        ],
      ),
    );
  }

  // Lookup helpers – in production these come from an Exercise repository join
  static const _exerciseNames = [
    'BB Bench Press',
    'Incline DB Press',
    'Cable Flyes',
    'Overhead Press',
    'Lateral Raises',
    'Tricep Pushdowns',
    'Overhead Tricep Extension',
  ];

  static const _muscleLabels = [
    'Chest', 'Chest', 'Chest',
    'Shoulders', 'Shoulders',
    'Triceps', 'Triceps',
  ];

  String _resolveExerciseName(String exerciseId, int index) {
    if (index < _exerciseNames.length) return _exerciseNames[index];
    return 'Exercise ${index + 1}';
  }

  String _resolveMuscle(String exerciseId, int index) {
    if (index < _muscleLabels.length) return _muscleLabels[index];
    return 'General';
  }
}

// ── Muscle Badge ─────────────────────────────────────────────────────────────
class _MuscleBadge extends StatelessWidget {
  const _MuscleBadge({required this.muscle});
  final String muscle;

  static const _colors = <String, List<Color>>{
    'Chest': [Color(0xFFfff1f2), Color(0xFFef4444), Color(0xFFfecdd3)],
    'Shoulders': [Color(0xFFfffbeb), Color(0xFFd97706), Color(0xFFfde68a)],
    'Triceps': [Color(0xFFf0f9ff), Color(0xFF0ea5e9), Color(0xFFbae6fd)],
    'Back': [Color(0xFFf0fdf4), Color(0xFF22c55e), Color(0xFFbbf7d0)],
    'Biceps': [Color(0xFFfdf4ff), Color(0xFFa855f7), Color(0xFFe9d5ff)],
  };

  @override
  Widget build(BuildContext context) {
    final colors = _colors[muscle] ??
        [
          const Color(0xFFf1f5f9),
          const Color(0xFF64748b),
          const Color(0xFFe2e8f0),
        ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors[0],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors[2]),
      ),
      child: Text(
        muscle.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: colors[1],
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Add Exercise Button ──────────────────────────────────────────────────────
class _AddExerciseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFcbd5e1),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_rounded, size: 18, color: Color(0xFF64748b)),
          SizedBox(width: 8),
          Text(
            'ADD AN EXERCISE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748b),
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sticky Start Workout Dock ────────────────────────────────────────────────
class _StickyStartDock extends StatelessWidget {
  const _StickyStartDock({required this.onStartTap});

  final VoidCallback onStartTap;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      color: Colors.white.withOpacity(0.95),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: bottomPadding + 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary CTA
          GestureDetector(
            onTap: onStartTap,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00d68f),
                    Color(0xFF00b779),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00d68f).withOpacity(0.28),
                    blurRadius: 32,
                    spreadRadius: -4,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow_rounded,
                        size: 18, color: Color(0xFF0f172a)),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Start Workout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0f172a),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // iOS home indicator
          const SizedBox(height: 8),
          Container(
            width: 120,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFcbd5e1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error / Not Found Bodies ─────────────────────────────────────────────────
class _NotFoundBody extends StatelessWidget {
  const _NotFoundBody({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded,
              size: 48, color: Color(0xFF94a3b8)),
          const SizedBox(height: 12),
          const Text(
            'Workout not found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: onBack,
            child: const Text('Go Back',
                style: TextStyle(color: Color(0xFF00d68f))),
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.error, required this.onBack});
  final Object error;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: Color(0xFFef4444)),
          const SizedBox(height: 12),
          Text(
            'Error: $error',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748b),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: onBack,
            child: const Text('Go Back',
                style: TextStyle(color: Color(0xFF00d68f))),
          ),
        ],
      ),
    );
  }
}
