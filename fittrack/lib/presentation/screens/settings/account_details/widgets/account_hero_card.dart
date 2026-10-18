import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fittrack/domain/entities/user_profile.dart';
import 'package:fittrack/presentation/screens/dashboard/widgets/ft_pressable.dart';
import 'package:fittrack/presentation/theme/ft_glass.dart';

/// Hero Card for Account Details screen.
///
/// Features:
/// - Specular avatar with live status dot
/// - Athlete name, dynamic handle, and Synced/Unsaved status pill
/// - Tapping anywhere on the profile info navigates directly to the Profile screen
/// - Frosted camera button allows instant profile photo updates
class AccountHeroCard extends StatelessWidget {
  final UserProfile profile;
  final bool isDirty;
  final VoidCallback onEditPhoto;

  const AccountHeroCard({
    super.key,
    required this.profile,
    required this.isDirty,
    required this.onEditPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = context.ftPrimary;
    final ink = context.ftInk;
    final muted = context.ftMuted;
    final settings = FtGlassTheme.resolveThemeSettings(context);

    final imagePath = profile.profileImagePath;
    final initials = profile.name.trim().isNotEmpty
        ? profile.name.trim()[0].toUpperCase()
        : 'D';
    final handle =
        '@${profile.name.toLowerCase().replaceAll(RegExp(r'\s+'), '')}.fit';

    final syncColor =
        isDirty ? const Color(0xFFD97706) : const Color(0xFF059669);
    final syncBg =
        isDirty ? const Color(0x25F59E0B) : const Color(0x2010B981);
    final syncLabel = isDirty ? 'Unsaved' : 'Synced';

    return FtPressable(
      onTap: () => context.push('/settings/profile'),
      pressedScale: 0.985,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: FtGlassTheme.cardDecoration(
          context,
          radius: 24,
          settings: settings,
        ),
        child: Row(
          children: [
            // ── Avatar with Live Dot & Gradient Ring ───────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  padding: const EdgeInsets.all(2.5),
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
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF241D3B) : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.20)
                            : Colors.white,
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: (imagePath != null &&
                              imagePath.isNotEmpty &&
                              File(imagePath).existsSync())
                          ? Image.file(
                              File(imagePath),
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                              cacheWidth: 120,
                              errorBuilder: (_, _, _) =>
                                  _buildInitials(initials, primary, isDark),
                            )
                          : _buildInitials(initials, primary, isDark),
                    ),
                  ),
                ),

                // Live Sync Dot Indicator
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: syncColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF1D1735) : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // ── Name, Handle & Status ──────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          profile.name.isNotEmpty ? profile.name : 'Athlete',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Synced/Unsaved Status Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: syncBg,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: syncColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              syncLabel,
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                                color: syncColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$handle · Member since 2026',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: muted,
                    ),
                  ),
                  const SizedBox(height: 5),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: isDark ? 0.20 : 0.10),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Pro Athlete Tier',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '· View Profile',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Camera Update Icon Button ──────────────────────────────
            FtPressable(
              onTap: onEditPhoto,
              pressedScale: 0.88,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.white,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.photo_camera_rounded,
                  size: 18,
                  color: primary,
                ),
              ),
            ),
          ],
        ),
      ),
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
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: primary,
        ),
      ),
    );
  }
}
