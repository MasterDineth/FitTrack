import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A single circular progress ring that animates its sweep when it first
/// appears.
///
/// The animation is driven by [TweenAnimationBuilder], so it automatically
/// halts when the route is covered by an opaque overlay (TickerMode) and
/// collapses to an instant fill when the user has disabled animations.
class AnimatedActivationRing extends StatelessWidget {
  const AnimatedActivationRing({
    super.key,
    required this.progress,
    required this.color,
    required this.trackColor,
    this.strokeWidth = 6,
    this.size = 44,
    this.duration = const Duration(milliseconds: 900),
    this.curve = Curves.easeOutCubic,
    this.child,
  });

  /// Target fill between 0.0 and 1.0.
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;
  final double size;
  final Duration duration;
  final Curve curve;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final target = progress.clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: target),
      duration: disableAnimations ? Duration.zero : duration,
      curve: curve,
      builder: (context, value, _) {
        return CustomPaint(
          painter: _RingPainter(
            progress: value,
            color: color,
            trackColor: trackColor,
            strokeWidth: strokeWidth,
          ),
          child: SizedBox(
            width: size,
            height: size,
            child: child == null ? null : Center(child: child),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.shortestSide <= 0) return;

    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    if (radius <= 0) return;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
