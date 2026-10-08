import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/workout_history_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Month navigator row for Workout History (< SEPTEMBER 2026 >, X sessions badge, calendar button).
class HistoryMonthNavigator extends ConsumerWidget {
  const HistoryMonthNavigator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(workoutHistoryProvider);
    final notifier = ref.read(workoutHistoryProvider.notifier);
    final month = historyState.selectedMonth;
    final monthLabel = DateFormat('MMMM yyyy').format(month).toUpperCase();
    final count = historyState.filtered.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: < MONTH YEAR > Pill
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: GlassSurface(
              tier: FtGlassTier.glass2,
              radius: FtGlassTheme.radiusPill,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              shadow: false,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FtPressable(
                    onTap: notifier.prevMonth,
                    pressedScale: 0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        size: 18,
                        color: context.ftMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    monthLabel,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: context.ftInk,
                    ),
                  ),
                  const SizedBox(width: 4),
                  FtPressable(
                    onTap: notifier.nextMonth,
                    pressedScale: 0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: context.ftMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Right: "7 sessions" Badge & Calendar Button
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: context.ftPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                    border: Border.all(
                      color: context.ftPrimary.withValues(alpha: 0.24),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '$count ${count == 1 ? 'session' : 'sessions'}',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: context.ftPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Calendar Icon Picker Button
                FtPressable(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: month,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: context.ftPrimary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      notifier.setSelectedMonth(picked);
                    }
                  },
                  pressedScale: 0.92,
                  child: GlassSurface(
                    tier: FtGlassTier.glass2,
                    radius: 12,
                    width: 36,
                    height: 36,
                    shadow: false,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: context.ftMuted,
                    ),
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
