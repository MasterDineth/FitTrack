import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../providers/active_workout_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../dashboard/widgets/ft_pressable.dart';

class ActiveSessionDock extends StatefulWidget {
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
  State<ActiveSessionDock> createState() => _ActiveSessionDockState();
}

class _ActiveSessionDockState extends State<ActiveSessionDock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completedSets = widget.state.completedSets.length;
    final totalSets =
        widget.state.totalSetCount > 0 ? widget.state.totalSetCount : 21;
    final calories =
        widget.state.estimatedCalories > 0 ? widget.state.estimatedCalories : 14;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 6, 16, widget.bottomOffset + 12),
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
                        widget.state.formattedElapsed,
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
                // Animated Pause Session Button
                Expanded(
                  child: FtPressable(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      widget.onPauseTap();
                    },
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(
                                    alpha: 0.14 + (0.12 * _pulseController.value),
                                  ),
                                ),
                                child: child,
                              );
                            },
                            child: const Icon(
                              Icons.pause_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 7),
                          const Flexible(
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

                // End Workout Destructive Button
                Expanded(
                  child: FtPressable(
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      widget.onEndTap();
                    },
                    pressedScale: 0.95,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: _resolveDestructiveColor(context),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _resolveDestructiveColor(context)
                                .withValues(alpha: 0.30),
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
    final isRedish =
        (hsl.hue <= 25 || hsl.hue >= 340) && hsl.saturation >= 0.35;
    if (isRedish) {
      return const Color(0xFF991B1B);
    }
    return const Color(0xFFE11D48);
  }
}
