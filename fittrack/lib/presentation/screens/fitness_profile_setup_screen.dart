import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../widgets/ft_primary_button.dart';
import '../widgets/ft_selection_card.dart';
import '../widgets/ft_step_indicator.dart';
import '../providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';
import '../../domain/entities/fitness_profile.dart';

/// FitTrack Onboarding – Fitness Goals & Training Profile Screen (Step 4 of 4).
///
/// Collects [PrimaryFocus], [LiftingExperience], weekly frequency, and
/// [AvailableEquipment]. Saves via [UserProfileNotifier.saveFitnessProfile].
/// GoRouter's redirect will navigate to /dashboard on completion.
class FitnessProfileSetupScreen extends ConsumerStatefulWidget {
  const FitnessProfileSetupScreen({super.key});

  @override
  ConsumerState<FitnessProfileSetupScreen> createState() =>
      _FitnessProfileSetupScreenState();
}

class _FitnessProfileSetupScreenState
    extends ConsumerState<FitnessProfileSetupScreen> {
  PrimaryFocus _focus = PrimaryFocus.hypertrophy;
  LiftingExperience _experience = LiftingExperience.beginner;
  int _weeklyFrequency = 3;
  AvailableEquipment _equipment = AvailableEquipment.fullGym;
  bool _isSaving = false;

  Future<void> _complete() async {
    setState(() => _isSaving = true);
    final userAsync = ref.read(authProvider);
    final userId = userAsync.value?.id ?? 'local';

    final profile = FitnessProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      primaryFocus: _focus,
      liftingExperience: _experience,
      weeklyFrequency: _weeklyFrequency,
      availableEquipment: _equipment,
      updatedAt: DateTime.now(),
    );

    await ref
        .read(userProfileProvider.notifier)
        .saveFitnessProfile(profile);

    setState(() => _isSaving = false);
    // GoRouter redirect handles navigation to /dashboard once isComplete == true
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileProvider);
    final isLoading = profileState.isLoading || _isSaving;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Nav bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: AppColors.slate700),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.slate200.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      'STEP 4 OF 4',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: AppColors.slate700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title ────────────────────────────────────────
                    const Text(
                      'Define your training\nprofile',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppColors.slateDark,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'We build your first program around these — you can edit anytime.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.slate500,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ── Primary Focus ────────────────────────────────
                    _SectionLabel(
                      icon: Icons.flag_rounded,
                      title: 'Primary Training Focus',
                      subtitle: 'Powers your program structure & rep ranges',
                    ),
                    const SizedBox(height: 10),
                    FtSelectionCard(
                      label: 'Hypertrophy',
                      subtitle: 'Maximize muscle growth & aesthetic gains',
                      leadingIcon: const Icon(Icons.fitness_center_rounded),
                      trailingChips: const ['6–12 reps', 'Moderate load', '3–4 days'],
                      isSelected: _focus == PrimaryFocus.hypertrophy,
                      onTap: () =>
                          setState(() => _focus = PrimaryFocus.hypertrophy),
                    ),
                    const SizedBox(height: 8),
                    FtSelectionCard(
                      label: 'Strength',
                      subtitle: 'Build peak strength & progressive power',
                      leadingIcon: const Icon(Icons.bar_chart_rounded),
                      trailingChips: const ['1–5 reps', 'Heavy load', '3–5 days'],
                      isSelected: _focus == PrimaryFocus.strength,
                      onTap: () =>
                          setState(() => _focus = PrimaryFocus.strength),
                    ),
                    const SizedBox(height: 8),
                    FtSelectionCard(
                      label: 'Fat Loss',
                      subtitle: 'Optimize fat burn & body recomposition',
                      leadingIcon: const Icon(Icons.local_fire_department_rounded),
                      trailingChips: const ['HIIT', 'Circuit', 'Deficit'],
                      isSelected: _focus == PrimaryFocus.fatLoss,
                      onTap: () =>
                          setState(() => _focus = PrimaryFocus.fatLoss),
                    ),
                    const SizedBox(height: 18),

                    // ── Experience ───────────────────────────────────
                    _SectionLabel(
                      icon: Icons.star_rounded,
                      title: 'Lifting Experience',
                      subtitle: 'Determines starting loads & volume',
                    ),
                    const SizedBox(height: 10),
                    FtSelectionCard(
                      label: 'Beginner',
                      subtitle: '0–1 year | Form, foundation, and habits',
                      leadingIcon: const Icon(Icons.hiking_rounded),
                      isSelected: _experience == LiftingExperience.beginner,
                      onTap: () => setState(
                          () => _experience = LiftingExperience.beginner),
                    ),
                    const SizedBox(height: 8),
                    FtSelectionCard(
                      label: 'Intermediate',
                      subtitle: '1–3 years | Solid technique, increasing load',
                      leadingIcon: const Icon(Icons.directions_run_rounded),
                      isSelected: _experience == LiftingExperience.intermediate,
                      onTap: () => setState(
                          () => _experience = LiftingExperience.intermediate),
                    ),
                    const SizedBox(height: 8),
                    FtSelectionCard(
                      label: 'Advanced',
                      subtitle: '3+ years | Periodized, high-frequency splits',
                      leadingIcon: const Icon(Icons.rocket_launch_rounded),
                      isSelected: _experience == LiftingExperience.advanced,
                      onTap: () => setState(
                          () => _experience = LiftingExperience.advanced),
                    ),
                    const SizedBox(height: 18),

                    // ── Weekly Frequency ─────────────────────────────
                    _SectionLabel(
                      icon: Icons.calendar_today_rounded,
                      title: 'Weekly Training Days',
                      subtitle: '$_weeklyFrequency days selected',
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.slate200),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.slateDark.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(7, (i) {
                              final day = i + 1;
                              final isSelected = day <= _weeklyFrequency;
                              return GestureDetector(
                                onTap: () => setState(
                                    () => _weeklyFrequency = day),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.kineticMint
                                        : AppColors.slate100,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.kineticMint
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected
                                            ? AppColors.slateDark
                                            : AppColors.slate400,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$_weeklyFrequency training days · '
                                '${7 - _weeklyFrequency} rest days',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.slate400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _weeklyFrequency >= 5
                                    ? 'High Volume ↑'
                                    : _weeklyFrequency >= 3
                                        ? 'Balanced ✓'
                                        : 'Low Volume ↓',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _weeklyFrequency >= 5
                                      ? AppColors.errorRed
                                      : _weeklyFrequency >= 3
                                          ? AppColors.kineticMint
                                          : AppColors.slate400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ── Equipment ────────────────────────────────────
                    _SectionLabel(
                      icon: Icons.sports_gymnastics_rounded,
                      title: 'Available Equipment',
                      subtitle: 'Exercise alternatives auto-generated',
                    ),
                    const SizedBox(height: 10),
                    FtSelectionCard(
                      label: 'Full Gym',
                      subtitle: 'All machines, free weights & cables',
                      leadingIcon: const Icon(Icons.home_work_rounded),
                      trailingChips: const ['Barbells', 'Cables', 'Machines'],
                      isSelected: _equipment == AvailableEquipment.fullGym,
                      onTap: () => setState(
                          () => _equipment = AvailableEquipment.fullGym),
                    ),
                    const SizedBox(height: 8),
                    FtSelectionCard(
                      label: 'Barbell & Dumbbells',
                      subtitle: 'Home setup with free weights',
                      leadingIcon: const Icon(Icons.fitness_center_rounded),
                      trailingChips: const ['Barbells', 'Dumbbells', 'Bench'],
                      isSelected:
                          _equipment == AvailableEquipment.barbellDumbbells,
                      onTap: () => setState(
                          () => _equipment = AvailableEquipment.barbellDumbbells),
                    ),
                    const SizedBox(height: 8),
                    FtSelectionCard(
                      label: 'Home / Bodyweight',
                      subtitle: 'No equipment, anywhere in the world',
                      leadingIcon: const Icon(Icons.self_improvement_rounded),
                      trailingChips: const ['Bands', 'Bodyweight', 'Cardio'],
                      isSelected:
                          _equipment == AvailableEquipment.homeBodyweight,
                      onTap: () => setState(
                          () => _equipment = AvailableEquipment.homeBodyweight),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Sticky footer ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.96),
                border: Border(
                    top: BorderSide(color: AppColors.slate200, width: 1)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const FtStepIndicator(totalSteps: 4, currentStep: 3),
                      const Text(
                        '100% completed',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.kineticMint,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FtPrimaryButton(
                          label: 'Complete Setup',
                          isLoading: isLoading,
                          trailingIcon: isLoading
                              ? null
                              : const Icon(Icons.check_rounded,
                                  color: AppColors.slateDark, size: 18),
                          onPressed: isLoading ? null : _complete,
                        ),
                      ),
                    ],
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.kineticMintLight,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: AppColors.kineticMintDark, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slateDark,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.slate500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
