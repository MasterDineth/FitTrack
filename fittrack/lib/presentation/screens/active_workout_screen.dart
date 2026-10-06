import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/active_workout_provider.dart';
import '../widgets/active_rest_timer_view.dart';
import '../widgets/modals/skip_exercise_modal.dart';
import '../widgets/modals/workout_paused_modal.dart';
import '../widgets/modals/end_workout_early_modal.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key, required this.scheduleId});
  final String scheduleId;

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState
    extends ConsumerState<ActiveWorkoutScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final current = ref.read(activeWorkoutProvider);
        if (current.schedule.id != widget.scheduleId ||
            current.phase == WorkoutPhase.loading ||
            current.phase == WorkoutPhase.error ||
            current.phase == WorkoutPhase.discarded ||
            current.phase == WorkoutPhase.finished) {
          ref
              .read(activeWorkoutProvider.notifier)
              .startWorkout(widget.scheduleId);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeWorkoutProvider);
    final notifier = ref.read(activeWorkoutProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // ── Loading ──────────────────────────────────────────────────────────────
    if (state.phase == WorkoutPhase.loading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    // ── Error ────────────────────────────────────────────────────────────────
    if (state.phase == WorkoutPhase.error) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(state.errorMessage ?? 'Error loading session'),
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

    // ── Finished ────────────────────────────────────────────────────────────────
    if (state.phase == WorkoutPhase.finished) {
      // Navigate to summary once the phase flips to finished (from stopSession)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pushReplacement('/workouts/summary');
      });
      // Show a transient loading scaffold while navigation happens
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    final entry = state.currentEntry;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showPaused(context, state, notifier);
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            // ── Scrollable body ─────────────────────────────────────────
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    MediaQuery.paddingOf(context).top + 68,
                    16,
                    MediaQuery.paddingOf(context).bottom + 130,
                  ),
                  sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Render the entire list: Past, Active, and Upcoming
                        ...state.entries.asMap().entries.map((mapEntry) {
                          final index = mapEntry.key;
                          final loopEntry = mapEntry.value;

                          if (index < state.currentExerciseIndex) {
                            final isFirstPast = index == 0;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isFirstPast)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 4, bottom: 8, top: 4),
                                    child: Text(
                                      'COMPLETED',
                                      style: TextStyle(
                                        color: Color(0xFF94a3b8),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.6,
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: _PastCard(entry: loopEntry),
                                ),
                              ],
                            );
                          } else if (index == state.currentExerciseIndex) {
                            final isFirstUpcomingAfterPast = state.currentExerciseIndex > 0;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isFirstUpcomingAfterPast)
                                  const SizedBox(height: 8),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 350),
                                  transitionBuilder: (child, animation) =>
                                      FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.08),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOut,
                                      )),
                                      child: child,
                                    ),
                                  ),
                                  child: state.isResting
                                      ? const ActiveRestTimerView(key: ValueKey('rest'))
                                      : entry != null
                                          ? _ActiveExerciseCard(
                                              key: ValueKey(
                                                  '${entry.exerciseId}-${state.currentSetIndex}'),
                                              state: state,
                                              notifier: notifier,
                                              scheduleId: widget.scheduleId,
                                            )
                                          : const SizedBox.shrink(),
                                ),
                              ],
                            );
                          } else {
                            final isFirstUpcoming = index == state.currentExerciseIndex + 1;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isFirstUpcoming)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 4, bottom: 8, top: 16),
                                    child: Text(
                                      'UPCOMING',
                                      style: TextStyle(
                                        color: Color(0xFF94a3b8),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.6,
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: _UpcomingCard(entry: loopEntry),
                                ),
                              ],
                            );
                          }
                        }),
                      ]),
                    ),
                  ),
                ],
              ),

            // ── Sticky header ───────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _WorkoutHeader(
                state: state,
                onSettingsTap: () => _showSessionOptions(context, state, notifier),
              ),
            ),

            // ── Sticky footer ───────────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _SessionFooter(
                state: state,
                notifier: notifier,
                onPause: () => _showPaused(context, state, notifier),
                onStop: () => _showEndEarly(context, state, notifier),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaused(
    BuildContext context,
    ActiveWorkoutState state,
    ActiveWorkoutNotifier notifier,
  ) {
    showWorkoutPausedModal(
      context,
      state: state,
      notifier: notifier,
      onEndWorkout: () => _showEndEarly(context, state, notifier),
    );
  }

  void _showEndEarly(
    BuildContext context,
    ActiveWorkoutState state,
    ActiveWorkoutNotifier notifier,
  ) {
    showEndWorkoutEarlyModal(
      context,
      state: state,
      notifier: notifier,
      onFinishAndSave: ({String? notes, String? intensity}) async {
        await notifier.stopSession();
      },
      onDiscard: () {
        notifier.discardSession();
        if (context.mounted && context.canPop()) {
          context.pop();
        }
      },
    );
  }

  void _showSessionOptions(
    BuildContext context,
    ActiveWorkoutState state,
    ActiveWorkoutNotifier notifier,
  ) {
    _showEndEarly(context, state, notifier);
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _WorkoutHeader extends StatelessWidget {
  const _WorkoutHeader({
    required this.state,
    this.onSettingsTap,
  });
  final ActiveWorkoutState state;
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final isPaused = state.phase == WorkoutPhase.paused;
    final topPadding = MediaQuery.paddingOf(context).top;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          padding: EdgeInsets.only(
            top: topPadding + 12,
            left: 16,
            right: 16,
            bottom: 12,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.85),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Minimize
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Icon(Icons.keyboard_arrow_down,
                      color: Theme.of(context).colorScheme.onSurface, size: 22),
                ),
              ),
              const SizedBox(width: 10),

              // Title + timer pill
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.schedule.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (!isPaused)
                          _PulseDot()
                        else
                          const Icon(Icons.pause_circle,
                              color: Color(0xFFf59e0b), size: 10),
                        const SizedBox(width: 4),
                        Text(
                          state.elapsedFormatted,
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isPaused
                                ? const Color(0xFFfef3c7)
                                : const Color(0xFFe6faf3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isPaused ? 'PAUSED' : 'ACTIVE',
                            style: TextStyle(
                              color: isPaused
                                  ? const Color(0xFFd97706)
                                  : const Color(0xFF00875a),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Settings cog
              GestureDetector(
                onTap: onSettingsTap,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Icon(Icons.settings_outlined,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pulsating dot ─────────────────────────────────────────────────────────────

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ── Active Exercise Card ──────────────────────────────────────────────────────

class _ActiveExerciseCard extends StatelessWidget {
  const _ActiveExerciseCard({
    super.key,
    required this.state,
    required this.notifier,
    required this.scheduleId,
  });
  final ActiveWorkoutState state;
  final ActiveWorkoutNotifier notifier;
  final String scheduleId;

  @override
  Widget build(BuildContext context) {
    final entry = state.currentEntry!;
    final setIndex = state.currentSetIndex;
    final totalSets = entry.totalSets;

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          // Theme ambient glow
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.18),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 22,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
          const BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tags
                    Row(
                      children: [
                        _Tag(
                          label: entry.exercise.movementClassification.name
                              .toUpperCase(),
                          bg: const Color(0xFFfff1f2),
                          fg: const Color(0xFFe11d48),
                          border: const Color(0xFFfecdd3),
                        ),
                        const SizedBox(width: 6),
                        _Tag(
                          label: entry.exercise.equipment.name.toUpperCase(),
                          bg: const Color(0xFFf1f5f9),
                          fg: const Color(0xFF475569),
                          border: const Color(0xFFe2e8f0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              // Info button → exercise guide
              GestureDetector(
                onTap: () => context
                    .push('/workouts/guide/${entry.exerciseId}'),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFf1f5f9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFe2e8f0)),
                  ),
                  child: const Icon(Icons.info_outline,
                      size: 16, color: Color(0xFF64748b)),
                ),
              ),
            ],
          ),

          // Current phase row
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFf1f5f9)),
                bottom: BorderSide(color: Color(0xFFf1f5f9)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CURRENT PHASE',
                      style: TextStyle(
                        color: Color(0xFF94a3b8),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Set ${setIndex + 1} ',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          TextSpan(
                            text: 'of $totalSets',
                            style: const TextStyle(
                              color: Color(0xFF64748b),
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'TARGET REPS',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        '${entry.targetReps} reps',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Stepper inputs
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StepperInput(
                        label: 'WEIGHT',
                        badge: 'KG',
                        value:
                            entry.liveWeightKg.toStringAsFixed(
                                entry.liveWeightKg % 1 == 0 ? 0 : 1),
                        caption: 'Prev: ${entry.targetWeightKg.toStringAsFixed(entry.targetWeightKg % 1 == 0 ? 0 : 1)} kg',
                        onDecrement: () =>
                            notifier.adjustWeight(-2.5),
                        onIncrement: () =>
                            notifier.adjustWeight(2.5),
                        captionColor: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StepperInput(
                        label: 'REPS',
                        badge: 'COUNT',
                        value: entry.liveReps.toString(),
                        caption:
                            'Target: ${entry.targetReps}',
                        onDecrement: () => notifier.adjustReps(-1),
                        onIncrement: () => notifier.adjustReps(1),
                        captionColor: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Rest notice
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.timer_outlined,
                            size: 13, color: colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Rest timer: ${entry.restDurationSeconds}s on complete',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Complete Set CTA
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: notifier.completeSet,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.check, size: 20),
              label: const Text(
                'COMPLETE SET',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          // Skip exercise
          Center(
            child: TextButton.icon(
              onPressed: () {
                final currentEntry = state.currentEntry;
                if (currentEntry == null) return;

                // Build next exercise info (if any)
                final nextIndex = state.currentExerciseIndex + 1;
                final hasNext = nextIndex < state.entries.length;
                final nextEntry =
                    hasNext ? state.entries[nextIndex] : null;

                final args = SkipExerciseArgs(
                  currentExerciseName: currentEntry.name,
                  currentExerciseMuscleTag:
                      currentEntry.exercise.movementClassification
                          .name.toUpperCase(),
                  currentSetIndex: state.currentSetIndex,
                  totalSets: currentEntry.totalSets,
                  nextExerciseName: nextEntry?.name,
                  nextExerciseSets: nextEntry?.totalSets,
                  nextExerciseReps: nextEntry?.targetReps,
                );

                showSkipExerciseModal(context, args: args);
              },
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
              ),
              icon: const Icon(Icons.skip_next, size: 14),
              label: const Text(
                'Skip Exercise',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          ),

          // Sets carousel
          const SizedBox(height: 4),
          _SetsCarousel(
            state: state,
            onAddSet: notifier.addSet,
          ),
        ],
      ),
    );
  }
}

// ── Sets Carousel ─────────────────────────────────────────────────────────────

class _SetsCarousel extends StatelessWidget {
  const _SetsCarousel({required this.state, required this.onAddSet});
  final ActiveWorkoutState state;
  final VoidCallback onAddSet;

  @override
  Widget build(BuildContext context) {
    final entry = state.currentEntry!;
    final currentSet = state.currentSetIndex;
    final completedForExercise = state.completedSets
        .where((s) => s.exerciseId == entry.exerciseId)
        .length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < entry.totalSets; i++) ...[
          _SetBadge(
            setNumber: i + 1,
            isCompleted: i < completedForExercise,
            isActive: i == currentSet,
            weightLabel: entry.liveWeightKg.toStringAsFixed(
                entry.liveWeightKg % 1 == 0 ? 0 : 1),
          ),
          const SizedBox(width: 10),
        ],
        // + Set
        Column(
          children: [
            GestureDetector(
              onTap: onAddSet,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFcbd5e1),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.add,
                    size: 16, color: Color(0xFF64748b)),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '+ Set',
              style: TextStyle(
                color: Color(0xFF64748b),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SetBadge extends StatelessWidget {
  const _SetBadge({
    required this.setNumber,
    required this.isCompleted,
    required this.isActive,
    required this.weightLabel,
  });
  final int setNumber;
  final bool isCompleted;
  final bool isActive;
  final String weightLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Color bg;
    Color fg;
    Widget child;

    if (isCompleted) {
      bg = colorScheme.primary;
      fg = colorScheme.onPrimary;
      child = Icon(Icons.check, size: 16, color: colorScheme.onPrimary);
    } else if (isActive) {
      bg = colorScheme.primary;
      fg = colorScheme.onPrimary;
      child = Text(
        '$setNumber',
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
      );
    } else {
      bg = const Color(0xFFf1f5f9);
      fg = const Color(0xFF475569);
      child = Text(
        '$setNumber',
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.35),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: Center(child: child),
        ),
        const SizedBox(height: 4),
        Text(
          isCompleted
              ? '✓'
              : isActive
                  ? 'Active'
                  : '$weightLabel kg',
          style: TextStyle(
            color: isActive
                ? colorScheme.primary
                : const Color(0xFF64748b),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ── Upcoming Queue ────────────────────────────────────────────────────────────

class _PastCard extends StatelessWidget {
  const _PastCard({required this.entry});
  final LiveExerciseEntry entry;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.6,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFf8fafc),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFe2e8f0)),
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    style: const TextStyle(
                      color: Color(0xFF64748b),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Completed',
                    style: TextStyle(
                      color: Color(0xFF94a3b8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.entry});
  final LiveExerciseEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFe2e8f0),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.totalSets} sets × ${entry.targetReps} reps · ${entry.targetWeightKg.toStringAsFixed(entry.targetWeightKg % 1 == 0 ? 0 : 1)} kg',
                  style: const TextStyle(
                    color: Color(0xFF64748b),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.drag_handle, color: Color(0xFFcbd5e1)),
        ],
      ),
    );
  }
}

// ── Session Footer ────────────────────────────────────────────────────────────

class _SessionFooter extends StatelessWidget {
  const _SessionFooter({
    required this.state,
    required this.notifier,
    required this.onPause,
    required this.onStop,
  });
  final ActiveWorkoutState state;
  final ActiveWorkoutNotifier notifier;
  final VoidCallback onPause;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final isPaused = state.phase == WorkoutPhase.paused;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.only(
            left: 16,
            top: 12,
            right: 16,
            bottom: bottomPadding + 16,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Metrics row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MetricChip(
                    label: 'DONE',
                    value:
                        '${state.completedSetCount}/${state.totalSetCount}',
                  ),
                  _MetricChip(
                    label: 'KCAL',
                    value: '~${state.estimatedCalories}',
                  ),
                  _MetricChip(
                    label: 'TIME',
                    value: state.elapsedFormatted,
                    mono: true,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isPaused ? notifier.resumeSession : onPause,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        foregroundColor: Theme.of(context).colorScheme.onSurface,
                        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: Icon(
                        isPaused ? Icons.play_arrow : Icons.pause,
                        size: 18,
                      ),
                      label: Text(
                        isPaused ? 'Resume' : 'Pause',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onStop,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.stop, size: 18),
                      label: const Text(
                        'Stop Session',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip(
      {required this.label, required this.value, this.mono = false});
  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748b),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 15,
            fontFeatures: mono ? const [FontFeature.tabularFigures()] : null,
          ),
        ),
      ],
    );
  }
}

// ── Tags ──────────────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.bg,
    required this.fg,
    required this.border,
  });
  final String label;
  final Color bg;
  final Color fg;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ── Stepper Input ─────────────────────────────────────────────────────────────

class _StepperInput extends StatelessWidget {
  const _StepperInput({
    required this.label,
    required this.badge,
    required this.value,
    required this.caption,
    required this.onDecrement,
    required this.onIncrement,
    required this.captionColor,
  });
  final String label;
  final String badge;
  final String value;
  final String caption;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final Color captionColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StepBtn(icon: Icons.remove, onTap: onDecrement),
              Text(
                value,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              _StepBtn(icon: Icons.add, onTap: onIncrement),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            style: TextStyle(
              color: captionColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: colorScheme.onSurface),
      ),
    );
  }
}


