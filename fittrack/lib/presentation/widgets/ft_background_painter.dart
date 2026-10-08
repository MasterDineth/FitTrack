import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/ft_glass.dart';

/// Fixed multi-point radial gradient background for the FitTrack Stitch layout.
/// Rasterises once via [RepaintBoundary] and never repaints on scroll.
class FtMeshBackground extends StatelessWidget {
  const FtMeshBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isOled = isDark &&
        (theme.scaffoldBackgroundColor == Colors.black ||
            theme.scaffoldBackgroundColor == const Color(0xFF000000));
    final primaryColor = theme.colorScheme.primary;
    final backgroundColor = isDark
        ? (isOled ? const Color(0xFF000000) : theme.scaffoldBackgroundColor)
        : FtGlassTheme.canvas;

    return RepaintBoundary(
      child: CustomPaint(
        painter: _FtMeshCustomPainter(
          isDark: isDark,
          isOled: isOled,
          primaryColor: primaryColor,
          backgroundColor: backgroundColor,
        ),
        isComplex: true,
        willChange: false,
        size: Size.infinite,
      ),
    );
  }
}

class _FtMeshCustomPainter extends CustomPainter {
  final bool isDark;
  final bool isOled;
  final Color primaryColor;
  final Color backgroundColor;

  const _FtMeshCustomPainter({
    required this.isDark,
    required this.isOled,
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    if (!isDark) {
      // ── Light Mode Canvas & Glows (#F6F4FF) ────────────────────────────────
      final bgPaint = Paint()..color = backgroundColor;
      canvas.drawRect(Offset.zero & size, bgPaint);

      _drawRadialGlow(
        canvas: canvas,
        size: size,
        cxPercent: 0.10,
        cyPercent: 0.08,
        color: primaryColor.withValues(alpha: 0.22),
        stopPercent: 0.55,
      );

      _drawRadialGlow(
        canvas: canvas,
        size: size,
        cxPercent: 0.90,
        cyPercent: 0.18,
        color: const Color.fromRGBO(20, 184, 166, 0.20),
        stopPercent: 0.52,
      );

      _drawRadialGlow(
        canvas: canvas,
        size: size,
        cxPercent: 0.15,
        cyPercent: 0.65,
        color: const Color.fromRGBO(254, 183, 139, 0.22),
        stopPercent: 0.55,
      );

      _drawRadialGlow(
        canvas: canvas,
        size: size,
        cxPercent: 0.85,
        cyPercent: 0.82,
        color: primaryColor.withValues(alpha: 0.18),
        stopPercent: 0.60,
      );
      return;
    }

    if (isOled) {
      // ── Pure AMOLED OLED Dark Mode (#000000) ───────────────────────────────
      final bgPaint = Paint()..color = const Color(0xFF000000);
      canvas.drawRect(Offset.zero & size, bgPaint);

      // radial-gradient(at 10% 6%, primary@14% 0px, transparent 45%)
      _drawRadialGlow(
        canvas: canvas,
        size: size,
        cxPercent: 0.10,
        cyPercent: 0.06,
        color: primaryColor.withValues(alpha: 0.14),
        stopPercent: 0.45,
      );

      // radial-gradient(at 90% 16%, rgba(45, 212, 191, 0.10) 0px, transparent 42%)
      _drawRadialGlow(
        canvas: canvas,
        size: size,
        cxPercent: 0.90,
        cyPercent: 0.16,
        color: const Color.fromRGBO(45, 212, 191, 0.10),
        stopPercent: 0.42,
      );

      // radial-gradient(at 20% 60%, primary@8% 0px, transparent 48%)
      _drawRadialGlow(
        canvas: canvas,
        size: size,
        cxPercent: 0.20,
        cyPercent: 0.60,
        color: primaryColor.withValues(alpha: 0.08),
        stopPercent: 0.48,
      );

      // radial-gradient(at 85% 82%, rgba(249, 115, 22, 0.06) 0px, transparent 50%)
      _drawRadialGlow(
        canvas: canvas,
        size: size,
        cxPercent: 0.85,
        cyPercent: 0.82,
        color: const Color.fromRGBO(249, 115, 22, 0.06),
        stopPercent: 0.50,
      );
      return;
    }

    // ── Slate Dark Mode (#0C0A18 / #0B131F) ──────────────────────────────────
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    _drawRadialGlow(
      canvas: canvas,
      size: size,
      cxPercent: 0.10,
      cyPercent: 0.08,
      color: primaryColor.withValues(alpha: 0.25),
      stopPercent: 0.55,
    );

    _drawRadialGlow(
      canvas: canvas,
      size: size,
      cxPercent: 0.90,
      cyPercent: 0.18,
      color: const Color.fromRGBO(20, 184, 166, 0.20),
      stopPercent: 0.52,
    );

    _drawRadialGlow(
      canvas: canvas,
      size: size,
      cxPercent: 0.20,
      cyPercent: 0.60,
      color: primaryColor.withValues(alpha: 0.12),
      stopPercent: 0.55,
    );

    _drawRadialGlow(
      canvas: canvas,
      size: size,
      cxPercent: 0.85,
      cyPercent: 0.82,
      color: const Color.fromRGBO(249, 115, 22, 0.08),
      stopPercent: 0.60,
    );
  }

  void _drawRadialGlow({
    required Canvas canvas,
    required Size size,
    required double cxPercent,
    required double cyPercent,
    required Color color,
    required double stopPercent,
  }) {
    final cx = size.width * cxPercent;
    final cy = size.height * cyPercent;

    final maxDx = math.max(cx, size.width - cx);
    final maxDy = math.max(cy, size.height - cy);
    final farthestCorner = math.sqrt(maxDx * maxDx + maxDy * maxDy);
    final radius = farthestCorner * stopPercent;

    if (radius <= 0) return;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0.0)],
        stops: const [0.0, 1.0],
      ).createShader(rect);

    canvas.drawCircle(Offset(cx, cy), radius, paint);
  }

  @override
  bool shouldRepaint(covariant _FtMeshCustomPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.isOled != isOled ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
