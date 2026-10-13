import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/dashboard_providers.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Top header for Workout History matching the Dashboard navigation bar & actions.
class WorkoutHistoryHeader extends ConsumerWidget {
  const WorkoutHistoryHeader({super.key});

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
          // Left: Screen Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'History',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 26,
                    height: 32 / 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.65,
                    color: context.ftInk,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Track your past sessions & milestones',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.ftMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Right: Notification Bell + User Avatar (identical to Dashboard)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 40x40 circle glass2 bell
              FtPressable(
                onTap: () {
                  // TODO(notifications): Leave empty for dedicated notifications screen
                },
                pressedScale: 0.95,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GlassSurface(
                        tier: FtGlassTier.glass2,
                        radius: 20,
                        width: 40,
                        height: 40,
                        shadow: false,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.notifications_outlined,
                          size: 20,
                          color: context.ftInk,
                        ),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF43F5E), // Red badge matching Stitch
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // 36x36 circular user avatar
              FtPressable(
                onTap: () => context.push('/settings/profile'),
                pressedScale: 0.95,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.isDark
                          ? Colors.white.withValues(alpha: 0.25)
                          : Colors.white.withValues(alpha: 0.85),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                        : Container(
                            color: context.ftPrimary,
                            alignment: Alignment.center,
                            child: Text(
                              userName.isNotEmpty ? userName[0].toUpperCase() : 'M',
                              style: const TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
