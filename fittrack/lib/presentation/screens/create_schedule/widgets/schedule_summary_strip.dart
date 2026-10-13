import 'package:flutter/material.dart';
import '../../../theme/ft_glass.dart';

/// 3-Metric Summary Strip card displaying Duration, Total Sets, and Est. Energy Burn.
/// Matching Stitch Screen ID 378f56a0b632436289e53841eb67b6fb.
class ScheduleSummaryStrip extends StatelessWidget {
  const ScheduleSummaryStrip({
    super.key,
    required this.durationFormatted,
    required this.totalSets,
    required this.estimatedCalories,
  });

  final String durationFormatted;
  final int totalSets;
  final int estimatedCalories;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = context.ftPrimary;
    final ink = context.ftInk;
    final muted = context.ftMuted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0x331E1838)
            : Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? const Color(0x26FFFFFF)
              : Colors.white.withValues(alpha: 0.9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: isDark ? 0.15 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Duration
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.schedule_rounded,
                    size: 20,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  durationFormatted,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'DURATION',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),

          // 2. Target Sets
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0x1AFFFFFF)
                    : const Color(0x33ECE4FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2DD4BF).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.repeat_rounded,
                      size: 20,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$totalSets',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'SETS',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Energy Burn
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF43F5E).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    size: 20,
                    color: Color(0xFFF43F5E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '~$estimatedCalories kcal',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ENERGY',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: muted,
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
