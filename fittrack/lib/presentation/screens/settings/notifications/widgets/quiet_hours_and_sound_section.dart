import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/notification_settings_provider.dart';
import '../../../../providers/notifications_provider.dart';
import '../../../../theme/ft_glass.dart';
import '../../widgets/ft_settings_card.dart';
import 'ft_switch_row.dart';
import 'notifications_bottom_actions.dart';

/// Quiet Hours, Feel & Sound settings and bottom launch actions.
class QuietHoursAndSoundSection extends ConsumerWidget {
  final VoidCallback? onScrollToTop;

  const QuietHoursAndSoundSection({
    super.key,
    this.onScrollToTop,
  });

  Future<void> _pickTime({
    required BuildContext context,
    required WidgetRef ref,
    required bool isFrom,
    required String currentTime,
  }) async {
    final parts = currentTime.split(':');
    final initialHour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 22 : 22;
    final initialMinute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
    );

    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      final notifState = ref.read(notificationSettingsNotifierProvider);
      final notifier = ref.read(notificationSettingsNotifierProvider.notifier);

      if (isFrom) {
        notifier.setQuietHoursRange(formatted, notifState.quietHoursTo);
      } else {
        notifier.setQuietHoursRange(notifState.quietHoursFrom, formatted);
      }
    }
  }

  void _sendTestNotification(WidgetRef ref) {
    try {
      ref.read(notificationIslandProvider.notifier).show(
            FtNotificationItem(
              id: 'test-${DateTime.now().millisecondsSinceEpoch}',
              type: FtNotificationType.pr,
              title: 'New bench PR · 85 kg',
              body: 'Test notification triggered from notifications screen',
              timestamp: DateTime.now(),
            ),
          );
    } catch (_) {}
    onScrollToTop?.call();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifState = ref.watch(notificationSettingsNotifierProvider);
    final notifier = ref.read(notificationSettingsNotifierProvider.notifier);
    final primary = context.ftPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. QUIET HOURS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'QUIET HOURS',
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

        FtSettingsCard(
          radius: 24,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              FtSettingSwitchRow(
                leading: FtLeadingIconTile(
                  icon: Icons.dark_mode_rounded,
                  color: primary,
                  backgroundColor: primary.withValues(alpha: 0.15),
                ),
                title: 'Quiet hours',
                subtitle: 'Mute reminders and summaries',
                value: notifState.quietHoursEnabled,
                onChanged: (val) => notifier.toggleQuietHoursEnabled(val),
              ),
              const SizedBox(height: 12),

              // From ... to ... row
              Row(
                children: [
                  Text(
                    'From',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: context.ftMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _pickTime(
                      context: context,
                      ref: ref,
                      isFrom: true,
                      currentTime: notifState.quietHoursFrom,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        notifState.quietHoursFrom,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'to',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: context.ftMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _pickTime(
                      context: context,
                      ref: ref,
                      isFrom: false,
                      currentTime: notifState.quietHoursTo,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        notifState.quietHoursTo,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Still show live workout
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: primary.withValues(alpha: 0.08),
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Still show the live workout notification',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.ftInk,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FtStitchSwitch(
                      value: notifState.quietHoursShowLive,
                      onChanged: (val) =>
                          notifier.toggleQuietHoursShowLive(val),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. FEEL AND SOUND
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'FEEL AND SOUND',
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

        FtSettingsCard(
          radius: 24,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.vibration_rounded,
                    size: 20,
                    color: primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Haptic feedback',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: context.ftInk,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FtStitchSwitch(
                    value: notifState.hapticsEnabled,
                    onChanged: (val) => notifier.toggleHapticsEnabled(val),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Divider(
                color: primary.withValues(alpha: 0.08),
                height: 1,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.volume_up_rounded,
                    size: 20,
                    color: primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Sounds and timer countdown beeps',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: context.ftInk,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FtStitchSwitch(
                    value: notifState.audioEnabled,
                    onChanged: (val) => notifier.toggleAudioEnabled(val),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 3. BOTTOM ACTIONS
        NotificationsBottomActions(
          onSendTestNotification: () => _sendTestNotification(ref),
          onOpenSystemSettings: () {},
        ),
      ],
    );
  }
}
