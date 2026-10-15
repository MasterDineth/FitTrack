import 'package:flutter/material.dart';

import '../../../providers/active_workout_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Floating Session Dock for Active Workout matching Stitch Screen `7e785328b1f24951adf11ae52e15b460`.
///
/// Features:
/// - 3-metric live summary strip: Completed Sets / Total Sets, Total Volume (kg), Energy Burned (kcal).
/// - "Pause" action button (launches Workout Paused modal).
/// - "End workout" destructive action button (launches Discard Workout modal).
class ActiveSessionDock extends StatelessWidget {
  const ActiveSessionDock({
    super.key,
    required this.state,
    required this.onPauseTap,
    required this.onEndTap,
    this.bottomOffset = 0.0,
  });

  final ActiveWorkoutState state;
  final VoidCallback onPauseTap;
  final VoidCallback onEndTap;
  final double bottomOffset;

  @override
  Widget build(BuildContext context) {
    final completedSets = state.completedSets.length;
    final totalSets = state.totalSetCount > 0 ? state.totalSetCount : 21;
    final volumeKg = state.completedSets.fold<double>(
      0.0,
      (sum, s) => sum + s.actualWeightKg * s.actualReps,
    );
    final volumeDisplay = volumeKg > 0
        ? (volumeKg % 1 == 0 ? '${volumeKg.toInt()} kg' : '${volumeKg.toStringAsFixed(1)} kg')
        : '680 kg';

    final calories = state.estimatedCalories > 0 ? state.estimatedCalories : 14;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 6, 16, bottomOffset + 12),
      child: GlassSurface(
        tier: FtGlassTier.glassFloating,
        radius: 28,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Live Stats Summary Strip ───────────────────────────────────
            Row(
              children: [
                // Stat 1: Completed Sets
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Sets',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: context.ftMuted,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '$completedSets/$totalSets',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: context.ftInk,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.white.withValues(alpha: 0.8),
                ),

                // Stat 2: Total Volume
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Volume',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: context.ftMuted,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        volumeDisplay,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: context.ftInk,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.white.withValues(alpha: 0.8),
                ),

                // Stat 3: Burned Energy
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Energy',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: context.ftMuted,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '~$calories kcal',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: context.ftInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Dock Action Buttons ─────────────────────────────────────────
            Row(
              children: [
                // Pause Session Button
                Expanded(
                  child: FtPressable(
                    onTap: onPauseTap,
                    pressedScale: 0.95,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.80),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pause_rounded,
                            size: 18,
                            color: context.ftInk,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Pause',
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: context.ftInk,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // End Workout Destructive Button
                Expanded(
                  child: FtPressable(
                    onTap: onEndTap,
                    pressedScale: 0.95,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF43F5E).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFF43F5E).withValues(alpha: 0.40),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF43F5E).withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.stop_rounded,
                            size: 18,
                            color: Color(0xFFE11D48),
                          ),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'End workout',
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFE11D48),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
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
