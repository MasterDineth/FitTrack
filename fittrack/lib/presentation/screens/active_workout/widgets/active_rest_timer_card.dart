import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/active_workout_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Rest Timer Mode Card matching Stitch Screen `7e785328b1f24951adf11ae52e15b460`.
///
/// Features:
/// - Recovery Period header with next set preview pill.
/// - Circular luminous countdown timer dial with isolated countdown timer widget.
/// - Quick adjustment chips (-15s, +15s, +30s).
/// - "Next Up Immediately" preview card.
/// - Primary "Start next set" gradient CTA button.
/// - Sub-action "Skip rest timer" button.
class ActiveRestTimerCard extends StatelessWidget {
  const ActiveRestTimerCard({
    super.key,
    required this.entry,
    required this.nextSetNumber,
    required this.onAdjustRest,
    required this.onStartNextSet,
    required this.onSkipRest,
  });

  final LiveExerciseEntry entry;
  final int nextSetNumber;
  final ValueChanged<int> onAdjustRest;
  final VoidCallback onStartNextSet;
  final VoidCallback onSkipRest;

  @override
  Widget build(BuildContext context) {
    final weight = entry.liveWeightKg;
    final weightStr = weight % 1 == 0 ? weight.toInt().toString() : weight.toStringAsFixed(1);
    final totalRest = entry.restDurationSeconds > 0 ? entry.restDurationSeconds : 120;
    final totalM = totalRest ~/ 60;
    final totalS = totalRest % 60;
    final totalFormatted =
        '${totalM.toString().padLeft(2, '0')}:${totalS.toString().padLeft(2, '0')}';

    return GlassSurface(
      tier: FtGlassTier.glass1,
      radius: 28,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. Recovery Period Header ─────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RECOVERY PERIOD',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: context.ftMuted,
                    ),
                  ),
                  Text(
                    'Resting Before Set $nextSetNumber',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: context.ftInk,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.white,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/images/dashboard/coaching_bench.webp',
                        fit: BoxFit.cover,
                        cacheWidth: 36,
                        cacheHeight: 36,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Set $nextSetNumber · $weightStr kg',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: context.ftInk,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── 2. Circular Countdown Timer Dial ──────────────────────────────
          _IsolatedRestDial(
            totalRestSeconds: totalRest,
            totalFormatted: totalFormatted,
          ),
          const SizedBox(height: 12),

          // ── 3. Quick Time Adjustment Chips ────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAdjustChip(context, '-15s', () => onAdjustRest(-15)),
              const SizedBox(width: 8),
              _buildAdjustChip(context, '+15s', () => onAdjustRest(15)),
              const SizedBox(width: 8),
              _buildAdjustChip(context, '+30s', () => onAdjustRest(30)),
            ],
          ),
          const SizedBox(height: 16),

          // ── 4. Next Up in Set Preview Card ────────────────────────────────
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.70),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: context.isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.white,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.white,
                      width: 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/dashboard/coaching_bench.webp',
                    fit: BoxFit.cover,
                    cacheWidth: 88,
                    cacheHeight: 88,
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NEXT UP IMMEDIATELY',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: context.ftPrimary,
                        ),
                      ),
                      Text(
                        entry.name,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: context.ftInk,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Set $nextSetNumber · Target ${entry.targetReps} reps @ $weightStr kg',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: context.ftMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: context.ftPrimary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: context.ftPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── 5. Primary Action CTA: Start Next Set ─────────────────────────
          FtPressable(
            onTap: onStartNextSet,
            pressedScale: 0.98,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.ftPrimary,
                    Color.lerp(context.ftPrimary, Colors.white, 0.12) ?? context.ftPrimary,
                    Color.lerp(context.ftPrimary, Colors.black, 0.15) ?? context.ftPrimary,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.ftPrimary.withValues(alpha: 0.40),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_arrow_rounded,
                    size: 22,
                    color: Colors.white,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Start next set',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── 6. Sub-Action: Skip Rest Timer ────────────────────────────────
          Center(
            child: FtPressable(
              onTap: onSkipRest,
              pressedScale: 0.95,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fast_forward_rounded,
                      size: 16,
                      color: context.ftMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Skip rest timer',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: context.ftMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustChip(BuildContext context, String label, VoidCallback onTap) {
    return FtPressable(
      onTap: onTap,
      pressedScale: 0.92,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: context.isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.white,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: context.isDark ? 0.20 : 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: FtText.fontFamily,
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: context.ftInk,
          ),
        ),
      ),
    );
  }
}

/// Isolated Circular Timer Dial widget watching only `restRemainingSeconds`
/// via `.select` so rest ticks don't re-render parent cards.
class _IsolatedRestDial extends ConsumerWidget {
  const _IsolatedRestDial({
    required this.totalRestSeconds,
    required this.totalFormatted,
  });

  final int totalRestSeconds;
  final String totalFormatted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = ref.watch(
      activeWorkoutProvider.select((s) => s.restRemainingSeconds),
    );
    final progress = totalRestSeconds > 0
        ? (remaining / totalRestSeconds).clamp(0.0, 1.0)
        : 0.0;

    final m = remaining ~/ 60;
    final s = remaining % 60;
    final remainingFormatted =
        '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    return Center(
      child: SizedBox(
        width: 170,
        height: 170,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circular arc canvas
            CustomPaint(
              size: const Size(170, 170),
              painter: _RestRingPainter(
                progress: progress,
                primaryColor: context.ftPrimary,
                tealColor: const Color(0xFF2DD4BF),
                trackColor: context.isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.07),
              ),
            ),

            // Inside Center text
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'REMAINING',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: context.ftMuted,
                  ),
                ),
                Text(
                  remainingFormatted,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                    color: context.ftInk,
                    height: 1.1,
                  ),
                ),
                Text(
                  'of $totalFormatted',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.ftMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RestRingPainter extends CustomPainter {
  _RestRingPainter({
    required this.progress,
    required this.primaryColor,
    required this.tealColor,
    required this.trackColor,
  });

  final double progress;
  final Color primaryColor;
  final Color tealColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background ring track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // Progress Ring Arc with Gradient rotated so it starts at 12 o'clock (-pi / 2)
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      colors: [primaryColor, tealColor],
      transform: const GradientRotation(-math.pi / 2),
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 9;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _RestRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.trackColor != trackColor;
  }
}
