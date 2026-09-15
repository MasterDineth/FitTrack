import 'package:flutter/material.dart';

import '../../providers/active_workout_provider.dart';

/// Shows the End Workout Early confirmation bottom sheet.
/// The sheet has:
///   - Session stats summary
///   - Disabled "Finish & Save" if session < 2 min OR 0 sets done
///   - Double confirmation dialog before committing
///   - Discard button also requires confirmation
Future<void> showEndWorkoutEarlyModal(
  BuildContext context, {
  required ActiveWorkoutState state,
  required ActiveWorkoutNotifier notifier,
  required Future<void> Function({String? notes, String? intensity})
      onFinishAndSave,
  required VoidCallback onDiscard,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EndWorkoutEarlySheet(
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

  static const Color _mint = Color(0xFF00d68f);
  static const Color _dark = Color(0xFF0f172a);

  bool get _canSave =>
      state.elapsedSeconds >= 120 && state.completedSetCount > 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFe2e8f0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          // Red stop icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFfef2f2),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFfecaca), width: 1.5),
            ),
            child: const Icon(
              Icons.stop_circle_outlined,
              size: 32,
              color: Color(0xFFef4444),
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'End Workout Early?',
            style: TextStyle(
              color: Color(0xFF0f172a),
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
              color: _dark.withValues(alpha: 0.5),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          // ── Stats row ────────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFf8fafc),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFe2e8f0)),
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              children: [
                _QuickStat(
                  label: 'Time',
                  value: state.elapsedFormatted,
                  icon: Icons.timer_outlined,
                  color: const Color(0xFF0d9488),
                ),
                _vDivider(),
                _QuickStat(
                  label: 'Sets',
                  value: '${state.completedSetCount}',
                  icon: Icons.repeat_rounded,
                  color: _mint,
                ),
                _vDivider(),
                _QuickStat(
                  label: 'Exercises',
                  value:
                      '${state.entries.where((e) => state.completedSets.any((s) => s.exerciseId == e.exerciseId)).length}/${state.entries.length}',
                  icon: Icons.fitness_center_rounded,
                  color: const Color(0xFF8b5cf6),
                ),
                _vDivider(),
                _QuickStat(
                  label: 'Calories',
                  value: '${state.estimatedCalories}',
                  icon: Icons.local_fire_department_rounded,
                  color: const Color(0xFFf97316),
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
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.elapsedSeconds < 120
                          ? 'Session too short to save (minimum 2 minutes)'
                          : 'No sets completed — nothing to save',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF92400E),
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
                ? () async {
                    final confirmed = await _showConfirmDialog(
                      context,
                      title: 'Save this session?',
                      message:
                          'Your completed sets will be saved to your history.',
                      confirmLabel: 'Yes, Save It',
                      confirmColor: _mint,
                      confirmTextColor: _dark,
                    );
                    if (confirmed && context.mounted) {
                      Navigator.of(context).pop();
                      await onFinishAndSave();
                    }
                  }
                : null,
            icon: const Icon(Icons.save_alt_rounded, size: 18),
            label: const Text(
              'Finish & Save',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: _mint,
              foregroundColor: _dark,
              disabledBackgroundColor: const Color(0xFFe2e8f0),
              disabledForegroundColor: const Color(0xFF94a3b8),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Discard ──────────────────────────────────────────────────────
          OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await _showConfirmDialog(
                context,
                title: 'Discard workout?',
                message:
                    'All progress will be permanently lost. This cannot be undone.',
                confirmLabel: 'Discard',
                confirmColor: const Color(0xFFef4444),
                confirmTextColor: Colors.white,
              );
              if (confirmed && context.mounted) {
                Navigator.of(context).pop();
                onDiscard();
              }
            },
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text(
              'Discard Workout',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFef4444),
              side: const BorderSide(color: Color(0xFFfecaca)),
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
                color: _dark.withValues(alpha: 0.45),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required Color confirmTextColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: Color(0xFF0f172a),
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF64748b),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF64748b),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: confirmTextColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              confirmLabel,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 36,
        color: const Color(0xFFf1f5f9),
      );
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: Color(0xFF0f172a),
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94a3b8),
            ),
          ),
        ],
      ),
    );
  }
}
