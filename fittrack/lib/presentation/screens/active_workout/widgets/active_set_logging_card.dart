import 'package:flutter/material.dart';

import '../../../providers/active_workout_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Active Set Logging Card matching Stitch Screen `7e785328b1f24951adf11ae52e15b460`.
///
/// Features:
/// - Exercise hero cover image with Compound & Equipment badges, guide button, and title.
/// - Current set tracker row with target reps badge.
/// - Weight & Reps stepper controls (-/+ 2.5kg, -/+ 1 rep).
/// - Auto rest duration info row.
/// - Primary "Complete set" gradient CTA button.
/// - Sub-action "Skip exercise" button.
class ActiveSetLoggingCard extends StatelessWidget {
  const ActiveSetLoggingCard({
    super.key,
    required this.entry,
    required this.currentSetNumber,
    required this.totalSets,
    required this.onWeightAdjust,
    required this.onRepsAdjust,
    required this.onCompleteSet,
    required this.onSkipExercise,
  });

  final LiveExerciseEntry entry;
  final int currentSetNumber;
  final int totalSets;
  final ValueChanged<double> onWeightAdjust;
  final ValueChanged<int> onRepsAdjust;
  final VoidCallback onCompleteSet;
  final VoidCallback onSkipExercise;

  @override
  Widget build(BuildContext context) {
    final weight = entry.weightForSet(currentSetNumber - 1);
    final weightStr = weight % 1 == 0 ? weight.toInt().toString() : weight.toStringAsFixed(1);
    final reps = entry.repsForSet(currentSetNumber - 1);
    final autoRestM = entry.restDurationSeconds ~/ 60;
    final autoRestS = entry.restDurationSeconds % 60;
    final restFormatted =
        '${autoRestM.toString().padLeft(2, '0')}:${autoRestS.toString().padLeft(2, '0')}';

    return GlassSurface(
      tier: FtGlassTier.glass1,
      radius: 28,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. Exercise Hero Cover & Badges ─────────────────────────────
          Container(
            height: 145,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.85),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/dashboard/hero_workout.webp',
                    fit: BoxFit.cover,
                    cacheWidth: 800,
                  ),

                  // Ambient Gradient Scrims
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.80),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),

                  // Top badges
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Wrap(
                          spacing: 6,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                              decoration: BoxDecoration(
                                color: context.isDark
                                    ? Colors.black.withValues(alpha: 0.65)
                                    : Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                entry.exercise.movementClassification.name.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: FtText.fontFamily,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  color: context.isDark ? Colors.white : context.ftInk,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                              decoration: BoxDecoration(
                                color: context.isDark
                                    ? Colors.black.withValues(alpha: 0.65)
                                    : Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                entry.exercise.equipment.name.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: FtText.fontFamily,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  color: context.isDark ? Colors.white : context.ftInk,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Tutorial / Guide Info button
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: context.isDark
                                ? Colors.black.withValues(alpha: 0.65)
                                : Colors.white.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: context.isDark ? Colors.white : context.ftInk,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Exercise Name on Hero bottom
                  Positioned(
                    bottom: 10,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'ACTIVE EXERCISE',
                                style: TextStyle(
                                  fontFamily: FtText.fontFamily,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                              Text(
                                entry.name,
                                style: const TextStyle(
                                  fontFamily: FtText.fontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Chest · Triceps',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── 2. Current Set Subheader Row ─────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT SET',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: context.ftMuted,
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        text: 'Set $currentSetNumber ',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: context.ftInk,
                        ),
                        children: [
                          TextSpan(
                            text: 'of $totalSets',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.ftMuted,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.ftPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.ftPrimary.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  'Target: ${entry.targetReps} reps',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: context.ftPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── 3. Weight & Reps Stepper Zone ────────────────────────────────
          Row(
            children: [
              // Weight Tile
              Expanded(
                child: _buildStepperTile(
                  context: context,
                  label: 'Weight (kg)',
                  value: weightStr,
                  subtitle: 'Last time 85 kg',
                  onMinus: () => onWeightAdjust(-2.5),
                  onPlus: () => onWeightAdjust(2.5),
                ),
              ),
              const SizedBox(width: 10),

              // Reps Tile
              Expanded(
                child: _buildStepperTile(
                  context: context,
                  label: 'Reps',
                  value: '$reps',
                  subtitle: 'Target: ${entry.targetReps} reps',
                  onMinus: () => onRepsAdjust(-1),
                  onPlus: () => onRepsAdjust(1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── 4. Auto Rest Preset Info Row ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 15,
                        color: context.ftPrimary,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Auto rest: $restFormatted after set',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: context.ftMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Edit',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: context.ftPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── 5. Primary Action CTA: Complete Set ──────────────────────────
          FtPressable(
            onTap: onCompleteSet,
            pressedScale: 0.98,
            child: Container(
              height: 52,
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
                    color: const Color(0xFF5F3BDC).withValues(alpha: 0.40),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Complete set',
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

          // ── 6. Sub-Action: Skip Exercise ─────────────────────────────────
          Center(
            child: FtPressable(
              onTap: onSkipExercise,
              pressedScale: 0.95,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.skip_next_rounded,
                      size: 16,
                      color: context.ftMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Skip exercise',
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

  Widget _buildStepperTile({
    required BuildContext context,
    required String label,
    required String value,
    required String subtitle,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: context.ftMuted,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FtPressable(
                onTap: onMinus,
                pressedScale: 0.88,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.white,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.remove_rounded,
                    size: 18,
                    color: context.ftInk,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: context.ftInk,
                ),
              ),
              FtPressable(
                onTap: onPlus,
                pressedScale: 0.88,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.white,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: context.ftInk,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: context.ftMuted,
            ),
          ),
        ],
      ),
    );
  }
}
