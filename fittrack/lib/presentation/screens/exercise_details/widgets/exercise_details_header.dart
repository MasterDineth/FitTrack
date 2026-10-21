import 'package:flutter/material.dart';

import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../../widgets/header/header.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Top navigation header for the Exercise Details screen.
///
/// Category A screen (notification bell), so it is wrapped with
/// [FtDynamicHeader] exactly as described in
/// `MODULAR_HEADER_AND_NOTIFICATIONS_GUIDE.md` (Pattern 2 — sub-flow header
/// with a back button). The bell anchors far right; no avatar is shown on a
/// flow screen, matching `AppearanceHeader`.
class ExerciseDetailsHeader extends StatelessWidget {
  const ExerciseDetailsHeader({
    super.key,
    required this.onBackTap,
    required this.exerciseName,
  });

  final VoidCallback onBackTap;
  final String exerciseName;

  @override
  Widget build(BuildContext context) {
    final ink = context.ftInk;
    final muted = context.ftMuted;

    return FtDynamicHeader(
      padding: const EdgeInsets.only(
        top: FtHeaderTokens.topPadding,
        bottom: 6.0,
      ),
      leftChild: Row(
        children: [
          FtPressable(
            onTap: onBackTap,
            pressedScale: 0.90,
            child: Semantics(
              button: true,
              label: 'Back to workout',
              child: GlassSurface(
                tier: FtGlassTier.glass2,
                radius: 20,
                width: 40,
                height: 40,
                shadow: false,
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: ink,
                ),
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
                  'Exercise Details',
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
                if (exerciseName.isNotEmpty)
                  Text(
                    exerciseName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
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
