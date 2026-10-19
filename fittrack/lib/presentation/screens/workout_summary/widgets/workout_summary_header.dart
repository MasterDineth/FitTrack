import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Top header for Workout Summary Screen.
///
/// Features:
/// - 40x40 circular frosted glass back button.
/// - Unclipped title "Workout Summary" and subtitle "Review completed sets, volume & records".
/// - Integrated share action button.
/// - In-flow scrollable header with no notification bell or profile avatar.
class WorkoutSummaryHeader extends StatelessWidget {
  const WorkoutSummaryHeader({
    super.key,
    required this.onBackTap,
    this.onShareTap,
  });

  final VoidCallback onBackTap;
  final VoidCallback? onShareTap;

  void _defaultShare(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Workout summary copied to clipboard!',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.white,
          ),
        ),
        backgroundColor: context.ftPrimary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ink = context.ftInk;
    final muted = context.ftMuted;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Row(
        children: [
          // Circular Glass Back Button
          FtPressable(
            onTap: onBackTap,
            pressedScale: 0.90,
            child: GlassSurface(
              tier: FtGlassTier.glass2,
              radius: 20,
              width: 40,
              height: 40,
              shadow: false,
              enableBlur: false,
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: ink,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title & Subtitle Stack
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Workout Summary',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Review completed sets, volume & records',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Share Action Button
          FtPressable(
            onTap: onShareTap ?? () => _defaultShare(context),
            pressedScale: 0.90,
            child: GlassSurface(
              tier: FtGlassTier.glass2,
              radius: 20,
              width: 40,
              height: 40,
              shadow: false,
              enableBlur: false,
              alignment: Alignment.center,
              child: Icon(
                Icons.share_outlined,
                size: 19,
                color: ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
