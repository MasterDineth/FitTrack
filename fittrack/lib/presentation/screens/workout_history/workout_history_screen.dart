import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/workout_history_provider.dart';
import '../../theme/ft_glass.dart';
import '../../widgets/ambient_mesh_background.dart';
import '../../widgets/glass_surface.dart';
import 'widgets/history_filter_chips.dart';
import 'widgets/history_month_navigator.dart';
import 'widgets/monthly_telemetry_stack.dart';
import 'widgets/workout_history_card.dart';
import 'widgets/workout_history_header.dart';

/// Redesigned Workout History screen matching the FitTrack Stitch Mobile Design System.
///
/// Features:
/// - Dynamic liquid mesh frosted glass background responding to Appearance settings.
/// - Top header with title, subtitle, notification badge & profile avatar matching Dashboard.
/// - Swipable stacked telemetry cards with realistic monthly metrics & animations.
/// - Horizontal category filter chips (All, Push, Pull, Legs, PRs only).
/// - Interactive month navigator (< MONTH YEAR >) with sessions count and calendar picker.
/// - Expandable workout session cards (first card expanded by default).
/// - 112dp bottom clearance for the floating navigation dock.
class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(workoutHistoryProvider);
    final sessions = historyState.filtered;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientMeshBackground(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Top Header ───────────────────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: WorkoutHistoryHeader(),
                ),
              ),

              // ── Monthly Telemetry Stack ──────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: MonthlyTelemetryStack(),
                ),
              ),

              // ── Filter Chips ─────────────────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: HistoryFilterChips(),
                ),
              ),

              // ── Month Navigator ──────────────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: HistoryMonthNavigator(),
                ),
              ),

              // ── Workout Sessions List ────────────────────────────────
              if (sessions.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 32),
                    child: _EmptyHistoryView(),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: GlassSurface(
                      tier: FtGlassTier.glass1,
                      radius: 24,
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Column(
                          children: [
                            for (int i = 0; i < sessions.length; i++) ...[
                              if (i > 0)
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: context.isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : const Color(0xFFF1F5F9),
                                ),
                              WorkoutHistoryCard(
                                key: ValueKey(sessions[i].id),
                                session: sessions[i],
                                initialExpanded: i == 0,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // ── Bottom Dock Clearance (112dp) ────────────────────────
              const SliverToBoxAdapter(
                child: SizedBox(height: 112),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHistoryView extends StatelessWidget {
  const _EmptyHistoryView();

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      tier: FtGlassTier.glass1,
      radius: FtGlassTheme.radiusCards,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: context.ftPrimary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fitness_center_rounded,
                size: 28,
                color: context.ftPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No workouts found',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.ftInk,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No logged sessions match this period or filter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.ftMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
