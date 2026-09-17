import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/active_workout_provider.dart';

/// Circular countdown ring shown during rest periods.
class ActiveRestTimerView extends ConsumerWidget {
  const ActiveRestTimerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activeWorkoutProvider);
    final notifier = ref.read(activeWorkoutProvider.notifier);
    final entry = state.currentEntry;
    final colorScheme = Theme.of(context).colorScheme;

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
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              // Dynamic ambient glow
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.18),
                blurRadius: 16,
                spreadRadius: 0,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.08),
                blurRadius: 22,
                spreadRadius: 1,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'REST PERIOD',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                            color: colorScheme.primary.withValues(alpha: 0.2),
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
                        trackColor: colorScheme.surfaceContainerHighest,
                        strokeWidth: 12,
                      ),
                    ),
                    // Foreground arc
                    CustomPaint(
                      size: const Size(180, 180),
                      painter: _RingPainter(
                        progress: progress,
                        strokeWidth: 12,
                        primaryColor: colorScheme.primary,
                      ),
                    ),
                    // Center text
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.restRemainingFormatted,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            fontFeatures: const [FontFeature.tabularFigures()],
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'of ${_fmtSeconds(totalRest)}',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
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
              
              const SizedBox(height: 24),
              
              // Set progression carousel
              _SetProgressionCarousel(
                totalSets: entry?.totalSets ?? 3,
                currentSetIndex: state.currentSetIndex,
                weight: entry?.liveWeightKg ?? 0,
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
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: positive
              ? colorScheme.primaryContainer
              : colorScheme.errorContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: positive
                ? colorScheme.primary.withValues(alpha: 0.4)
                : colorScheme.error.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: positive
                ? colorScheme.onPrimaryContainer
                : colorScheme.onErrorContainer,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.fitness_center,
              color: colorScheme.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UP NEXT',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                Text(
                  entry.name,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${entry.totalSets} sets × ${entry.targetReps} reps',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
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
    this.primaryColor = Colors.blue,
  });
  final double progress;
  final Color? trackColor;
  final double strokeWidth;
  final Color primaryColor;

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
      final color = primaryColor;
      // Gradient arc
      paint.shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + 2 * math.pi,
        colors: [color, color.withValues(alpha: 0.6), color],
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
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.primaryColor != primaryColor;
}

class _SetProgressionCarousel extends StatelessWidget {
  const _SetProgressionCarousel({
    required this.totalSets,
    required this.currentSetIndex,
    required this.weight,
  });

  final int totalSets;
  final int currentSetIndex;
  final double weight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSets, (index) {
          final isCompleted = index <= currentSetIndex;
          final isNext = index == currentSetIndex + 1;
          
          return Row(
            children: [
              if (index > 0)
                Container(
                  width: 20,
                  height: 2,
                  color: isCompleted || isNext
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
              Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? colorScheme.primary
                          : isNext
                              ? colorScheme.surface
                              : colorScheme.surfaceContainerLow,
                      border: Border.all(
                        color: isNext
                            ? colorScheme.primary
                            : (isCompleted
                                ? colorScheme.primary
                                : colorScheme.outlineVariant),
                        width: isNext ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(Icons.check, color: colorScheme.onPrimary, size: 24)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isNext
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurface.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isNext ? 'NEXT' : 'Set ${index + 1}',
                    style: TextStyle(
                      color: isNext
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} kg',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}
