import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fittrack/presentation/screens/dashboard/widgets/ft_pressable.dart';
import 'package:fittrack/presentation/theme/ft_glass.dart';

/// Settings & Preferences Navigation Section on Profile Screen.
///
/// Features strictly 3 curated links:
/// 1. Account Details (Name, email, phone & credentials)
/// 2. Data & Backup (Cloud sync, export & health integrations)
/// 3. Workout Settings (Rest timer defaults, equipment & units)
class ProfileSettingsLinks extends StatelessWidget {
  const ProfileSettingsLinks({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final ink = context.ftInk;
    final muted = context.ftMuted;
    final primary = context.ftPrimary;
    final settings = FtGlassTheme.resolveThemeSettings(context);

    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE2E8F0).withValues(alpha: 0.60);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Header ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: Text(
            'SETTINGS & PREFERENCES',
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: muted,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // ── 3 Settings Navigation Tiles ────────────────────────────────
        Container(
          decoration: FtGlassTheme.cardDecoration(
            context,
            radius: 24,
            settings: settings,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // 1. Account Details
              _buildTile(
                icon: Icons.manage_accounts_rounded,
                iconBg: primary.withValues(alpha: isDark ? 0.22 : 0.12),
                iconColor: primary,
                title: 'Account Details',
                subtitle: 'Name, email, phone & credentials',
                onTap: () => context.push('/settings/account'),
                ink: ink,
                muted: muted,
              ),
              Divider(height: 1, thickness: 1, color: dividerColor),

              // 2. Data & Backup
              _buildTile(
                icon: Icons.cloud_sync_rounded,
                iconBg: const Color(0xFF14B8A6).withValues(alpha: isDark ? 0.22 : 0.12),
                iconColor: const Color(0xFF14B8A6),
                title: 'Data & Backup',
                subtitle: 'Cloud sync, export & health integrations',
                onTap: () => context.push('/settings/data'),
                ink: ink,
                muted: muted,
              ),
              Divider(height: 1, thickness: 1, color: dividerColor),

              // 3. Workout Settings
              _buildTile(
                icon: Icons.tune_rounded,
                iconBg: const Color(0xFF6366F1).withValues(alpha: isDark ? 0.22 : 0.12),
                iconColor: const Color(0xFF6366F1),
                title: 'Workout Settings',
                subtitle: 'Rest timer defaults, equipment & units',
                onTap: () => context.push('/settings/workout-preferences'),
                ink: ink,
                muted: muted,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color ink,
    required Color muted,
  }) {
    return FtPressable(
      onTap: onTap,
      pressedScale: 0.98,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 1.5),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: muted.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
