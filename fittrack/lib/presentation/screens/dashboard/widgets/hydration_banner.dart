import 'package:flutter/material.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';

/// Reusable hydration banner with 220ms height + fade dismiss animation.
class HydrationBanner extends StatefulWidget {
  final bool initialVisible;
  final VoidCallback? onLogTap;

  const HydrationBanner({
    super.key,
    this.initialVisible = false,
    this.onLogTap,
  });

  @override
  State<HydrationBanner> createState() => _HydrationBannerState();
}

class _HydrationBannerState extends State<HydrationBanner> with SingleTickerProviderStateMixin {
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
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() => _isDismissed = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();

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
                const Text('💧', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 12,
                        color: FtGlassTheme.ink,
                      ),
                      children: [
                        const TextSpan(text: 'Hydration check: 1.8L / 2.5L logged · '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: GestureDetector(
                            onTap: widget.onLogTap,
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
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: FtGlassTheme.muted,
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
