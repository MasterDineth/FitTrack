import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/modals/modal_backdrop_helper.dart';

/// FitTrack Settings Screen – Tab Index 3 of the main navigation dock.
///
/// Implemented strictly adhering to the Stitch design specification:
/// - Top header with animated mint indicator dot
/// - Search settings text field
/// - Profile & Account Header Card with verified tick, PRO LIFTER badge, and "Manage Account"
/// - 4 grouped sections: Account & Security, Workout & Timers, App Preferences, Support & About
/// - Status pill badges ("Biometrics On", "Enabled")
/// - Outlined destructive Log Out button with confirmation dialog
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // ── Theme tokens matching Stitch specification ─────────────────────────
  static const Color _bg = Color(0xFFF7F9FB);
  static const Color _cardBg = Colors.white;
  static const Color _mint = Color(0xFF00D68F);
  static const Color _darkGreen = Color(0xFF006C46);
  static const Color _slateDark = Color(0xFF0F172A);
  static const Color _slateMuted = Color(0xFF64748B);
  static const Color _slateLight = Color(0xFF94A3B8);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _iconBg = Color(0xFFF1F5F9);
  static const Color _errorRed = Color(0xFFBA1A1A);
  static const Color _proLifterBg = Color(0xFFDAE2FD);
  static const Color _proLifterText = Color(0xFF1E293B);

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _cardBg,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Log Out',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _slateDark,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out of your FitTrack account?',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              color: _slateMuted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                  color: _slateMuted,
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
                  color: _errorRed,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRatingSheet(BuildContext context) {
    showBlurBottomSheet<void>(
      context: context,
      child: Container(
        decoration: const BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Icon(
                  Icons.star_rate_rounded,
                  color: Color(0xFFF59E0B),
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Enjoying FitTrack?',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _slateDark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your feedback helps us continuously improve the lifting and tracking experience.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    color: _slateMuted,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _mint,
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
                          backgroundColor: _slateDark,
                        ),
                      );
                    },
                    child: const Text(
                      'Rate on App Store',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        color: _slateDark,
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
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
                    // Mint dot indicator
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: _mint,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.015 * 22,
                        color: _slateDark,
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
                  _buildSearchBar(),
                  const SizedBox(height: 16),

                  // Profile & Account Header Card
                  _buildProfileCard(context),
                  const SizedBox(height: 24),

                  // Section 1: ACCOUNT & SECURITY
                  _buildSectionHeader('Account & Security'),
                  const SizedBox(height: 8),
                  _buildSectionCard([
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
                        backgroundColor: _mint.withValues(alpha: 0.18),
                        textColor: const Color(0xFF005737),
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
                  _buildSectionHeader('Workout & Timers'),
                  const SizedBox(height: 8),
                  _buildSectionCard([
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
                  _buildSectionHeader('App Preferences'),
                  const SizedBox(height: 8),
                  _buildSectionCard([
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
                      trailingBadge: const _BadgePill(
                        label: 'Enabled',
                        backgroundColor: _proLifterBg,
                        textColor: _proLifterText,
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
                  _buildSectionHeader('Support & About'),
                  const SizedBox(height: 8),
                  _buildSectionCard([
                    _SettingsTile(
                      icon: Icons.help_outline_rounded,
                      iconColor: _slateMuted,
                      title: 'Help Center & FAQs',
                      subtitle: 'Guides, tutorials, contact support',
                      onTap: () => context.push('/settings/help'),
                    ),
                    _SettingsTile(
                      icon: Icons.star_rate_rounded,
                      iconColor: _slateMuted,
                      title: 'Share & Rate FitTrack',
                      subtitle: 'Support our development with a review',
                      onTap: () => _showRatingSheet(context),
                    ),
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: _slateMuted,
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
  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _slateDark.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.search_rounded,
              size: 20,
              color: _slateMuted,
            ),
          ),
          const Expanded(
            child: TextField(
              enabled: false,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                color: _slateDark,
              ),
              decoration: InputDecoration(
                hintText: 'Search settings...',
                hintStyle: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  color: _slateLight,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _iconBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '⌘K',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _slateMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Profile & Account Header Card ───────────────────────────────────────
  Widget _buildProfileCard(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/profile'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: _slateDark.withValues(alpha: 0.04),
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
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [_darkGreen, _mint],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'D',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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
                      color: _mint,
                      shape: BoxShape.circle,
                      border: Border.all(color: _cardBg, width: 2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: 11,
                        color: Color(0xFF003922),
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
                      const Flexible(
                        child: Text(
                          'Dineth',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _slateDark,
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
                          color: _proLifterBg,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Text(
                          'PRO LIFTER',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: _proLifterText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '@dineth.fit',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      color: _slateMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Manage Account',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _darkGreen,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 9,
                        color: _darkGreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: _slateLight,
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Header ──────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.06 * 11,
          color: _slateMuted,
        ),
      ),
    );
  }

  // ── Section Container Card ──────────────────────────────────────────────
  Widget _buildSectionCard(List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _slateDark.withValues(alpha: 0.03),
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
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF1F5F9),
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
    return InkWell(
      onTap: () => _showLogoutDialog(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _errorRed.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _errorRed.withValues(alpha: 0.04),
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
              color: _errorRed,
            ),
            SizedBox(width: 8),
            Text(
              'Log Out',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _errorRed,
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
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: iconColor ?? const Color(0xFF006C46),
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
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
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
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFF94A3B8),
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
