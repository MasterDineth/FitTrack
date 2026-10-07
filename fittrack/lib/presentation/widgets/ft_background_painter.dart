import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/ft_glass.dart';

/// Fixed multi-point radial gradient background for the FitTrack Stitch layout.
/// Rasterises once via [RepaintBoundary] and never repaints on scroll.
class FtMeshBackground extends StatelessWidget {
  const FtMeshBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: CustomPaint(
        painter: _FtMeshCustomPainter(),
        isComplex: true,
        willChange: false,
        size: Size.infinite,
      ),
    );
  }
}

class _FtMeshCustomPainter extends CustomPainter {
  const _FtMeshCustomPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Base canvas fill #F6F4FF
    final bgPaint = Paint()..color = FtGlassTheme.canvas;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 4 radial gradients, each transparent at the given stop:
    // radius = stop% of the farthest-corner distance:
    // 1) 10% 8% rgba(95,59,220,.22) stop 55%
    // 2) 90% 18% rgba(20,184,166,.20) stop 52%
    // 3) 15% 65% rgba(254,183,139,.22) stop 55%
    // 4) 85% 82% rgba(120,88,246,.20) stop 60%

    _drawRadialGlow(
      canvas: canvas,
      size: size,
      cxPercent: 0.10,
      cyPercent: 0.08,
      color: const Color.fromRGBO(95, 59, 220, 0.22),
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
      color: const Color.fromRGBO(120, 88, 246, 0.20),
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
