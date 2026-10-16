import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../theme/ft_glass.dart';
import 'glass/glass_backdrop.dart';

export 'glass/glass_backdrop.dart';

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
  final GlassBackdrop backdrop;
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
    this.backdrop = GlassBackdrop.auto,
    this.customBlurSigma,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool enableTransparency = true;
    double blurIntensity = 16.0;
    try {
      final (transparency, intensity) = ref.watch(
        themeNotifierProvider.select(
          (s) => (s.enableGlassTransparency, s.blurIntensity),
        ),
      );
      enableTransparency = transparency;
      blurIntensity = intensity;
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

    // Resolve whether this surface creates a real live BackdropFilter.
    // enableBlur: false forces flat for backward compatibility; enableBlur: true defers to backdrop.
    final bool isLive;
    if (!enableTransparency || !enableBlur) {
      isLive = false;
    } else {
      switch (backdrop) {
        case GlassBackdrop.flat:
          isLive = false;
        case GlassBackdrop.live:
          isLive = true;
        case GlassBackdrop.auto:
          isLive = tier == FtGlassTier.glassFloating;
      }
    }

    // Normalized intensity factor t: 0.0 (4px Subtle) -> 0.42857 (16px Default) -> 1.0 (32px Intense)
    final double t = ((blurIntensity - 4.0) / (32.0 - 4.0)).clamp(0.0, 1.0);

    // Dynamic blur sigma scaling:
    // At Subtle (4px): crisp 3.0px sigma (objects behind remain sharp)
    // At Default (16px): natural spec.blurSigma
    // At Intense (32px): heavy milky diffusion up to 36-48px sigma
    final double baseSigma = customBlurSigma ?? spec.blurSigma;
    final double effectiveBlur;
    if (!enableTransparency || !isLive) {
      effectiveBlur = 0.0;
    } else if (t <= 0.42857) {
      final double progress = t / 0.42857;
      const double minSigma = 3.0;
      effectiveBlur = minSigma + (baseSigma - minSigma) * progress;
    } else {
      final double progress = (t - 0.42857) / (1.0 - 0.42857);
      final double maxSigma = (baseSigma * 2.25).clamp(32.0, 48.0);
      effectiveBlur = baseSigma + (maxSigma - baseSigma) * progress;
    }

    // Dynamic fill opacity scaling:
    // At Subtle (4px): ultra-translucent (drops to ~20%-30%), revealing background mesh and graphics
    // At Default (16px): exact Stitch spec.fill alpha (~50%-60%)
    // At Intense (32px): dense, milky frosted acrylic (~76%-88%), diffusing background into a cloud
    final double baseAlpha = spec.fill.a;
    final double effectiveAlpha;
    if (!enableTransparency) {
      effectiveAlpha = baseAlpha;
    } else if (t <= 0.42857) {
      final double progress = t / 0.42857;
      final double minAlpha = (baseAlpha * 0.45).clamp(0.18, 0.32);
      effectiveAlpha = minAlpha + (baseAlpha - minAlpha) * progress;
    } else {
      final double progress = (t - 0.42857) / (1.0 - 0.42857);
      final double maxAlpha = (baseAlpha * 1.35).clamp(0.76, 0.88);
      effectiveAlpha = baseAlpha + (maxAlpha - baseAlpha) * progress;
    }
    final Color effectiveFill = spec.fill.withValues(alpha: effectiveAlpha);

    // Specular highlight line sheen: Subtle is delicate, Intense is brilliant
    final Color effectiveHighlight = !enableTransparency
        ? spec.highlight
        : spec.highlight.withValues(
            alpha: (spec.highlight.a * (0.65 + 0.65 * t)).clamp(0.0, 1.0),
          );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color sheenColor = isDark
        ? const Color(0xFF5F3BDC).withValues(alpha: 0.08 * (0.65 + 0.65 * t))
        : Colors.white.withValues(alpha: 0.22 * (0.65 + 0.65 * t));

    // Inner surface container with border, fill, directional specular sheen, and top specular highlight
    Widget innerBox = CustomPaint(
      painter: _SpecularSheenPainter(
        sheenColor: sheenColor,
        radius: effectiveRadius,
      ),
      foregroundPainter: _TopHighlightPainter(
        highlightColor: effectiveHighlight,
        radius: effectiveRadius,
      ),
      child: Container(
        width: width,
        height: height,
        alignment: alignment,
        decoration: BoxDecoration(
          color: effectiveFill,
          borderRadius: borderRadius,
          border: Border.all(
            color: borderTint ?? spec.border,
            width: 1.0,
          ),
        ),
        child: content,
      ),
    );

    // Apply BackdropFilter blur inside ClipRRect when live
    Widget surface;
    if (isLive && effectiveBlur > 0) {
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

/// Paints an inset directional specular gradient sheen from top-left across the glass surface.
/// This simulates translucent light scattering across frosted acrylic over ambient gradient meshes
/// without requiring an offscreen GPU blur pass.
class _SpecularSheenPainter extends CustomPainter {
  final Color sheenColor;
  final double radius;

  const _SpecularSheenPainter({
    required this.sheenColor,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || sheenColor.a <= 0) return;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    canvas.clipRRect(rrect);

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          sheenColor,
          sheenColor.withValues(alpha: (sheenColor.a * 0.35).clamp(0.0, 1.0)),
          Colors.transparent,
        ],
        stops: const [0.0, 0.40, 0.85],
      ).createShader(Offset.zero & size);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _SpecularSheenPainter oldDelegate) {
    return oldDelegate.sheenColor != sheenColor || oldDelegate.radius != radius;
  }
}

