import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/user_profile_provider.dart';
import '../../screens/dashboard/widgets/ft_pressable.dart';
import '../../theme/ft_glass.dart';
import 'ft_header_tokens.dart';

/// Circular profile avatar button with image caching and profile navigation.
class FtHeaderAvatar extends ConsumerWidget {
  const FtHeaderAvatar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? profileImagePath;
    String? name;

    try {
      final profile = ref.watch(userProfileProvider.select((p) => p.value));
      profileImagePath = profile?.profileImagePath;
      name = profile?.name;
    } catch (_) {
      // Graceful fallback for widget tests without ProviderScope
    }

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = (FtHeaderTokens.avatarVisualSize * dpr).ceil();

    return Semantics(
      button: true,
      label: 'Profile settings',
      child: FtPressable(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/settings/profile');
        },
        pressedScale: 0.95,
        child: Container(
          width: FtHeaderTokens.avatarVisualSize,
          height: FtHeaderTokens.avatarVisualSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2.0,
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
            child: _buildAvatarImage(
              context,
              profileImagePath,
              name,
              cacheWidth,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage(
    BuildContext context,
    String? path,
    String? name,
    int cacheWidth,
  ) {
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      return Image(
        image: ResizeImage(
          FileImage(file),
          width: cacheWidth,
        ),
        width: FtHeaderTokens.avatarVisualSize,
        height: FtHeaderTokens.avatarVisualSize,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildFallbackAvatar(context, name, cacheWidth),
      );
    }
    return _buildFallbackAvatar(context, name, cacheWidth);
  }

  Widget _buildFallbackAvatar(
    BuildContext context,
    String? name,
    int cacheWidth,
  ) {
    return Image.asset(
      'assets/images/dashboard/sample_avatar.webp',
      width: FtHeaderTokens.avatarVisualSize,
      height: FtHeaderTokens.avatarVisualSize,
      fit: BoxFit.cover,
      cacheWidth: cacheWidth,
      errorBuilder: (_, _, _) {
        final initial = (name != null && name.trim().isNotEmpty)
            ? name.trim()[0].toUpperCase()
            : 'M';
        return Container(
          color: context.ftPrimary,
          alignment: Alignment.center,
          child: Text(
            initial,
            style: const TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
