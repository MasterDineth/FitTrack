import 'package:flutter/material.dart';

import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Sticky bottom dock for Workout Summary Screen containing the primary
/// session completion CTA.
class WorkoutSummaryBottomDock extends StatelessWidget {
  const WorkoutSummaryBottomDock({
    super.key,
    required this.isSaving,
    required this.isSaved,
    required this.onCompleteTap,
    this.bottomOffset = 0.0,
  });

  final bool isSaving;
  final bool isSaved;
  final VoidCallback onCompleteTap;
  final double bottomOffset;

  @override
  Widget build(BuildContext context) {
    final primary = context.ftPrimary;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 6, 16, bottomOffset + 12),
      child: GlassSurface(
        tier: FtGlassTier.glassFloating,
        radius: 28,
        padding: const EdgeInsets.all(8),
        child: FtPressable(
          onTap: isSaving ? () {} : onCompleteTap,
          pressedScale: 0.98,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: isSaved
                  ? const Color(0xFF059669) // Emerald-600
                  : primary,
              boxShadow: [
                BoxShadow(
                  color: (isSaved ? const Color(0xFF059669) : primary)
                      .withValues(alpha: 0.36),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSaving) ...[
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Saving session...',
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ] else ...[
                  const Icon(
                    Icons.done_all_rounded,
                    size: 22,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isSaved ? 'Saved & Completed!' : 'Save & Complete Session',
                    maxLines: 1,
                    style: const TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
