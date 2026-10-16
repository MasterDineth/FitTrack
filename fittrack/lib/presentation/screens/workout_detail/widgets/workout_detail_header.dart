import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Top navigation header for Workout Details matching Stitch Screen `fc32d4d5a15441178564c24cb5dad0f4`
/// and AGENTS.md clean architecture rules.
///
/// Features:
/// - Circular back button (40x40 circle glass2)
/// - Title "Workout Details" and subtitle "Review routine, exercises & target sets"
/// - Triple-dots (3-dot) menu button with frosted glass popup menu:
///   - "Share" (stub / implement later feedback)
///   - "Edit workout" (stub / implement later feedback)
///   - "Settings" (navigates to `/settings/workout-preferences`)
class WorkoutDetailHeader extends StatelessWidget {
  const WorkoutDetailHeader({
    super.key,
    required this.onBackTap,
  });

  final VoidCallback onBackTap;

  Future<void> _showMenu(BuildContext context) async {
    final RenderBox? button = context.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (button == null || overlay == null) return;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final value = await showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: context.isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.8),
          width: 1.5,
        ),
      ),
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xEB1D1735)
          : const Color(0xF2FFFFFF),
      elevation: 12,
      items: [
        PopupMenuItem<String>(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share_outlined, size: 18, color: context.ftPrimary),
              const SizedBox(width: 12),
              Text(
                'Share',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: context.ftInk,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: context.ftPrimary),
              const SizedBox(width: 12),
              Text(
                'Edit workout',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: context.ftInk,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings_outlined, size: 18, color: context.ftPrimary),
              const SizedBox(width: 12),
              Text(
                'Settings',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: context.ftInk,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (!context.mounted || value == null) return;

    if (value == 'share') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Workout sharing will be available soon'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else if (value == 'edit') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Workout editor will be available soon'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else if (value == 'settings') {
      context.push('/settings/workout-preferences');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Back button + Title & Subtitle
          Expanded(
            child: Row(
              children: [
                FtPressable(
                  onTap: onBackTap,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Workout Details',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: context.ftInk,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Review routine, exercises & target sets',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: context.ftMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Right: 3-Dot More Button only (Profile and notification removed per spec)
          Builder(
            builder: (btnContext) => FtPressable(
              onTap: () => _showMenu(btnContext),
              pressedScale: 0.90,
              child: GlassSurface(
                tier: FtGlassTier.glass2,
                radius: 20,
                width: 38,
                height: 38,
                shadow: false,
                alignment: Alignment.center,
                child: Icon(
                  Icons.more_vert_rounded,
                  size: 20,
                  color: context.ftInk,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
