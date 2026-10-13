import 'package:flutter/material.dart';
import '../../../theme/ft_glass.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Weekly Schedule Section Card with 7 Weekday Tiles (Mon-Sun), up to 3 days max.
/// Matching Stitch Screen ID 378f56a0b632436289e53841eb67b6fb.
class ScheduleWeeklyCard extends StatelessWidget {
  const ScheduleWeeklyCard({
    super.key,
    required this.assignedWeekdays,
    required this.onToggleWeekday,
  });

  final List<int> assignedWeekdays;
  final bool Function(int weekday) onToggleWeekday;

  static const List<String> dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  void _handleTap(BuildContext context, int weekday) {
    final success = onToggleWeekday(weekday);
    if (!success) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Maximum 3 days per week allowed',
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          backgroundColor: context.ftPrimary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = context.ftPrimary;
    final ink = context.ftInk;
    final muted = context.ftMuted;

    final int daysCount = assignedWeekdays.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0x331E1838)
            : Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? const Color(0x26FFFFFF)
              : Colors.white.withValues(alpha: 0.9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: isDark ? 0.12 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0x22FFFFFF)
                          : const Color(0xFFE6DEFF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      size: 20,
                      color: primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Weekly schedule',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                ],
              ),
              if (daysCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? primary.withValues(alpha: 0.3)
                        : const Color(0xFFE6DEFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$daysCount day${daysCount > 1 ? 's' : ''} / week',
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
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Text(
              'Repeats every week (up to 3 days)',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: muted,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 7 Weekday Tiles Row
          Row(
            children: List.generate(7, (i) {
              final weekday = i + 1; // 1 = Mon ... 7 = Sun
              final isAssigned = assignedWeekdays.contains(weekday);

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 6 ? 6 : 0),
                  child: FtPressable(
                    onTap: () => _handleTap(context, weekday),
                    pressedScale: 0.92,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 60,
                      decoration: BoxDecoration(
                        color: isAssigned
                            ? primary
                            : (isDark
                                ? const Color(0x1FFFFFFF)
                                : Colors.white.withValues(alpha: 0.6)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isAssigned
                              ? primary
                              : (isDark
                                  ? const Color(0x22FFFFFF)
                                  : Colors.white.withValues(alpha: 0.85)),
                          width: 1,
                        ),
                        boxShadow: isAssigned
                            ? [
                                BoxShadow(
                                  color: primary.withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayLetters[i],
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 14,
                              fontWeight: isAssigned
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isAssigned ? Colors.white : muted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isAssigned
                                  ? Colors.white
                                  : (isDark
                                      ? const Color(0x4DFFFFFF)
                                      : const Color(0xFFCAC4D7)),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
