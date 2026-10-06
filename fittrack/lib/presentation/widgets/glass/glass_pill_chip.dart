import 'package:flutter/material.dart';

import '../../theme/glass_tokens.dart';
import 'frosted_glass_box.dart';

/// Micro-pill badge chip (height 22–26px) built on [GlassTier.elevated] material
/// with tinted specular borders and an optional 6px glowing status dot.
class GlassPillChip extends StatelessWidget {
  const GlassPillChip({
    super.key,
    required this.label,
    this.dotColor,
    this.textColor,
    this.borderColor,
    this.fillColor,
    this.height = 24.0,
    this.fontSize = 11.0,
    this.fontWeight = FontWeight.w700,
    this.letterSpacing = 0.4,
    this.padding,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String label;
  final Color? dotColor;
  final Color? textColor;
  final Color? borderColor;
  final Color? fillColor;
  final double height;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final EdgeInsetsGeometry? padding;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final effectiveColor = textColor ?? dotColor ?? primary;
    final effectiveBorder = borderColor ??
        (dotColor ?? primary).withValues(alpha: 0.20);

    return FrostedGlassBox(
      tier: GlassTier.elevated,
      height: height,
      borderRadius: BorderRadius.circular(height / 2),
      border: Border.all(color: effectiveBorder, width: 1),
      fillColor: fillColor,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 5),
          ] else if (dotColor != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: dotColor!.withValues(alpha: 0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: effectiveColor,
              letterSpacing: letterSpacing,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 5),
            trailing!,
          ],
        ],
      ),
    );
  }
}
