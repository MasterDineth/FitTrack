import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/active_workout_provider.dart';
import '../../widgets/ft_background_painter.dart';
import '../../widgets/modals/leave_without_saving_modal.dart';
import 'widgets/workout_summary_bento_grid.dart';
import 'widgets/workout_summary_bottom_dock.dart';
import 'widgets/workout_summary_header.dart';
import 'widgets/workout_summary_hero_card.dart';
import 'widgets/workout_summary_muscle_breakdown.dart';
import 'widgets/workout_summary_notes_card.dart';
import 'widgets/workout_summary_rpe_card.dart';

/// Redesigned Workout Summary Screen adhering strictly to Stitch Screen specifications,
/// MODULAR_HEADER_AND_NOTIFICATIONS_GUIDE.md, and AGENTS.md architectural mandates.
///
/// Features:
/// - Dynamic mesh gradient background (`FtMeshBackground`) adapting to Appearance settings.
/// - Dynamic in-header notifications island header (`WorkoutSummaryHeader`).
/// - Cinematic Hero card with routine cover image, date chips, and completion progress.
/// - 2x2 Telemetry Bento Grid (Duration, Volume, Total Sets, Active Energy).
/// - Dynamic Muscle Volume Breakdown with segmented linear distribution track.
/// - 5-Grade Perceived Exertion (RPE 6 - 10) scale with athletic wave bars.
/// - Lifter reflection journal with live character count.
/// - Floating sticky bottom dock CTA with smooth save feedback and session persistence.
class WorkoutSummaryScreen extends ConsumerStatefulWidget {
  const WorkoutSummaryScreen({super.key});

  @override
  ConsumerState<WorkoutSummaryScreen> createState() =>
      _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends ConsumerState<WorkoutSummaryScreen> {
  final _notesController = TextEditingController();
  int _selectedRpe = 9; // Default: RPE 9 ("1 In Tank")
  bool _isSaving = false;
  bool _isSaved = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleBackPress() async {
    if (_isSaved) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/dashboard');
      }
      return;
    }

    final leave = await showLeaveWithoutSavingModal(context);
    if (leave && mounted) {
      ref.read(activeWorkoutProvider.notifier).resetSession();
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/dashboard');
      }
    }
  }

  Future<void> _handleSaveAndComplete() async {
    if (_isSaving || _isSaved) return;

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    final notifier = ref.read(activeWorkoutProvider.notifier);
    final intensityGrade = WorkoutSummaryRpeCard.grades.firstWhere(
      (g) => g.rating == _selectedRpe,
      orElse: () => WorkoutSummaryRpeCard.grades[3],
    );

    final notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();

    try {
      await notifier.finishSession(
        notes: notes,
        intensity: intensityGrade.intensityName,
      );
      notifier.resetSession();

      if (mounted) {
        setState(() {
          _isSaving = false;
          _isSaved = true;
        });

        HapticFeedback.heavyImpact();

        // Brief delay to display "Saved & Completed!" emerald transition
        await Future.delayed(const Duration(milliseconds: 650));
        if (mounted) {
          context.go('/history');
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(activeWorkoutProvider);
    final schedule = workoutState.schedule;

    final completedExercisesCount = workoutState.entries
        .where(
          (e) => workoutState.completedSets
              .any((s) => s.exerciseId == e.exerciseId),
        )
        .length;
    final totalExercisesCount = workoutState.entries.length;

    final totalVolumeKg = workoutState.completedSets
        .fold(0.0, (sum, s) => sum + s.actualWeightKg * s.actualReps);

    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const Positioned.fill(child: FtMeshBackground()),
            SafeArea(
              bottom: false,
              child: Stack(
                children: [
                // ── Scrollable Content Area ─────────────────────────────────
                Positioned.fill(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      16,
                      60, // Clear header space
                      16,
                      bottomPadding + 110, // Clear floating CTA dock
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8),

                            // 1. Cinematic Hero Card
                            WorkoutSummaryHeroCard(
                              schedule: schedule,
                              completedExercisesCount: completedExercisesCount,
                              totalExercisesCount: totalExercisesCount,
                            ),

                            const SizedBox(height: 14),

                            // 2. 2x2 Telemetry Bento Grid
                            WorkoutSummaryBentoGrid(
                              elapsedSeconds: workoutState.elapsedSeconds,
                              totalVolumeKg: totalVolumeKg,
                              completedSetsCount: workoutState.completedSetCount,
                              calories: workoutState.estimatedCalories,
                            ),

                            const SizedBox(height: 14),

                            // 3. Muscle Volume Breakdown Card
                            WorkoutSummaryMuscleBreakdown(
                              completedSets: workoutState.completedSets,
                              entries: workoutState.entries,
                            ),

                            const SizedBox(height: 14),

                            // 4. Perceived Exertion (RPE)
                            WorkoutSummaryRpeCard(
                              selectedRpe: _selectedRpe,
                              onRpeChanged: (rpe) {
                                setState(() => _selectedRpe = rpe);
                              },
                            ),

                            const SizedBox(height: 14),

                            // 5. Lifter Reflection & Notes
                            WorkoutSummaryNotesCard(
                              controller: _notesController,
                            ),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Universal In-Header Dynamic Island Header ───────────────
                Positioned(
                  top: 0,
                  left: 16,
                  right: 16,
                  child: WorkoutSummaryHeader(
                    onBackTap: _handleBackPress,
                  ),
                ),

                // ── Sticky Floating Bottom Dock ─────────────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: WorkoutSummaryBottomDock(
                    isSaving: _isSaving,
                    isSaved: _isSaved,
                    onCompleteTap: _handleSaveAndComplete,
                    bottomOffset: bottomPadding,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}
