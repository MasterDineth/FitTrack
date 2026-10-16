import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/dashboard_providers.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';

/// Reusable hydration banner with 220ms height + fade dismiss animation and haptic feedback.
class HydrationBanner extends ConsumerStatefulWidget {
  final bool initialVisible;
  final VoidCallback? onLogTap;

  const HydrationBanner({
    super.key,
    this.initialVisible = false,
    this.onLogTap,
  });

  @override
  ConsumerState<HydrationBanner> createState() => _HydrationBannerState();
}

class _HydrationBannerState extends ConsumerState<HydrationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _isDismissed = !widget.initialVisible;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: widget.initialVisible ? 1.0 : 0.0,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void dismiss() {
    HapticFeedback.lightImpact();
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() => _isDismissed = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();

    final loggedLiters = ref.watch(
      dashboardNotificationsProvider.select((s) => s.loggedWaterLiters),
    );

    return SizeTransition(
      sizeFactor: _animation,
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: _animation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: GlassSurface(
            tier: FtGlassTier.glass1,
            radius: 16.0,
            borderTint: FtGlassTheme.primary.withValues(alpha: 0.20),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.water_drop_rounded,
                  size: 16,
                  color: Color(0xFF0EA5E9),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 12,
                        color: context.ftInk,
                      ),
                      children: [
                        TextSpan(
                          text:
                              'Hydration check: ${loggedLiters.toStringAsFixed(1)}L / 2.5L logged · ',
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              if (widget.onLogTap != null) {
                                widget.onLogTap!();
                              } else {
                                ref
                                    .read(dashboardNotificationsProvider.notifier)
                                    .pushPreset(FtNotificationType.hydration);
                              }
                            },
                            child: const Text(
                              'Tap to log glass',
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: FtGlassTheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: dismiss,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: context.ftMuted,
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
}
