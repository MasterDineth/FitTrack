import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../../widgets/header/ft_header_actions.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Top header for Workout History Details screen with back button, title,
/// unread notification bell, and user profile avatar matching Dashboard.
class WorkoutDetailHeader extends StatelessWidget {
  const WorkoutDetailHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Back button & Title Column
          Expanded(
            child: Row(
              children: [
                FtPressable(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/history');
                    }
                  },
                  pressedScale: 0.92,
                  child: GlassSurface(
                    tier: FtGlassTier.glass2,
                    radius: FtGlassTheme.radiusPill,
                    padding: const EdgeInsets.all(8),
                    shadow: false,
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: 26,
                      color: context.ftInk,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Workout Details',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 22,
                          height: 28 / 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: context.ftInk,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Review completed sets, volume & records',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: context.ftMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Right: Standard Header Actions (Bell & Profile Avatar)
          const FtHeaderActions(),
        ],
      ),
    );
  }
}
