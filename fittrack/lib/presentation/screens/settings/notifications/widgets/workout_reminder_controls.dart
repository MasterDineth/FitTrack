import 'package:flutter/material.dart';
import '../../../../theme/ft_glass.dart';

/// Day chips selector and time picker control for workout reminders.
class WorkoutReminderControls extends StatelessWidget {
  final List<String> selectedDays;
  final String reminderTime;
  final ValueChanged<String> onDayToggled;
  final VoidCallback onTimePickerTapped;

  static const daysMap = [
    ('M', 'Mon'),
    ('T', 'Tue'),
    ('W', 'Wed'),
    ('T', 'Thu'),
    ('F', 'Fri'),
    ('S', 'Sat'),
    ('S', 'Sun'),
  ];

  const WorkoutReminderControls({
    super.key,
    required this.selectedDays,
    required this.reminderTime,
    required this.onDayToggled,
    required this.onTimePickerTapped,
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.ftPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
          child: Text(
            'REPEAT DAYS',
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: context.ftMuted,
            ),
          ),
        ),
        // Day Chips
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: daysMap.map((d) {
            final isSelected = selectedDays.contains(d.$2);
            return GestureDetector(
              onTap: () => onDayToggled(d.$2),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? primary : Colors.white.withValues(alpha: 0.65),
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    d.$1,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : context.ftMuted,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        // Remind me at
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Remind me at',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.ftInk,
                ),
              ),
              GestureDetector(
                onTap: onTimePickerTapped,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 15,
                        color: primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        reminderTime,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
