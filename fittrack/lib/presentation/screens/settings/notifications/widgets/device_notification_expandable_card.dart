import 'package:flutter/material.dart';
import '../../../../theme/ft_glass.dart';
import '../../widgets/ft_settings_card.dart';
import 'ft_switch_row.dart';

/// Reusable expandable card component for Device Notification options.
class DeviceNotificationExpandableCard extends StatelessWidget {
  final IconData leadingIcon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool isExpanded;
  final VoidCallback onHeaderTap;
  final bool masterValue;
  final ValueChanged<bool> onMasterChanged;
  final List<Widget> children;

  const DeviceNotificationExpandableCard({
    super.key,
    required this.leadingIcon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.isExpanded,
    required this.onHeaderTap,
    required this.masterValue,
    required this.onMasterChanged,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return FtSettingsCard(
      radius: 24,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              // Tap area for expand/collapse
              Expanded(
                child: GestureDetector(
                  onTap: onHeaderTap,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      FtLeadingIconTile(
                        icon: leadingIcon,
                        color: iconColor,
                        backgroundColor: iconBg,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                      const SizedBox(width: 6),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        turns: isExpanded ? 0.25 : 0.0,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: context.ftMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Master Switch
              FtStitchSwitch(
                value: masterValue,
                onChanged: onMasterChanged,
              ),
            ],
          ),
          // Sub-items collapsible body
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: children,
                      ),
                    )
                  : const SizedBox(width: double.infinity, height: 0),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper for a sub-item row inside an expandable card.
class DeviceNotificationSubItem extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const DeviceNotificationSubItem({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: context.ftPrimary.withValues(alpha: 0.08),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
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
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
