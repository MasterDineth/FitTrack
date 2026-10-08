import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/dashboard_providers.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Top header for Workout History Details screen with back button, title,
/// unread notification bell, and user profile avatar matching Dashboard.
class WorkoutDetailHeader extends ConsumerWidget {
  const WorkoutDetailHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final avatarAsync = ref.watch(userAvatarFileProvider);
    final userName = ref.watch(
      userProfileProvider.select((p) => p.value?.name.trim() ?? ''),
    );
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = (36 * dpr).ceil();

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

          // Right: Notification Bell & Profile Avatar
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Notification bell with unread badge
              FtPressable(
                onTap: () => _showNotificationsSheet(context),
                pressedScale: 0.92,
                child: GlassSurface(
                  tier: FtGlassTier.glass2,
                  radius: FtGlassTheme.radiusPill,
                  padding: const EdgeInsets.all(8),
                  shadow: false,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 20,
                        color: context.ftInk,
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF5252),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Profile Avatar
              FtPressable(
                onTap: () => context.push('/profile'),
                pressedScale: 0.92,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.ftPrimary.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: avatarAsync.value != null
                        ? Image(
                            image: ResizeImage(
                              FileImage(avatarAsync.value!),
                              width: cacheWidth,
                            ),
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                          )
                        : _fallbackAvatar(userName, context),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fallbackAvatar(String userName, BuildContext context) {
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    return Container(
      color: context.ftPrimary.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontFamily: FtText.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: context.ftPrimary,
        ),
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GlassSurface(
        tier: FtGlassTier.glass1,
        radius: FtGlassTheme.radiusCards,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ctx.ftInk,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'No new unread alerts or notifications.',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 14,
                color: ctx.ftMuted,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
