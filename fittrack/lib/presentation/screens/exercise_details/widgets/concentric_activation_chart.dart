import 'dart:math' as math;

import 'package:flutter/material.dart';

/// One animated band of the concentric activation chart.
class ActivationBand {
  const ActivationBand({
    required this.progress,
    required this.color,
    required this.radius,
    required this.strokeWidth,
  });

  /// Fill of the band between 0.0 and 1.0.
  final double progress;
  final Color color;

  /// Radius in the chart's 160x160 design space.
  final double radius;
  final double strokeWidth;
}

/// Concentric ring chart used to summarise muscle activation.
///
/// Each band sweeps in with a short stagger so the chart reads as a single
/// animated gesture rather than three independent loops.
class ConcentricActivationChart extends StatelessWidget {
  const ConcentricActivationChart({
    super.key,
    required this.bands,
    required this.trackColor,
    this.size = 176,
    this.duration = const Duration(milliseconds: 1100),
    this.child,
  });

  final List<ActivationBand> bands;
  final Color trackColor;
  final double size;
  final Duration duration;
  final Widget? child;

  static const double _designSpace = 160;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: disableAnimations ? Duration.zero : duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size.square(size),
                painter: _ConcentricPainter(
                  bands: bands,
                  trackColor: trackColor,
                  reveal: value,
                ),
              ),
              if (child != null) ?child,
            ],
          ),
        );
      },
    );
  }
}

class _ConcentricPainter extends CustomPainter {
  const _ConcentricPainter({
    required this.bands,
    required this.trackColor,
    required this.reveal,
  });

  final List<ActivationBand> bands;
  final Color trackColor;
  final double reveal;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.shortestSide <= 0) return;

    final scale = size.shortestSide / ConcentricActivationChart._designSpace;
    canvas.save();
    canvas.scale(scale);

    final center = Offset(80, 80);
    const stagger = 0.14;

    for (var i = 0; i < bands.length; i++) {
      final band = bands[i];
      final offset = i * stagger;
      final window = (1.0 - stagger).clamp(0.01, 1.0);
      final local = ((reveal - offset) / window).clamp(0.0, 1.0);

      final track = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = band.strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = trackColor;
      canvas.drawCircle(center, band.radius, track);

      final arcProgress = local * band.progress.clamp(0.0, 1.0);
      if (arcProgress <= 0) continue;

      final arc = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = band.strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = band.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: band.radius),
        -math.pi / 2,
        2 * math.pi * arcProgress,
        false,
        arc,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ConcentricPainter oldDelegate) {
    return oldDelegate.reveal != reveal || oldDelegate.trackColor != trackColor;
  }
}
