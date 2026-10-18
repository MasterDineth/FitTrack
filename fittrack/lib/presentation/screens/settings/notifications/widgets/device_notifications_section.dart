import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/notification_settings_provider.dart';
import '../../../../theme/ft_glass.dart';
import '../../widgets/ft_settings_card.dart';
import 'device_notification_expandable_card.dart';
import 'ft_switch_row.dart';
import 'notification_segmented_control.dart';
import 'workout_reminder_controls.dart';

/// Device Notifications Section.
///
/// Contains expandable glass cards for:
/// - Live workout sub-toggles (exercise progress, set counter, rest timer, lock screen)
/// - Workout reminders (repeat days chips, time picker, skip if trained)
/// - Water reminders (frequency interval segmented control)
/// - Workout & weekly summaries
/// - Achievements & milestones
/// - Important alerts (security locked always-on)
class DeviceNotificationsSection extends ConsumerStatefulWidget {
  const DeviceNotificationsSection({super.key});

  @override
  ConsumerState<DeviceNotificationsSection> createState() =>
      _DeviceNotificationsSectionState();
}

class _DeviceNotificationsSectionState
    extends ConsumerState<DeviceNotificationsSection> {
  bool _liveExpanded = true;
  bool _workoutRemindersExpanded = false;
  bool _waterExpanded = false;
  bool _summariesExpanded = false;
  bool _achievementsExpanded = false;

  Future<void> _pickReminderTime(BuildContext context, String current) async {
    final parts = current.split(':');
    final initialHour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 18 : 18;
    final initialMinute = parts.length > 1 ? int.tryParse(parts[1]) ?? 30 : 30;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
    );

    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      ref.read(notificationSettingsNotifierProvider.notifier).setReminderTime(formatted);
    }
  }

  String _formatReminderSummary(List<String> days, String time) {
    if (days.isEmpty) {
      return 'No repeat days · $time';
    }
    return '${days.join(', ')} at $time';
  }

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationSettingsNotifierProvider);
    final notifier = ref.read(notificationSettingsNotifierProvider.notifier);
    final primary = context.ftPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Label
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'DEVICE NOTIFICATIONS',
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.12 * 11.5,
              color: primary,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // 1. Live Workout (Expandable)
        DeviceNotificationExpandableCard(
          leadingIcon: Icons.bolt_rounded,
          iconColor: FtGlassTheme.orange,
          iconBg: const Color(0x26F97316),
          title: 'Live workout',
          subtitle: 'Progress, rest timer and quick controls',
          isExpanded: _liveExpanded,
          onHeaderTap: () => setState(() => _liveExpanded = !_liveExpanded),
          masterValue: notifState.liveWorkoutStatus,
          onMasterChanged: (val) => notifier.toggleLiveWorkoutStatus(val),
          children: [
            DeviceNotificationSubItem(
              title: 'Exercise progress bar',
              value: notifState.showScheduleProgress,
              onChanged: (val) => notifier.toggleShowScheduleProgress(val),
            ),
            DeviceNotificationSubItem(
              title: 'Set counter (Set 3 of 4)',
              value: notifState.showSetProgress,
              onChanged: (val) => notifier.toggleShowSetProgress(val),
            ),
            DeviceNotificationSubItem(
              title: 'Rest timer with −15s · Skip · +15s',
              value: notifState.showRestTimerControls,
              onChanged: (val) => notifier.toggleShowRestTimerControls(val),
            ),
            DeviceNotificationSubItem(
              title: 'Show details on lock screen',
              value: notifState.showLockScreenDetails,
              onChanged: (val) => notifier.toggleShowLockScreenDetails(val),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 2. Workout Reminders (Expandable)
        DeviceNotificationExpandableCard(
          leadingIcon: Icons.calendar_month_rounded,
          iconColor: primary,
          iconBg: primary.withValues(alpha: 0.15),
          title: 'Workout reminders',
          subtitle: _formatReminderSummary(
            notifState.reminderDays,
            notifState.reminderTime,
          ),
          isExpanded: _workoutRemindersExpanded,
          onHeaderTap: () => setState(
            () => _workoutRemindersExpanded = !_workoutRemindersExpanded,
          ),
          masterValue: notifState.routineWorkoutReminders,
          onMasterChanged: (val) => notifier.toggleRoutineWorkoutReminders(val),
          children: [
            WorkoutReminderControls(
              selectedDays: notifState.reminderDays,
              reminderTime: notifState.reminderTime,
              onDayToggled: (day) => notifier.toggleReminderDay(day),
              onTimePickerTapped: () => _pickReminderTime(
                context,
                notifState.reminderTime,
              ),
            ),
            DeviceNotificationSubItem(
              title: 'Skip if I already trained today',
              value: notifState.skipIfTrainedToday,
              onChanged: (val) => notifier.toggleSkipIfTrainedToday(val),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 3. Water Reminders (Expandable)
        DeviceNotificationExpandableCard(
          leadingIcon: Icons.water_drop_rounded,
          iconColor: const Color(0xFF0E96C8),
          iconBg: const Color(0x260E96C8),
          title: 'Water reminders',
          subtitle: 'Every ${notifState.hydrationInterval}, 8 AM to 8 PM',
          isExpanded: _waterExpanded,
          onHeaderTap: () => setState(() => _waterExpanded = !_waterExpanded),
          masterValue: notifState.hydrationReminders,
          onMasterChanged: (val) => notifier.toggleHydrationReminders(val),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Frequency interval',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.ftInk,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  NotificationSegmentedControl<String>(
                    selected: notifState.hydrationInterval,
                    options: const {
                      '1 hr': '1 hr',
                      '2 hrs': '2 hrs',
                      '3 hrs': '3 hrs',
                    },
                    onSelected: (val) => notifier.setHydrationInterval(val),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 4. Summaries (Expandable)
        DeviceNotificationExpandableCard(
          leadingIcon: Icons.bar_chart_rounded,
          iconColor: FtGlassTheme.teal,
          iconBg: const Color(0x2614B8A6),
          title: 'Summaries',
          subtitle: 'After workouts and every week',
          isExpanded: _summariesExpanded,
          onHeaderTap: () => setState(
            () => _summariesExpanded = !_summariesExpanded,
          ),
          masterValue: notifState.summariesEnabled,
          onMasterChanged: (val) => notifier.toggleSummariesEnabled(val),
          children: [
            DeviceNotificationSubItem(
              title: 'Workout summary after session',
              value: notifState.workoutScheduleCompletion,
              onChanged: (val) => notifier.toggleWorkoutScheduleCompletion(val),
            ),
            DeviceNotificationSubItem(
              title: 'Weekly recap, Sundays 6 PM',
              value: notifState.weeklyRecap,
              onChanged: (val) => notifier.toggleWeeklyRecap(val),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 5. Achievements (Expandable)
        DeviceNotificationExpandableCard(
          leadingIcon: Icons.military_tech_rounded,
          iconColor: const Color(0xFFC8A03C),
          iconBg: const Color(0x33F5C86E),
          title: 'Achievements',
          subtitle: 'Personal records and streaks',
          isExpanded: _achievementsExpanded,
          onHeaderTap: () => setState(
            () => _achievementsExpanded = !_achievementsExpanded,
          ),
          masterValue: notifState.achievementsEnabled,
          onMasterChanged: (val) => notifier.toggleAchievementsEnabled(val),
          children: [
            DeviceNotificationSubItem(
              title: 'New personal records (PRs)',
              value: notifState.prAchievements,
              onChanged: (val) => notifier.togglePrAchievements(val),
            ),
            DeviceNotificationSubItem(
              title: 'Streak milestones',
              value: notifState.streakMilestones,
              onChanged: (val) => notifier.toggleStreakMilestones(val),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 6. Important Alerts (Locked Card)
        FtSettingsCard(
          radius: 24,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              const FtLeadingIconTile(
                icon: Icons.security_rounded,
                color: FtGlassTheme.rose,
                backgroundColor: Color(0x26F43F5E),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Important alerts',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: context.ftInk,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Security, backup and schedule problems',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: context.ftMuted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.lock_rounded,
                size: 18,
                color: context.ftMuted,
              ),
              const SizedBox(width: 8),
              FtStitchSwitch(
                value: true,
                isLocked: true,
                onChanged: null,
                onLockedTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
