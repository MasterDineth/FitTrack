import 'package:flutter/material.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';

/// Volume by muscle segmented breakdown bar & legend inside a GlassSurface card.
class WorkoutDetailMuscleSplit extends StatelessWidget {
  final Map<String, double> musclePercentages;

  const WorkoutDetailMuscleSplit({
    super.key,
    required this.musclePercentages,
  });

  @override
  Widget build(BuildContext context) {
    // Defaults if map is empty
    final chest = (musclePercentages['Chest'] ?? 52.0).round();
    final triceps = (musclePercentages['Triceps'] ?? 29.0).round();
    final shoulders = (musclePercentages['Shoulders'] ?? 19.0).round();

    const chestColor = Color(0xFFF43F5E); // Rose-500
    const tricepsColor = Color(0xFF14B8A6); // Teal-500
    const shouldersColor = Color(0xFFF97316); // Orange-400
    final isDark = context.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Text(
            'Volume by muscle',
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: context.ftMuted,
            ),
          ),
        ),
        const SizedBox(height: 8),

        GlassSurface(
          tier: FtGlassTier.glass1,
          radius: 24,
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              // Segmented Rounded Track
              Container(
                height: 14,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: chest > 0 ? chest : 52,
                        child: Container(color: chestColor),
                      ),
                      const SizedBox(width: 1.5),
                      Expanded(
                        flex: triceps > 0 ? triceps : 29,
                        child: Container(color: tricepsColor),
                      ),
                      const SizedBox(width: 1.5),
                      Expanded(
                        flex: shoulders > 0 ? shoulders : 19,
                        child: Container(color: shouldersColor),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Legend Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: _LegendItem(color: chestColor, label: 'Chest', percentage: '$chest%'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: _LegendItem(color: tricepsColor, label: 'Triceps', percentage: '$triceps%'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: _LegendItem(color: shouldersColor, label: 'Shoulders', percentage: '$shoulders%'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String percentage;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: FtText.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: context.ftInk,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          percentage,
          style: TextStyle(
            fontFamily: FtText.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: context.ftMuted,
          ),
        ),
      ],
    );
  }
}
