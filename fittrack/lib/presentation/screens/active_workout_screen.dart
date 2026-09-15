import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/active_workout_provider.dart';
import '../widgets/active_rest_timer_view.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key, required this.scheduleId});
  final String scheduleId;

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState
    extends ConsumerState<ActiveWorkoutScreen> {
  static const Color _bg = Color(0xFFf7f9fb);

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(activeWorkoutProvider.notifier)
            .startSession(widget.scheduleId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeWorkoutProvider);
    final notifier = ref.read(activeWorkoutProvider.notifier);

    // ── Loading ──────────────────────────────────────────────────────────────
    if (state.phase == WorkoutPhase.loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFf7f9fb),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00d68f)),
        ),
      );
    }

    // ── Error ────────────────────────────────────────────────────────────────
    if (state.phase == WorkoutPhase.error) {
      return Scaffold(
        backgroundColor: _bg,
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

    // ── Finished ─────────────────────────────────────────────────────────────
    if (state.phase == WorkoutPhase.finished) {
      return Scaffold(
        backgroundColor: _bg,
        body: _FinishedView(state: state, onDismiss: () => context.pop()),
      );
    }

    final entry = state.currentEntry;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Scrollable body ─────────────────────────────────────────
            CustomScrollView(
              slivers: [
                // Sticky header
                SliverAppBar(
                  pinned: true,
                  backgroundColor: _bg.withValues(alpha: 0.95),
                  elevation: 0,
                  scrolledUnderElevation: 1,
                  automaticallyImplyLeading: false,
                  title: _WorkoutHeader(state: state),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Active card OR rest timer
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
                            ? const ActiveRestTimerView(
                                key: ValueKey('rest'))
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

                      // Upcoming queue
                      if (state.upcomingEntries.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _UpcomingQueue(entries: state.upcomingEntries),
                      ],
                    ]),
                  ),
                ),
              ],
            ),

            // ── Sticky footer ───────────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _SessionFooter(state: state, notifier: notifier),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _WorkoutHeader extends StatelessWidget {
  const _WorkoutHeader({required this.state});
  final ActiveWorkoutState state;

  @override
  Widget build(BuildContext context) {
    final isPaused = state.phase == WorkoutPhase.paused;

    return Row(
      children: [
        // Minimize
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFe2e8f0)),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: const Icon(Icons.keyboard_arrow_down,
                color: Color(0xFF475569), size: 22),
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
                style: const TextStyle(
                  color: Color(0xFF0f172a),
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
          onTap: () {},
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFe2e8f0)),
            ),
            child: const Icon(Icons.settings_outlined,
                color: Color(0xFF475569), size: 18),
          ),
        ),
      ],
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
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF00d68f),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF166534), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 20,
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
                      style: const TextStyle(
                        color: Color(0xFF0f172a),
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
                            style: const TextStyle(
                              color: Color(0xFF0f172a),
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
                    color: const Color(0xFFf0fdf4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFbbf7d0)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'TARGET REPS',
                        style: TextStyle(
                          color: Color(0xFF166534),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        '${entry.targetReps} reps',
                        style: const TextStyle(
                          color: Color(0xFF14532d),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          fontFeatures: [FontFeature.tabularFigures()],
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
              color: const Color(0xFFf8fafc),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFe2e8f0)),
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
                        captionColor: const Color(0xFF64748b),
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
                        captionColor: const Color(0xFF059669),
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
                        const Icon(Icons.timer_outlined,
                            size: 13, color: Color(0xFF00875a)),
                        const SizedBox(width: 4),
                        Text(
                          'Rest timer: ${entry.restDurationSeconds}s on complete',
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Edit',
                        style: TextStyle(
                          color: Color(0xFF0f172a),
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
                backgroundColor: const Color(0xFF166534),
                foregroundColor: Colors.white,
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
              onPressed: notifier.skipExercise,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF166534),
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
    Color bg;
    Color fg;
    Widget child;

    if (isCompleted) {
      bg = const Color(0xFF166534);
      fg = Colors.white;
      child = const Icon(Icons.check, size: 16, color: Colors.white);
    } else if (isActive) {
      bg = const Color(0xFF166534);
      fg = Colors.white;
      child = Text(
        '$setNumber',
        style: const TextStyle(
          color: Colors.white,
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
                    const BoxShadow(
                      color: Color(0x5000d68f),
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
                ? const Color(0xFF166534)
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

class _UpcomingQueue extends StatelessWidget {
  const _UpcomingQueue({required this.entries});
  final List<LiveExerciseEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
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
        ...entries.take(3).map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _UpcomingCard(entry: e),
              ),
            ),
      ],
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
        color: Colors.white,
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
                  style: const TextStyle(
                    color: Color(0xFF0f172a),
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
  const _SessionFooter(
      {required this.state, required this.notifier});
  final ActiveWorkoutState state;
  final ActiveWorkoutNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final isPaused = state.phase == WorkoutPhase.paused;

    return Container(
      padding:
          const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, -4),
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
                  onPressed: notifier.togglePause,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0f172a),
                    side: const BorderSide(color: Color(0xFFe2e8f0)),
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
                  onPressed: () =>
                      _confirmStop(context, notifier),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFef4444),
                    foregroundColor: Colors.white,
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
    );
  }

  Future<void> _confirmStop(
      BuildContext context, ActiveWorkoutNotifier notifier) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Stop Session?'),
        content: const Text(
            'Your progress will be saved. Are you sure you want to end this workout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFef4444)),
            child: const Text('Stop'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await notifier.stopSession();
    }
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
            color: Color(0xFF94a3b8),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF0f172a),
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
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFe2e8f0)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x05000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF64748b),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFf1f5f9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Color(0xFF64748b),
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
                style: const TextStyle(
                  color: Color(0xFF0f172a),
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  fontFeatures: [FontFeature.tabularFigures()],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFf1f5f9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF475569)),
      ),
    );
  }
}

// ── Finished View ─────────────────────────────────────────────────────────────

class _FinishedView extends StatelessWidget {
  const _FinishedView({required this.state, required this.onDismiss});
  final ActiveWorkoutState state;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFe6faf3),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00d68f).withValues(alpha: 0.3),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.emoji_events,
                  color: Color(0xFF00d68f), size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'Workout Complete!',
              style: TextStyle(
                color: Color(0xFF0f172a),
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${state.completedSetCount} sets · ${state.estimatedCalories} kcal · ${state.elapsedFormatted}',
              style: const TextStyle(
                color: Color(0xFF64748b),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00d68f),
                  foregroundColor: const Color(0xFF0f172a),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Back to Dashboard',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
