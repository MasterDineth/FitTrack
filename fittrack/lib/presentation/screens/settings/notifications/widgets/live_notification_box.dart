import 'package:flutter/material.dart';
import '../../../../theme/ft_glass.dart';
import '../../../dashboard/widgets/ft_pressable.dart';

enum WorkoutNotificationMode {
  workout,
  rest,
  done,
}

/// The Android notification drawer box presentation.
class LiveNotificationBox extends StatelessWidget {
  final WorkoutNotificationMode mode;
  final int elapsedSeconds;
  final int restSeconds;
  final int maxRestSeconds;
  final int currentExercise;
  final int totalExercises;
  final int currentSet;
  final int totalSets;
  final bool isPaused;
  final VoidCallback onPauseResume;
  final VoidCallback onCompleteSet;
  final VoidCallback onOpen;
  final ValueChanged<int> onAdjustRest;
  final VoidCallback onSkipRest;
  final VoidCallback onViewSummary;
  final VoidCallback onDismiss;

  const LiveNotificationBox({
    super.key,
    required this.mode,
    required this.elapsedSeconds,
    required this.restSeconds,
    required this.maxRestSeconds,
    required this.currentExercise,
    required this.totalExercises,
    required this.currentSet,
    required this.totalSets,
    required this.isPaused,
    required this.onPauseResume,
    required this.onCompleteSet,
    required this.onOpen,
    required this.onAdjustRest,
    required this.onSkipRest,
    required this.onViewSummary,
    required this.onDismiss,
  });

  String _formatTime(int totalSeconds) {
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = context.ftPrimary;
    final progressPct = ((currentExercise / totalExercises) * 100).round();

    final cardBg = isDark
        ? const Color(0xE61F1A3A)
        : Colors.white.withValues(alpha: 0.88);
    final cardBorder = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.95);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
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
                ),
                child: const Center(
                  child: Icon(
                    Icons.fitness_center_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'FitTrack · Push Day',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.ftMuted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                mode == WorkoutNotificationMode.rest
                    ? _formatTime(restSeconds)
                    : mode == WorkoutNotificationMode.done
                        ? '52:08'
                        : _formatTime(elapsedSeconds),
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: context.ftInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Titles & Subtitles
          if (mode == WorkoutNotificationMode.workout) ...[
            Text(
              '$currentExercise of $totalExercises exercises · $progressPct%',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: context.ftInk,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Bench press · Set $currentSet of $totalSets',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: context.ftMuted,
              ),
            ),
          ] else if (mode == WorkoutNotificationMode.rest) ...[
            Text(
              'Rest · ${_formatTime(restSeconds)} left',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: context.ftInk,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Next: Bench press · Set $currentSet of $totalSets',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: context.ftMuted,
              ),
            ),
          ] else ...[
            Text(
              'Workout complete',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: context.ftInk,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '52 min · 24 sets · 10 exercises',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: context.ftMuted,
              ),
            ),
          ],
          const SizedBox(height: 8),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 8,
              width: double.infinity,
              color: primary.withValues(alpha: 0.12),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: mode == WorkoutNotificationMode.done
                    ? 1.0
                    : (currentExercise / totalExercises).clamp(0.05, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, const Color(0xFFC846AA)],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Rest countdown bar
          if (mode == WorkoutNotificationMode.rest) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Container(
                height: 6,
                width: double.infinity,
                color: FtGlassTheme.teal.withValues(alpha: 0.15),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (restSeconds / maxRestSeconds).clamp(0.0, 1.0),
                  child: Container(color: FtGlassTheme.teal),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              if (mode == WorkoutNotificationMode.workout) ...[
                Expanded(
                  child: _NotifActionButton(
                    label: isPaused ? 'Resume' : 'Pause',
                    onTap: onPauseResume,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _NotifActionButton(
                    label: 'Complete set',
                    isPrimary: true,
                    onTap: onCompleteSet,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _NotifActionButton(
                    label: 'Open',
                    onTap: onOpen,
                  ),
                ),
              ] else if (mode == WorkoutNotificationMode.rest) ...[
                Expanded(
                  child: _NotifActionButton(
                    label: '−15s',
                    onTap: () => onAdjustRest(-15),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _NotifActionButton(
                    label: 'Skip rest',
                    isPrimary: true,
                    onTap: onSkipRest,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _NotifActionButton(
                    label: '+15s',
                    onTap: () => onAdjustRest(15),
                  ),
                ),
              ] else ...[
                Expanded(
                  flex: 2,
                  child: _NotifActionButton(
                    label: 'View summary',
                    isPrimary: true,
                    onTap: onViewSummary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _NotifActionButton(
                    label: 'Dismiss',
                    onTap: onDismiss,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _NotifActionButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _NotifActionButton({
    required this.label,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.ftPrimary;

    return FtPressable(
      onTap: onTap,
      pressedScale: 0.96,
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isPrimary ? primary : primary.withValues(alpha: 0.10),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: FtText.fontFamily,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: isPrimary ? Colors.white : primary,
          ),
        ),
      ),
    );
  }
}
