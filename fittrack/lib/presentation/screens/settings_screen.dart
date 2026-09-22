import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/modals/modal_backdrop_helper.dart';

/// FitTrack Settings Screen – Tab Index 3 of the main navigation dock.
///
/// Implemented strictly adhering to the Stitch design specification:
/// - Top header with animated mint indicator dot
/// - Search settings text field
/// - Profile & Account Header Card with verified tick, dynamic avatar, and "Manage Account"
/// - 4 grouped sections: Account & Security, Workout & Timers, App Preferences, Support & About
/// - Status pill badges ("Biometrics On", "Enabled")
/// - Outlined destructive Log Out button with confirmation dialog
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardBg = theme.cardTheme.color ?? colorScheme.surface;
    const errorRed = Color(0xFFBA1A1A);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardBg,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Log Out',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            'Are you sure you want to log out of your FitTrack account?',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                debugPrint('Logout confirmed');
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Log Out',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  color: errorRed,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRatingSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardBg = theme.cardTheme.color ?? colorScheme.surface;

    showBlurBottomSheet<void>(
      context: context,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_rounded, size: 28, color: Color(0xFFF59E0B)),
                    Icon(Icons.star_rounded, size: 28, color: Color(0xFFF59E0B)),
                    Icon(Icons.star_rounded, size: 28, color: Color(0xFFF59E0B)),
                    Icon(Icons.star_rounded, size: 28, color: Color(0xFFF59E0B)),
                    Icon(Icons.star_rounded, size: 28, color: Color(0xFFF59E0B)),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Enjoying FitTrack?',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your feedback helps us continuously improve the lifting and tracking experience.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Thank you for rating FitTrack!',
                            style: TextStyle(fontFamily: 'Plus Jakarta Sans'),
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: colorScheme.surfaceContainerHighest,
                        ),
                      );
                    },
                    child: Text(
                      'Rate on App Store',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userProfileAsync = ref.watch(userProfileProvider);
    final profile = userProfileAsync.value;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Top Header ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    // Dynamic accent dot indicator
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.015 * 22,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Main Content Body ────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Search Bar
                  _buildSearchBar(context),
                  const SizedBox(height: 16),

                  // Profile & Account Header Card
                  _buildProfileCard(context, profile),
                  const SizedBox(height: 24),

                  // Section 1: ACCOUNT & SECURITY
                  _buildSectionHeader(context, 'Account & Security'),
                  const SizedBox(height: 8),
                  _buildSectionCard(context, [
                    _SettingsTile(
                      icon: Icons.badge_outlined,
                      title: 'Account Details',
                      subtitle: 'Name, username, email, mobile',
                      onTap: () => context.push('/settings/account'),
                    ),
                    _SettingsTile(
                      icon: Icons.shield_outlined,
                      title: 'Security & Privacy',
                      subtitle: 'App lock, Biometrics unlock, 2FA',
                      trailingBadge: _BadgePill(
                        label: 'Biometrics On',
                        backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                        textColor: colorScheme.primary,
                      ),
                      onTap: () => context.push('/settings/security'),
                    ),
                    _SettingsTile(
                      icon: Icons.key_outlined,
                      title: 'Password & Authentication',
                      subtitle: 'Change password, active sessions',
                      onTap: () => context.push('/settings/password'),
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // Section 2: WORKOUT & TIMERS
                  _buildSectionHeader(context, 'Workout & Timers'),
                  const SizedBox(height: 8),
                  _buildSectionCard(context, [
                    _SettingsTile(
                      icon: Icons.timer_outlined,
                      title: 'Workout Preferences',
                      subtitle: 'Rest timer (01:30), auto-start, haptics',
                      onTap: () => context.push('/settings/workout-preferences'),
                    ),
                    _SettingsTile(
                      icon: Icons.fitness_center_outlined,
                      title: 'Units & Equipment',
                      subtitle: 'Metric (kg, cm), Barbell 20.0 kg',
                      onTap: () => context.push('/settings/units-equipment'),
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // Section 3: APP PREFERENCES
                  _buildSectionHeader(context, 'App Preferences'),
                  const SizedBox(height: 8),
                  _buildSectionCard(context, [
                    _SettingsTile(
                      icon: Icons.palette_outlined,
                      title: 'Appearance & Display',
                      subtitle: 'System Default theme, accent colors',
                      onTap: () => context.push('/settings/appearance'),
                    ),
                    _SettingsTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'Notifications & Reminders',
                      subtitle: 'Workout reminders, streak alerts',
                      trailingBadge: _BadgePill(
                        label: 'Enabled',
                        backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                        textColor: colorScheme.primary,
                      ),
                      onTap: () => context.push('/settings/notifications'),
                    ),
                    _SettingsTile(
                      icon: Icons.sync_alt_rounded,
                      title: 'Data & Integrations',
                      subtitle: 'Apple Health synced, cloud backup',
                      onTap: () => context.push('/settings/data'),
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // Section 4: SUPPORT & ABOUT
                  _buildSectionHeader(context, 'Support & About'),
                  const SizedBox(height: 8),
                  _buildSectionCard(context, [
                    _SettingsTile(
                      icon: Icons.help_outline_rounded,
                      iconColor: colorScheme.onSurfaceVariant,
                      title: 'Help Center & FAQs',
                      subtitle: 'Guides, tutorials, contact support',
                      onTap: () => context.push('/settings/help'),
                    ),
                    _SettingsTile(
                      icon: Icons.star_rate_rounded,
                      iconColor: colorScheme.onSurfaceVariant,
                      title: 'Share & Rate FitTrack',
                      subtitle: 'Support our development with a review',
                      onTap: () => _showRatingSheet(context),
                    ),
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: colorScheme.onSurfaceVariant,
                      title: 'About FitTrack',
                      subtitle: 'v1.4.2 (Latest)',
                      onTap: () => context.push('/settings/about'),
                    ),
                  ]),
                  const SizedBox(height: 28),

                  // Destructive Log Out Action Button
                  _buildLogoutButton(context),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search Bar Component ────────────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final iconBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        enabled: false,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 14,
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Search settings...',
          hintStyle: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '⌘K',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ── Profile & Account Header Card ───────────────────────────────────────
  Widget _buildProfileCard(BuildContext context, UserProfile? profile) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = theme.cardTheme.color ?? colorScheme.surface;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    final hasCustomImage = profile?.profileImagePath != null &&
        File(profile!.profileImagePath!).existsSync();
    final name = (profile?.name.trim().isNotEmpty == true) ? profile!.name : 'Dineth';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'D';
    final handle = '@${name.toLowerCase().replaceAll(' ', '')}.fit';
    final experience = profile?.experienceLevel ?? 'Advanced';

    return InkWell(
      onTap: () => context.push('/settings/profile'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar with verified badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: hasCustomImage
                        ? null
                        : LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withValues(alpha: 0.75),
                              colorScheme.tertiary,
                            ],
                          ),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: hasCustomImage
                        ? Image.file(
                            File(profile.profileImagePath!),
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Text(
                              initial,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  bottom: -1,
                  right: -1,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: cardBg, width: 2),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: 11,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Profile info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '${experience.toUpperCase()} LIFTER',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    handle,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Manage Account',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 9,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Header ──────────────────────────────────────────────────────
  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.06 * 11,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  // ── Section Container Card ──────────────────────────────────────────────
  Widget _buildSectionCard(BuildContext context, List<Widget> tiles) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = theme.cardTheme.color ?? colorScheme.surface;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            for (int i = 0; i < tiles.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: dividerColor,
                ),
              tiles[i],
            ],
          ],
        ),
      ),
    );
  }

  // ── Outlined Log Out Button ─────────────────────────────────────────────
  Widget _buildLogoutButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardBg = theme.cardTheme.color ?? colorScheme.surface;
    const errorRed = Color(0xFFBA1A1A);

    return InkWell(
      onTap: () => _showLogoutDialog(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: errorRed.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: errorRed.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              size: 20,
              color: errorRed,
            ),
            SizedBox(width: 8),
            Text(
              'Log Out',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: errorRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable List Tile for Settings Sections ────────────────────────────────
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.trailingBadge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Widget? trailingBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final iconBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: iconColor ?? colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),

            // Text column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12.5,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Optional status badge
            if (trailingBadge != null) ...[
              trailingBadge!,
              const SizedBox(width: 6),
            ],

            // Trailing chevron
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable Badge Pill Widget ──────────────────────────────────────────────
class _BadgePill extends StatelessWidget {
  const _BadgePill({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: textColor,
        ),
      ),
    );
  }
}
