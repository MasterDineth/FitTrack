import 'package:flutter/material.dart';

import '../../../theme/ft_glass.dart';

/// Shared header row for every section card on the Exercise Details screen.
///
/// Renders the round tinted icon tile, the section title, an optional
/// supporting line and an optional trailing count pill — matching the
/// Stitch section header pattern.
class DetailsSectionHeader extends StatelessWidget {
  const DetailsSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.countLabel,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? countLabel;

  @override
  Widget build(BuildContext context) {
    final primary = context.ftPrimary;
    final ink = context.ftInk;
    final muted = context.ftMuted;
    final isDark = context.isDark;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: isDark ? 0.22 : 0.12),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: primary, size: 20),
        ),
        const SizedBox(width: 12),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 1),
                Text(
                  subtitle!,
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
            ],
          ),
        ),
        if (countLabel != null) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: isDark ? 0.20 : 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                countLabel!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Compact pill used for the exercise metadata badges under the title.
class DetailsPill extends StatelessWidget {
  const DetailsPill({
    super.key,
    required this.label,
    this.icon,
    this.leadingDot,
    this.variant = DetailsPillVariant.soft,
  });

  final String label;
  final IconData? icon;
  final Color? leadingDot;
  final DetailsPillVariant variant;

  @override
  Widget build(BuildContext context) {
    final primary = context.ftPrimary;
    final isDark = context.isDark;

    final Color background;
    final Color foreground;
    final Color border;

    switch (variant) {
      case DetailsPillVariant.solid:
        background = primary;
        foreground = Colors.white;
        border = primary;
      case DetailsPillVariant.soft:
        background = primary.withValues(alpha: isDark ? 0.20 : 0.10);
        foreground = primary;
        border = primary.withValues(alpha: isDark ? 0.28 : 0.18);
      case DetailsPillVariant.outline:
        background = isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.70);
        foreground = context.ftInk;
        border = isDark
            ? Colors.white.withValues(alpha: 0.14)
            : Colors.white.withValues(alpha: 0.90);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingDot != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: leadingDot,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ] else if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Visual weight of a [DetailsPill].
enum DetailsPillVariant { solid, soft, outline }
