import 'package:flutter/material.dart';

import '../../providers/active_workout_provider.dart';
import 'discard_workout_modal.dart';
import 'modal_backdrop_helper.dart';
import 'save_session_modal.dart';

/// Shows the End Workout Early bottom sheet with backdrop blur.
Future<void> showEndWorkoutEarlyModal(
  BuildContext context, {
  required ActiveWorkoutState state,
  required ActiveWorkoutNotifier notifier,
  required Future<void> Function({String? notes, String? intensity})
      onFinishAndSave,
  required VoidCallback onDiscard,
}) async {
  await showBlurBottomSheet<void>(
    context: context,
    child: _EndWorkoutEarlySheet(
      state: state,
      notifier: notifier,
      onFinishAndSave: onFinishAndSave,
      onDiscard: onDiscard,
    ),
  );
}

class _EndWorkoutEarlySheet extends StatelessWidget {
  const _EndWorkoutEarlySheet({
    required this.state,
    required this.notifier,
    required this.onFinishAndSave,
    required this.onDiscard,
  });

  final ActiveWorkoutState state;
  final ActiveWorkoutNotifier notifier;
  final Future<void> Function({String? notes, String? intensity})
      onFinishAndSave;
  final VoidCallback onDiscard;

  bool get _canSave =>
      state.elapsedSeconds >= 120 && state.completedSetCount > 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 460),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 36,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          const SizedBox(height: 18),

          // Red stop icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.error.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.stop_circle_outlined,
              size: 32,
              color: colorScheme.onErrorContainer,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'End Workout Early?',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Save your progress so far or discard the session.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          // ── Stats row ────────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              children: [
                _QuickStat(
                  label: 'Time',
                  value: state.elapsedFormatted,
                  icon: Icons.timer_outlined,
                  color: colorScheme.primary,
                ),
                _vDivider(colorScheme.outlineVariant),
                _QuickStat(
                  label: 'Sets',
                  value: '${state.completedSetCount}',
                  icon: Icons.repeat_rounded,
                  color: colorScheme.primary,
                ),
                _vDivider(colorScheme.outlineVariant),
                _QuickStat(
                  label: 'Exercises',
                  value:
                      '${state.entries.where((e) => state.completedSets.any((s) => s.exerciseId == e.exerciseId)).length}/${state.entries.length}',
                  icon: Icons.fitness_center_rounded,
                  color: Colors.purple,
                ),
                _vDivider(colorScheme.outlineVariant),
                _QuickStat(
                  label: 'Calories',
                  value: '${state.estimatedCalories}',
                  icon: Icons.local_fire_department_rounded,
                  color: Colors.orange,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Validation warning
          if (!_canSave) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.elapsedSeconds < 120
                          ? 'Session too short to save (minimum 2 minutes)'
                          : 'No sets completed — nothing to save',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // ── Finish & Save ────────────────────────────────────────────────
          FilledButton.icon(
            onPressed: _canSave
                ? () {
                    Navigator.of(context).pop();
                    showSaveSessionModal(
                      context,
                      state: state,
                      onSave: () async {
                        await onFinishAndSave();
                      },
                    );
                  }
                : null,
            icon: Icon(Icons.save_alt_rounded, size: 18, color: _canSave ? colorScheme.onPrimary : null),
            label: Text(
              'Finish & Save',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: _canSave ? colorScheme.onPrimary : null,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              disabledBackgroundColor: colorScheme.surfaceContainerHighest,
              disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Discard ──────────────────────────────────────────────────────
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              showDiscardWorkoutModal(
                context,
                state: state,
                onDiscard: onDiscard,
              );
            },
            icon: Icon(Icons.delete_outline_rounded, size: 18, color: colorScheme.error),
            label: Text(
              'Discard Workout',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: colorScheme.error),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error.withValues(alpha: 0.3)),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 6),

          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Keep Training',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vDivider(Color color) => Container(
        width: 1,
        height: 36,
        color: color,
      );
}

// ── Quick stat widget ─────────────────────────────────────────────────────────

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
