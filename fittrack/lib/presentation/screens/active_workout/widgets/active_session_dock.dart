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
                  color: context.isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.08),
                ),

                // Stat 2: Workout Timer
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Timer',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: context.ftMuted,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        state.formattedElapsed,
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
                  color: context.isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.08),
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
                // Pause Session Button (Filled with Primary Brand Color)
                Expanded(
                  child: FtPressable(
                    onTap: onPauseTap,
                    pressedScale: 0.95,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: context.ftPrimary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: context.ftPrimary.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pause_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Pause',
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
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

                // End Workout Destructive Button (Completely filled, no red outline)
                Expanded(
                  child: FtPressable(
                    onTap: onEndTap,
                    pressedScale: 0.95,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: _resolveDestructiveColor(context),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _resolveDestructiveColor(context).withValues(alpha: 0.30),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.stop_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'End workout',
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
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

  Color _resolveDestructiveColor(BuildContext context) {
    final primary = context.ftPrimary;
    final hsl = HSLColor.fromColor(primary);
    final isRedish = (hsl.hue <= 25 || hsl.hue >= 340) && hsl.saturation >= 0.35;
    if (isRedish) {
      return const Color(0xFF991B1B);
    }
    return const Color(0xFFE11D48);
  }
}
