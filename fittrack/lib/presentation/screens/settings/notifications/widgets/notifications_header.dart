import 'package:flutter/material.dart';
import '../../../../theme/ft_glass.dart';
import '../../../../widgets/glass_surface.dart';
import '../../../../widgets/header/ft_dynamic_header.dart';
import '../../../dashboard/widgets/ft_pressable.dart';

/// Flushed header for the Notifications settings screen.
///
/// Follows Category A from `MODULAR_HEADER_AND_NOTIFICATIONS_GUIDE.md`:
/// Features a 40×40 circular frosted glass back button, bold title and category caption,
/// and the universal in-header dynamic island notification bell on the far right.
class NotificationsHeader extends StatelessWidget {
  const NotificationsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return FtDynamicHeader(
      padding: const EdgeInsets.only(top: 8.0, bottom: 14.0),
      leftChild: Row(
        children: [
          // 40x40 Frosted Back Button with >= 48x48 touch target
          FtPressable(
            onTap: () => Navigator.of(context).maybePop(),
            pressedScale: 0.90,
            child: GlassSurface(
              tier: FtGlassTier.glass2,
              radius: 20,
              width: 40,
              height: 40,
              shadow: false,
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: context.ftInk,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Notifications',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: context.ftInk,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Live workout, reminders & alerts',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: context.ftMuted,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      trailing: null,
    );
  }
}
