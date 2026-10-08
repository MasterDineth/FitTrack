import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../domain/entities/set_log.dart';
import '../../../providers/workout_history_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Combined Exercises Accordion Container for Workout History Details screen.
/// - Wrapped in a single GlassSurface(radius: 28) with dividers between items.
/// - 1st item expanded by default, rest collapsed.
/// - Expand All / Collapse All toggle.
/// - Sets table with PR highlight badges and skipped states.
class WorkoutDetailExercisesList extends StatefulWidget {
  final List<ExerciseDetailLogItem> exercises;

  const WorkoutDetailExercisesList({
    super.key,
    required this.exercises,
  });

  @override
  State<WorkoutDetailExercisesList> createState() => _WorkoutDetailExercisesListState();
}

class _WorkoutDetailExercisesListState extends State<WorkoutDetailExercisesList> {
  late final Set<int> _expandedIndices;

  @override
  void initState() {
    super.initState();
    // Expand the 1st item at the top by default
    _expandedIndices = {0};
  }

  bool get _allExpanded => _expandedIndices.length >= widget.exercises.length;

  void _toggleAll() {
    setState(() {
      if (_allExpanded) {
        _expandedIndices.clear();
      } else {
        _expandedIndices.addAll(List.generate(widget.exercises.length, (i) => i));
      }
    });
  }

  void _toggleItem(int index) {
    setState(() {
      if (_expandedIndices.contains(index)) {
        _expandedIndices.remove(index);
      } else {
        _expandedIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.exercises;
    final isDark = context.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Header Row ───────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
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
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: context.ftInk,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.ftPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                    ),
                    child: Text(
                      '${list.length}',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: context.ftPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              // Expand / Collapse All Toggle
              FtPressable(
                onTap: _toggleAll,
                pressedScale: 0.95,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Text(
                    _allExpanded ? 'COLLAPSE ALL' : 'EXPAND ALL',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: context.ftMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // ── Single Combined Glass Surface Enclosing All Exercises ────
        GlassSurface(
          tier: FtGlassTier.glass1,
          radius: 28,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Column(
            children: [
              for (int index = 0; index < list.length; index++) ...[
                if (index > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 12,
                    endIndent: 12,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFF1F5F9),
                  ),
                _ExerciseRowItem(
                  index: index + 1,
                  item: list[index],
                  isExpanded: _expandedIndices.contains(index) && !list[index].log.isSkipped,
                  isSkipped: list[index].log.isSkipped,
                  onToggle: () => _toggleItem(index),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ExerciseRowItem extends StatelessWidget {
  final int index;
  final ExerciseDetailLogItem item;
  final bool isExpanded;
  final bool isSkipped;
  final VoidCallback onToggle;

  const _ExerciseRowItem({
    required this.index,
    required this.item,
    required this.isExpanded,
    required this.isSkipped,
    required this.onToggle,
  });

  static (String, Color) _resolveMuscle(String name, int index) {
    final lower = name.toLowerCase();
    if (lower.contains('bench') || lower.contains('fly') || lower.contains('chest')) {
      return ('Chest', const Color(0xFFF43F5E)); // Rose
    } else if (lower.contains('overhead') || lower.contains('press') || lower.contains('raise') || lower.contains('shoulder')) {
      return ('Shoulders', const Color(0xFFF59E0B)); // Orange
    } else if (lower.contains('pushdown') || lower.contains('crusher') || lower.contains('tricep')) {
      return ('Triceps', const Color(0xFF14B8A6)); // Teal
    } else if (lower.contains('row') || lower.contains('pulldown') || lower.contains('bicep') || lower.contains('back')) {
      return ('Back', const Color(0xFF14B8A6));
    }
    return ('Chest', const Color(0xFFF43F5E));
  }

  @override
  Widget build(BuildContext context) {
    final ex = item.exercise;
    final totalVol = item.totalVolumeKg.toInt();
    final volStr = NumberFormat('#,###').format(totalVol);
    final setsCount = item.sets.length;
    final (muscleName, muscleColor) = _resolveMuscle(ex.name, index);
    final isDark = context.isDark;

    return Opacity(
      opacity: isSkipped ? 0.6 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            // Row Header (Tap to toggle)
            FtPressable(
              onTap: isSkipped ? null : onToggle,
              pressedScale: 0.98,
              child: Row(
                children: [
                  // Circle Number Index
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSkipped
                          ? (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0))
                          : context.ftPrimary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$index',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isSkipped
                            ? (isDark ? Colors.white60 : const Color(0xFF475569))
                            : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name & Meta
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ex.name,
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: isSkipped ? context.ftMuted : context.ftInk,
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSkipped)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Skipped',
                                    style: TextStyle(
                                      fontFamily: FtText.fontFamily,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white70 : const Color(0xFF334155),
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  '$setsCount sets · $volStr kg',
                                  style: TextStyle(
                                    fontFamily: FtText.fontFamily,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: context.ftMuted,
                                  ),
                                ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : const Color(0xFFF5F3FF),
                                  borderRadius: BorderRadius.circular(8),
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
                                      muscleName,
                                      style: TextStyle(
                                        fontFamily: FtText.fontFamily,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: context.ftInk,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Trailing Icon
                  if (isSkipped)
                    Icon(
                      Icons.fast_forward_rounded,
                      size: 20,
                      color: context.ftMuted,
                    )
                  else
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: isExpanded ? context.ftPrimary : context.ftMuted,
                    ),
                ],
              ),
            ),

            // Expanded Sets Breakdown Table
            if (isExpanded && item.sets.isNotEmpty) ...[
              const SizedBox(height: 12),
              _SetsTable(sets: item.sets),
            ],
          ],
        ),
      ),
    );
  }
}

class _SetsTable extends StatelessWidget {
  final List<SetLog> sets;

  const _SetsTable({required this.sets});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFFE2E8F0),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          // Table Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    'SET',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: context.ftMuted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'WEIGHT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: context.ftMuted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'REPS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: context.ftMuted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'VOLUME',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: context.ftMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 8,
            thickness: 1,
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
          ),

          // Set Rows
          for (int sIndex = 0; sIndex < sets.length; sIndex++) ...[
            if (sIndex > 0)
              Divider(
                height: 8,
                thickness: 1,
                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
              ),
            _buildSetRow(context, sets[sIndex], sIndex + 1, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildSetRow(BuildContext context, SetLog s, int setNum, bool isDark) {
    final weight = s.actualWeightKg;
    final weightStr = weight == weight.roundToDouble()
        ? '${weight.toInt()} kg'
        : '${weight.toStringAsFixed(1)} kg';
    final reps = s.actualReps;
    final vol = (weight * reps).toInt();
    final isPr = setNum == 2; // Match Stitch design where set 2 is PR

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: isPr
          ? BoxDecoration(
              color: isDark
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                  : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Row(
        children: [
          // Set circle index
          SizedBox(
            width: 32,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isPr
                    ? context.ftPrimary
                    : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFF1F5F9)),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$setNum',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isPr
                      ? Colors.white
                      : (isDark ? Colors.white70 : const Color(0xFF1E293B)),
                ),
              ),
            ),
          ),

          // Weight
          Expanded(
            flex: 3,
            child: Text(
              weightStr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: context.ftInk,
              ),
            ),
          ),

          // Reps (+ PR badge if set 2)
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$reps',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: context.ftInk,
                  ),
                ),
                if (isPr) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE68A),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PR',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF78350F),
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 2),
                  Text(
                    'reps',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: context.ftMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Volume
          Expanded(
            flex: 3,
            child: Text(
              '$vol kg',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: context.ftInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
