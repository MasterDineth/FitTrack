import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../providers/dashboard_providers.dart';
import 'ft_pressable.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.value;

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Brand Mark + Name
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  'assets/images/dashboard/brand_mark.webp',
                  width: 32,
                  height: 32,
                  cacheWidth: 64,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'FitTrack',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.55, // 22 * -0.025em
                  color: context.ftInk,
                ),
              ),
            ],
          ),

          // Right: Notification Bell + Avatar
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 40x40 circle glass2 bell
              FtPressable(
                onTap: () {
                  // Navigate to notifications or history if available
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
                              color: context.ftPrimary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 36x36 circle avatar
              FtPressable(
                onTap: () => context.go('/settings'),
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
                    child: _buildAvatarImage(profile?.profileImagePath, profile?.name),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(String? path, String? name) {
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

    // Bundled 2x sample avatar
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
