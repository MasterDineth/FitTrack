import 'package:flutter/material.dart';
import '../theme/ft_glass.dart';

/// Lightweight, high-performance glass surface without expensive BackdropFilter.
/// Uses calibrated fills, 1px borders, subtle drop shadows, and an inset 1.5px top highlight line.
class GlassSurface extends StatelessWidget {
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
  });

  @override
  Widget build(BuildContext context) {
    final spec = FtGlassTheme.specFor(tier, context);
    final effectiveRadius = radius ?? FtGlassTheme.radiusCards;
    final borderRadius = BorderRadius.circular(effectiveRadius);

    Widget content = child ?? const SizedBox.shrink();

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    // Outer container with drop shadow
    final decoration = BoxDecoration(
      color: spec.fill,
      borderRadius: borderRadius,
      border: Border.all(
        color: borderTint ?? spec.border,
        width: 1.0,
      ),
      boxShadow: (shadow && spec.shadows.isNotEmpty) ? spec.shadows : null,
    );

    // Inset top highlight drawn inside clip
    final surface = ClipRRect(
      borderRadius: borderRadius,
      child: CustomPaint(
        foregroundPainter: _TopHighlightPainter(
          highlightColor: spec.highlight,
          radius: effectiveRadius,
        ),
        child: Container(
          width: width,
          height: height,
          alignment: alignment,
          decoration: decoration,
          child: content,
        ),
      ),
    );

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
