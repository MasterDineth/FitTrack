import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../providers/active_workout_provider.dart';
import '../../theme/ft_glass.dart';
import '../glass_surface.dart';
import '../../screens/dashboard/widgets/ft_pressable.dart';
import 'discard_workout_modal.dart';
import 'modal_backdrop_helper.dart';

/// Shows the redesigned FitTrack Workout Paused Modal matching Stitch Screen `1556ae98b80e42e69741ef8fb9f66f52`.
///
/// Features:
/// - Frosted glass modal card with top specular highlight sheen.
/// - Top status bar: Pulsating amber "Session Standby" pill and Monospace "Paused" stopwatch pill.
/// - Hero animated multi-layer interactive pause orb (breathing aura, rotating orbital dashed ring,
///   pulsing pause bars, tap to resume).
/// - 4-Column stats strip (Duration, Sets, Volume, Burned).
/// - Current Exercise Card with photo thumbnail, target specs, and 4-segment progress bar.
/// - Next Upcoming Exercise Card with queue rank badge and specs.
/// - "Resume Workout" primary gradient action.
/// - "End Workout Session" secondary action launching the Discard Workout Warning Modal.
Future<void> showWorkoutPausedModal(
  BuildContext context, {
  required ActiveWorkoutState state,
  required ActiveWorkoutNotifier notifier,
  required VoidCallback onEndWorkout,
}) async {
  // Ensure the provider is paused
  notifier.pauseSession();

  await showBlurModal<void>(
    context: context,
    barrierDismissible: false,
    child: _WorkoutPausedModalCard(
      state: state,
      notifier: notifier,
      onEndWorkout: onEndWorkout,
    ),
  );
}

class _WorkoutPausedModalCard extends StatefulWidget {
  const _WorkoutPausedModalCard({
    required this.state,
    required this.notifier,
    required this.onEndWorkout,
  });

  final ActiveWorkoutState state;
  final ActiveWorkoutNotifier notifier;
  final VoidCallback onEndWorkout;

  @override
  State<_WorkoutPausedModalCard> createState() => _WorkoutPausedModalCardState();
}

class _WorkoutPausedModalCardState extends State<_WorkoutPausedModalCard>
    with TickerProviderStateMixin {
  late final AnimationController _orbitController;
  late final AnimationController _breatheController;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  void _onResume() {
    widget.notifier.resumeSession();
    Navigator.of(context).pop();
  }

  void _onEndWorkout() {
    // Dismiss the paused modal, then launch the Discard Workout Warning modal
    Navigator.of(context).pop();
    showDiscardWorkoutModal(
      context,
      state: widget.state,
      onDiscard: widget.onEndWorkout,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final currentEntry = state.currentEntry;
    final upcomingEntries = state.upcomingEntries;
    final nextEntry = upcomingEntries.isNotEmpty ? upcomingEntries.first : null;

    final completedCount = state.completedSets.length;
    final totalCount = state.totalSetCount > 0 ? state.totalSetCount : 21;
    final volumeKg = state.completedSets.fold<double>(
      0.0,
      (sum, s) => sum + s.actualWeightKg * s.actualReps,
    );
    final volumeDisplay = volumeKg > 0
        ? (volumeKg % 1 == 0 ? volumeKg.toInt().toString() : volumeKg.toStringAsFixed(1))
        : '680';

    final calories = state.estimatedCalories > 0 ? state.estimatedCalories : 14;

    final scheduleTitle = state.schedule.name.isNotEmpty
        ? state.schedule.name
        : 'Push–Pull–Legs Split';

    final currentExerciseName = currentEntry?.name ?? 'Barbell Bench Press';
    final currentExerciseTarget =
        '${currentEntry?.targetReps ?? 8} reps @ ${currentEntry?.targetWeightKg ?? 85} kg';
    final currentSetIndex = state.currentSetIndex + 1;
    final totalExerciseSets = currentEntry?.totalSets ?? 4;

    final nextExerciseName = nextEntry?.name ?? 'Incline Dumbbell Press';
    final nextExerciseSpecs =
        '${nextEntry?.totalSets ?? 3} sets × ${nextEntry?.targetReps ?? 10} reps · ${nextEntry?.targetWeightKg ?? 30} kg';

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: GlassSurface(
        tier: FtGlassTier.glassFloating,
        radius: 32,
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // ── 1. Top Status Bar: Pill Badges ───────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Amber pulsating standby badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD97706),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'SESSION STANDBY',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),

                // Monospace Paused badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.pause_circle_outline_rounded,
                        size: 13,
                        color: context.ftMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Paused',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: context.ftInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── 2. Hero Animated Multi-Layer Pause Orb & Header ─────────────
            Center(
              child: GestureDetector(
                onTap: _onResume,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_orbitController, _breatheController]),
                  builder: (context, child) {
                    final breatheScale = 0.96 + (_breatheController.value * 0.08);

                    return SizedBox(
                      width: 88,
                      height: 88,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Layer 1: Outermost breathing translucent purple aura
                          Transform.scale(
                            scale: breatheScale * 1.15,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.ftPrimary.withValues(alpha: 0.22),
                              ),
                            ),
                          ),

                          // Layer 2: Rotating dashed SVG orbital ring with teal dot
                          Transform.rotate(
                            angle: _orbitController.value * 2 * math.pi,
                            child: CustomPaint(
                              size: const Size(88, 88),
                              painter: _OrbitRingPainter(accentColor: context.ftPrimary),
                            ),
                          ),

                          // Layer 3: Core tactile gradient sphere with pause bars
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF5F3BDC),
                                  Color(0xFF6F4BEB),
                                  Color(0xFF4E2BC2),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF5F3BDC).withValues(alpha: 0.45),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 5,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
                                    width: 5,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Header titles
            Text(
              'Workout Paused',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 21,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: context.ftInk,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: context.ftPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    scheduleTitle,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.ftMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── 3. 4-Column Stats Strip ──────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _buildMiniStat(
                    label: 'DURATION',
                    value: state.elapsedFormatted,
                    unit: '',
                    isMono: true,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildMiniStat(
                    label: 'SETS',
                    value: '$completedCount',
                    unit: '/$totalCount',
                    valueColor: context.ftPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildMiniStat(
                    label: 'VOLUME',
                    value: volumeDisplay,
                    unit: 'kg',
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildMiniStat(
                    label: 'BURNED',
                    value: '$calories',
                    unit: 'kcal',
                    valueColor: const Color(0xFFF43F5E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── 4. Current Exercise Card ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: context.isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: context.isDark ? Colors.white.withValues(alpha: 0.10) : Colors.white,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: context.ftPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'CURRENT EXERCISE',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: context.ftPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: context.ftPrimary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Set $currentSetIndex of $totalExerciseSets Active',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: context.ftPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white,
                            width: 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/images/dashboard/coaching_bench.webp',
                          fit: BoxFit.cover,
                          cacheWidth: 92,
                          cacheHeight: 92,
                        ),
                      ),
                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentExerciseName,
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
                            const SizedBox(height: 1),
                            Text(
                              'Target: $currentExerciseTarget',
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: context.ftMuted,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Multi-segment progress bar
                            Row(
                              children: [
                                for (int i = 1; i <= totalExerciseSets; i++)
                                  Expanded(
                                    child: Container(
                                      height: 4,
                                      margin: EdgeInsets.only(right: i < totalExerciseSets ? 3 : 0),
                                      decoration: BoxDecoration(
                                        color: i <= currentSetIndex
                                            ? context.ftPrimary
                                            : (context.isDark
                                                ? Colors.white.withValues(alpha: 0.12)
                                                : Colors.black.withValues(alpha: 0.10)),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── 5. Next Upcoming Exercise Card ───────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: context.isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.70),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: context.isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white,
                        width: 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/dashboard/hero_workout.webp',
                      fit: BoxFit.cover,
                      cacheWidth: 76,
                      cacheHeight: 76,
                    ),
                  ),
                  const SizedBox(width: 8),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'UP NEXT',
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: context.ftMuted,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF43F5E).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Chest',
                                style: TextStyle(
                                  fontFamily: FtText.fontFamily,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFF43F5E),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          nextExerciseName,
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: context.ftInk,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          nextExerciseSpecs,
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: context.ftMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    Icons.drag_indicator_rounded,
                    size: 18,
                    color: context.ftMuted.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── 6. Action Buttons ───────────────────────────────────────────
            FtPressable(
              onTap: _onResume,
              pressedScale: 0.98,
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF5F3BDC),
                      Color(0xFF6F4BEB),
                      Color(0xFF502BBD),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5F3BDC).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Resume Workout',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 14.5,
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

            FtPressable(
              onTap: _onEndWorkout,
              pressedScale: 0.98,
              child: Container(
                width: double.infinity,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF43F5E).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFF43F5E).withValues(alpha: 0.40),
                    width: 1,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.stop_rounded,
                      size: 16,
                      color: Color(0xFFE11D48),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'End Workout Session',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: Color(0xFFE11D48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required String unit,
    Color? valueColor,
    bool isMono = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
      decoration: BoxDecoration(
        color: context.isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: context.ftMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: isMono ? 'monospace' : FtText.fontFamily,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: valueColor ?? context.ftInk,
              letterSpacing: isMono ? 0.0 : -0.3,
            ),
          ),
          if (unit.isNotEmpty)
            Text(
              unit,
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: context.ftMuted,
              ),
            ),
        ],
      ),
    );
  }
}

class _OrbitRingPainter extends CustomPainter {
  _OrbitRingPainter({required this.accentColor});

  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    final ringPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw dashed circle
    const dashLength = 6.0;
    const dashSpace = 6.0;
    final circumference = 2 * math.pi * radius;
    final dashCount = (circumference / (dashLength + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i * (dashLength + dashSpace) / circumference) * 2 * math.pi;
      final sweepAngle = (dashLength / circumference) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        ringPaint,
      );
    }

    // Draw orbital teal beacon dot at 0 angle
    final dotPaint = Paint()..color = const Color(0xFF2DD4BF);
    final dotCenter = Offset(center.dx + radius * math.cos(0), center.dy + radius * math.sin(0));
    canvas.drawCircle(dotCenter, 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _OrbitRingPainter oldDelegate) => false;
}
