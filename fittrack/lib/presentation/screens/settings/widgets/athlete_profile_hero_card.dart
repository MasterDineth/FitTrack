import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/entities/user_profile.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../theme/ft_glass.dart';
import 'ft_settings_card.dart';

/// Athlete Profile Hero Card matching the Stitch design specification:
/// - 60x60 Avatar wrapped in brand gradient ring with bottom-right emerald verified checkmark badge
/// - Athlete Name & handle (@username.fit)
/// - Experience Level pill badge with star icon
/// - Trailing chevron with tap feedback pushing to `/settings/profile`
class AthleteProfileHeroCard extends StatelessWidget {
  const AthleteProfileHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final hasScope = context.findAncestorWidgetOfExactType<ProviderScope>() != null ||
        context.findAncestorWidgetOfExactType<UncontrolledProviderScope>() != null;

    if (hasScope) {
      return const _ReactiveAthleteProfileHeroCard();
    }
    return const _StaticAthleteProfileHeroCard(profile: null);
  }
}

class _ReactiveAthleteProfileHeroCard extends ConsumerWidget {
  const _ReactiveAthleteProfileHeroCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(
      userProfileProvider.select((asyncVal) => asyncVal.value),
    );
    return _StaticAthleteProfileHeroCard(profile: userProfile);
  }
}

class _StaticAthleteProfileHeroCard extends StatelessWidget {
  final UserProfile? profile;

  const _StaticAthleteProfileHeroCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final name = (profile?.name.trim().isNotEmpty == true)
        ? profile!.name
        : 'Dineth';
    final handle = '@${name.toLowerCase().replaceAll(' ', '')}.fit';
    final experience = (profile?.experienceLevel.trim().isNotEmpty == true)
        ? profile!.experienceLevel
        : 'Advanced Lifter';

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Semantics(
        button: true,
        label: 'Open profile details for $name',
        child: FtSettingsCard(
          radius: 24,
          padding: const EdgeInsets.all(16),
          onTap: () => context.push('/settings/profile'),
          child: Row(
            children: [
              // Avatar with gradient halo ring & verified checkmark badge
              _buildAvatarStack(context, profile),
              const SizedBox(width: 14),

              // Name, handle, and experience level badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: context.ftInk,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      handle,
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: context.ftMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Dynamic Experience badge with star icon
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: context.ftPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: context.ftPrimary.withValues(alpha: 0.28),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: context.ftPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            experience,
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: context.ftPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Trailing Chevron
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: context.ftMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarStack(BuildContext context, UserProfile? profile) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Gradient outer ring
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.ftPrimary,
                  context.ftPrimaryLight,
                  FtGlassTheme.teal,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: context.ftPrimary.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(2.5),
            child: ClipOval(
              child: _buildAvatarImage(profile?.profileImagePath),
            ),
          ),

          // Emerald verified checkmark badge at bottom-right
          Positioned(
            bottom: -1,
            right: -1,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981), // Emerald-500
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 12,
                color: Colors.white,
              ),
            ),
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
        width: 55,
        height: 55,
        fit: BoxFit.cover,
        cacheWidth: 120,
        errorBuilder: (_, _, _) => _buildFallbackAvatar(),
      );
    }
    return _buildFallbackAvatar();
  }

  Widget _buildFallbackAvatar() {
    return Image.asset(
      'assets/images/dashboard/sample_avatar.webp',
      width: 55,
      height: 55,
      fit: BoxFit.cover,
      cacheWidth: 120,
    );
  }
}
