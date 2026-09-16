import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// FitTrack Profile Screen – Tab Index 3 of the 5-tab navigation dock.
///
/// Implemented strictly adhering to the Stitch design specification:
/// - Screen navigation header with centered "Profile" title and top-right settings shortcut gear
/// - User Hero Section: 112x112 avatar with emerald gradient ring, camera badge, verified checkmark,
///   metadata, and "ADVANCED LIFTER" & "PRO" pill badges
/// - 2x2 Overview Card: Days Trained, Workouts, Calories, and BMI with NORMAL status pill
/// - Personal Info Card: 7 structured rows (Name, Age, Weight, Height, Level, Goal, Target)
/// - Preferences & Security Card: Workout Preferences, Health Sync (Connected), and Account Security
/// - Ghost "Sign Out of FitTrack" button with confirmation dialog
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ── Kinetic Slate Design Tokens ─────────────────────────────────────────
  static const Color _bg = Color(0xFFF7F9FB);
  static const Color _cardBg = Colors.white;
  static const Color _mint = Color(0xFF00D68F);
  static const Color _mintDark = Color(0xFF00A86B);
  static const Color _mintLight = Color(0xFFE6FAF3);
  static const Color _slateDark = Color(0xFF0F172A);
  static const Color _slate700 = Color(0xFF334155);
  static const Color _slateMuted = Color(0xFF64748B);
  static const Color _slateLight = Color(0xFF94A3B8);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _errorRed = Color(0xFFF43F5E);

  void _showSignOutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _cardBg,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Sign Out',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _slateDark,
            ),
          ),
          content: const Text(
            'Are you sure you want to sign out of FitTrack?',
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
                'Sign Out',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            children: [
              // ── Navigation Header ────────────────────────────────────────
              _buildHeader(context),

              // ── Hero Section ─────────────────────────────────────────────
              const SizedBox(height: 8),
              _buildHeroSection(),
              const SizedBox(height: 20),

              // ── Main Content Cards ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Overview Stats Card (2x2 Grid)
                    _buildOverviewCard(),
                    const SizedBox(height: 16),

                    // Personal Info Card (7 items)
                    _buildPersonalInfoCard(),
                    const SizedBox(height: 16),

                    // Preferences & Security Card (3 items)
                    _buildPreferencesCard(context),
                    const SizedBox(height: 20),

                    // Ghost Sign Out Button
                    _buildSignOutButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top Screen Navigation Header ────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Spacer for symmetry
          const SizedBox(width: 38, height: 38),

          // Title
          const Text(
            'Profile',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: _slateDark,
            ),
          ),

          // Settings shortcut gear
          InkWell(
            onTap: () => context.go('/settings'),
            borderRadius: BorderRadius.circular(19),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _cardBg,
                shape: BoxShape.circle,
                border: Border.all(color: _border),
                boxShadow: [
                  BoxShadow(
                    color: _slateDark.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.settings_outlined,
                size: 19,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero Section: Avatar, Verified Name, Metadata & Badges ───────────────
  Widget _buildHeroSection() {
    return Column(
      children: [
        // Avatar with gradient border & camera icon button
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 112,
              height: 112,
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [_mint, Color(0xFF6EE7B7), Color(0xFF2DD4BF)],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3300D68F),
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: const Center(
                  child: Text(
                    'D',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: _slateDark,
                    ),
                  ),
                ),
              ),
            ),

            // Camera badge button
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _mint,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _slateDark.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 16,
                    color: _slateDark,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // User name with verified badge
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Dineth',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: _slateDark,
              ),
            ),
            SizedBox(width: 6),
            Icon(
              Icons.verified_rounded,
              size: 20,
              color: _mintDark,
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Handle & join metadata
        const Text(
          '@dineth.fit • Member since 2026',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _slateMuted,
          ),
        ),
        const SizedBox(height: 12),

        // Badges: "ADVANCED LIFTER" & "PRO"
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Advanced Lifter Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _mintLight,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: const Color(0xFF6EE7B7).withValues(alpha: 0.6),
                ),
              ),
              child: const Text(
                'ADVANCED LIFTER',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: Color(0xFF008F5C),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // PRO Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _slateDark,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: Color(0xFFF59E0B),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'PRO',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Overview Card: 2x2 Grid of Performance Metrics ───────────────────────
  Widget _buildOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _slateDark.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row with "This Month" badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overview',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _slateDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'This Month',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _mintDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2x2 Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.calendar_today_rounded,
                  iconBg: const Color(0xFFE6FAF3),
                  iconColor: const Color(0xFF008F5C),
                  label: 'Days Trained',
                  value: '1',
                  unit: 'day streak',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.fitness_center_rounded,
                  iconBg: const Color(0xFFDBEAFE),
                  iconColor: const Color(0xFF2563EB),
                  label: 'Workouts',
                  value: '1',
                  unit: 'Session',
                  unitColor: _mintDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.local_fire_department_rounded,
                  iconBg: const Color(0xFFFEF3C7),
                  iconColor: const Color(0xFFD97706),
                  label: 'Calories',
                  value: '350.5',
                  unit: 'kcal',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.speed_rounded,
                  iconBg: const Color(0xFFCCFBF1),
                  iconColor: const Color(0xFF0F766E),
                  label: 'BMI',
                  value: '22.5',
                  badge: 'NORMAL',
                  badgeBg: const Color(0xFFD1FAE5),
                  badgeColor: const Color(0xFF047857),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    String? unit,
    Color? unitColor,
    String? badge,
    Color? badgeBg,
    Color? badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(icon, size: 16, color: iconColor),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _slateMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: _slateDark,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: unitColor ?? _slateLight,
                  ),
                ),
              ],
              if (badge != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeBg ?? const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: badgeColor ?? const Color(0xFF047857),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── Personal Info Card: 7 Configured Rows ────────────────────────────────
  Widget _buildPersonalInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _slateDark.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Personal Info',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _slateDark,
                ),
              ),
              Text(
                'Tap to edit',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _slateLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 7 items
          _buildInfoRow(label: 'Name', value: 'Dineth', isEditable: true),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildInfoRow(label: 'Age', value: '20 yrs', isEditable: true),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildInfoRow(label: 'Weight', value: '80.0 kg', isEditable: true),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildInfoRow(label: 'Height', value: '170.0 cm', isEditable: true),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildInfoRow(
            label: 'Experience Level',
            customValueWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _mintLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Advanced',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF008F5C),
                ),
              ),
            ),
            hasChevron: true,
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildInfoRow(
            label: 'Primary Goal',
            value: 'Hypertrophy & Strength',
            hasChevron: true,
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildInfoRow(
            label: 'Weekly Target',
            customValueWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: _mint,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '4 Days',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _slateDark,
                  ),
                ),
              ],
            ),
            hasChevron: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    String? value,
    Widget? customValueWidget,
    bool isEditable = false,
    bool hasChevron = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _slateMuted,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (customValueWidget != null)
                customValueWidget
              else if (value != null)
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _slateDark,
                  ),
                ),
              if (isEditable) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.edit_outlined,
                  size: 14,
                  color: _slateLight,
                ),
              ],
              if (hasChevron) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: _slateLight,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── Preferences & Security Card ─────────────────────────────────────────
  Widget _buildPreferencesCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _slateDark.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preferences & Security',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _slateDark,
            ),
          ),
          const SizedBox(height: 12),

          // 1. Workout Preferences
          _buildActionRow(
            icon: Icons.tune_rounded,
            iconBg: const Color(0xFFF1F5F9),
            iconColor: _slate700,
            title: 'Workout Preferences',
            onTap: () => context.push('/settings/workout-preferences'),
          ),
          const SizedBox(height: 6),

          // 2. Health Sync (Connected)
          _buildActionRow(
            icon: Icons.favorite_rounded,
            iconBg: const Color(0xFFFFE4E6),
            iconColor: _errorRed,
            title: 'Health Sync',
            subtitle: 'Connected',
            subtitleColor: _mintDark,
            onTap: () => context.push('/settings/data'),
          ),
          const SizedBox(height: 6),

          // 3. Account Security
          _buildActionRow(
            icon: Icons.shield_outlined,
            iconBg: const Color(0xFFEEF2FF),
            iconColor: const Color(0xFF4F46E5),
            title: 'Account Security',
            onTap: () => context.push('/settings/security'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? subtitleColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(icon, size: 18, color: iconColor),
              ),
            ),
            const SizedBox(width: 12),
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
                      color: _slate700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: subtitleColor ?? _mintDark,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: _slateLight,
            ),
          ],
        ),
      ),
    );
  }

  // ── Ghost Sign Out Button ───────────────────────────────────────────────
  Widget _buildSignOutButton(BuildContext context) {
    return InkWell(
      onTap: () => _showSignOutDialog(context),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.logout_rounded,
              size: 16,
              color: _errorRed.withValues(alpha: 0.9),
            ),
            const SizedBox(width: 8),
            Text(
              'Sign Out of FitTrack',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _errorRed.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
