import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fittrack/domain/entities/user_profile.dart';
import 'package:fittrack/presentation/screens/dashboard/widgets/ft_pressable.dart';
import 'package:fittrack/presentation/theme/ft_glass.dart';

/// Top Hero Section for Profile screen.
///
/// Features:
/// - Athlete avatar portrait with luminous gradient ring & edit photo badge
/// - Verified athlete name and dynamic handle
/// - Pulsing status pill indicating athlete tier (e.g. ADVANCED LIFTER)
class ProfileHeroSection extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEditPhoto;

  const ProfileHeroSection({
    super.key,
    required this.profile,
    required this.onEditPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = context.ftPrimary;
    final ink = context.ftInk;
    final muted = context.ftMuted;

    final imagePath = profile.profileImagePath;
    final initials = profile.name.trim().isNotEmpty
        ? profile.name.trim()[0].toUpperCase()
        : 'D';
    final handle =
        '@${profile.name.toLowerCase().replaceAll(RegExp(r'\s+'), '')}.fit';
    final level = profile.experienceLevel.trim().isNotEmpty
        ? profile.experienceLevel.toUpperCase()
        : 'ACTIVE';

    return Column(
      children: [
        // ── Avatar with Luminous Glow & Edit Photo Button ──────────────
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 96,
              height: 96,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    primary,
                    primary.withValues(alpha: 0.65),
                    const Color(0xFF2DD4BF),
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: isDark ? 0.40 : 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF241D3B) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.20)
                        : Colors.white,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: (imagePath != null &&
                          imagePath.isNotEmpty &&
                          File(imagePath).existsSync())
                      ? Image.file(
                          File(imagePath),
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                          cacheWidth: 176,
                          errorBuilder: (_, _, _) => _buildInitials(initials, primary, isDark),
                        )
                      : _buildInitials(initials, primary, isDark),
                ),
              ),
            ),

            // Camera / Edit Photo Badge
            Positioned(
              bottom: 0,
              right: 0,
              child: FtPressable(
                onTap: onEditPhoto,
                pressedScale: 0.88,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2A2049)
                        : Colors.white.withValues(alpha: 0.90),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.30)
                          : Colors.white,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.edit_rounded,
                    size: 16,
                    color: primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Verified Name ──────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                profile.name.isNotEmpty ? profile.name : 'Athlete',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: ink,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.verified_rounded,
              size: 20,
              color: primary,
            ),
          ],
        ),
        const SizedBox(height: 2),

        // ── Dynamic Handle ─────────────────────────────────────────────
        Text(
          handle,
          style: TextStyle(
            fontFamily: FtText.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: muted,
          ),
        ),
        const SizedBox(height: 10),

        // ── Athlete Status Pill ────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4.5),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: isDark ? 0.20 : 0.10),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: primary.withValues(alpha: isDark ? 0.35 : 0.20),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$level LIFTER',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInitials(String initials, Color primary, bool isDark) {
    return Container(
      color: primary.withValues(alpha: isDark ? 0.25 : 0.12),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: FtText.fontFamily,
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: primary,
        ),
      ),
    );
  }
}
