import 'package:flutter/material.dart';
import '../../../domain/entities/live_workout_snapshot.dart';
import '../../theme/ft_glass.dart';
import '../glass_surface.dart';
import '../../screens/dashboard/widgets/ft_pressable.dart';
import 'modal_backdrop_helper.dart';

/// Shows the "Resume your workout?" recovery dialog when a snapshot younger than
/// 12 hours is found on cold restart (see §2.3 of the spec).
Future<void> showResumeWorkoutRecoveryModal(
  BuildContext context, {
  required LiveWorkoutSnapshot snapshot,
  required VoidCallback onResume,
  required VoidCallback onDiscard,
}) async {
  await showBlurModal<void>(
    context: context,
    barrierDismissible: false,
    child: _ResumeWorkoutRecoveryCard(
      snapshot: snapshot,
      onResume: onResume,
      onDiscard: onDiscard,
    ),
  );
}

class _ResumeWorkoutRecoveryCard extends StatelessWidget {
  const _ResumeWorkoutRecoveryCard({
    required this.snapshot,
    required this.onResume,
    required this.onDiscard,
  });

  final LiveWorkoutSnapshot snapshot;
  final VoidCallback onResume;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = context.ftPrimary;
    final elapsedMinutes = snapshot.elapsedSecondsAt(DateTime.now()) ~/ 60;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: GlassSurface(
          tier: FtGlassTier.glassFloating,
          radius: 28,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: isDark
                  ? Colors.black.withValues(alpha: 0.40)
                  : Colors.white.withValues(alpha: 0.70),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Hero Icon Badge
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          primary.withValues(alpha: 0.25),
                          primary.withValues(alpha: 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: primary.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.fitness_center_rounded,
                        size: 28,
                        color: primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Titles
                Text(
                  'Resume your workout?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: context.ftInk,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'You have an active session from earlier that was saved automatically.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: context.ftMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Snapshot summary card
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.white.withValues(alpha: 0.55),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.10)
                          : Colors.white.withValues(alpha: 0.80),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              snapshot.scheduleName.isNotEmpty
                                  ? snapshot.scheduleName
                                  : 'Workout session',
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: context.ftInk,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              snapshot.progressPercent,
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: snapshot.progressFraction.clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: primary.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(primary),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: context.ftMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$elapsedMinutes min elapsed',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 12,
                              color: context.ftMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Icon(
                            Icons.repeat_rounded,
                            size: 14,
                            color: context.ftMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${snapshot.finishedExercises} of ${snapshot.totalExercises} exercises done',
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 12,
                                color: context.ftMuted,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (snapshot.exerciseName.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Current: ${snapshot.exerciseName} · Set ${snapshot.setNumber} of ${snapshot.totalSets}',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.ftInk,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Action Buttons
                // Resume CTA
                FtPressable(
                  onTap: () {
                    Navigator.of(context).pop();
                    onResume();
                  },
                  pressedScale: 0.98,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                        colors: [
                          HSLColor.fromColor(primary)
                              .withLightness((HSLColor.fromColor(primary).lightness + 0.12).clamp(0.0, 1.0))
                              .toColor(),
                          primary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.35),
                          blurRadius: 18,
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
                        SizedBox(width: 8),
                        Text(
                          'Resume Workout',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Discard Button
                FtPressable(
                  onTap: () {
                    Navigator.of(context).pop();
                    onDiscard();
                  },
                  pressedScale: 0.98,
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    child: Text(
                      'Discard Workout',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: FtGlassTheme.rose,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
