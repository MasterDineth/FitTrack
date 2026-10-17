import 'package:flutter/material.dart';

import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../../widgets/header/ft_header_actions.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Top Navigation Header for Create Exercise matching Stitch Screen ID de3d4ad0debd49a9905572984fbbde63
/// and consistent with Workout Library Search & Create Schedule screens.
class CreateExerciseHeader extends StatelessWidget {
  const CreateExerciseHeader({
    super.key,
    required this.onBackTap,
  });

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    final ink = context.ftInk;
    final muted = context.ftMuted;

    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: 40x40 Back Button + Title & Subtitle
          Expanded(
            child: Row(
              children: [
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create Exercise',
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
                        'Only a name is required',
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
          ),
          const SizedBox(width: 8),

          // Right: Modular Notification Bell + Profile Avatar
          const FtHeaderActions(),
        ],
      ),
    );
  }
}
