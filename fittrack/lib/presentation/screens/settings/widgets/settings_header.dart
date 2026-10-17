import 'package:flutter/material.dart';

import '../../../theme/ft_glass.dart';
import '../../../widgets/header/ft_header_actions.dart';

/// Top header for FitTrack Settings matching the dashboard header layout & UI consistency.
class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Screen Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: context.ftInk,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Manage your account, preferences & hardware',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.ftMuted,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Right: Frosted Notification Bell + Profile Avatar
          const FtHeaderActions(),
        ],
      ),
    );
  }
}
