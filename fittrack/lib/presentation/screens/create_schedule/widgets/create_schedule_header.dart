import 'package:flutter/material.dart';

import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../../widgets/header/ft_dynamic_header.dart';
import '../../../widgets/header/ft_header_avatar.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Top App Bar matching Stitch Screen ID 378f56a0b632436289e53841eb67b6fb
/// and aligned with WorkoutSearchScreen for UI consistency, featuring universal
/// in-header dynamic island notifications morphing.
class CreateScheduleHeader extends StatelessWidget {
  const CreateScheduleHeader({
    super.key,
    required this.onBackTap,
  });

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    final ink = context.ftInk;
    final muted = context.ftMuted;

    return FtDynamicHeader(
      padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
      leftChild: Row(
        children: [
          FtPressable(
            onTap: onBackTap,
            pressedScale: 0.90,
            child: GlassSurface(
              tier: FtGlassTier.glass2,
              radius: 18,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'New Schedule',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Hypertrophy split plan',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: muted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      trailing: const FtHeaderAvatar(),
    );
  }
}
