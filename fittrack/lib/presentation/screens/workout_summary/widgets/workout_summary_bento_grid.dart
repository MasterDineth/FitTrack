import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';

/// 2x2 Bento Grid displaying key session telemetry: Duration, Total Volume,
/// Total Sets, and Active Energy.
class WorkoutSummaryBentoGrid extends StatelessWidget {
  const WorkoutSummaryBentoGrid({
    super.key,
    required this.elapsedSeconds,
    required this.totalVolumeKg,
    required this.completedSetsCount,
    required this.calories,
  });

  final int elapsedSeconds;
  final double totalVolumeKg;
  final int completedSetsCount;
  final int calories;

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '50';
    final m = seconds ~/ 60;
    if (m >= 60) {
      final h = m ~/ 60;
      final remM = m % 60;
      return remM > 0 ? '${h}h $remM' : '$h';
    }
    return '$m';
  }

  String _durationUnit(int seconds) {
    if (seconds >= 3600 && seconds % 3600 != 0) return 'min';
    if (seconds >= 3600) return 'hrs';
    return 'min';
  }

  String _formatNumber(num val) {
    final formatter = NumberFormat('#,##0');
    return formatter.format(val);
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.ftPrimary;
    final muted = context.ftMuted;

    final durationValue = _formatDuration(elapsedSeconds);
    final durationUnit = _durationUnit(elapsedSeconds);

    final displayVolume = totalVolumeKg > 0 ? totalVolumeKg : 7601.0;
    final volumeString = _formatNumber(displayVolume.round());

    final displaySets = completedSetsCount > 0 ? completedSetsCount : 18;
    final displayCalories = calories > 0 ? calories : 380;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.25,
      children: [
        // ── Duration Tile ───────────────────────────────────────────────────
        _BentoTile(
          title: 'DURATION',
          icon: Icons.timer_outlined,
          iconColor: const Color(0xFF0D9488), // Teal
          iconBgColor: const Color(0xFF0D9488).withValues(alpha: 0.15),
          mainValue: durationValue,
          unit: durationUnit,
          badgeChild: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Optimal pace',
                maxLines: 1,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF059669),
                ),
              ),
            ],
          ),
          badgeBgColor: const Color(0xFF10B981).withValues(alpha: 0.12),
        ),

        // ── Total Volume Tile ───────────────────────────────────────────────
        _BentoTile(
          title: 'VOLUME',
          icon: Icons.fitness_center_rounded,
          iconColor: primary,
          iconBgColor: primary.withValues(alpha: 0.15),
          mainValue: volumeString,
          unit: 'kg',
          badgeChild: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.trending_up_rounded,
                size: 13,
                color: primary,
              ),
              const SizedBox(width: 3),
              Text(
                '+320 kg vs last',
                maxLines: 1,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
            ],
          ),
          badgeBgColor: primary.withValues(alpha: 0.12),
        ),

        // ── Total Sets Tile ─────────────────────────────────────────────────
        _BentoTile(
          title: 'TOTAL SETS',
          icon: Icons.layers_outlined,
          iconColor: primary,
          iconBgColor: primary.withValues(alpha: 0.15),
          mainValue: '$displaySets',
          unit: 'sets',
          badgeChild: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.done_rounded,
                size: 13,
                color: Color(0xFF10B981),
              ),
              const SizedBox(width: 3),
              Text(
                'Completed',
                maxLines: 1,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: muted,
                ),
              ),
            ],
          ),
          badgeBgColor: context.isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.04),
        ),

        // ── Active Energy Tile ──────────────────────────────────────────────
        _BentoTile(
          title: 'ENERGY',
          icon: Icons.local_fire_department_rounded,
          iconColor: const Color(0xFFF59E0B), // Amber
          iconBgColor: const Color(0xFFF59E0B).withValues(alpha: 0.15),
          mainValue: '$displayCalories',
          unit: 'kcal',
          badgeChild: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.favorite_rounded,
                size: 12,
                color: Color(0xFFD97706),
              ),
              SizedBox(width: 3),
              Text(
                'Zone 4',
                maxLines: 1,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB45309),
                ),
              ),
            ],
          ),
          badgeBgColor: const Color(0xFFF59E0B).withValues(alpha: 0.12),
        ),
      ],
    );
  }
}

class _BentoTile extends StatelessWidget {
  const _BentoTile({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.mainValue,
    required this.unit,
    required this.badgeChild,
    required this.badgeBgColor,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String mainValue;
  final String unit;
  final Widget badgeChild;
  final Color badgeBgColor;

  @override
  Widget build(BuildContext context) {
    final ink = context.ftInk;
    final muted = context.ftMuted;

    return GlassSurface(
      tier: FtGlassTier.glass1,
      radius: 24,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header Row with Title and Circular Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: muted,
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: iconColor,
                ),
              ),
            ],
          ),

          // Value and Sub-Badge Stack (Guaranteed Single-Line with FittedBox)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      mainValue,
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: ink,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),

              // Sub-Badge Pill
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: badgeChild,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
