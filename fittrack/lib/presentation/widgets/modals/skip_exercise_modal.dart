import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/active_workout_provider.dart';

// ── Data class passed from the calling screen ─────────────────────────────────

class SkipExerciseArgs {
  const SkipExerciseArgs({
    required this.currentExerciseName,
    required this.currentExerciseMuscleTag,
    required this.currentSetIndex,
    required this.totalSets,
    this.nextExerciseName,
    this.nextExerciseSets,
    this.nextExerciseReps,
  });

  final String currentExerciseName;
  final String currentExerciseMuscleTag;
  final int currentSetIndex;
  final int totalSets;
  final String? nextExerciseName;
  final int? nextExerciseSets;
  final int? nextExerciseReps;
}

// ── Reason options ─────────────────────────────────────────────────────────────

enum _SkipReason {
  equipmentBusy('Equipment Busy', Icons.timer_outlined),
  fatiguedPain('Fatigued / Pain', Icons.bolt_outlined),
  shortOnTime('Short on Time', Icons.hourglass_empty_outlined),
  other('Other Reason', Icons.edit_outlined);

  const _SkipReason(this.label, this.icon);
  final String label;
  final IconData icon;
}

// ── Static helper to open the sheet ──────────────────────────────────────────

Future<void> showSkipExerciseModal(
  BuildContext context, {
  required SkipExerciseArgs args,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    // Transparent so we can paint our own frosted backdrop
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x99000000),
    builder: (_) => SkipExerciseModal(args: args),
  );
}

// ── Modal widget ──────────────────────────────────────────────────────────────

class SkipExerciseModal extends ConsumerStatefulWidget {
  const SkipExerciseModal({super.key, required this.args});
  final SkipExerciseArgs args;

  @override
  ConsumerState<SkipExerciseModal> createState() => _SkipExerciseModalState();
}

class _SkipExerciseModalState extends ConsumerState<SkipExerciseModal> {
  _SkipReason? _selectedReason;

  static const Color _amber = Color(0xFFf59e0b);
  static const Color _amberSoft = Color(0xFFfef3c7);
  static const Color _amberDark = Color(0xFF92400e);

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final notifier = ref.read(activeWorkoutProvider.notifier);
    final setsCompleted = args.currentSetIndex; // 0-based = sets done so far
    final setsRemaining = args.totalSets - setsCompleted;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        // Push sheet above keyboard if needed
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Drag handle ─────────────────────────────────────────
                const _DragHandle(),
                const SizedBox(height: 4),

                // ── Close button ────────────────────────────────────────
                Align(
                  alignment: Alignment.topRight,
                  child: _CloseButton(
                      onTap: () => Navigator.pop(context)),
                ),
                const SizedBox(height: 2),

                // ── Header: icon + status pill + title + subtitle ───────
                _SkipIcon(),
                const SizedBox(height: 10),

                // Status pill
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _amberSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: _amber,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Set ${args.currentSetIndex + 1} of ${args.totalSets} in progress',
                        style: const TextStyle(
                          color: _amberDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Title
                const Text(
                  'Skip Exercise?',
                  style: TextStyle(
                    color: Color(0xFF0f172a),
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle
                Text(
                  'Are you sure you want to skip '
                  '${args.currentExerciseName}? You can return to it before '
                  'finishing your session or proceed directly to '
                  '${args.nextExerciseName ?? 'the next exercise'}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF64748b),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),

                // ── Context card ────────────────────────────────────────
                _ContextCard(
                  args: args,
                  setsRemaining: setsRemaining,
                  setsCompleted: setsCompleted,
                ),
                const SizedBox(height: 14),

                // ── Reason grid ─────────────────────────────────────────
                _ReasonGrid(
                  selected: _selectedReason,
                  onSelect: (r) =>
                      setState(() => _selectedReason = r),
                ),
                const SizedBox(height: 16),

                // ── Action buttons ──────────────────────────────────────
                _ActionButtons(
                  onKeepExercising: () => Navigator.pop(context),
                  onSkip: () {
                    Navigator.pop(context);
                    notifier.skipExercise(
                        reason: _selectedReason?.label);
                  },
                ),
                const SizedBox(height: 6),

                // Footer hint
                const Text(
                  'Tap outside or press ✕ to cancel',
                  style: TextStyle(
                    color: Color(0xFF94a3b8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // iOS home bar spacer
                const SizedBox(height: 8),
                Container(
                  width: 128,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFcbd5e1),
                    borderRadius: BorderRadius.circular(2),
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

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 44,
        height: 5,
        decoration: BoxDecoration(
          color: const Color(0xFFe2e8f0),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFf1f5f9),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close,
            size: 16, color: Color(0xFF94a3b8)),
      ),
    );
  }
}

class _SkipIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFDE68A)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14F59E0B),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.skip_next,
                  color: Color(0xFFf59e0b), size: 32),
            ),
          ),
          // Warning badge
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFFf59e0b),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  size: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({
    required this.args,
    required this.setsRemaining,
    required this.setsCompleted,
  });
  final SkipExerciseArgs args;
  final int setsRemaining;
  final int setsCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFf8fafc),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFe2e8f0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: "SKIPPING EXERCISE" label + muscle badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFf43f5e),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'SKIPPING EXERCISE',
                    style: TextStyle(
                      color: Color(0xFF64748b),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFfff1f2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFfecdd3)),
                ),
                child: Text(
                  args.currentExerciseMuscleTag.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFe11d48),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Two-column split
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: current exercise
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      args.currentExerciseName,
                      style: const TextStyle(
                        color: Color(0xFF0f172a),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12),
                        children: [
                          TextSpan(
                            text: '$setsRemaining sets remaining ',
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text:
                                '($setsCompleted of ${args.totalSets} completed)',
                            style: const TextStyle(
                              color: Color(0xFF94a3b8),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Vertical divider
              Container(
                width: 1,
                height: 56,
                color: const Color(0xFFe2e8f0),
                margin:
                    const EdgeInsets.symmetric(horizontal: 12),
              ),

              // Right: next up
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'NEXT UP',
                      style: TextStyle(
                        color: Color(0xFF94a3b8),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (args.nextExerciseName != null)
                      Text(
                        args.nextExerciseName!,
                        style: const TextStyle(
                          color: Color(0xFF064E3B),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.end,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      const Text(
                        'Last Exercise',
                        style: TextStyle(
                          color: Color(0xFF94a3b8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (args.nextExerciseSets != null &&
                        args.nextExerciseReps != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${args.nextExerciseSets} sets × ${args.nextExerciseReps} reps',
                        style: const TextStyle(
                          color: Color(0xFF94a3b8),
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReasonGrid extends StatelessWidget {
  const _ReasonGrid({required this.selected, required this.onSelect});
  final _SkipReason? selected;
  final ValueChanged<_SkipReason> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'REASON FOR SKIPPING (OPTIONAL)',
          style: TextStyle(
            color: Color(0xFF94a3b8),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 3.2,
          children: _SkipReason.values
              .map((r) => _ReasonPill(
                    reason: r,
                    isSelected: selected == r,
                    onTap: () => onSelect(r),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _ReasonPill extends StatelessWidget {
  const _ReasonPill({
    required this.reason,
    required this.isSelected,
    required this.onTap,
  });
  final _SkipReason reason;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFe6faf3)
              : const Color(0xFFf8fafc),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00d68f)
                : const Color(0xFFe2e8f0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              reason.icon,
              size: 15,
              color: isSelected
                  ? const Color(0xFF00875a)
                  : const Color(0xFF94a3b8),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                reason.label,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF065f46)
                      : const Color(0xFF475569),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.onKeepExercising,
    required this.onSkip,
  });
  final VoidCallback onKeepExercising;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary — Keep Exercising
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onKeepExercising,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00d68f),
              foregroundColor: const Color(0xFF0f172a),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 0,
              shadowColor: const Color(0x5000d68f),
            ),
            icon: const Icon(Icons.play_circle_fill, size: 18),
            label: const Text(
              'Keep Exercising',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Secondary — Skip & Next
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onSkip,
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFFf8fafc),
              foregroundColor: const Color(0xFF334155),
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFFe2e8f0)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.skip_next, size: 18,
                color: Color(0xFF64748b)),
            label: const Text(
              'Skip & Next Exercise',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
