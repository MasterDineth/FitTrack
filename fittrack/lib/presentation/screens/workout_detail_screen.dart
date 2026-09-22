import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/repository_providers.dart';
import '../providers/active_workout_provider.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/schedule_exercise.dart';
import '../../domain/entities/workout_schedule.dart';

/// Local private card decoration helper matching Stitch specifications.
BoxDecoration _buildCardDecoration(BuildContext context, {double radius = 16}) {
  final isLight = Theme.of(context).brightness == Brightness.light;
  final colorScheme = Theme.of(context).colorScheme;

  if (isLight) {
    return BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: const [
        BoxShadow(
          color: Color(0x080F172A),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
    );
  } else {
    return BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: colorScheme.outline),
    );
  }
}

/// Workout Detail Screen – shows the full routine breakdown for a given [scheduleId].
class WorkoutDetailScreen extends ConsumerWidget {
  const WorkoutDetailScreen({
    super.key,
    required this.scheduleId,
    this.workoutSchedule,
  });

  final String scheduleId;
  final WorkoutSchedule? workoutSchedule;

  Schedule _mapWorkoutSchedule(WorkoutSchedule ws) {
    return Schedule(
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
  }

  List<ScheduleExercise> _fallbackExercises(String schedId) {
    return [
      ScheduleExercise(
        id: '${schedId}_ex1',
        scheduleId: schedId,
        exerciseId: 'ex_barbell_bench_press',
        sortOrder: 1,
        targetSets: 4,
        targetReps: 6,
        targetWeightKg: 80.0,
        restDurationSeconds: 120,
      ),
      ScheduleExercise(
        id: '${schedId}_ex2',
        scheduleId: schedId,
        exerciseId: 'ex_incline_dumbbell_press',
        sortOrder: 2,
        targetSets: 3,
        targetReps: 8,
        targetWeightKg: 28.0,
        restDurationSeconds: 90,
      ),
      ScheduleExercise(
        id: '${schedId}_ex3',
        scheduleId: schedId,
        exerciseId: 'ex_cable_flyes',
        sortOrder: 3,
        targetSets: 3,
        targetReps: 10,
        targetWeightKg: 15.0,
        restDurationSeconds: 60,
      ),
      ScheduleExercise(
        id: '${schedId}_ex4',
        scheduleId: schedId,
        exerciseId: 'ex_overhead_press',
        sortOrder: 4,
        targetSets: 4,
        targetReps: 6,
        targetWeightKg: 50.0,
        restDurationSeconds: 120,
      ),
      ScheduleExercise(
        id: '${schedId}_ex5',
        scheduleId: schedId,
        exerciseId: 'ex_lateral_raises',
        sortOrder: 5,
        targetSets: 3,
        targetReps: 10,
        targetWeightKg: 12.0,
        restDurationSeconds: 60,
      ),
      ScheduleExercise(
        id: '${schedId}_ex6',
        scheduleId: schedId,
        exerciseId: 'ex_tricep_pushdowns',
        sortOrder: 6,
        targetSets: 4,
        targetReps: 10,
        targetWeightKg: 25.0,
        restDurationSeconds: 60,
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // If workoutSchedule was provided via extra, immediately render it
    if (workoutSchedule != null) {
      final effectiveSchedule = _mapWorkoutSchedule(workoutSchedule!);
      final effectiveExercises = workoutSchedule!.exercises.isNotEmpty
          ? workoutSchedule!.exercises
          : _fallbackExercises(scheduleId);

      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        bottomNavigationBar: _StickyStartDock(
          onStartTap: () {
            ref
                .read(activeWorkoutProvider.notifier)
                .startWorkout(scheduleId);
            context.push('/workouts/active/$scheduleId');
          },
        ),
        body: SafeArea(
          bottom: false,
          child: _DetailBody(
            schedule: effectiveSchedule,
            exercises: effectiveExercises,
            workoutSchedule: workoutSchedule,
          ),
        ),
      );
    }

    final scheduleRepo = ref.watch(scheduleRepositoryProvider);
    final colorScheme = theme.colorScheme;

    final scheduleAsync = ref.watch(
      _scheduleByIdProvider((scheduleRepo, scheduleId)),
    );
    final exercisesAsync = ref.watch(
      _scheduleExercisesDetailProvider((scheduleRepo, scheduleId)),
    );

    final fallbackExs = _fallbackExercises(scheduleId);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: _StickyStartDock(
        onStartTap: () {
          ref
              .read(activeWorkoutProvider.notifier)
              .startWorkout(scheduleId);
          context.push('/workouts/active/$scheduleId');
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
              data: (exercises) {
                final effectiveExercises =
                    exercises.isNotEmpty ? exercises : fallbackExs;
                return _DetailBody(
                  schedule: schedule,
                  exercises: effectiveExercises,
                  workoutSchedule: null,
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              ),
              error: (_, _) => _DetailBody(
                schedule: schedule,
                exercises: fallbackExs,
                workoutSchedule: null,
              ),
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          ),
          error: (e, _) => _ErrorBody(error: e, onBack: () => context.pop()),
        ),
      ),
    );
  }
}

// ── Scoped Providers ─────────────────────────────────────────────────────────

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
    this.workoutSchedule,
  });

  final Schedule schedule;
  final List<ScheduleExercise> exercises;
  final WorkoutSchedule? workoutSchedule;

  int get _totalSets => workoutSchedule != null && workoutSchedule!.exercises.isNotEmpty
      ? workoutSchedule!.exercises.fold(0, (sum, e) => sum + e.targetSets)
      : exercises.fold(0, (sum, e) => sum + e.targetSets);

  int get _estimatedMinutes {
    if (workoutSchedule != null && workoutSchedule!.estimatedMinutes > 0) {
      return workoutSchedule!.estimatedMinutes;
    }
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
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Top Navigation ─────────────────────────────────────────────
        SliverToBoxAdapter(
          child: _TopNav(
            title: workoutSchedule?.title ?? schedule.name,
          ),
        ),

        // ── Workout Header Section ──────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: _WorkoutHeaderSection(
              schedule: schedule,
              workoutSchedule: workoutSchedule,
            ),
          ),
        ),

        // ── Stat Grid ──────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _StatGrid(
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
                Text(
                  'ROUTINE BREAKDOWN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Icon(Icons.swap_vert_rounded,
                          size: 16, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Reorder',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Exercise List ───────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final ex = exercises[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ExerciseCard(
                    index: index,
                    exercise: ex,
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
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
            child: _AddExerciseButton(),
          ),
        ),

        // Bottom clearance for sticky dock
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}

// ── Top Navigation Bar ───────────────────────────────────────────────────────
class _TopNav extends StatelessWidget {
  const _TopNav({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
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
                color: colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Center App Bar Title
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Trailing action buttons
          _NavIconBtn(icon: Icons.share_outlined, onTap: () {}),
          const SizedBox(width: 8),
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
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Icon(
          icon,
          size: 17,
          color: colorScheme.onSurface.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

// ── Workout Header Section ───────────────────────────────────────────────────
class _WorkoutHeaderSection extends StatelessWidget {
  const _WorkoutHeaderSection({
    required this.schedule,
    this.workoutSchedule,
  });

  final Schedule schedule;
  final WorkoutSchedule? workoutSchedule;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final focusLabel = workoutSchedule?.focus.isNotEmpty == true
        ? workoutSchedule!.focus
        : (schedule.targetMuscles.isNotEmpty
            ? schedule.targetMuscles.first
            : 'Push Hypertrophy');
    final durationLabel = workoutSchedule != null && workoutSchedule!.durationWeeks > 0
        ? '${workoutSchedule!.durationWeeks} Weeks'
        : '8 Weeks';
    final frequencyLabel = workoutSchedule != null && workoutSchedule!.daysPerWeek > 0
        ? '${workoutSchedule!.daysPerWeek} Days/Week'
        : '${schedule.assignedWeekdays.length.clamp(3, 6)} Days/Week';
    final equipmentLabel = workoutSchedule?.equipment.isNotEmpty == true
        ? workoutSchedule!.equipment
        : 'Full Gym';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Eyebrow pill badge ─────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${focusLabel.toUpperCase()} • WEEK 3',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ── Major Title ────────────────────────────────────────────
        Text(
          schedule.name,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
            letterSpacing: -0.6,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),

        // ── Uniform Metadata Tags Row ──────────────────────────────
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MetaTagPill(
              label: focusLabel,
              hasMintDot: true,
            ),
            _MetaTagPill(
              label: equipmentLabel,
              hasMintDot: false,
            ),
            _MetaTagPill(
              label: durationLabel,
              hasMintDot: false,
            ),
            _MetaTagPill(
              label: frequencyLabel,
              hasMintDot: false,
            ),
          ],
        ),
      ],
    );
  }
}

class _MetaTagPill extends StatelessWidget {
  const _MetaTagPill({
    required this.label,
    required this.hasMintDot,
  });

  final String label;
  final bool hasMintDot;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: hasMintDot
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Grid ────────────────────────────────────────────────────────────────
class _StatGrid extends StatelessWidget {
  const _StatGrid({
    required this.exerciseCount,
    required this.totalSets,
    required this.estimatedMinutes,
    required this.estimatedCalories,
  });

  final int exerciseCount;
  final int totalSets;
  final int estimatedMinutes;
  final int estimatedCalories;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: _buildCardDecoration(context, radius: 20),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _StatColumn(
              icon: Icons.format_list_bulleted_rounded,
              value: '$exerciseCount',
              label: 'Exercises',
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
            _StatColumn(
              icon: Icons.repeat_rounded,
              value: '$totalSets',
              label: 'Total Sets',
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
            _StatColumn(
              icon: Icons.access_time_rounded,
              value: '${estimatedMinutes}m',
              label: 'Est. Time',
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
            _StatColumn(
              icon: Icons.local_fire_department_rounded,
              value: '~$estimatedCalories',
              label: 'Est. KCAL',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 17, color: colorScheme.primary),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Exercise Card ────────────────────────────────────────────────────────────
class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.index,
    required this.exercise,
  });

  final int index;
  final ScheduleExercise exercise;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final exerciseName = _resolveExerciseName(exercise.exerciseId, index);
    final muscleName = _resolveMuscle(exercise.exerciseId, index);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: _buildCardDecoration(context, radius: 18),
      child: Row(
        children: [
          // ── Sequence Circle (surfaceContainerHighest background, onSurface text) ──
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // ── Exercise Detail ────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exerciseName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    // Muscle tag with mint dot
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            muscleName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${exercise.targetSets} sets × ${exercise.targetReps} reps',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Trailing Chevron ───────────────────────────────────────
          Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurface.withValues(alpha: 0.35),
            size: 22,
          ),
        ],
      ),
    );
  }

  static const _exerciseNames = [
    'BB Bench Press',
    'Incline DB Press',
    'Cable Flyes',
    'Overhead Press',
    'Lateral Raises',
    'Tricep Pushdowns',
  ];

  static const _muscleLabels = [
    'Chest',
    'Chest',
    'Chest',
    'Shoulders',
    'Shoulders',
    'Triceps',
  ];

  String _resolveExerciseName(String exerciseId, int index) {
    if (exerciseId.startsWith('ex_')) {
      final raw = exerciseId.substring(3).replaceAll('_', ' ');
      return raw.split(' ').map((w) {
        if (w.isEmpty) return '';
        return '${w[0].toUpperCase()}${w.substring(1)}';
      }).join(' ');
    }
    if (index < _exerciseNames.length) return _exerciseNames[index];
    return 'Exercise ${index + 1}';
  }

  String _resolveMuscle(String exerciseId, int index) {
    final lower = exerciseId.toLowerCase();
    if (lower.contains('bench') ||
        lower.contains('chest') ||
        lower.contains('flyes') ||
        lower.contains('push_ups')) {
      return 'Chest';
    }
    if (lower.contains('squat') ||
        lower.contains('leg') ||
        lower.contains('calf')) {
      return 'Quads';
    }
    if (lower.contains('row') ||
        lower.contains('deadlift') ||
        lower.contains('lat') ||
        lower.contains('pull')) {
      return 'Back';
    }
    if (lower.contains('overhead') ||
        lower.contains('lateral') ||
        lower.contains('delt') ||
        lower.contains('shoulder')) {
      return 'Shoulders';
    }
    if (lower.contains('triceps') ||
        lower.contains('pushdown') ||
        lower.contains('skull') ||
        lower.contains('dips')) {
      return 'Triceps';
    }
    if (lower.contains('curl') || lower.contains('bicep')) {
      return 'Biceps';
    }
    if (lower.contains('abs') ||
        lower.contains('core') ||
        lower.contains('rollout')) {
      return 'Core';
    }
    if (index < _muscleLabels.length) return _muscleLabels[index];
    return 'Chest';
  }
}

// ── Add Exercise Button ──────────────────────────────────────────────────────
class _AddExerciseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_rounded,
            size: 18,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'ADD AN EXERCISE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
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
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.25),
          ),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: bottomPadding + 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onStartTap,
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isLight
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_arrow_rounded,
                    size: 22,
                    color: colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Start Workout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'Workout not found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: onBack,
            child: Text(
              'Go Back',
              style: TextStyle(color: colorScheme.primary),
            ),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(
            'Error: $error',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: onBack,
            child: Text(
              'Go Back',
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
