import 'package:flutter/material.dart';
import 'package:fittrack/presentation/screens/dashboard/widgets/ft_pressable.dart';
import 'package:fittrack/presentation/theme/ft_glass.dart';
import 'package:fittrack/presentation/widgets/glass_surface.dart';
import 'package:fittrack/presentation/widgets/header/ft_dynamic_header.dart';

/// Top header for the Profile screen.
///
/// Features:
/// - 40x40 Frosted Glass Back Button
/// - "Profile" title & "Personal settings & athlete record" subtitle
/// - Single notification bell anchored to the far right (no avatar)
/// - Universal in-header Dynamic Island morph on notification arrival
class ProfileHeader extends StatelessWidget {
  final VoidCallback onBackTap;

  const ProfileHeader({
    super.key,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary = theme.colorScheme.onSurface;
    final textMuted = theme.colorScheme.onSurface.withValues(alpha: 0.60);

    return FtDynamicHeader(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      leftChild: Row(
        children: [
          // 40x40 Frosted Back Button with >= 48x48 touch target
          FtPressable(
            onTap: onBackTap,
            pressedScale: 0.92,
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
                color: textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Title & Subtitle lockup
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Profile',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: textPrimary,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Personal settings & athlete record',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textMuted,
                    height: 1.25,
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
