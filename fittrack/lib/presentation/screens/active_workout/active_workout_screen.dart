import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/schedule_exercise.dart';
import '../../providers/active_workout_provider.dart';
import '../../widgets/ft_background_painter.dart';
import '../../widgets/modals/discard_workout_modal.dart';
import '../../widgets/modals/skip_exercise_modal.dart';
import '../../widgets/modals/workout_paused_modal.dart';
import 'widgets/active_rest_timer_card.dart';
import 'widgets/active_session_dock.dart';
import 'widgets/active_set_logging_card.dart';
import 'widgets/active_set_tracker.dart';
import 'widgets/active_up_next_section.dart';
import 'widgets/active_workout_header.dart';

/// Redesigned Active Workout Screen adhering strictly to Stitch Screen `7e785328b1f24951adf11ae52e15b460`
/// and AGENTS.md constitutional rules.
///
/// Features:
/// - Dynamic mesh gradient background (`FtMeshBackground`) and frosted glass surfaces.
/// - Top header with minimize button, split title, isolated stopwatch timer, and settings button.
/// - Active set logging card with exercise hero image, stepper weight & reps controls,
///   complete set gradient CTA, and skip exercise sub-action.
/// - Rest timer card with luminous circular dial, remaining countdown, time adjustment chips,
///   and start next set CTA. Rest timer triggers automatically when a set is completed.
/// - Unified set tracker row with checkmarks, active indicator, and `+ Set` button that dynamically
///   increments set count, preserving individual set weights.
/// - Up Next section displaying remaining exercises with order badges and finished/skipped exercises at the bottom.
/// - Floating session dock with Sets, Volume, and Energy metrics, Pause button, and End workout button.
/// - Back gesture ([PopScope]) launches Workout Paused modal.
/// - End workout launches Discard Workout Warning modal with 1.25s hold-to-discard protection.
/// - Modular decomposition with all files strictly under 400 lines.
class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({
    super.key,
    required this.scheduleId,
    this.customExercises,
  });

  final String scheduleId;
  final List<ScheduleExercise>? customExercises;

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final current = ref.read(activeWorkoutProvider);
        final isDifferent = current.schedule.id != widget.scheduleId;
        final isDeadPhase = current.phase == WorkoutPhase.error ||
            current.phase == WorkoutPhase.discarded ||
            current.phase == WorkoutPhase.finished;
        final needsInit = current.entries.isEmpty;

        if (isDifferent || isDeadPhase || needsInit) {
          ref.read(activeWorkoutProvider.notifier).startWorkout(
            widget.scheduleId,
            customExercises: widget.customExercises,
          );
        }
      });
    }
  }

  void _onPause(BuildContext context, ActiveWorkoutState state, ActiveWorkoutNotifier notifier) {
    showWorkoutPausedModal(
      context,
      state: state,
      notifier: notifier,
      onEndWorkout: () => _onDiscard(context, notifier),
    );
  }

  void _onDiscard(BuildContext context, ActiveWorkoutNotifier notifier) {
    notifier.discardSession();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/workouts');
    }
  }

  void _onSkipExercise(BuildContext context, ActiveWorkoutState state, ActiveWorkoutNotifier notifier) {
    showSkipExerciseModal(
      context,
      state: state,
      notifier: notifier,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeWorkoutProvider);
    final notifier = ref.read(activeWorkoutProvider.notifier);

    // ── Phase 1: Loading ────────────────────────────────────────────────────
    if (state.phase == WorkoutPhase.loading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ── Phase 2: Error ──────────────────────────────────────────────────────
    if (state.phase == WorkoutPhase.error) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(state.errorMessage ?? 'Error loading workout session'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    // ── Phase 3: Finished ───────────────────────────────────────────────────
    if (state.phase == WorkoutPhase.finished) {
      if (state.schedule.id == widget.scheduleId) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.pushReplacement('/workouts/summary');
        });
      }
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final entry = state.currentEntry;
    if (entry == null) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isResting = state.isResting;
    final currentSetNumber = state.currentSetIndex + 1;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onPause(context, state, notifier);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // 1. Dynamic Mesh Gradient Background
            const Positioned.fill(
              child: FtMeshBackground(),
            ),

            // 2. Scrollable Workout Content
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
                          6,
                          16,
                          bottomPadding + 140, // Clearance for sticky dock
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Session Header (Minimize, Split Title & Elapsed Timer, Settings)
                            ActiveWorkoutHeader(
                              schedule: state.schedule,
                              onMinimize: () => _onPause(context, state, notifier),
                              onSettings: () {
                                context.push('/settings/workout-preferences');
                              },
                            ),
                            const SizedBox(height: 12),

                            // Dynamic State Card: Active Set Logging OR Rest Timer Card
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 280),
                              child: isResting
                                  ? ActiveRestTimerCard(
                                      key: const ValueKey('rest_mode'),
                                      entry: entry,
                                      nextSetNumber: currentSetNumber + 1,
                                      onAdjustRest: notifier.adjustRestTime,
                                      onStartNextSet: () => notifier.skipRest(),
                                      onSkipRest: () => notifier.skipRest(),
                                    )
                                  : ActiveSetLoggingCard(
                                      key: ValueKey('active_set_${entry.exerciseId}_$currentSetNumber'),
                                      entry: entry,
                                      currentSetNumber: currentSetNumber,
                                      totalSets: entry.totalSets,
                                      onWeightAdjust: notifier.adjustWeight,
                                      onRepsAdjust: notifier.adjustReps,
                                      onCompleteSet: () {
                                        notifier.completeSet();
                                      },
                                      onSkipExercise: () =>
                                          _onSkipExercise(context, state, notifier),
                                    ),
                            ),
                            const SizedBox(height: 14),

                            // Unified Set Tracker Row (+ Set dynamically adds another set)
                            ActiveSetTracker(
                              totalSets: entry.totalSets,
                              currentSetIndex: state.currentSetIndex,
                              entry: entry,
                              completedSets: state.completedSets,
                              onAddSet: notifier.addSet,
                            ),
                            const SizedBox(height: 16),

                            // Up Next Section
                            ActiveUpNextSection(
                              upcomingEntries: state.upcomingEntries,
                              pastEntries: state.pastEntries,
                              skippedExerciseIds: state.skippedExerciseIds,
                              currentExerciseIndex: state.currentExerciseIndex,
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Floating Bottom Session Dock
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 393),
                  child: ActiveSessionDock(
                    state: state,
                    onPauseTap: () => _onPause(context, state, notifier),
                    onEndTap: () {
                      showDiscardWorkoutModal(
                        context,
                        state: state,
                        onDiscard: () => _onDiscard(context, notifier),
                      );
                    },
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
