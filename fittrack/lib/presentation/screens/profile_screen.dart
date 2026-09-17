import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/modals/selection_modal.dart';
import '../widgets/modals/text_input_modal.dart';

/// FitTrack Profile Screen – Sub-screen pushed from Settings with full editability
/// and SQLite persistence via [UserProfileNotifier].
class ProfileScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final profile = userProfileAsync.value ??
        const UserProfile(
          id: '1',
          name: 'Dineth',
          age: 20,
          weightKg: 80.0,
          heightCm: 170.0,
          experienceLevel: 'Advanced',
          primaryGoal: 'Hypertrophy & Strength',
          weeklyTargetDays: 4,
        );

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(color: _slateDark),
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: _slateDark,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 36),
          child: Column(
            children: [
              // ── Hero Section ─────────────────────────────────────────────
              const SizedBox(height: 8),
              _buildHeroSection(context, ref, profile),
              const SizedBox(height: 20),

              // ── Main Content Cards ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Overview Stats Card (2x2 Grid with dynamic BMI)
                    _buildOverviewCard(profile),
                    const SizedBox(height: 16),

                    // Personal Info Card (7 editable items)
                    _buildPersonalInfoCard(context, ref, profile),
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

  // ── Hero Section: Avatar, Verified Name, Metadata & Badges ───────────────
  Widget _buildHeroSection(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) {
    final hasCustomImage = profile.profileImagePath != null &&
        File(profile.profileImagePath!).existsSync();

    final initials = profile.name.trim().isNotEmpty
        ? profile.name.trim()[0].toUpperCase()
        : 'D';

    final handle =
        '@${profile.name.toLowerCase().replaceAll(RegExp(r'\s+'), '')}.fit';

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
                child: ClipOval(
                  child: hasCustomImage
                      ? Image.file(
                          File(profile.profileImagePath!),
                          width: 104,
                          height: 104,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: _slateDark,
                            ),
                          ),
                        ),
                ),
              ),
            ),

            // Camera badge button
            Positioned(
              bottom: 2,
              right: 2,
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () {
                    ref
                        .read(userProfileProvider.notifier)
                        .updateProfileImage();
                  },
                  customBorder: const CircleBorder(),
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
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // User name with verified badge
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                profile.name,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: _slateDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.verified_rounded,
              size: 20,
              color: _mintDark,
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Handle & join metadata
        Text(
          '$handle • Member since 2026',
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _slateMuted,
          ),
        ),
        const SizedBox(height: 12),

        // Level Badge (PRO badge removed per requirements)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: _mintLight,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: const Color(0xFF6EE7B7).withValues(alpha: 0.6),
            ),
          ),
          child: Text(
            '${profile.experienceLevel.toUpperCase()} LIFTER',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: Color(0xFF008F5C),
            ),
          ),
        ),
      ],
    );
  }

  // ── Overview Card: 2x2 Grid of Performance Metrics ───────────────────────
  Widget _buildOverviewCard(UserProfile profile) {
    final bmi = profile.calculateBMI;
    final bmiCategory = profile.getBMICategory;

    // Adaptive theme colors based on BMI Category
    final Color badgeBg;
    final Color badgeColor;
    final Color iconBg;
    final Color iconColor;

    if (bmiCategory == 'NORMAL') {
      badgeBg = const Color(0xFFD1FAE5);
      badgeColor = const Color(0xFF047857);
      iconBg = const Color(0xFFCCFBF1);
      iconColor = const Color(0xFF0F766E);
    } else if (bmiCategory == 'OVERWEIGHT') {
      badgeBg = const Color(0xFFFFE4E6);
      badgeColor = const Color(0xFFE11D48);
      iconBg = const Color(0xFFFFE4E6);
      iconColor = const Color(0xFFE11D48);
    } else {
      // Underweight
      badgeBg = const Color(0xFFFEF3C7);
      badgeColor = const Color(0xFFD97706);
      iconBg = const Color(0xFFFEF3C7);
      iconColor = const Color(0xFFD97706);
    }

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
                  iconBg: iconBg,
                  iconColor: iconColor,
                  label: 'BMI',
                  value: bmi > 0 ? bmi.toStringAsFixed(1) : '22.5',
                  badge: bmiCategory,
                  badgeBg: badgeBg,
                  badgeColor: badgeColor,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Icon(icon, size: 14, color: iconColor),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                flex: badge != null ? 1 : 1,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _slateMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 4),
                Flexible(
                  flex: 2,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg ?? const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          color: badgeColor ?? const Color(0xFF047857),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: _slateDark,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    unit,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: unitColor ?? _slateLight,
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

  // ── Personal Info Card: 7 Configured Rows with Edit Modals ───────────────
  Widget _buildPersonalInfoCard(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Personal Info',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _slateDark,
                ),
              ),
              InkWell(
                onTap: () async {
                  final result = await TextInputModal.show(
                    context: context,
                    title: 'Edit Name',
                    subtitle: 'Update your display name across FitTrack',
                    initialValue: profile.name,
                    hintText: 'Enter your name',
                  );
                  if (result != null && result.isNotEmpty) {
                    await ref
                        .read(userProfileProvider.notifier)
                        .updateField(name: result);
                  }
                },
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'Tap to edit',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _slateLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 1. Name
          _buildInfoRow(
            label: 'Name',
            value: profile.name,
            isEditable: true,
            onTap: () async {
              final result = await TextInputModal.show(
                context: context,
                title: 'Edit Name',
                subtitle: 'Update your display name',
                initialValue: profile.name,
                hintText: 'Enter your name',
              );
              if (result != null && result.isNotEmpty) {
                await ref
                    .read(userProfileProvider.notifier)
                    .updateField(name: result);
              }
            },
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 2. Age
          _buildInfoRow(
            label: 'Age',
            value: '${profile.age} yrs',
            isEditable: true,
            onTap: () async {
              final result = await TextInputModal.show(
                context: context,
                title: 'Edit Age',
                subtitle: 'Enter your age in years',
                initialValue: profile.age.toString(),
                keyboardType: TextInputType.number,
                suffixText: 'yrs',
              );
              if (result != null) {
                final parsed = int.tryParse(result);
                if (parsed != null && parsed > 0) {
                  await ref
                      .read(userProfileProvider.notifier)
                      .updateField(age: parsed);
                }
              }
            },
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 3. Weight
          _buildInfoRow(
            label: 'Weight',
            value: '${profile.weightKg.toStringAsFixed(1)} kg',
            isEditable: true,
            onTap: () async {
              final result = await TextInputModal.show(
                context: context,
                title: 'Edit Weight',
                subtitle: 'Enter current bodyweight in kilograms',
                initialValue: profile.weightKg.toStringAsFixed(1),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                suffixText: 'kg',
              );
              if (result != null) {
                final parsed = double.tryParse(result);
                if (parsed != null && parsed > 0) {
                  await ref
                      .read(userProfileProvider.notifier)
                      .updateField(weightKg: parsed);
                }
              }
            },
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 4. Height
          _buildInfoRow(
            label: 'Height',
            value: '${profile.heightCm.toStringAsFixed(1)} cm',
            isEditable: true,
            onTap: () async {
              final result = await TextInputModal.show(
                context: context,
                title: 'Edit Height',
                subtitle: 'Enter height in centimeters',
                initialValue: profile.heightCm.toStringAsFixed(1),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                suffixText: 'cm',
              );
              if (result != null) {
                final parsed = double.tryParse(result);
                if (parsed != null && parsed > 0) {
                  await ref
                      .read(userProfileProvider.notifier)
                      .updateField(heightCm: parsed);
                }
              }
            },
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 5. Experience Level
          _buildInfoRow(
            label: 'Experience Level',
            customValueWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _mintLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                profile.experienceLevel,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF008F5C),
                ),
              ),
            ),
            hasChevron: true,
            onTap: () async {
              final result = await SelectionModal.show(
                context: context,
                title: 'Select Experience Level',
                subtitle: 'Choose your lifting experience tier',
                options: const [
                  'Beginner',
                  'Intermediate',
                  'Advanced',
                  'Elite',
                ],
                selectedOption: profile.experienceLevel,
              );
              if (result != null) {
                await ref
                    .read(userProfileProvider.notifier)
                    .updateField(experienceLevel: result);
              }
            },
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 6. Primary Goal
          _buildInfoRow(
            label: 'Primary Goal',
            value: profile.primaryGoal,
            hasChevron: true,
            onTap: () async {
              final result = await SelectionModal.show(
                context: context,
                title: 'Select Primary Goal',
                subtitle: 'Choose your main training objective',
                options: const [
                  'Hypertrophy & Strength',
                  'Pure Strength (Powerlifting)',
                  'Fat Loss & Conditioning',
                  'Cardiovascular & Endurance',
                  'Mobility & General Fitness',
                ],
                selectedOption: profile.primaryGoal,
              );
              if (result != null) {
                await ref
                    .read(userProfileProvider.notifier)
                    .updateField(primaryGoal: result);
              }
            },
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 7. Weekly Target
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
                Text(
                  '${profile.weeklyTargetDays} Days',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _slateDark,
                  ),
                ),
              ],
            ),
            hasChevron: true,
            onTap: () async {
              final result = await SelectionModal.show(
                context: context,
                title: 'Select Weekly Target',
                subtitle: 'Number of training sessions scheduled each week',
                options: const [
                  '2 Days',
                  '3 Days',
                  '4 Days',
                  '5 Days',
                  '6 Days',
                  '7 Days',
                ],
                selectedOption: '${profile.weeklyTargetDays} Days',
              );
              if (result != null) {
                final days = int.tryParse(result.split(' ').first);
                if (days != null) {
                  await ref
                      .read(userProfileProvider.notifier)
                      .updateField(weeklyTargetDays: days);
                }
              }
            },
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
    VoidCallback? onTap,
    int maxLines = 2,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (customValueWidget != null)
                    Flexible(child: customValueWidget)
                  else if (value != null)
                    Flexible(
                      child: Text(
                        value,
                        textAlign: TextAlign.end,
                        maxLines: maxLines,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _slateDark,
                          height: 1.25,
                        ),
                      ),
                    ),
                  if (isEditable) ...[
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: _slateLight,
                    ),
                  ],
                  if (hasChevron) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: _slateLight,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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
