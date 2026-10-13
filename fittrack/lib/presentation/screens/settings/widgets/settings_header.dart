import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/dashboard_providers.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../theme/ft_glass.dart';
import 'ft_settings_card.dart';

/// Top header for FitTrack Settings matching the dashboard header layout & UI consistency.
class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final hasScope = context.findAncestorWidgetOfExactType<ProviderScope>() != null ||
        context.findAncestorWidgetOfExactType<UncontrolledProviderScope>() != null;

    if (hasScope) {
      return const _ReactiveSettingsHeader();
    }
    return const _StaticSettingsHeader(unreadCount: 0, profileImagePath: null);
  }
}

class _ReactiveSettingsHeader extends ConsumerWidget {
  const _ReactiveSettingsHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final profileImagePath = ref.watch(
      userProfileProvider.select((asyncVal) => asyncVal.value?.profileImagePath),
    );
    return _StaticSettingsHeader(
      unreadCount: unreadCount,
      profileImagePath: profileImagePath,
    );
  }
}

class _StaticSettingsHeader extends StatelessWidget {
  final int unreadCount;
  final String? profileImagePath;

  const _StaticSettingsHeader({
    required this.unreadCount,
    required this.profileImagePath,
  });

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

          // Right: Frosted Notification Bell + Profile Avatar (matching Dashboard UI consistency)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Notification Bell (40x40 circle glass2 with unread rose dot)
              Semantics(
                button: true,
                label: 'Notifications',
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      FtSettingsCard(
                        radius: 20,
                        padding: EdgeInsets.zero,
                        onTap: () => context.push('/settings/notifications'),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: Icon(
                              Icons.notifications_outlined,
                              size: 20,
                              color: context.ftInk,
                            ),
                          ),
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
                              color: const Color(0xFFF43F5E), // Rose indicator
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
              const SizedBox(width: 8),

              // Profile Avatar (36x36 circle avatar with white border and shadow)
              Semantics(
                button: true,
                label: 'View Profile',
                child: InkWell(
                  onTap: () => context.push('/settings/profile'),
                  borderRadius: BorderRadius.circular(18),
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
                      child: _buildAvatarImage(profileImagePath),
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

  Widget _buildAvatarImage(String? path) {
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      return Image.file(
        file,
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
