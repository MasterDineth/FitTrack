import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fittrack/domain/entities/schedule_exercise.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../dashboard/widgets/ft_pressable.dart';
import 'workout_detail_exercise_row.dart';

/// Exercises list for Workout Details matching Stitch Screen `fc32d4d5a15441178564c24cb5dad0f4`.
///
/// Features:
/// - Exercises count badge in section header.
/// - Exercises reorderable by holding and dragging directly from the number icon (no extra 3 dots or handles).
/// - Buttery smooth AnimatedSize expansion and collapse for exercise set details.
/// - Bottom "+ Add an exercise" action button.
/// - Strict adherence to AGENTS.md clean architecture and <400 line modular rule.
class WorkoutDetailExercises extends StatefulWidget {
  const WorkoutDetailExercises({
    super.key,
    required this.exercises,
    required this.onAddExerciseTap,
    this.onRemoveExercise,
    this.onReorderExercises,
  });

  final List<ScheduleExercise> exercises;
  final VoidCallback onAddExerciseTap;
  final void Function(int index)? onRemoveExercise;
  final void Function(int oldIndex, int newIndex)? onReorderExercises;

  @override
  State<WorkoutDetailExercises> createState() => _WorkoutDetailExercisesState();
}

class _WorkoutDetailExercisesState extends State<WorkoutDetailExercises> {
  late List<ScheduleExercise> _exercises;
  final Set<String> _expandedIds = {};

  @override
  void initState() {
    super.initState();
    _exercises = List.from(widget.exercises);
    if (_exercises.isNotEmpty) {
      _expandedIds.add(_exercises.first.id);
    }
  }

  @override
  void didUpdateWidget(covariant WorkoutDetailExercises oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.exercises != oldWidget.exercises) {
      _exercises = List.from(widget.exercises);
    }
  }

  void _toggleExpanded(String id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex == newIndex || oldIndex >= _exercises.length || newIndex >= _exercises.length) {
      return;
    }
    setState(() {
      final item = _exercises.removeAt(oldIndex);
      _exercises.insert(newIndex, item);
    });
    widget.onReorderExercises?.call(oldIndex, newIndex);
    HapticFeedback.selectionClick();
  }

  void _onReorderDone() {
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Header ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Exercises',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: context.ftInk,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? Colors.white.withValues(alpha: 0.10)
                          : Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.white,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${_exercises.length}',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: context.ftMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Hold # to reorder',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: context.ftMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ── Exercises Combined Container ────────────────────────────────────
        GlassSurface(
          tier: FtGlassTier.glass1,
          radius: 26,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < _exercises.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: context.isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                WorkoutDetailExerciseRow(
                  key: ValueKey(_exercises[i].id),
                  exercise: _exercises[i],
                  index: i,
                  isExpanded: _expandedIds.contains(_exercises[i].id),
                  onToggleExpanded: () => _toggleExpanded(_exercises[i].id),
                  onReorder: _onReorder,
                  onReorderDone: _onReorderDone,
                  onRemove: widget.onRemoveExercise != null
                      ? () => widget.onRemoveExercise!(i)
                      : null,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Add Exercise Action Button ──────────────────────────────────────
        FtPressable(
          onTap: widget.onAddExerciseTap,
          pressedScale: 0.98,
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: context.isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: context.ftPrimary.withValues(alpha: 0.45),
                style: BorderStyle.solid,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_rounded,
                  size: 20,
                  color: context.ftPrimary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Add an exercise',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: context.ftPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
