import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../theme/ft_glass.dart';

enum IslandPreviewMode {
  banner,
  live,
  rest,
}

/// The animated Dynamic Island Pill widget.
class DynamicIslandPill extends StatelessWidget {
  final IslandPreviewMode mode;
  final Animation<double> scaleAnimation;
  final VoidCallback onTap;
  final VoidCallback onSkip;

  const DynamicIslandPill({
    super.key,
    required this.mode,
    required this.scaleAnimation,
    required this.onTap,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.ftPrimary;
    return ScaleTransition(
      scale: scaleAnimation,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          decoration: BoxDecoration(
            color: const Color(0xFF15102B),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x5915102B),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left Icon / Indicator
              if (mode == IslandPreviewMode.banner) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x33F5C86E),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.emoji_events_rounded,
                      size: 18,
                      color: Color(0xFFF5C86E),
                    ),
                  ),
                ),
              ] else ...[
                _RingGauge(
                  progress: 0.35,
                  color: primary,
                ),
              ],
              const SizedBox(width: 10),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      mode == IslandPreviewMode.banner
                          ? 'New bench PR'
                          : mode == IslandPreviewMode.live
                              ? 'Push Day · 2 of 10'
                              : 'Rest · 0:45 left',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      mode == IslandPreviewMode.banner
                          ? '85 kg × 8 reps'
                          : mode == IslandPreviewMode.live
                              ? 'Bench press · 12:40'
                              : 'Next: Set 3 of 4',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFC9C0EE),
                      ),
                    ),
                  ],
                ),
              ),

              // Right Badge / Action
              if (mode == IslandPreviewMode.banner) ...[
                const Text(
                  '+5kg',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFF5C86E),
                  ),
                ),
              ] else if (mode == IslandPreviewMode.live) ...[
                Text(
                  '2/10',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: primary,
                  ),
                ),
              ] else ...[
                GestureDetector(
                  onTap: onSkip,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular ring gauge indicator for live & rest dynamic island pills.
class _RingGauge extends StatelessWidget {
  final double progress;
  final Color color;

  const _RingGauge({
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(
        painter: _RingGaugePainter(progress: progress, color: color),
      ),
    );
  }
}

class _RingGaugePainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingGaugePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingGaugePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
