import 'dart:ui';
import 'package:flutter/material.dart';

import '../../providers/active_workout_provider.dart';
import 'discard_workout_modal.dart';
import 'save_session_modal.dart';

/// Shows the End Workout Early bottom sheet with backdrop blur.
/// The sheet has:
///   - Session stats summary
///   - Disabled "Finish & Save" if session < 2 min OR 0 sets done
///   - Launches modern SaveSessionModal (Stitch ID: b42dc5d85712471eaaf22f1f2cc118e6)
///   - Launches modern DiscardWorkoutModal (Stitch ID: a9255ebb92064a47ab69b52063e5e9f9)
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
    barrierColor: Colors.transparent, // Handled by custom BackdropFilter
    builder: (_) => _EndWorkoutEarlyHost(
      state: state,
      notifier: notifier,
      onFinishAndSave: onFinishAndSave,
      onDiscard: onDiscard,
    ),
  );
}

class _EndWorkoutEarlyHost extends StatelessWidget {
  const _EndWorkoutEarlyHost({
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          // ── Blurred Dimmed Backdrop ──────────────────────────────────────────
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: const Color(0xFF0F172A).withValues(alpha: 0.45),
              ),
            ),
          ),

          // ── Bottom Sheet Card ────────────────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {}, // Prevent taps inside sheet from dismissing
              child: _EndWorkoutEarlySheet(
                state: state,
                notifier: notifier,
                onFinishAndSave: onFinishAndSave,
                onDiscard: onDiscard,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
      constraints: const BoxConstraints(maxWidth: 460),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 36,
            offset: Offset(0, 14),
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
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          const SizedBox(height: 18),

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

          // ── Finish & Save (Launches SaveSessionModal) ─────────────────────
          FilledButton.icon(
            onPressed: _canSave
                ? () {
                    // Close this sheet and present modern SaveSessionModal
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

          // ── Discard (Launches DiscardWorkoutModal) ────────────────────────
          OutlinedButton.icon(
            onPressed: () {
              // Close this sheet and present modern DiscardWorkoutModal
              Navigator.of(context).pop();
              showDiscardWorkoutModal(
                context,
                state: state,
                onDiscard: onDiscard,
              );
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

  Widget _vDivider() => Container(
        width: 1,
        height: 36,
        color: const Color(0xFFe2e8f0),
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
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0f172a),
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94a3b8),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
