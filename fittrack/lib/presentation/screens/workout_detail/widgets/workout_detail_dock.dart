import 'package:flutter/material.dart';

import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Floating Start Workout Dock for Workout Details matching Stitch Screen `fc32d4d5a15441178564c24cb5dad0f4`.
///
/// Features:
/// - Summary caption label: e.g. "~60 min · 21 sets total"
/// - Full-width gradient "Start workout" primary action button with play arrow icon
/// - Frosted glass container with specular rim and elevation
class WorkoutDetailDock extends StatelessWidget {
  const WorkoutDetailDock({
    super.key,
    required this.estimatedMinutes,
    required this.totalSets,
    required this.onStartTap,
    this.bottomOffset = 0.0,
  });

  final int estimatedMinutes;
  final int totalSets;
  final VoidCallback onStartTap;
  final double bottomOffset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottomOffset + 12),
      child: GlassSurface(
        tier: FtGlassTier.glassFloating,
        radius: 28,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Caption Label
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '~$estimatedMinutes min',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: context.ftMuted,
                  ),
                ),
                Container(
                  width: 3.5,
                  height: 3.5,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: context.ftMuted.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  '$totalSets sets total',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: context.ftMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Primary Start Workout Button
            FtPressable(
              onTap: onStartTap,
              pressedScale: 0.98,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF5F3BDC),
                      Color(0xFF7551FA),
                      Color(0xFF4E2BC2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5F3BDC).withValues(alpha: 0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_arrow_rounded,
                      size: 22,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Start workout',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
