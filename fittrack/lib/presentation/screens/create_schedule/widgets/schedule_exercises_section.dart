import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/ft_glass.dart';
import '../../../providers/schedule_editor_notifier.dart';
import '../../dashboard/widgets/ft_pressable.dart';
import 'schedule_exercise_card.dart';

/// Exercises Section in the Create Schedule screen with header,
/// reorderable list of exercise cards, drag confinement, and swipe-to-discard.
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

  Widget _buildDismissBackground({required bool alignLeft}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFBA1A1A),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33BA1A1A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.delete_rounded,
            color: Colors.white,
            size: 26,
          ),
          SizedBox(width: 8),
          Text(
            'Discard',
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 10, animValue)!;
        return Material(
          elevation: elevation,
          color: Colors.transparent,
          shadowColor: const Color(0x335F3BDC),
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: child,
        );
      },
      child: child,
    );
  }

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
          ReorderableListView.builder(
            proxyDecorator: _proxyDecorator,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: exercises.length,
            buildDefaultDragHandles: false,
            onReorderItem: onReorderExercises,
            itemBuilder: (context, i) {
              final entry = exercises[i];
              final isExp = expandedIndex == i;
              return Dismissible(
                key: ValueKey('dismiss_${entry.exerciseId}_$i'),
                direction: DismissDirection.horizontal,
                onUpdate: (details) {
                  if (details.reached) {
                    HapticFeedback.mediumImpact();
                  }
                },
                confirmDismiss: (direction) async {
                  HapticFeedback.heavyImpact();
                  return true;
                },
                onDismissed: (_) {
                  onRemoveExercise(i);
                },
                background: _buildDismissBackground(alignLeft: true),
                secondaryBackground: _buildDismissBackground(alignLeft: false),
                child: ScheduleExerciseCard(
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
                ),
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
