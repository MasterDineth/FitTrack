import 'package:flutter/material.dart';
import '../../../../theme/ft_glass.dart';
import '../../../dashboard/widgets/ft_pressable.dart';

/// Bottom action buttons for Notifications screen (Send test notification & System settings).
class NotificationsBottomActions extends StatelessWidget {
  final VoidCallback onSendTestNotification;
  final VoidCallback onOpenSystemSettings;

  const NotificationsBottomActions({
    super.key,
    required this.onSendTestNotification,
    required this.onOpenSystemSettings,
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.ftPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Send Test Notification Button
        FtPressable(
          onTap: onSendTestNotification,
          pressedScale: 0.98,
          child: Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  HSLColor.fromColor(primary)
                      .withLightness((HSLColor.fromColor(primary).lightness + 0.12).clamp(0.0, 1.0))
                      .toColor(),
                  primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.send_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  'Send test notification',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // System Settings Button
        FtPressable(
          onTap: onOpenSystemSettings,
          pressedScale: 0.98,
          child: Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withValues(alpha: 0.70),
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'System settings',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: primary,
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
