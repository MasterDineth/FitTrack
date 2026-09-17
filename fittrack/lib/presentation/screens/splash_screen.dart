import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../widgets/ft_logo_emblem.dart';
import '../providers/auth_provider.dart';

/// FitTrack Splash & Loading Screen.
///
/// Displays the kinetic brand identity with an animated progress bar.
/// GoRouter's redirect logic will automatically navigate away once
/// [authProvider] resolves.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _progressController;
  late final Animation<double> _progressAnim;
  late final Animation<double> _logoScaleAnim;
  late final Animation<double> _logoOpacityAnim;

  // Shimmer animation for the progress bar
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _progressAnim = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );
    _logoScaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _logoOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  String _loadingMessage(double progress) {
    if (progress < 0.3) return 'Initializing vault…';
    if (progress < 0.6) return 'Loading telemetry engine…';
    if (progress < 0.85) return 'Syncing workout data…';
    return 'Ready to go!';
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state — GoRouter will redirect once it resolves.
    ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Ambient glow orbs
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.kineticMint.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF064E3B).withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Hero brand section ──────────────────────────────────────
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoOpacityAnim.value,
                          child: Transform.scale(
                            scale: _logoScaleAnim.value,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Glow backdrop
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.kineticMint.withValues(alpha: 0.22),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Center(
                              child: FtLogoEmblem(size: 96),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Title
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.8,
                                    color: AppColors.slateDark,
                                  ),
                                  children: [
                                    TextSpan(text: 'Fit'),
                                    TextSpan(
                                      text: 'Track',
                                      style: TextStyle(
                                          color: AppColors.kineticMint),
                                    ),
                                  ],
                                ),
                              ),
                              // Ping dot
                              Padding(
                                padding: const EdgeInsets.only(top: 6, left: 3),
                                child: _PingDot(),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),
                          const Text(
                            'SMART HYPERTROPHY & TELEMETRY',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.5,
                              color: AppColors.slate400,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Your high-performance personal fitness companion',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.slate500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Progress section ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                  child: AnimatedBuilder(
                    animation: _progressAnim,
                    builder: (context, _) {
                      final p = _progressAnim.value;
                      final pct = (p * 100).round();
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  _PulsingDot(),
                                  const SizedBox(width: 8),
                                  Text(
                                    _loadingMessage(p),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.slate600,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '$pct%',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'monospace',
                                  color: AppColors.slateDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: Container(
                              height: 7,
                              color: AppColors.slate200,
                              child: Stack(
                                children: [
                                  FractionallySizedBox(
                                    widthFactor: p,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF0D5C4A),
                                            Color(0xFF059669),
                                            AppColors.kineticMint,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.kineticMint
                                                .withValues(alpha: 0.5),
                                            blurRadius: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Shimmer
                                  AnimatedBuilder(
                                    animation: _shimmerController,
                                    builder: (context, _) {
                                      return FractionallySizedBox(
                                        widthFactor: p,
                                        child: OverflowBox(
                                          alignment: Alignment.centerLeft,
                                          maxWidth: double.infinity,
                                          child: Transform.translate(
                                            offset: Offset(
                                              (_shimmerController.value * 2 - 1) *
                                                  200,
                                              0,
                                            ),
                                            child: Container(
                                              width: 80,
                                              height: 7,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.white
                                                        .withValues(alpha: 0.5),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.verified_user,
                                size: 12,
                                color: AppColors.kineticMintDark,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'End-to-End Vault',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.slate400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.slate400,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'v2.4.0 Pro',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.slate400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
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

class _PingDot extends StatefulWidget {
  @override
  State<_PingDot> createState() => _PingDotState();
}

class _PingDotState extends State<_PingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: false);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10,
      height: 10,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _c,
            builder: (_, _) => Transform.scale(
              scale: 1 + _c.value,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      AppColors.kineticMint.withValues(alpha: 1 - _c.value),
                ),
              ),
            ),
          ),
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.kineticMintDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.lerp(
            AppColors.kineticMint,
            AppColors.kineticMintDark,
            _c.value,
          ),
        ),
      ),
    );
  }
}
