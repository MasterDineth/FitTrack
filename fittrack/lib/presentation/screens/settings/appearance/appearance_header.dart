import 'package:flutter/material.dart';

import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../../widgets/header/ft_dynamic_header.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Top header for Appearance Settings.
///
/// Features back button, title, and descriptive subtitle on the left,
/// with the universal in-header dynamic island notification bell on the right
/// (replacing the profile avatar for clean ergonomics).
class AppearanceHeader extends StatelessWidget {
  const AppearanceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary = theme.colorScheme.onSurface;
    final textMuted = theme.colorScheme.onSurface.withValues(alpha: 0.60);

    return FtDynamicHeader(
      padding: const EdgeInsets.only(top: 8.0, bottom: 14.0),
      leftChild: Row(
        children: [
          // Back button (40x40 circular glass chip)
          FtPressable(
            onTap: () => Navigator.of(context).maybePop(),
            pressedScale: 0.95,
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
          // Title and Subtitle lockup
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Appearance',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: textPrimary,
                    height: 1.15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Customize your visual theme, kinetic accents, and display ergonomics',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textMuted,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

