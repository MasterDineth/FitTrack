import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/active_workout_provider.dart';
import '../widgets/modals/leave_without_saving_modal.dart';

class WorkoutSummaryScreen extends ConsumerStatefulWidget {
  const WorkoutSummaryScreen({super.key});

  @override
  ConsumerState<WorkoutSummaryScreen> createState() =>
      _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState
    extends ConsumerState<WorkoutSummaryScreen>
    with TickerProviderStateMixin {
  // Feeling selector
  static const _feelings = ['Easy', 'Moderate', 'Intense', 'Extreme'];
  int _selectedFeeling = 1; // default: Moderate

  // Notes
  final _notesController = TextEditingController();

  // Bounce animation for trophy
  late final AnimationController _trophyCtrl;
  late final Animation<double> _trophyScale;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _trophyCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _trophyScale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _trophyCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _trophyCtrl.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final notifier = ref.read(activeWorkoutProvider.notifier);
    final intensity = _feelings[_selectedFeeling];
    final notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();

    await notifier.finishSession(notes: notes, intensity: intensity);

    if (mounted) {
      HapticFeedback.mediumImpact();
      context.go('/history');
    }
  }

  Future<bool> _onWillPop() async {
    return await showLeaveWithoutSavingModal(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final workoutState = ref.watch(activeWorkoutProvider);
    final schedule = workoutState.schedule;

    final totalMinutes = workoutState.elapsedSeconds ~/ 60;
    final secs = workoutState.elapsedSeconds % 60;
    final timeStr =
        '${totalMinutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    final completedExercises = workoutState.entries
        .where(
          (e) => workoutState.completedSets
              .any((s) => s.exerciseId == e.exerciseId),
        )
        .length;
    final totalExercises = workoutState.entries.length;
    final totalSets = workoutState.completedSetCount;
    final totalReps =
        workoutState.completedSets.fold(0, (s, e) => s + e.actualReps);
    final totalVolumeKg = workoutState.completedSets
        .fold(0.0, (s, e) => s + e.actualWeightKg * e.actualReps);
    final calories = workoutState.estimatedCalories;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final router = GoRouter.of(context);
        final leave = await _onWillPop();
        if (leave && mounted) router.go('/dashboard');
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // ── Top nav ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    // Primary dot
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'WORKOUT COMPLETE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    // Share placeholder
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.share_outlined,
                        size: 20,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Scrollable body ──────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  child: Column(
                    children: [
                      // ── Trophy Hero ───────────────────────────────────────
                      _TrophyHeroSection(
                        trophyScale: _trophyScale,
                        scheduleName: schedule.name,
                        completedExercises: completedExercises,
                        totalExercises: totalExercises,
                      ),

                      const SizedBox(height: 20),

                      // ── Stats card ────────────────────────────────────────
                      _StatsCard(
                        scheduleName: schedule.name,
                        timeStr: timeStr,
                        completedExercises: completedExercises,
                        totalExercises: totalExercises,
                        totalSets: totalSets,
                        totalReps: totalReps,
                        totalVolumeKg: totalVolumeKg,
                        calories: calories,
                      ),

                      const SizedBox(height: 16),

                      // ── Feeling selector ──────────────────────────────────
                      _FeelingSelector(
                        selected: _selectedFeeling,
                        onChanged: (i) =>
                            setState(() => _selectedFeeling = i),
                      ),

                      const SizedBox(height: 16),

                      // ── Session notes ─────────────────────────────────────
                      _NotesInput(controller: _notesController),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Floating Save CTA ──────────────────────────────────────────────
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
            bottom: MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(context).padding.bottom +
                14,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _saving
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : const Text(
                    'Save & Finish',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 17),
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Trophy Hero Section ───────────────────────────────────────────────────────

class _TrophyHeroSection extends StatelessWidget {
  const _TrophyHeroSection({
    required this.trophyScale,
    required this.scheduleName,
    required this.completedExercises,
    required this.totalExercises,
  });

  final Animation<double> trophyScale;
  final String scheduleName;
  final int completedExercises;
  final int totalExercises;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pct =
        totalExercises == 0 ? 100 : (completedExercises * 100 ~/ totalExercises);
    return Column(
      children: [
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            // Background halo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFfef3c7).withValues(alpha: 0.8),
                    colorScheme.primary.withValues(alpha: 0.1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFf59e0b).withValues(alpha: 0.2),
                    blurRadius: 32,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
            // Trophy
            ScaleTransition(
              scale: trophyScale,
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 60,
                color: Color(0xFFf59e0b),
              ),
            ),
            // Completion badge
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.surface, width: 2),
                ),
                child: Text(
                  '$pct%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Workout Complete!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'You crushed ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          scheduleName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Stats Card ────────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.scheduleName,
    required this.timeStr,
    required this.completedExercises,
    required this.totalExercises,
    required this.totalSets,
    required this.totalReps,
    required this.totalVolumeKg,
    required this.calories,
  });

  final String scheduleName;
  final String timeStr;
  final int completedExercises;
  final int totalExercises;
  final int totalSets;
  final int totalReps;
  final double totalVolumeKg;
  final int calories;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final volumeStr = totalVolumeKg >= 1000
        ? '${(totalVolumeKg / 1000).toStringAsFixed(1)}k'
        : totalVolumeKg.toStringAsFixed(0);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  scheduleName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: colorScheme.outlineVariant),
          const SizedBox(height: 14),

          // 2×3 metrics grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.4,
            children: [
              _MetricTile(
                icon: Icons.timer_outlined,
                iconColor: const Color(0xFF0d9488),
                iconBg: const Color(0xFF0d9488).withValues(alpha: 0.12),
                label: 'Total Time',
                value: timeStr,
              ),
              _MetricTile(
                icon: Icons.fitness_center_rounded,
                iconColor: colorScheme.primary,
                iconBg: colorScheme.primary.withValues(alpha: 0.12),
                label: 'Exercises',
                value: '$completedExercises of $totalExercises',
              ),
              _MetricTile(
                icon: Icons.repeat_rounded,
                iconColor: const Color(0xFF8b5cf6),
                iconBg: const Color(0xFF8b5cf6).withValues(alpha: 0.12),
                label: 'Sets Done',
                value: '$totalSets',
              ),
              _MetricTile(
                icon: Icons.format_list_numbered_rounded,
                iconColor: const Color(0xFF3b82f6),
                iconBg: const Color(0xFF3b82f6).withValues(alpha: 0.12),
                label: 'Total Reps',
                value: '$totalReps',
              ),
              _MetricTile(
                icon: Icons.show_chart_rounded,
                iconColor: const Color(0xFFf97316),
                iconBg: const Color(0xFFf97316).withValues(alpha: 0.12),
                label: 'Volume',
                value: '${volumeStr}kg',
              ),
              _MetricTile(
                icon: Icons.local_fire_department_rounded,
                iconColor: const Color(0xFFef4444),
                iconBg: const Color(0xFFef4444).withValues(alpha: 0.12),
                label: 'Calories',
                value: '~$calories kcal',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Feeling Selector ──────────────────────────────────────────────────────────

class _FeelingSelector extends StatelessWidget {
  const _FeelingSelector({
    required this.selected,
    required this.onChanged,
  });

  final int selected;
  final ValueChanged<int> onChanged;

  static const _labels = ['Easy', 'Moderate', 'Intense', 'Extreme'];
  static const _icons = [
    Icons.sentiment_satisfied_alt_rounded,
    Icons.sentiment_neutral_rounded,
    Icons.sentiment_dissatisfied_rounded,
    Icons.local_fire_department_rounded,
  ];
  static const _colors = [
    Color(0xFF22c55e),
    Color(0xFF3b82f6),
    Color(0xFFf97316),
    Color(0xFFef4444),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How did it feel?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(_labels.length, (i) {
              final isSelected = i == selected;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                  child: GestureDetector(
                    onTap: () => onChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _colors[i].withValues(alpha: 0.12)
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? _colors[i]
                              : colorScheme.outlineVariant,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _icons[i],
                            color: isSelected
                                ? _colors[i]
                                : colorScheme.onSurface.withValues(alpha: 0.5),
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _labels[i],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? _colors[i]
                                  : colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Notes Input ───────────────────────────────────────────────────────────────

class _NotesInput extends StatelessWidget {
  const _NotesInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session Notes',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 4,
            minLines: 3,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText:
                  'How was the session? Any PRs, notes, or thoughts...',
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
                fontSize: 13,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: colorScheme.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
