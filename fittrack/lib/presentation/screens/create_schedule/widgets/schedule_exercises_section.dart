import 'package:flutter/material.dart';
import '../../../theme/ft_glass.dart';
import '../../../providers/schedule_editor_notifier.dart';
import '../../dashboard/widgets/ft_pressable.dart';
import 'schedule_exercise_card.dart';

/// Exercises Section in the Create Schedule screen with header,
/// reorderable list of exercise cards, and reorder hint.
class ScheduleExercisesSection extends StatelessWidget {
  const ScheduleExercisesSection({
    super.key,
    required this.exercises,
    required this.expandedIndex,
    required this.onToggleExpand,
    required this.onAddExerciseTap,
    required this.onRemoveExercise,
    required this.onReorderExercises,
    required this.onUpdateSets,
    required this.onUpdateReps,
    required this.onUpdateWeight,
    required this.onUpdateRest,
  });

  final List<ScheduleExerciseEntry> exercises;
  final int? expandedIndex;
  final ValueChanged<int> onToggleExpand;
  final VoidCallback onAddExerciseTap;
  final ValueChanged<int> onRemoveExercise;
  final void Function(int oldIndex, int newIndex) onReorderExercises;
  final void Function(int index, int sets) onUpdateSets;
  final void Function(int index, int reps) onUpdateReps;
  final void Function(int index, double weight) onUpdateWeight;
  final void Function(int index, int rest) onUpdateRest;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = context.ftPrimary;
    final ink = context.ftInk;
    final muted = context.ftMuted;

    final count = exercises.length;
    final canAddMore = count < 12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Header Row ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'Exercises',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: ink,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isDark
                            ? primary.withValues(alpha: 0.3)
                            : const Color(0xFFE6DEFF),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // "+ Add exercise" Pill Button
              Flexible(
                child: FtPressable(
                  onTap: canAddMore ? onAddExerciseTap : null,
                  pressedScale: 0.95,
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: canAddMore
                          ? (isDark
                              ? const Color(0x22FFFFFF)
                              : Colors.white.withValues(alpha: 0.9))
                          : (isDark
                              ? const Color(0x14FFFFFF)
                              : const Color(0xFFECE4FF)),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: canAddMore
                            ? primary.withValues(alpha: 0.3)
                            : Colors.transparent,
                        width: 1,
                      ),
                      boxShadow: canAddMore
                          ? [
                              BoxShadow(
                                color: primary.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 18,
                          color: canAddMore ? primary : muted,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Add exercise',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: canAddMore ? primary : muted,
                            ),
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
        ),
        const SizedBox(height: 6),

        // ── Empty State Card if no exercises yet ────────────────────────────
        if (exercises.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0x1FFFFFFF)
                  : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? const Color(0x22FFFFFF)
                    : Colors.white.withValues(alpha: 0.85),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fitness_center_rounded,
                    size: 26,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'No exercises added yet',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add at least 3 exercises (up to 12) to build your routine',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: muted,
                  ),
                ),
                const SizedBox(height: 16),
                FtPressable(
                  onTap: onAddExerciseTap,
                  pressedScale: 0.96,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Add exercises',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        else ...[
          // Reorderable list of exercise cards
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: exercises.length,
            buildDefaultDragHandles: false,
            onReorderItem: onReorderExercises,
            itemBuilder: (context, i) {
              final entry = exercises[i];
              final isExp = expandedIndex == i;
              return ScheduleExerciseCard(
                key: ValueKey('${entry.exerciseId}_$i'),
                index: i,
                entry: entry,
                isExpanded: isExp,
                onToggleExpand: () => onToggleExpand(i),
                onRemove: () => onRemoveExercise(i),
                onUpdateSets: (s) => onUpdateSets(i, s),
                onUpdateReps: (r) => onUpdateReps(i, r),
                onUpdateWeight: (w) => onUpdateWeight(i, w),
                onUpdateRest: (sec) => onUpdateRest(i, sec),
              );
            },
          ),

          // Reorder Hint Row
          if (exercises.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swap_vert_rounded,
                    size: 16,
                    color: muted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'DRAG TO REORDER',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
