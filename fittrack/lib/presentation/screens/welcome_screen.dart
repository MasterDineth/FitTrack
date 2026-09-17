import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FtExitConfirmation(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
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
                        colorScheme.primary.withValues(alpha: 0.20),
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
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primaryContainer,
                                  colorScheme.primary,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(alpha: 0.38),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.directions_run_rounded,
                                color: colorScheme.onPrimary,
                                size: 56,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(color: colorScheme.outlineVariant),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.shadow.withValues(alpha: 0.04),
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
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'FITTRACK CORE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.8,
                                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Headline
                          Text(
                            'Welcome to FitTrack',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                              color: colorScheme.onSurface,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Track your workouts, follow customized schedules, '
                              'and reach your fitness goals with precision telemetry.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                                height: 1.55,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Feature cards
                          _FeatureCard(
                            iconBg: colorScheme.primaryContainer,
                            iconColor: colorScheme.onPrimaryContainer,
                            icon: Icons.track_changes_rounded,
                            title: 'Smart Workout Guidance',
                            subtitle: 'Auto-regulated progressive overload tracking',
                          ),
                          const SizedBox(height: 10),
                          _FeatureCard(
                            iconBg: Colors.indigo.withValues(alpha: 0.15),
                            iconColor: Colors.indigo,
                            icon: Icons.timer_rounded,
                            title: 'Precision Rest Intervals',
                            subtitle: 'Haptic audio cues & set-by-set telemetry',
                          ),
                          const SizedBox(height: 10),
                          _FeatureCard(
                            iconBg: Colors.amber.withValues(alpha: 0.15),
                            iconColor: Colors.amber.shade800,
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
                              child: Text(
                                'SKIP SETUP',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.4,
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FtPrimaryButton(
                          label: 'Get Started',
                          trailingIcon: Icon(
                            Icons.arrow_forward_rounded,
                            color: colorScheme.onPrimary,
                            size: 18,
                          ),
                          onPressed: () => context.go('/auth'),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => context.go('/auth'),
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                  decorationColor: colorScheme.primary,
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
      ),
    );
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
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
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
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
