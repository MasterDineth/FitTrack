import 'package:flutter/material.dart';

/// FitTrack kinetic barbell / dumbbell logo emblem.
/// Renders the SVG-derived icon as a Flutter [CustomPainter].
class FtLogoEmblem extends StatelessWidget {
  const FtLogoEmblem({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withValues(alpha: 0.8),
            primary.withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: primary.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _DumbbellPainter(
          primaryColor: primary,
          onPrimaryColor: colorScheme.onPrimary,
        ),
      ),
    );
  }
}

class _DumbbellPainter extends CustomPainter {
  const _DumbbellPainter({
    required this.primaryColor,
    required this.onPrimaryColor,
  });

  final Color primaryColor;
  final Color onPrimaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Shaft gradient
    final shaftPaint = Paint()
      ..shader = LinearGradient(
        colors: [onPrimaryColor, primaryColor],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-0.785398); // -45°
    canvas.drawLine(
      Offset(-size.width * 0.25, 0),
      Offset(size.width * 0.25, 0),
      shaftPaint,
    );

    // Left weight (onPrimary)
    final onPrimaryPaint = Paint()..color = onPrimaryColor;
    final primaryPaint = Paint()..color = primaryColor;

    // Outer onPrimary weight block
    final rrInner = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(-size.width * 0.30, 0),
        width: size.width * 0.16,
        height: size.width * 0.22,
      ),
      Radius.circular(size.width * 0.05),
    );
    canvas.drawRRect(rrInner, onPrimaryPaint);

    // Primary inner accent
    final rrPrimaryL = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(-size.width * 0.38, 0),
        width: size.width * 0.11,
        height: size.width * 0.16,
      ),
      Radius.circular(size.width * 0.04),
    );
    canvas.drawRRect(
      rrPrimaryL,
      Paint()..color = primaryColor.withValues(alpha: 0.8),
    );

    // Right weight (primary)
    final rrRight = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.30, 0),
        width: size.width * 0.16,
        height: size.width * 0.22,
      ),
      Radius.circular(size.width * 0.05),
    );
    canvas.drawRRect(rrRight, primaryPaint);

    // Right accent (onPrimary)
    final rrOnPrimaryR = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.38, 0),
        width: size.width * 0.11,
        height: size.width * 0.16,
      ),
      Radius.circular(size.width * 0.04),
    );
    canvas.drawRRect(
      rrOnPrimaryR,
      Paint()..color = onPrimaryColor.withValues(alpha: 0.9),
    );

    // Arrow accent
    final arrowPaint = Paint()
      ..color = onPrimaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final arrowX = size.width * 0.1;
    final arrowY = size.height * -0.06;
    final arrowLen = size.width * 0.1;
    canvas.drawLine(
      Offset(arrowX, arrowY),
      Offset(arrowX + arrowLen, arrowY - arrowLen),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(arrowX + arrowLen, arrowY - arrowLen),
      Offset(arrowX + arrowLen * 2, arrowY),
      arrowPaint,
    );

    canvas.restore();

    // Glass shimmer
    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.25),
          Colors.transparent,
        ],
        begin: Alignment.topLeft,
        end: Alignment.center,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(size.width * 0.28),
      ),
      shimmerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DumbbellPainter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.onPrimaryColor != onPrimaryColor;
}
