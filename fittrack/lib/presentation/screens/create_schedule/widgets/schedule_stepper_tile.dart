import 'package:flutter/material.dart';
import '../../../theme/ft_glass.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Reusable stepper tile used in the exercise editor card (Sets, Reps, Weight, Rest).
class ScheduleStepperTile extends StatelessWidget {
  const ScheduleStepperTile({
    super.key,
    required this.label,
    required this.valueWidget,
    required this.onMinus,
    required this.onPlus,
    this.caption,
  });

  final String label;
  final Widget valueWidget;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final ink = context.ftInk;
    final muted = context.ftMuted;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x1AFFFFFF) : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0x1AFFFFFF) : Colors.white.withValues(alpha: 0.95),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: muted,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FtPressable(
                onTap: onMinus,
                pressedScale: 0.88,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0x22FFFFFF)
                        : const Color(0xFFF7F1FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.remove_rounded,
                    size: 16,
                    color: ink,
                  ),
                ),
              ),
              valueWidget,
              FtPressable(
                onTap: onPlus,
                pressedScale: 0.88,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0x22FFFFFF)
                        : const Color(0xFFF7F1FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 16,
                    color: ink,
                  ),
                ),
              ),
            ],
          ),
          if (caption != null) ...[
            const SizedBox(height: 4),
            Text(
              caption!,
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
                color: muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
