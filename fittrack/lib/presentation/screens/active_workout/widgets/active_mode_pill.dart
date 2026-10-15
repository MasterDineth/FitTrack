import 'package:flutter/material.dart';

import '../../../theme/ft_glass.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Segmented mode pill for Active Workout (Active Set vs Rest Timer)
/// matching Stitch Screen `7e785328b1f24951adf11ae52e15b460`.
class ActiveModePill extends StatelessWidget {
  const ActiveModePill({
    super.key,
    required this.isResting,
    required this.onModeSelected,
  });

  final bool isResting;
  final ValueChanged<bool> onModeSelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FtPressable(
              onTap: () => onModeSelected(false),
              pressedScale: 0.95,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: !isResting ? context.ftPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: !isResting
                      ? [
                          BoxShadow(
                            color: context.ftPrimary.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Active Set',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 12,
                    fontWeight: !isResting ? FontWeight.w800 : FontWeight.w600,
                    color: !isResting ? Colors.white : context.ftMuted,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            FtPressable(
              onTap: () => onModeSelected(true),
              pressedScale: 0.95,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: isResting ? context.ftPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isResting
                      ? [
                          BoxShadow(
                            color: context.ftPrimary.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Rest Timer',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 12,
                    fontWeight: isResting ? FontWeight.w800 : FontWeight.w600,
                    color: isResting ? Colors.white : context.ftMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
