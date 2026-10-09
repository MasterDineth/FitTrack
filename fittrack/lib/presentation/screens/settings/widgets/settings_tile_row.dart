import 'package:flutter/material.dart';
import '../../../theme/ft_glass.dart';

/// Individual interactive row in a Settings section card.
class SettingsTileRow extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final Color? iconBorderColor;
  final String title;
  final String subtitle;
  final String? trailingPreview;
  final Color? trailingPreviewColor;
  final VoidCallback onTap;

  const SettingsTileRow({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.iconBorderColor,
    required this.title,
    required this.subtitle,
    this.trailingPreview,
    this.trailingPreviewColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: context.ftPrimary.withValues(alpha: 0.12),
        highlightColor: context.ftPrimary.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Row(
            children: [
              // 38x38 Rounded icon container with calibrated Stitch tint & border
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: context.isDark
                      ? iconBgColor.withValues(alpha: 0.18)
                      : iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: iconBorderColor ??
                        (context.isDark
                            ? iconColor.withValues(alpha: 0.25)
                            : iconColor.withValues(alpha: 0.15)),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 19,
                    color: iconColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title and Subtitle text column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: context.ftInk,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: context.ftMuted,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Trailing preview text / badge
              if (trailingPreview != null && trailingPreview!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  trailingPreview!,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: trailingPreviewColor ?? context.ftMuted,
                  ),
                ),
              ],
              const SizedBox(width: 4),

              // Trailing chevron
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: context.ftMuted.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
