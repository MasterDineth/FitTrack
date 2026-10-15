import 'package:flutter/material.dart';

import 'package:fittrack/domain/entities/schedule_exercise.dart';
import '../../../theme/ft_glass.dart';

/// Single exercise row with expandable animated set breakdown and draggable number marker.
///
/// Features:
/// - Holding and dragging directly from the number icon to reorder (no extra 3 dots or drag handles).
/// - Buttery smooth AnimatedSize expansion and collapse.
/// - Full dark-mode adaptive theme tokens.
class WorkoutDetailExerciseRow extends StatelessWidget {
  const WorkoutDetailExerciseRow({
    super.key,
    required this.exercise,
    required this.index,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onReorder,
    required this.onReorderDone,
  });

  final ScheduleExercise exercise;
  final int index;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final void Function(int oldIndex, int newIndex) onReorder;
  final VoidCallback onReorderDone;

  @override
  Widget build(BuildContext context) {
    final name = _resolveName(exercise.exerciseId);
    final muscle = _resolveMuscle(exercise.exerciseId);
    final muscleColor = _resolveMuscleColor(muscle);

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != index,
      onAcceptWithDetails: (details) {
        if (details.data != index) {
          onReorder(details.data, index);
          onReorderDone();
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isTargetHovered = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isTargetHovered
                ? context.ftPrimary.withValues(alpha: 0.08)
                : Colors.transparent,
          ),
          child: Column(
            children: [
              InkWell(
                onTap: onToggleExpanded,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      // Draggable Number Marker (Hold and drag directly from here)
                      LongPressDraggable<int>(
                        data: index,
                        delay: const Duration(milliseconds: 150),
                        hapticFeedbackOnStart: true,
                        feedback: Material(
                          color: Colors.transparent,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: context.ftPrimary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: context.ftPrimary.withValues(alpha: 0.5),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.25,
                          child: _buildNumberBadge(context, index + 1),
                        ),
                        child: _buildNumberBadge(context, index + 1),
                      ),
                      const SizedBox(width: 12),

                      // Exercise Thumbnail
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: context.isDark
                                ? Colors.white.withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.9),
                            width: 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/images/dashboard/hero_workout.webp',
                          fit: BoxFit.cover,
                          cacheWidth: 96,
                          cacheHeight: 96,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Exercise Name & Muscle Category
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: context.ftPrimary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: context.ftPrimary.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'EXERCISE ${index + 1}',
                                    style: TextStyle(
                                      fontFamily: FtText.fontFamily,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                      color: context.ftPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              name,
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                color: context.ftInk,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: context.isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.white.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: context.isDark
                                          ? Colors.white.withValues(alpha: 0.10)
                                          : Colors.white,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: muscleColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        muscle,
                                        style: TextStyle(
                                          fontFamily: FtText.fontFamily,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: context.ftInk,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    '${exercise.targetSets} sets × ${exercise.targetReps} reps · ${exercise.targetWeightKg.toInt()} kg',
                                    style: TextStyle(
                                      fontFamily: FtText.fontFamily,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: context.ftMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Chevron Indicator
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeInOutCubic,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 22,
                          color: context.ftMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Animated Expandable Set Breakdown Table
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOutCubic,
                alignment: Alignment.topCenter,
                child: isExpanded
                    ? Container(
                        margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.white.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: context.isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.9),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Table Headers (no Tempo/RPE per user spec)
                            Row(
                              children: [
                                _tableHeaderCell(context, 'SET', flex: 1, align: TextAlign.left),
                                _tableHeaderCell(context, 'WEIGHT', flex: 2, align: TextAlign.center),
                                _tableHeaderCell(context, 'REPS', flex: 2, align: TextAlign.center),
                                _tableHeaderCell(context, 'REST', flex: 2, align: TextAlign.right),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: context.isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.06),
                            ),
                            const SizedBox(height: 6),

                            // Sets Rows
                            for (int s = 1; s <= exercise.targetSets; s++)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        '$s',
                                        style: TextStyle(
                                          fontFamily: FtText.fontFamily,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800,
                                          color: context.ftPrimary,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${exercise.targetWeightKg.toInt()} kg',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: FtText.fontFamily,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800,
                                          color: context.ftInk,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${exercise.targetReps}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: FtText.fontFamily,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800,
                                          color: context.ftInk,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${exercise.restDurationSeconds}s',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontFamily: FtText.fontFamily,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: context.ftMuted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNumberBadge(BuildContext context, int number) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: context.isDark
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.85),
        shape: BoxShape.circle,
        border: Border.all(
          color: context.isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: TextStyle(
          fontFamily: FtText.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: context.ftPrimary,
        ),
      ),
    );
  }

  Widget _tableHeaderCell(BuildContext context, String text, {required int flex, required TextAlign align}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontFamily: FtText.fontFamily,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: context.ftMuted,
        ),
      ),
    );
  }

  String _resolveName(String exerciseId) {
    if (exerciseId == 'e1') return 'Barbell Bench Press';
    if (exerciseId == 'e2') return 'Incline Dumbbell Press';
    if (exerciseId.startsWith('ex_')) {
      final raw = exerciseId.substring(3).replaceAll('_', ' ');
      return raw.split(' ').map((w) {
        if (w.isEmpty) return '';
        return '${w[0].toUpperCase()}${w.substring(1)}';
      }).join(' ');
    }
    return exerciseId;
  }

  String _resolveMuscle(String exerciseId) {
    final lower = exerciseId.toLowerCase();
    if (lower.contains('bench') || lower.contains('chest') || lower.contains('fly')) {
      return 'Chest';
    }
    if (lower.contains('overhead') || lower.contains('press') || lower.contains('lateral') || lower.contains('shoulder')) {
      return 'Shoulders';
    }
    if (lower.contains('tricep') || lower.contains('extension')) {
      return 'Triceps';
    }
    if (lower.contains('pull') || lower.contains('row') || lower.contains('lat') || lower.contains('back')) {
      return 'Back';
    }
    if (lower.contains('squat') || lower.contains('leg') || lower.contains('deadlift')) {
      return 'Legs';
    }
    return 'Full Body';
  }

  Color _resolveMuscleColor(String muscle) {
    switch (muscle.toLowerCase()) {
      case 'chest':
        return const Color(0xFFF43F5E);
      case 'shoulders':
        return const Color(0xFFF59E0B);
      case 'triceps':
        return const Color(0xFF14B8A6);
      case 'back':
        return const Color(0xFF3B82F6);
      case 'legs':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF10B981);
    }
  }
}
