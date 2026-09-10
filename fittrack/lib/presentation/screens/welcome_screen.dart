import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../widgets/ft_primary_button.dart';
import '../widgets/ft_step_indicator.dart';

import '../widgets/ft_exit_confirmation.dart';

/// FitTrack Onboarding – Welcome Screen.
///
/// Shows feature value propositions and navigates to the auth flow.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FtExitConfirmation(
      child: Scaffold(
        backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.kineticMint.withValues(alpha: 0.20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Main content ──────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      children: [
                        // Hero icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(34),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF9AFCD6), AppColors.kineticMint],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.kineticMint
                                    .withValues(alpha: 0.38),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.directions_run_rounded,
                              color: Color(0xFF022C22),
                              size: 56,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(color: AppColors.slate200),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.slateDark.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.kineticMint,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'FITTRACK CORE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.8,
                                  color: AppColors.slate700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Headline
                        const Text(
                          'Welcome to FitTrack',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: AppColors.slateDark,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Track your workouts, follow customized schedules, '
                            'and reach your fitness goals with precision telemetry.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.slate500,
                              height: 1.55,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Feature cards
                        _FeatureCard(
                          iconBg: AppColors.kineticMintLight,
                          iconColor: const Color(0xFF059669),
                          icon: Icons.track_changes_rounded,
                          title: 'Smart Workout Guidance',
                          subtitle: 'Auto-regulated progressive overload tracking',
                        ),
                        const SizedBox(height: 10),
                        _FeatureCard(
                          iconBg: const Color(0xFFEEF2FF),
                          iconColor: const Color(0xFF4F46E5),
                          icon: Icons.timer_rounded,
                          title: 'Precision Rest Intervals',
                          subtitle: 'Haptic audio cues & set-by-set telemetry',
                        ),
                        const SizedBox(height: 10),
                        _FeatureCard(
                          iconBg: const Color(0xFFFEF3C7),
                          iconColor: const Color(0xFFD97706),
                          icon: Icons.bar_chart_rounded,
                          title: 'Volume & PR Analytics',
                          subtitle: 'Real-time strength milestones & graphs',
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Bottom CTA ────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const FtStepIndicator(totalSteps: 4, currentStep: 0),
                          TextButton(
                            onPressed: () => context.go('/auth'),
                            child: const Text(
                              'SKIP SETUP',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.4,
                                color: AppColors.slate400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FtPrimaryButton(
                        label: 'Get Started',
                        trailingIcon: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.slateDark,
                          size: 18,
                        ),
                        onPressed: () => context.go('/auth'),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account?',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.slate500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => context.go('/auth'),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.slateDark,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.slateDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100),
        boxShadow: [
          BoxShadow(
            color: AppColors.slateDark.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate800,
                  ),
                ),
                const SizedBox(height: 2),
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
      ),
    );
  }
}
