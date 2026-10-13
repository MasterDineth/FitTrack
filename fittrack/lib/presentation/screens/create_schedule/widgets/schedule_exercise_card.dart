import 'package:flutter/material.dart';
import '../../../providers/theme_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../../providers/schedule_editor_notifier.dart';
import '../../dashboard/widgets/ft_pressable.dart';
import 'schedule_stepper_tile.dart';
import 'schedule_weight_dialog.dart';

/// Single Exercise Editor Card in the Create Schedule screen.
/// Matching Stitch Screen ID 378f56a0b632436289e53841eb67b6fb.
class ScheduleExerciseCard extends StatelessWidget {
  const ScheduleExerciseCard({
    super.key,
    required this.index,
    required this.entry,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onRemove,
    required this.onUpdateSets,
    required this.onUpdateReps,
    required this.onUpdateWeight,
    required this.onUpdateRest,
    this.settings,
  });

  final int index;
  final ScheduleExerciseEntry entry;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onRemove;
  final ValueChanged<int> onUpdateSets;
  final ValueChanged<int> onUpdateReps;
  final ValueChanged<double> onUpdateWeight;
  final ValueChanged<int> onUpdateRest;
  final ThemeSettings? settings;

  String _formatWeight(double weight) {
    if (weight % 1 == 0) {
      return weight.toInt().toString();
    }
    return weight.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = context.ftPrimary;
    final ink = context.ftInk;
    final muted = context.ftMuted;

    final durationMins = entry.estimatedDurationMinutes;
    final subtitle = isExpanded
        ? '${entry.equipment} · ${entry.movementType} · ~$durationMins min'
        : '${entry.targetSets} sets × ${entry.targetReps} reps · ${_formatWeight(entry.targetWeightKg)} kg · ~$durationMins min';

    final settings = this.settings ?? FtGlassTheme.resolveThemeSettings(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: FtGlassTheme.cardDecoration(
        context,
        radius: 24,
        settings: settings,
        customShadows: [
          BoxShadow(
            color: primary.withValues(alpha: isDark ? 0.12 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header (6-dots drag indicator, number pill, title, chevron) ──
          Row(
            children: [
              // 6 dots drag indicator
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    size: 22,
                    color: isDark ? const Color(0x66FFFFFF) : const Color(0xFFCAC4D7),
                  ),
                ),
              ),

              // Number Badge Pill (1, 2...)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isExpanded
                      ? primary
                      : (isDark ? const Color(0x22FFFFFF) : const Color(0xFFE7DEFF)),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isExpanded
                        ? Colors.white
                        : (isDark ? Colors.white : const Color(0xFF5F3BDC)),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Title & Subtitle summary
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.exerciseName,
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Expand / Collapse Chevron Button (animated rotation)
              FtPressable(
                onTap: onToggleExpand,
                pressedScale: 0.90,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0x1FFFFFFF)
                        : const Color(0xFFF2EBFF),
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeInOutCubic,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: ink,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Animated Expanded Content (2x2 Steppers Grid + Footer) ────────
          ClipRect(
            child: AnimatedCrossFade(
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 260),
              firstCurve: Curves.easeInOutCubic,
              secondCurve: Curves.easeInOutCubic,
              sizeCurve: Curves.easeInOutCubic,
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Column(
                children: [
            const SizedBox(height: 14),
            Row(
              children: [
                // SETS Stepper
                Expanded(
                  child: ScheduleStepperTile(
                    label: 'SETS',
                    settings: settings,
                    valueWidget: Text(
                      '${entry.targetSets}',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    onMinus: () => onUpdateSets(entry.targetSets - 1),
                    onPlus: () => onUpdateSets(entry.targetSets + 1),
                  ),
                ),
                const SizedBox(width: 8),

                // REPS Stepper
                Expanded(
                  child: ScheduleStepperTile(
                    label: 'REPS',
                    settings: settings,
                    valueWidget: Text(
                      '${entry.targetReps}',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    onMinus: () => onUpdateReps(entry.targetReps - 1),
                    onPlus: () => onUpdateReps(entry.targetReps + 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // WEIGHT Stepper (incremented by 2.5 KG, editable via pen)
                Expanded(
                  child: ScheduleStepperTile(
                    label: 'WEIGHT (KG)',
                    caption: '0 = bodyweight',
                    settings: settings,
                    valueWidget: FtPressable(
                      onTap: () => showScheduleWeightDialog(
                        context: context,
                        currentWeight: entry.targetWeightKg,
                        onWeightSet: onUpdateWeight,
                      ),
                      pressedScale: 0.95,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatWeight(entry.targetWeightKg),
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: ink,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: primary,
                          ),
                        ],
                      ),
                    ),
                    onMinus: () =>
                        onUpdateWeight((entry.targetWeightKg - 2.5).clamp(0.0, 500.0)),
                    onPlus: () => onUpdateWeight(entry.targetWeightKg + 2.5),
                  ),
                ),
                const SizedBox(width: 8),

                // REST Stepper (incremented by -/+ 15s)
                Expanded(
                  child: ScheduleStepperTile(
                    label: 'REST BETWEEN SETS',
                    caption: 'Recovery timer',
                    settings: settings,
                    valueWidget: Text(
                      entry.formattedRestTime,
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    onMinus: () =>
                        onUpdateRest((entry.restDurationSeconds - 15).clamp(0, 600)),
                    onPlus: () =>
                        onUpdateRest((entry.restDurationSeconds + 15).clamp(0, 600)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Card Footer: Est. duration + Remove button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0x14FFFFFF)
                    : const Color(0x40F7F1FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 15,
                        color: muted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Est. ~$durationMins min',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                  FtPressable(
                    onTap: onRemove,
                    pressedScale: 0.94,
                    child: const Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                          color: Color(0xFFF43F5E),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Remove',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFF43F5E),
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
    ),
  ],
),
);
  }
}
