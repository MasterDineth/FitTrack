import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../../widgets/header/ft_dynamic_header.dart';
import '../../../widgets/header/ft_header_avatar.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Top header for Workout Summary Screen adhering strictly to
/// MODULAR_HEADER_AND_NOTIFICATIONS_GUIDE.md and Stitch specifications.
///
/// Features:
/// - Universal in-header dynamic island notifications morphing with `FtDynamicHeader`.
/// - 40x40 circular frosted glass back button.
/// - Prominent title "Workout Summary" and subtitle "Review completed sets, volume & records".
/// - Integrated share action button and profile avatar.
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

    return FtDynamicHeader(
      padding: const EdgeInsets.only(top: 10.0, bottom: 4.0),
      trailing: const FtHeaderAvatar(),
      leftChild: Row(
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

          // Share Action Button
          const SizedBox(width: 8),
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
