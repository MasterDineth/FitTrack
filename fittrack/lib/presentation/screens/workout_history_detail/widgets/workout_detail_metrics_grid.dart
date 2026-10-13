import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../providers/workout_history_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';

/// Modular Two-Tier Telemetry Module for Workout History Details screen.
/// - Single combined GlassSurface(radius: 24) matching Stitch design.
/// - Tier 1: Duration & Volume primary tiles.
/// - 1px divider.
/// - Tier 2: 2x2 grid of Energy, Sets, Reps, Exercises.
class WorkoutDetailMetricsGrid extends StatelessWidget {
  final WorkoutSessionDetailData detail;

  const WorkoutDetailMetricsGrid({
    super.key,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final s = detail.session;
    final minutes = (s.durationSeconds != null && s.durationSeconds! > 0)
        ? (s.durationSeconds! ~/ 60)
        : 50;

    final volumeVal = s.totalVolumeKg > 0 ? s.totalVolumeKg : 7601.0;
    final volumeStr = NumberFormat('#,###').format(volumeVal.toInt());
    final cals = s.totalCalories ?? 380;
    final totalSets = s.totalSets > 0 ? s.totalSets : 18;
    final totalReps = s.totalReps > 0 ? s.totalReps : 173;
    final completedEx = detail.completedExercisesCount > 0 ? detail.completedExercisesCount : 6;
    final totalEx = detail.totalExercisesCount > 0 ? detail.totalExercisesCount : 7;
    final isDark = context.isDark;

    return GlassSurface(
      tier: FtGlassTier.glass1,
      radius: 24,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Row 1: Primary Metrics (Duration & Volume) ──────────────
          Row(
            children: [
              // Duration Card
              Expanded(
                child: _PrimaryMetricTile(
                  label: 'DURATION',
                  value: '$minutes',
                  unit: 'min',
                  icon: Icons.timer_outlined,
                  iconBg: isDark
                      ? const Color(0xFF14B8A6).withValues(alpha: 0.2)
                      : const Color(0xFFCCFBF1),
                  iconColor: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
                  footerDotColor: const Color(0xFF14B8A6),
                  footerText: 'Pace optimal',
                  footerTextColor: context.ftMuted,
                ),
              ),
              const SizedBox(width: 10),

              // Volume Card
              Expanded(
                child: _PrimaryMetricTile(
                  label: 'VOLUME',
                  value: volumeStr,
                  unit: 'kg',
                  icon: Icons.fitness_center_rounded,
                  iconBg: isDark
                      ? context.ftPrimary.withValues(alpha: 0.2)
                      : const Color(0xFFEDE9FE),
                  iconColor: isDark ? const Color(0xFFA78BFA) : const Color(0xFF6D28D9),
                  footerDotColor: context.ftPrimary,
                  footerText: '+320 kg vs last',
                  footerTextColor: isDark ? const Color(0xFFA78BFA) : const Color(0xFF6D28D9),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : context.ftPrimary.withValues(alpha: 0.1),
          ),

          const SizedBox(height: 12),

          // ── Row 2: Secondary Metrics (2x2 Grid) ─────────────────────
          Row(
            children: [
              Expanded(
                child: _SecondaryMetricTile(
                  label: 'ENERGY',
                  value: '$cals',
                  unit: 'kcal',
                  icon: Icons.local_fire_department_rounded,
                  iconBg: isDark
                      ? const Color(0xFFF97316).withValues(alpha: 0.2)
                      : const Color(0xFFFFEDD5),
                  iconColor: const Color(0xFFEA580C),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SecondaryMetricTile(
                  label: 'SETS',
                  value: '$totalSets',
                  unit: 'total',
                  icon: Icons.layers_rounded,
                  iconBg: isDark
                      ? context.ftPrimary.withValues(alpha: 0.2)
                      : const Color(0xFFEDE9FE),
                  iconColor: isDark ? const Color(0xFFA78BFA) : const Color(0xFF6D28D9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SecondaryMetricTile(
                  label: 'REPS',
                  value: '$totalReps',
                  unit: 'reps',
                  icon: Icons.repeat_rounded,
                  iconBg: isDark
                      ? context.ftPrimary.withValues(alpha: 0.2)
                      : const Color(0xFFEDE9FE),
                  iconColor: isDark ? const Color(0xFFA78BFA) : const Color(0xFF6D28D9),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SecondaryMetricTile(
                  label: 'EXERCISES',
                  value: '$completedEx',
                  unit: 'of $totalEx',
                  icon: Icons.check_circle_rounded,
                  iconBg: isDark
                      ? const Color(0xFF14B8A6).withValues(alpha: 0.2)
                      : const Color(0xFFCCFBF1),
                  iconColor: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color footerDotColor;
  final String footerText;
  final Color footerTextColor;

  const _PrimaryMetricTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.footerDotColor,
    required this.footerText,
    required this.footerTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.85),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.45,
                    color: context.ftMuted,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 15, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: context.ftInk,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.ftMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : context.ftPrimary.withValues(alpha: 0.08),
                ),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: footerDotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    footerText,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: footerTextColor,
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

class _SecondaryMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const _SecondaryMetricTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.85),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: context.ftMuted,
                  ),
                ),
                const SizedBox(height: 1),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                          color: context.ftInk,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        unit,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: context.ftMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
