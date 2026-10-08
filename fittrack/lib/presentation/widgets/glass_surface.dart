import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../theme/ft_glass.dart';

/// Translucent, high-performance frosted glass surface matching the Stitch design system.
/// Uses calibrated fills, real-time backdrop blur, 1px borders, subtle drop shadows,
/// and an inset 1.5px top specular highlight line.
class GlassSurface extends ConsumerWidget {
  final FtGlassTier tier;
  final double? radius;
  final EdgeInsetsGeometry? padding;
  final Widget? child;
  final Color? borderTint;
  final bool shadow;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final VoidCallback? onTap;
  final bool enableBlur;
  final double? customBlurSigma;

  const GlassSurface({
    super.key,
    this.tier = FtGlassTier.glass1,
    this.radius,
    this.padding,
    this.child,
    this.borderTint,
    this.shadow = true,
    this.width,
    this.height,
    this.alignment,
    this.onTap,
    this.enableBlur = true,
    this.customBlurSigma,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool enableTransparency = true;
    double blurScale = 1.0;
    try {
      final themeSettings = ref.watch(themeNotifierProvider);
      enableTransparency = themeSettings.enableGlassTransparency;
      blurScale = (themeSettings.blurIntensity / 16.0).clamp(0.2, 2.5);
    } catch (_) {
      // Smooth fallback in isolated unit/widget tests without ProviderScope
    }

    final spec = FtGlassTheme.specFor(tier, context, enableTransparency);
    final effectiveRadius = radius ?? FtGlassTheme.radiusCards;
    final borderRadius = BorderRadius.circular(effectiveRadius);

    Widget content = child ?? const SizedBox.shrink();

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    final double effectiveBlur = (enableTransparency && enableBlur)
        ? ((customBlurSigma ?? spec.blurSigma) * blurScale)
        : 0.0;

    // Inner surface container with border, fill, and top specular highlight
    Widget innerBox = CustomPaint(
      foregroundPainter: _TopHighlightPainter(
        highlightColor: spec.highlight,
        radius: effectiveRadius,
      ),
      child: Container(
        width: width,
        height: height,
        alignment: alignment,
        decoration: BoxDecoration(
          color: spec.fill,
          borderRadius: borderRadius,
          border: Border.all(
            color: borderTint ?? spec.border,
            width: 1.0,
          ),
        ),
        child: content,
      ),
    );

    // Apply BackdropFilter blur inside ClipRRect when enabled
    Widget surface;
    if (effectiveBlur > 0) {
      surface = ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: effectiveBlur, sigmaY: effectiveBlur),
          child: innerBox,
        ),
      );
    } else {
      surface = ClipRRect(
        borderRadius: borderRadius,
        child: innerBox,
      );
    }

    // Outer drop shadow (not clipped by ClipRRect)
    if (shadow && spec.shadows.isNotEmpty) {
      surface = Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: spec.shadows,
        ),
        child: surface,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: surface,
      );
    }

    return surface;
  }
}

/// Draws an inset 1.5px white gradient highlight at the top edge inside the card.
class _TopHighlightPainter extends CustomPainter {
  final Color highlightColor;
  final double radius;

  const _TopHighlightPainter({
    required this.highlightColor,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          highlightColor.withValues(alpha: 0.15),
          highlightColor,
          highlightColor.withValues(alpha: 0.15),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 1.5))
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw horizontal line at the very top edge inside the clip
    canvas.drawLine(
      Offset(radius * 0.5, 0.75),
      Offset(size.width - (radius * 0.5), 0.75),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _TopHighlightPainter oldDelegate) {
    return oldDelegate.highlightColor != highlightColor || oldDelegate.radius != radius;
  }
}
