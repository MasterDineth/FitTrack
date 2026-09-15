import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/active_workout_provider.dart';

/// Circular countdown ring shown during rest periods.
class ActiveRestTimerView extends ConsumerWidget {
  const ActiveRestTimerView({super.key});

  static const Color _mint = Color(0xFF00d68f);
  static const Color _dark = Color(0xFF0f172a);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activeWorkoutProvider);
    final notifier = ref.read(activeWorkoutProvider.notifier);
    final entry = state.currentEntry;

    final totalRest =
        entry?.restDurationSeconds ?? 90;
    final remaining = state.restRemainingSeconds;
    final progress = totalRest > 0
        ? (remaining / totalRest).clamp(0.0, 1.0)
        : 0.0;

    final nextSetNum = state.currentSetIndex + 2; // 1-based

    return Column(
      children: [
        // ── Circular Ring ───────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A0F172A),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'REST PERIOD',
                style: TextStyle(
                  color: Color(0xFF64748b),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 16),

              // Ring + countdown
              SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _mint.withValues(alpha: 0.2),
                            blurRadius: 32,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    // Background track
                    CustomPaint(
                      size: const Size(180, 180),
                      painter: _RingPainter(
                        progress: 1.0,
                        trackColor: const Color(0xFFe2e8f0),
                        strokeWidth: 12,
                      ),
                    ),
                    // Foreground arc
                    CustomPaint(
                      size: const Size(180, 180),
                      painter: _RingPainter(
                        progress: progress,
                        strokeWidth: 12,
                      ),
                    ),
                    // Center text
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.restRemainingFormatted,
                          style: const TextStyle(
                            color: _dark,
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            fontFeatures: [FontFeature.tabularFigures()],
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'of ${_fmtSeconds(totalRest)}',
                          style: const TextStyle(
                            color: Color(0xFF94a3b8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Quick adjustment pills
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _AdjustPill(
                    label: '-15s',
                    onTap: () => notifier.adjustRestTime(-15),
                  ),
                  const SizedBox(width: 8),
                  _AdjustPill(
                    label: '+30s',
                    positive: true,
                    onTap: () => notifier.adjustRestTime(30),
                  ),
                  const SizedBox(width: 8),
                  _AdjustPill(
                    label: '+60s',
                    positive: true,
                    onTap: () => notifier.adjustRestTime(60),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Start next set CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: notifier.skipRest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mint,
                    foregroundColor: _dark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'START SET $nextSetNum NOW →',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Next Exercise Preview ──────────────────────────────────────
        if (state.upcomingEntries.isNotEmpty) ...[
          const SizedBox(height: 8),
          _UpcomingExerciseCue(entry: state.upcomingEntries.first),
        ],
      ],
    );
  }

  static String _fmtSeconds(int s) {
    final m = s ~/ 60;
    final rem = s % 60;
    if (m == 0) return '${s}s';
    return rem == 0 ? '${m}m' : '${m}m ${rem}s';
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _AdjustPill extends StatelessWidget {
  const _AdjustPill({
    required this.label,
    required this.onTap,
    this.positive = false,
  });
  final String label;
  final VoidCallback onTap;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: positive
              ? const Color(0xFFe6faf3)
              : const Color(0xFFfef2f2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: positive
                ? const Color(0xFF00d68f).withValues(alpha: 0.3)
                : const Color(0xFFfca5a5).withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: positive
                ? const Color(0xFF00875a)
                : const Color(0xFFdc2626),
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _UpcomingExerciseCue extends StatelessWidget {
  const _UpcomingExerciseCue({required this.entry});
  final LiveExerciseEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFf8fafc),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFe2e8f0)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFe6faf3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Color(0xFF00d68f),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'UP NEXT',
                  style: TextStyle(
                    color: Color(0xFF94a3b8),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                Text(
                  entry.name,
                  style: const TextStyle(
                    color: Color(0xFF0f172a),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${entry.totalSets} sets × ${entry.targetReps} reps',
                  style: const TextStyle(
                    color: Color(0xFF64748b),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom painter for ring ───────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    this.trackColor,
    this.strokeWidth = 12,
  });
  final double progress;
  final Color? trackColor;
  final double strokeWidth;

  static const Color _mint = Color(0xFF00d68f);
  static const Color _mintDark = Color(0xFF00875a);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (trackColor != null) {
      paint.color = trackColor!;
      canvas.drawCircle(center, radius, paint);
    } else {
      // Gradient arc
      paint.shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + 2 * math.pi,
        colors: const [_mint, _mintDark, _mint],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.trackColor != trackColor;
}
