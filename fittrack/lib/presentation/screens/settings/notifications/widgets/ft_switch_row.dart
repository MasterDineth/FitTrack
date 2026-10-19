import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../theme/ft_glass.dart';

/// Tactile Stitch-styled frosted switch pill.
///
/// Exactly 48×28dp with a 22×22dp sliding white thumb, gradient active track,
/// and haptic feedback.
class FtStitchSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isLocked;
  final VoidCallback? onLockedTap;

  const FtStitchSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.isLocked = false,
    this.onLockedTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = context.ftPrimary;

    final inactiveBg = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : primary.withValues(alpha: 0.18);

    return Semantics(
      toggled: value,
      enabled: !isLocked,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (isLocked) {
            HapticFeedback.lightImpact();
            onLockedTap?.call();
          } else {
            HapticFeedback.selectionClick();
            onChanged?.call(!value);
          }
        },
        child: Container(
          width: 48,
          height: 48, // Accessible tap target
          alignment: Alignment.center,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isLocked ? 0.65 : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: value
                    ? LinearGradient(
                        colors: [
                          HSLColor.fromColor(primary)
                              .withLightness((HSLColor.fromColor(primary).lightness + 0.12).clamp(0.0, 1.0))
                              .toColor(),
                          primary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: value ? null : inactiveBg,
                boxShadow: value
                    ? [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.28),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    left: value ? 23 : 3,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.22),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Standardized setting row tile featuring leading colored icon, title, subtitle,
/// optional right lock/chevron, and [FtStitchSwitch].
class FtSettingSwitchRow extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isLocked;
  final VoidCallback? onLockedTap;
  final Widget? trailingExtra;

  const FtSettingSwitchRow({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLocked = false,
    this.onLockedTap,
    this.trailingExtra,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        leading,
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
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  maxLines: 2,
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
            ],
          ),
        ),
        if (trailingExtra != null) ...[
          const SizedBox(width: 8),
          trailingExtra!,
        ],
        const SizedBox(width: 8),
        FtStitchSwitch(
          value: value,
          onChanged: onChanged,
          isLocked: isLocked,
          onLockedTap: onLockedTap,
        ),
      ],
    );
  }
}

/// 44×44 Rounded icon box used for settings row leading tiles.
class FtLeadingIconTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const FtLeadingIconTile({
    super.key,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor,
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
          icon,
          size: 20,
          color: color,
        ),
      ),
    );
  }
}
