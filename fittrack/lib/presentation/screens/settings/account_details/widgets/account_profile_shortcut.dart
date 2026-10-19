import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fittrack/presentation/screens/dashboard/widgets/ft_pressable.dart';
import 'package:fittrack/presentation/theme/ft_glass.dart';

/// Shortcut card navigating to the Athlete Profile screen at the bottom of Account Details.
class AccountProfileShortcut extends StatelessWidget {
  const AccountProfileShortcut({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final ink = context.ftInk;
    final muted = context.ftMuted;
    final settings = FtGlassTheme.resolveThemeSettings(context);

    return FtPressable(
      onTap: () => context.push('/settings/profile'),
      pressedScale: 0.985,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: FtGlassTheme.cardDecoration(
          context,
          radius: 22,
          settings: settings,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6)
                    .withValues(alpha: isDark ? 0.22 : 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.person_pin_rounded,
                size: 22,
                color: Color(0xFF14B8A6),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Athlete Profile',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 1.5),
                  Text(
                    'View your fitness metrics, goals, and training tier',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: muted.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
