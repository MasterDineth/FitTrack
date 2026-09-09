import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// FitTrack kinetic barbell / dumbbell logo emblem.
/// Renders the SVG-derived icon as a Flutter [CustomPainter].
class FtLogoEmblem extends StatelessWidget {
  const FtLogoEmblem({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0E3B2E), Color(0xFF064E3B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: AppColors.kineticMint.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.kineticMint.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _DumbbellPainter(),
      ),
    );
  }
}

class _DumbbellPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Shaft gradient
    final shaftPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white, AppColors.kineticMint],
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

    // Left weight (white)
    final whitePaint = Paint()..color = Colors.white;
    final mintPaint = Paint()..color = AppColors.kineticMint;

    // Outer white weight block
    final rrInner = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(-size.width * 0.30, 0),
        width: size.width * 0.16,
        height: size.width * 0.22,
      ),
      Radius.circular(size.width * 0.05),
    );
    canvas.drawRRect(rrInner, whitePaint);

    // Mint inner accent
    final rrMintL = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(-size.width * 0.38, 0),
        width: size.width * 0.11,
        height: size.width * 0.16,
      ),
      Radius.circular(size.width * 0.04),
    );
    canvas.drawRRect(rrMintL, Paint()..color = AppColors.kineticMint.withValues(alpha: 0.8));

    // Right weight (mint)
    final rrRight = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.30, 0),
        width: size.width * 0.16,
        height: size.width * 0.22,
      ),
      Radius.circular(size.width * 0.05),
    );
    canvas.drawRRect(rrRight, mintPaint);

    // Right accent (white)
    final rrWhiteR = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.38, 0),
        width: size.width * 0.11,
        height: size.width * 0.16,
      ),
      Radius.circular(size.width * 0.04),
    );
    canvas.drawRRect(rrWhiteR, Paint()..color = Colors.white.withValues(alpha: 0.9));

    // Arrow accent
    final arrowPaint = Paint()
      ..color = AppColors.kineticMint
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
          Colors.transparent,
          Colors.white.withValues(alpha: 0.12),
          Colors.transparent,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), shimmerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
