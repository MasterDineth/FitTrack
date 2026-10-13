import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/workout_history_provider.dart';
import '../../theme/ft_glass.dart';
import '../../widgets/ambient_mesh_background.dart';
import '../../widgets/glass_surface.dart';
import 'widgets/workout_detail_exercises_list.dart';
import 'widgets/workout_detail_header.dart';
import 'widgets/workout_detail_hero_card.dart';
import 'widgets/workout_detail_metrics_grid.dart';
import 'widgets/workout_detail_muscle_split.dart';
import 'widgets/workout_detail_notes_card.dart';
import 'widgets/workout_detail_repeat_button.dart';

/// Redesigned Workout History Details screen matching the FitTrack Stitch Mobile Design System.
///
/// Features:
/// - Liquid mesh dynamic glass background responding to Appearance settings.
/// - Top header with back button, title, notification badge & profile avatar matching Dashboard.
/// - Hero banner with schedule image, floating meta badges, title, and segmented progress track.
/// - 2x3 metrics grid (Duration, Volume, Energy, Sets, Reps, Exercises).
/// - Session notes card with quote marks styling.
/// - Volume by muscle segmented breakdown with color-coded legend.
/// - Exercise accordion cards with first item expanded, expand/collapse all toggle, and PR badges.
/// - Pinned floating "Repeat workout" button navigating to the active workout screen.
class WorkoutHistoryDetailScreen extends ConsumerWidget {
  final String sessionId;

  const WorkoutHistoryDetailScreen({
    super.key,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(workoutSessionDetailProvider(sessionId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientMeshBackground(
        child: detailAsync.when(
          data: (detail) {
            if (detail == null) {
              return _SessionNotFoundView(onBack: () => context.pop());
            }

            return Stack(
              children: [
                // Scrollable Content
                SafeArea(
                  bottom: false,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // ── Top Header ─────────────────────────────────────
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: WorkoutDetailHeader(),
                        ),
                      ),

                      // ── Hero Banner Card ───────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: WorkoutDetailHeroCard(detail: detail),
                        ),
                      ),

                      // ── Key Metrics Grid (2x3) ─────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: WorkoutDetailMetricsGrid(detail: detail),
                        ),
                      ),

                      // ── Session Notes (if present) ─────────────────────
                      if (detail.hasNotes)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                            child: WorkoutDetailNotesCard(notes: detail.session.notes),
                          ),
                        ),

                      // ── Volume By Muscle ───────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                          child: WorkoutDetailMuscleSplit(
                            musclePercentages: detail.muscleVolumePercentages,
                          ),
                        ),
                      ),

                      // ── Exercises Accordion List ───────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: WorkoutDetailExercisesList(
                            exercises: detail.exercises,
                          ),
                        ),
                      ),

                      // ── Bottom Clearance for Floating Button ──────────
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 100),
                      ),
                    ],
                  ),
                ),

                // Floating Repeat Workout Button
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: WorkoutDetailRepeatButton(
                    scheduleId: detail.session.scheduleId,
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (err, stack) => _SessionErrorView(
            message: '$err',
            onBack: () => context.pop(),
          ),
        ),
      ),
    );
  }
}

class _SessionNotFoundView extends StatelessWidget {
  final VoidCallback onBack;

  const _SessionNotFoundView({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: GlassSurface(
            tier: FtGlassTier.glass1,
            radius: FtGlassTheme.radiusCards,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 44,
                  color: context.ftMuted,
                ),
                const SizedBox(height: 12),
                Text(
                  'Workout session not found',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.ftInk,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'The requested session details could not be retrieved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 13,
                    color: context.ftMuted,
                  ),
                ),
                const SizedBox(height: 18),
                TextButton(
                  onPressed: onBack,
                  child: const Text('Back to History'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onBack;

  const _SessionErrorView({
    required this.message,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: GlassSurface(
            tier: FtGlassTier.glass1,
            radius: FtGlassTheme.radiusCards,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 44,
                  color: Color(0xFFFF5252),
                ),
                const SizedBox(height: 12),
                Text(
                  'Error loading session',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.ftInk,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 12,
                    color: context.ftMuted,
                  ),
                ),
                const SizedBox(height: 18),
                TextButton(
                  onPressed: onBack,
                  child: const Text('Back to History'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
