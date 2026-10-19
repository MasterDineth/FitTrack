import 'package:flutter/material.dart';
import 'package:fittrack/domain/entities/user_profile.dart';
import 'package:fittrack/presentation/screens/dashboard/widgets/ft_pressable.dart';
import 'package:fittrack/presentation/theme/ft_glass.dart';
import 'package:fittrack/presentation/widgets/modals/selection_modal.dart';
import 'package:fittrack/presentation/widgets/modals/text_input_modal.dart';

/// Personal Information Section for Profile Screen.
///
/// NOTE: Per specification, Name and Date of Birth are omitted here
/// (moved to Account Details screen).
/// Displays:
/// 1. Weight (kg)
/// 2. Height (cm)
/// 3. Experience Level (Tier Pill)
/// 4. Primary Goal
/// 5. Weekly Target
class ProfilePersonalInfoSection extends StatelessWidget {
  final UserProfile profile;
  final ValueChanged<UserProfile> onProfileChanged;

  const ProfilePersonalInfoSection({
    super.key,
    required this.profile,
    required this.onProfileChanged,
  });

  Future<void> _editWeight(BuildContext context) async {
    final currentWeight =
        profile.weightKg > 0 ? profile.weightKg.toStringAsFixed(1) : '76.5';
    final result = await TextInputModal.show(
      context: context,
      title: 'Edit Weight',
      subtitle: 'Enter your bodyweight in kilograms',
      initialValue: currentWeight,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      suffixText: 'kg',
      hintText: 'e.g. 76.5',
    );

    if (result != null) {
      final parsed = double.tryParse(result.trim());
      if (parsed != null && parsed > 0) {
        onProfileChanged(profile.copyWith(weightKg: parsed));
      }
    }
  }

  Future<void> _editHeight(BuildContext context) async {
    final currentHeight =
        profile.heightCm > 0 ? profile.heightCm.toStringAsFixed(1) : '178.0';
    final result = await TextInputModal.show(
      context: context,
      title: 'Edit Height',
      subtitle: 'Enter your height in centimeters',
      initialValue: currentHeight,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      suffixText: 'cm',
      hintText: 'e.g. 178',
    );

    if (result != null) {
      final parsed = double.tryParse(result.trim());
      if (parsed != null && parsed > 0) {
        onProfileChanged(profile.copyWith(heightCm: parsed));
      }
    }
  }

  Future<void> _editExperience(BuildContext context) async {
    const options = [
      'Beginner',
      'Intermediate',
      'Advanced',
      'Elite',
    ];
    final current = options.firstWhere(
      (o) => o.toLowerCase() == profile.experienceLevel.toLowerCase(),
      orElse: () => 'Advanced',
    );

    final result = await SelectionModal.show(
      context: context,
      title: 'Select Experience Level',
      subtitle: 'Choose your lifting experience tier',
      options: options,
      selectedOption: current,
    );

    if (result != null) {
      onProfileChanged(profile.copyWith(experienceLevel: result));
    }
  }

  Future<void> _editGoal(BuildContext context) async {
    const options = [
      'Pure strength (powerlifting)',
      'Hypertrophy & strength',
      'Fat loss & conditioning',
      'Cardiovascular & endurance',
      'Mobility & general fitness',
    ];

    final current = options.firstWhere(
      (o) => o.toLowerCase() == profile.primaryGoal.toLowerCase(),
      orElse: () => 'Pure strength (powerlifting)',
    );

    final result = await SelectionModal.show(
      context: context,
      title: 'Select Primary Goal',
      subtitle: 'Choose your main training objective',
      options: options,
      selectedOption: current,
    );

    if (result != null) {
      onProfileChanged(profile.copyWith(primaryGoal: result));
    }
  }

  Future<void> _editWeeklyTarget(BuildContext context) async {
    const options = [
      '2 days / week',
      '3 days / week',
      '4 days / week',
      '5 days / week',
      '6 days / week',
      '7 days / week',
    ];

    final currentDays =
        profile.weeklyTargetDays > 0 ? profile.weeklyTargetDays : 3;
    final currentOption = '$currentDays days / week';

    final result = await SelectionModal.show(
      context: context,
      title: 'Select Weekly Target',
      subtitle: 'Target workout days scheduled per week',
      options: options,
      selectedOption: currentOption,
    );

    if (result != null) {
      final days = int.tryParse(result.split(' ').first);
      if (days != null) {
        onProfileChanged(profile.copyWith(weeklyTargetDays: days));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final ink = context.ftInk;
    final muted = context.ftMuted;
    final primary = context.ftPrimary;
    final settings = FtGlassTheme.resolveThemeSettings(context);

    final weightStr = profile.weightKg > 0
        ? '${profile.weightKg.toStringAsFixed(1)} kg'
        : '76.5 kg';
    final heightStr = profile.heightCm > 0
        ? '${profile.heightCm.toStringAsFixed(1)} cm'
        : '178 cm';
    final expStr = profile.experienceLevel.isNotEmpty
        ? profile.experienceLevel
        : 'Advanced';
    final goalStr = profile.primaryGoal.isNotEmpty
        ? profile.primaryGoal
        : 'Pure strength (powerlifting)';
    final targetStr = profile.weeklyTargetDays > 0
        ? '${profile.weeklyTargetDays} days / week'
        : '3 days / week';

    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE2E8F0).withValues(alpha: 0.60);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Header ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PERSONAL INFO',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: muted,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.edit_rounded,
                    size: 13,
                    color: primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tap to edit',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ── Frosted Card with 5 Rows ───────────────────────────────────
        Container(
          decoration: FtGlassTheme.cardDecoration(
            context,
            radius: 24,
            settings: settings,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // 1. Weight
              _buildRow(
                context: context,
                label: 'Weight',
                value: weightStr,
                onTap: () => _editWeight(context),
                ink: ink,
                muted: muted,
              ),
              Divider(height: 1, thickness: 1, color: dividerColor),

              // 2. Height
              _buildRow(
                context: context,
                label: 'Height',
                value: heightStr,
                onTap: () => _editHeight(context),
                ink: ink,
                muted: muted,
              ),
              Divider(height: 1, thickness: 1, color: dividerColor),

              // 3. Experience
              _buildRow(
                context: context,
                label: 'Experience',
                customValue: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: isDark ? 0.22 : 0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    expStr,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                  ),
                ),
                onTap: () => _editExperience(context),
                ink: ink,
                muted: muted,
              ),
              Divider(height: 1, thickness: 1, color: dividerColor),

              // 4. Primary Goal
              _buildRow(
                context: context,
                label: 'Primary Goal',
                value: goalStr,
                onTap: () => _editGoal(context),
                ink: ink,
                muted: muted,
              ),
              Divider(height: 1, thickness: 1, color: dividerColor),

              // 5. Weekly Target
              _buildRow(
                context: context,
                label: 'Weekly Target',
                value: targetStr,
                onTap: () => _editWeeklyTarget(context),
                ink: ink,
                muted: muted,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow({
    required BuildContext context,
    required String label,
    String? value,
    Widget? customValue,
    required VoidCallback onTap,
    required Color ink,
    required Color muted,
  }) {
    return FtPressable(
      onTap: onTap,
      pressedScale: 0.98,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: muted,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (customValue != null)
                    customValue
                  else if (value != null)
                    Flexible(
                      child: Text(
                        value,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: ink,
                          height: 1.25,
                        ),
                      ),
                    ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: muted.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
