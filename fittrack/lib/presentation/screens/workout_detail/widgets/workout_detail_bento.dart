import 'package:flutter/material.dart';

import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';

/// 2x2 Telemetry Bento Grid for Workout Details matching Stitch Screen `fc32d4d5a15441178564c24cb5dad0f4`.
///
/// Features 4 frosted glass cards:
/// 1. Exercises count
/// 2. Total sets
/// 3. Est. duration
/// 4. Est. energy expenditure
class WorkoutDetailBento extends StatelessWidget {
  const WorkoutDetailBento({
    super.key,
    required this.exerciseCount,
    required this.totalSets,
    required this.estimatedMinutes,
    required this.estimatedCalories,
  });

  final int exerciseCount;
  final int totalSets;
  final int estimatedMinutes;
  final int estimatedCalories;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 10) / 2;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: itemWidth,
              child: _buildBentoTile(
                context: context,
                icon: Icons.fitness_center_rounded,
                value: '$exerciseCount',
                label: 'Exercises',
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _buildBentoTile(
                context: context,
                icon: Icons.repeat_rounded,
                value: '$totalSets',
                label: 'Total sets',
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _buildBentoTile(
                context: context,
                icon: Icons.timer_outlined,
                value: '${estimatedMinutes}m',
                label: 'Est. time',
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _buildBentoTile(
                context: context,
                icon: Icons.local_fire_department_rounded,
                value: '~$estimatedCalories',
                label: 'Est. energy',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBentoTile({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
  }) {
    return GlassSurface(
      tier: FtGlassTier.glass1,
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: context.isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.white,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.ftPrimary.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 20,
              color: context.ftPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: context.ftInk,
                    height: 1.1,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.ftMuted,
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
