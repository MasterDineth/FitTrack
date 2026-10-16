import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/schedule.dart';
import '../../providers/active_workout_provider.dart';
import '../../providers/repository_providers.dart';
import '../../providers/schedules_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/ft_glass.dart';
import '../../widgets/exercise_picker/add_exercise_picker_sheet.dart';
import '../../widgets/ft_background_painter.dart';
import 'widgets/workout_detail_bento.dart';
import 'widgets/workout_detail_dock.dart';
import 'widgets/workout_detail_exercises.dart';
import 'widgets/workout_detail_header.dart';
import 'widgets/workout_detail_hero.dart';

/// Redesigned Workout Detail Screen adhering strictly to Stitch Screen `fc32d4d5a15441178564c24cb5dad0f4`
/// and AGENTS.md constitutional architecture rules.
///
/// Features:
/// - Dynamic mesh gradient background (`FtMeshBackground`) and frosted glass surfaces.
/// - Top header with Back button, Title & Subtitle, 3-dot popup menu.
/// - Routine focus badge with hero schedule card with frosted tags.
/// - 2x2 Telemetry Bento Grid (Exercises, Total sets, Est. time, Est. energy).
/// - Complete exercises list with expand/collapse set details and remove action.
/// - Temporary add/remove/reorder of exercises for current session forwarded to active workout
///   without mutating database records.
/// - AddExercisePickerSheet modal bottom sheet for adding exercises.
/// - Generous bottom scroll clearance (bottomPadding + 175) so "+ Add an exercise" is never eclipsed.
/// - Floating start workout dock calling `startWorkout` with custom exercises.
class WorkoutDetailScreen extends ConsumerStatefulWidget {
  const WorkoutDetailScreen({
    super.key,
    required this.scheduleId,
    this.workoutSchedule,
  });

  final String scheduleId;
  final WorkoutSchedule? workoutSchedule;

  @override
  ConsumerState<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
  List<ScheduleExercise>? _temporaryExercises;

  @override
  void didUpdateWidget(covariant WorkoutDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scheduleId != widget.scheduleId) {
      _temporaryExercises = null;
    }
  }

  void _onBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/workouts');
    }
  }

  void _onStartWorkout(BuildContext context, List<ScheduleExercise> currentList) {
    setState(() {
      _temporaryExercises = null;
    });
    ref.read(activeWorkoutProvider.notifier).startWorkout(
      widget.scheduleId,
      customExercises: currentList,
    );
    context.push('/workouts/active/${widget.scheduleId}', extra: currentList);
  }

  void _onAddExercise(BuildContext context, List<ScheduleExercise> currentList) {
    if (currentList.length >= 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Schedule is full (maximum 12 exercises reached)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.white,
            ),
          ),
          backgroundColor: context.ftPrimary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final themeSettings = ref.read(themeNotifierProvider);
    final enableTransparency = themeSettings.enableGlassTransparency;
    final blurIntensity = themeSettings.blurIntensity;
    final double t = ((blurIntensity - 4.0) / (32.0 - 4.0)).clamp(0.0, 1.0);
    final double scrimSigma = enableTransparency ? (6.0 + 10.0 * t) : 0.0;

    final sheet = AddExercisePickerSheet(
      currentExercisesCount: currentList.length,
      existingExerciseIds: currentList.map((e) => e.exerciseId).toSet(),
      onExercisesAdded: (selected) {
        setState(() {
          final updated = List<ScheduleExercise>.from(_temporaryExercises ?? currentList);
          for (int i = 0; i < selected.length; i++) {
            if (updated.length >= 12) break;
            final item = selected[i];
            if (updated.any((e) => e.exerciseId == item.exerciseId)) continue;
            updated.add(
              ScheduleExercise(
                id: 'temp_${DateTime.now().microsecondsSinceEpoch}_$i',
                scheduleId: widget.scheduleId,
                exerciseId: item.exerciseId,
                sortOrder: updated.length + 1,
                targetSets: item.targetSets,
                targetReps: item.targetReps,
                targetWeightKg: item.targetWeightKg,
                restDurationSeconds: item.restDurationSeconds,
              ),
            );
          }
          _temporaryExercises = updated;
        });
      },
      onCreateNew: () => context.push('/exercises/create-custom'),
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.45),
      builder: (_) => enableTransparency && scrimSigma > 0
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: scrimSigma, sigmaY: scrimSigma),
              child: sheet,
            )
          : sheet,
    );
  }

  void _onRemoveExercise(int index, List<ScheduleExercise> currentList) {
    setState(() {
      final updated = List<ScheduleExercise>.from(_temporaryExercises ?? currentList);
      if (index >= 0 && index < updated.length) {
        updated.removeAt(index);
        _temporaryExercises = updated;
      }
    });
  }

  void _onReorderExercises(int oldIndex, int newIndex, List<ScheduleExercise> currentList) {
    setState(() {
      final updated = List<ScheduleExercise>.from(_temporaryExercises ?? currentList);
      if (oldIndex < updated.length && newIndex < updated.length) {
        final item = updated.removeAt(oldIndex);
        updated.insert(newIndex, item);
        _temporaryExercises = updated;
      }
    });
  }

  Schedule _mapWorkoutSchedule(WorkoutSchedule ws) {
    return Schedule(
      id: ws.id,
      name: ws.title,
      description: ws.description,
      targetMuscles: ws.targetMuscles.isNotEmpty ? ws.targetMuscles : [ws.focus],
      assignedWeekdays: List.generate(
        ws.daysPerWeek.clamp(1, 7),
        (i) => i + 1,
      ),
      orderIndex: 0,
    );
  }

  List<ScheduleExercise> _fallbackExercises(String schedId) {
    const specs = [
      ('ex_barbell_bench_press', 4, 8, 85.0, 90),
      ('ex_incline_dumbbell_press', 3, 10, 30.0, 75),
      ('ex_standing_overhead_press', 4, 8, 52.5, 90),
      ('ex_cable_lateral_raise', 4, 15, 10.0, 60),
      ('ex_cable_chest_flyes', 3, 12, 15.0, 60),
      ('ex_overhead_triceps_extension', 3, 12, 25.0, 60),
    ];
    return [
      for (int i = 0; i < specs.length; i++)
        ScheduleExercise(
          id: '${schedId}_ex${i + 1}',
          scheduleId: schedId,
          exerciseId: specs[i].$1,
          sortOrder: i + 1,
          targetSets: specs[i].$2,
          targetReps: specs[i].$3,
          targetWeightKg: specs[i].$4,
          restDurationSeconds: specs[i].$5,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // 1. If workoutSchedule is passed in directly, render it immediately
    if (widget.workoutSchedule != null) {
      final effectiveSchedule = _mapWorkoutSchedule(widget.workoutSchedule!);
      final baseExercises = widget.workoutSchedule!.exercises.isNotEmpty
          ? widget.workoutSchedule!.exercises
          : _fallbackExercises(widget.scheduleId);
      final currentExercises = _temporaryExercises ?? baseExercises;

      return _WorkoutDetailScaffold(
        schedule: effectiveSchedule,
        workoutSchedule: widget.workoutSchedule,
        exercises: currentExercises,
        onBackTap: () => _onBack(context),
        onStartTap: () => _onStartWorkout(context, currentExercises),
        onAddExerciseTap: () => _onAddExercise(context, currentExercises),
        onRemoveExercise: (idx) => _onRemoveExercise(idx, currentExercises),
        onReorderExercises: (oldIdx, newIdx) => _onReorderExercises(oldIdx, newIdx, currentExercises),
      );
    }

    // 2. Otherwise load schedule & exercises from repositories or schedulesProvider
    final inMemorySchedules = ref.watch(schedulesProvider).allSchedules;
    final matchedWs = inMemorySchedules
        .where((s) => s.id == widget.scheduleId)
        .firstOrNull;

    if (matchedWs != null) {
      final effectiveSchedule = _mapWorkoutSchedule(matchedWs);
      final baseExercises = matchedWs.exercises.isNotEmpty
          ? matchedWs.exercises
          : _fallbackExercises(widget.scheduleId);
      final currentExercises = _temporaryExercises ?? baseExercises;

      return _WorkoutDetailScaffold(
        schedule: effectiveSchedule,
        workoutSchedule: matchedWs,
        exercises: currentExercises,
        onBackTap: () => _onBack(context),
        onStartTap: () => _onStartWorkout(context, currentExercises),
        onAddExerciseTap: () => _onAddExercise(context, currentExercises),
        onRemoveExercise: (idx) => _onRemoveExercise(idx, currentExercises),
        onReorderExercises: (oldIdx, newIdx) => _onReorderExercises(oldIdx, newIdx, currentExercises),
      );
    }

    // SQLite repository async loading
    final scheduleAsync = ref.watch(_scheduleByIdProvider(widget.scheduleId));
    final exercisesAsync = ref.watch(_scheduleExercisesDetailProvider(widget.scheduleId));

    return scheduleAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) {
        final currentExercises = _temporaryExercises ?? _fallbackExercises(widget.scheduleId);
        return _WorkoutDetailScaffold(
          schedule: Schedule(
            id: widget.scheduleId,
            name: 'Push–Pull–Legs Split',
            description: '',
            targetMuscles: const ['Chest', 'Shoulders', 'Triceps'],
            assignedWeekdays: const [1, 3, 5],
            orderIndex: 0,
          ),
          workoutSchedule: null,
          exercises: currentExercises,
          onBackTap: () => _onBack(context),
          onStartTap: () => _onStartWorkout(context, currentExercises),
          onAddExerciseTap: () => _onAddExercise(context, currentExercises),
          onRemoveExercise: (idx) => _onRemoveExercise(idx, currentExercises),
          onReorderExercises: (oldIdx, newIdx) => _onReorderExercises(oldIdx, newIdx, currentExercises),
        );
      },
      data: (schedule) {
        final effectiveSchedule = schedule ??
            Schedule(
              id: widget.scheduleId,
              name: 'Push–Pull–Legs Split',
              description: '',
              targetMuscles: const ['Chest', 'Shoulders', 'Triceps'],
              assignedWeekdays: const [1, 3, 5],
              orderIndex: 0,
            );

        final exercises = exercisesAsync.value ?? const [];
        final baseExercises =
            exercises.isNotEmpty ? exercises : _fallbackExercises(widget.scheduleId);
        final currentExercises = _temporaryExercises ?? baseExercises;

        return _WorkoutDetailScaffold(
          schedule: effectiveSchedule,
          workoutSchedule: null,
          exercises: currentExercises,
          onBackTap: () => _onBack(context),
          onStartTap: () => _onStartWorkout(context, currentExercises),
          onAddExerciseTap: () => _onAddExercise(context, currentExercises),
          onRemoveExercise: (idx) => _onRemoveExercise(idx, currentExercises),
          onReorderExercises: (oldIdx, newIdx) => _onReorderExercises(oldIdx, newIdx, currentExercises),
        );
      },
    );
  }
}

class _WorkoutDetailScaffold extends StatelessWidget {
  const _WorkoutDetailScaffold({
    required this.schedule,
    required this.workoutSchedule,
    required this.exercises,
    required this.onBackTap,
    required this.onStartTap,
    required this.onAddExerciseTap,
    required this.onRemoveExercise,
    required this.onReorderExercises,
  });

  final Schedule schedule;
  final WorkoutSchedule? workoutSchedule;
  final List<ScheduleExercise> exercises;
  final VoidCallback onBackTap;
  final VoidCallback onStartTap;
  final VoidCallback onAddExerciseTap;
  final void Function(int index) onRemoveExercise;
  final void Function(int oldIndex, int newIndex) onReorderExercises;

  @override
  Widget build(BuildContext context) {
    final totalSets = exercises.fold<int>(0, (sum, e) => sum + e.targetSets);
    final exerciseCount = exercises.length;

    final estMinutes = workoutSchedule?.estimatedMinutes != null &&
            workoutSchedule!.estimatedMinutes > 0
        ? workoutSchedule!.estimatedMinutes
        : (totalSets * 2.5 + exerciseCount * 2).clamp(30, 90).toInt();

    final estCalories = (estMinutes * 6.5).round();

    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        onBackTap();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // 1. Dynamic Luminous Mesh Background
            const Positioned.fill(
              child: FtMeshBackground(),
            ),

            // 2. Scrollable Body Content
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 393),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverSafeArea(
                      top: true,
                      bottom: false,
                      sliver: SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          8,
                          16,
                          bottomPadding + 175, // Generous clearance so Add Exercise is fully visible above dock
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Navigation Header
                            WorkoutDetailHeader(onBackTap: onBackTap),
                            const SizedBox(height: 14),

                            // Hero Preview Card & Focus Tag
                            WorkoutDetailHero(
                              schedule: schedule,
                              workoutSchedule: workoutSchedule,
                              totalSets: totalSets,
                              exerciseCount: exerciseCount,
                            ),
                            const SizedBox(height: 16),

                            // 2x2 Telemetry Bento Grid
                            WorkoutDetailBento(
                              exerciseCount: exerciseCount,
                              totalSets: totalSets,
                              estimatedMinutes: estMinutes,
                              estimatedCalories: estCalories,
                            ),
                            const SizedBox(height: 18),

                            // Exercises Breakdown List
                            WorkoutDetailExercises(
                              exercises: exercises,
                              onAddExerciseTap: onAddExerciseTap,
                              onRemoveExercise: onRemoveExercise,
                              onReorderExercises: onReorderExercises,
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Floating Start Workout Sticky Dock
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 393),
                  child: WorkoutDetailDock(
                    estimatedMinutes: estMinutes,
                    totalSets: totalSets,
                    onStartTap: onStartTap,
                    bottomOffset: bottomPadding,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private SQLite Providers ──────────────────────────────────────────────────

final _scheduleByIdProvider = FutureProvider.autoDispose
    .family<Schedule?, String>((ref, id) async {
  return ref.watch(scheduleRepositoryProvider).getScheduleById(id);
});

final _scheduleExercisesDetailProvider = FutureProvider.autoDispose
    .family<List<ScheduleExercise>, String>((ref, id) async {
  return ref.watch(scheduleRepositoryProvider).getScheduleExercises(id);
});
