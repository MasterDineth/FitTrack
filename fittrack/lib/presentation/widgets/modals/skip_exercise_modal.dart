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
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final args = widget.args;
    final notifier = ref.read(activeWorkoutProvider.notifier);
    final setsCompleted = args.currentSetIndex; // 0-based = sets done so far
    final setsRemaining = args.totalSets - setsCompleted;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
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
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Set ${args.currentSetIndex + 1} of ${args.totalSets} in progress',
                        style: TextStyle(
                          color: Colors.amber.shade800,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  'Skip Exercise?',
                  style: TextStyle(
                    color: colorScheme.onSurface,
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
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                Text(
                  'Tap outside or press ✕ to cancel',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),
                Container(
                  width: 128,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
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
          color: Theme.of(context).colorScheme.outlineVariant,
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
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.close,
            size: 16, color: colorScheme.onSurface.withValues(alpha: 0.6)),
      ),
    );
  }
}

class _SkipIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.skip_next,
                  color: Colors.amber, size: 32),
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
                color: Colors.amber,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.surface, width: 2),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
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
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'SKIPPING EXERCISE',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  args.currentExerciseMuscleTag.toUpperCase(),
                  style: TextStyle(
                    color: colorScheme.onErrorContainer,
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
                      style: TextStyle(
                        color: colorScheme.onSurface,
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
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text:
                                '($setsCompleted of ${args.totalSets} completed)',
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
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
                color: colorScheme.outlineVariant,
                margin:
                    const EdgeInsets.symmetric(horizontal: 12),
              ),

              // Right: next up
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'NEXT UP',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (args.nextExerciseName != null)
                      Text(
                        args.nextExerciseName!,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.end,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        'Last Exercise',
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (args.nextExerciseSets != null &&
                        args.nextExerciseReps != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${args.nextExerciseSets} sets × ${args.nextExerciseReps} reps',
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REASON FOR SKIPPING (OPTIONAL)',
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
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
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              reason.icon,
              size: 15,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                reason.label,
                style: TextStyle(
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        // Primary — Keep Exercising
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onKeepExercising,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 0,
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
              backgroundColor: colorScheme.surfaceContainerLow,
              foregroundColor: colorScheme.onSurface,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: colorScheme.outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: Icon(Icons.skip_next, size: 18,
                color: colorScheme.onSurface.withValues(alpha: 0.7)),
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
