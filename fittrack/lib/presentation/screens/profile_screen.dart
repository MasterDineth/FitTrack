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

  void _showSignOutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardBg = theme.cardTheme.color ?? colorScheme.surface;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardBg,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Sign Out',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            'Are you sure you want to sign out of FitTrack?',
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
              child: Text(
                'Sign Out',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  color: colorScheme.error,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(color: colorScheme.onSurface),
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: colorScheme.onSurface,
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
                    _buildOverviewCard(context, profile),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardBg = theme.cardTheme.color ?? colorScheme.surface;
    final tileBg = colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);

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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.75),
                    colorScheme.tertiary,
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: tileBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.surface,
                    width: 2.5,
                  ),
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
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
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
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: cardBg, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.camera_alt_outlined,
                        size: 16,
                        color: colorScheme.onPrimary,
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
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.verified_rounded,
              size: 20,
              color: colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Handle & join metadata
        Text(
          '$handle • Member since 2026',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),

        // Level Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.35),
            ),
          ),
          child: Text(
            '${profile.experienceLevel.toUpperCase()} LIFTER',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  // ── Overview Card: 2x2 Grid of Performance Metrics ───────────────────────
  Widget _buildOverviewCard(BuildContext context, UserProfile profile) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = theme.cardTheme.color ?? colorScheme.surface;
    final border = colorScheme.outlineVariant;

    final bmi = profile.calculateBMI;
    final bmiCategory = profile.getBMICategory;

    // Adaptive theme colors based on BMI Category
    final Color badgeBg;
    final Color badgeColor;
    final Color iconBg;
    final Color iconColor;

    if (bmiCategory == 'NORMAL') {
      badgeBg = colorScheme.primary.withValues(alpha: 0.15);
      badgeColor = colorScheme.primary;
      iconBg = colorScheme.primary.withValues(alpha: 0.15);
      iconColor = colorScheme.primary;
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
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: isDark ? 0.2 : 0.04),
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
              Text(
                'Overview',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'This Month',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
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
                  context: context,
                  icon: Icons.calendar_today_rounded,
                  iconBg: colorScheme.primary.withValues(alpha: 0.15),
                  iconColor: colorScheme.primary,
                  label: 'Days Trained',
                  value: '1',
                  unit: 'day streak',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  context: context,
                  icon: Icons.fitness_center_rounded,
                  iconBg: const Color(0xFFDBEAFE),
                  iconColor: const Color(0xFF2563EB),
                  label: 'Workouts',
                  value: '1',
                  unit: 'Session',
                  unitColor: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context: context,
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
                  context: context,
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
    required BuildContext context,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tileBg = colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    final border = colorScheme.outlineVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
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
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
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
                        color: badgeBg ?? colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          color: badgeColor ?? colorScheme.primary,
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
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: colorScheme.onSurface,
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
                      color: unitColor ?? colorScheme.onSurfaceVariant,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = theme.cardTheme.color ?? colorScheme.surface;
    final border = colorScheme.outlineVariant;
    final dividerColor = colorScheme.outlineVariant;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: isDark ? 0.2 : 0.04),
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
              Text(
                'Personal Info',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'Tap to edit',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 1. Name
          _buildInfoRow(
            context: context,
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
          Divider(height: 1, color: dividerColor),

          // 2. Age
          _buildInfoRow(
            context: context,
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
          Divider(height: 1, color: dividerColor),

          // 3. Weight
          _buildInfoRow(
            context: context,
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
          Divider(height: 1, color: dividerColor),

          // 4. Height
          _buildInfoRow(
            context: context,
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
          Divider(height: 1, color: dividerColor),

          // 5. Experience Level
          _buildInfoRow(
            context: context,
            label: 'Experience Level',
            customValueWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                profile.experienceLevel,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
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
          Divider(height: 1, color: dividerColor),

          // 6. Primary Goal
          _buildInfoRow(
            context: context,
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
          Divider(height: 1, color: dividerColor),

          // 7. Weekly Target
          _buildInfoRow(
            context: context,
            label: 'Weekly Target',
            customValueWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${profile.weeklyTargetDays} Days',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
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
    required BuildContext context,
    required String label,
    String? value,
    Widget? customValueWidget,
    bool isEditable = false,
    bool hasChevron = false,
    VoidCallback? onTap,
    int maxLines = 2,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
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
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                          height: 1.25,
                        ),
                      ),
                    ),
                  if (isEditable) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                  if (hasChevron) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = theme.cardTheme.color ?? colorScheme.surface;
    final border = colorScheme.outlineVariant;
    final tileBg = colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences & Security',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          // 1. Workout Preferences
          _buildActionRow(
            context: context,
            icon: Icons.tune_rounded,
            iconBg: tileBg,
            iconColor: colorScheme.onSurfaceVariant,
            title: 'Workout Preferences',
            onTap: () => context.push('/settings/workout-preferences'),
          ),
          const SizedBox(height: 6),

          // 2. Health Sync (Connected)
          _buildActionRow(
            context: context,
            icon: Icons.favorite_rounded,
            iconBg: const Color(0xFFFFE4E6),
            iconColor: const Color(0xFFF43F5E),
            title: 'Health Sync',
            subtitle: 'Connected',
            subtitleColor: colorScheme.primary,
            onTap: () => context.push('/settings/data'),
          ),
          const SizedBox(height: 6),

          // 3. Account Security
          _buildActionRow(
            context: context,
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
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? subtitleColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
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
                        color: subtitleColor ?? colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  // ── Ghost Sign Out Button ───────────────────────────────────────────────
  Widget _buildSignOutButton(BuildContext context) {
    final errorRed = Theme.of(context).colorScheme.error;
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
              color: errorRed.withValues(alpha: 0.9),
            ),
            const SizedBox(width: 8),
            Text(
              'Sign Out of FitTrack',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: errorRed.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
