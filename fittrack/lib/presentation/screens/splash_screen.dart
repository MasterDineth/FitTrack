import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                    colorScheme.primary.withValues(alpha: 0.15),
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
                    colorScheme.primary.withValues(alpha: 0.08),
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
                                  colorScheme.primary.withValues(alpha: 0.22),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: const Center(
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
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.8,
                                    color: colorScheme.onSurface,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Fit'),
                                    TextSpan(
                                      text: 'Track',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Ping dot
                              Padding(
                                padding: const EdgeInsets.only(top: 6, left: 3),
                                child: _PingDot(color: colorScheme.primary),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),
                          Text(
                            'SMART HYPERTROPHY & TELEMETRY',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.5,
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Your high-performance personal fitness companion',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
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
                                  _PulsingDot(color: colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    _loadingMessage(p),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '$pct%',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'monospace',
                                  color: colorScheme.onSurface,
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
                              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                              child: Stack(
                                children: [
                                  FractionallySizedBox(
                                    widthFactor: p,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            colorScheme.primary.withValues(alpha: 0.7),
                                            colorScheme.primary,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: colorScheme.primary
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
                                                    colorScheme.onPrimary
                                                        .withValues(alpha: 0.4),
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
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'End-to-End Vault',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'v2.4.0 Pro',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurface.withValues(alpha: 0.5),
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
  const _PingDot({required this.color});
  final Color color;

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
                  color: widget.color.withValues(alpha: 1 - _c.value),
                ),
              ),
            ),
          ),
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});
  final Color color;

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
          color: widget.color.withValues(alpha: 0.6 + 0.4 * _c.value),
        ),
      ),
    );
  }
}
