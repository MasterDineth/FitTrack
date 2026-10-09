import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/entities/user_profile.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Top header for Appearance Settings.
///
/// Implements Stitch navigation lockup on the left and keeps the athlete
/// profile avatar in the exact same placement as the Dashboard for
/// cross-screen UI consistency.
class AppearanceHeader extends ConsumerWidget {
  const AppearanceHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.value;

    final theme = Theme.of(context);
    final textPrimary = theme.colorScheme.onSurface;
    final textMuted = theme.colorScheme.onSurface.withValues(alpha: 0.60);

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Left: Back Button + Title & Subtitle ────────────────────────────
          Expanded(
            child: Row(
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
          ),
          const SizedBox(width: 8),

          // ── Right: Athlete Avatar (Matching Dashboard) ─────────────────────
          FtPressable(
            onTap: () => context.push('/settings/profile'),
            pressedScale: 0.95,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildAvatarImage(profile),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(UserProfile? profile) {
    final path = profile?.profileImagePath;
    if (path != null && path.isNotEmpty) {
      return Image.file(
        File(path),
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        cacheWidth: 72,
        errorBuilder: (_, _, _) => _buildFallbackAvatar(),
      );
    }
    return _buildFallbackAvatar();
  }

  Widget _buildFallbackAvatar() {
    return Image.asset(
      'assets/images/dashboard/sample_avatar.webp',
      width: 36,
      height: 36,
      fit: BoxFit.cover,
      cacheWidth: 72,
    );
  }
}
