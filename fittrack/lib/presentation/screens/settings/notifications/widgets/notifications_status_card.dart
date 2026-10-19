import 'package:flutter/material.dart';
import '../../../../theme/ft_glass.dart';
import '../../../../widgets/glass_surface.dart';
import 'notification_segmented_control.dart';

/// Top notification status banner and simulation switch.
///
/// Reflects whether device notifications are allowed or blocked.
/// If blocked, offers an "Enable" action to request/grant permission.
/// Also provides an interactive segmented simulator switch between "Allowed" and "Blocked".
class NotificationsStatusCard extends StatelessWidget {
  final bool isBlocked;
  final ValueChanged<bool> onPermissionSimulationChanged;
  final VoidCallback onEnableTap;

  const NotificationsStatusCard({
    super.key,
    required this.isBlocked,
    required this.onPermissionSimulationChanged,
    required this.onEnableTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final blockedBg = isDark
        ? const Color(0x3DF43F5E)
        : const Color(0xCCFFF1F2);
    final blockedBorder = isDark
        ? const Color(0x66F43F5E)
        : const Color(0xE6FECDD3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Status Card
        GlassSurface(
          tier: FtGlassTier.glass1,
          radius: 24,
          borderTint: isBlocked ? blockedBorder : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              color: isBlocked ? blockedBg : Colors.transparent,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
              children: [
                // Icon Tile
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isBlocked
                        ? const Color(0x24F43F5E)
                        : const Color(0x2614B8A6),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.8),
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      isBlocked
                          ? Icons.notifications_off_rounded
                          : Icons.notifications_active_rounded,
                      size: 24,
                      color: isBlocked
                          ? FtGlassTheme.rose
                          : FtGlassTheme.teal,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isBlocked
                            ? 'Notifications are blocked'
                            : 'Device notifications are on',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: context.ftInk,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isBlocked
                            ? 'Allow them in system settings to get live workout, reminders and summaries.'
                            : 'Live workout, reminders and summaries can reach you.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: context.ftMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                // Enable button if blocked
                if (isBlocked) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onEnableTap,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.white.withValues(alpha: 0.80),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.9),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: context.ftPrimary.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        'Enable',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: context.ftPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
        const SizedBox(height: 10),

        // 2. Simulation Toggle Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Design simulation: system permission',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: context.ftMuted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              NotificationSegmentedControl<String>(
                selected: isBlocked ? 'blocked' : 'allowed',
                options: const {
                  'allowed': 'Allowed',
                  'blocked': 'Blocked',
                },
                onSelected: (val) {
                  onPermissionSimulationChanged(val == 'blocked');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
