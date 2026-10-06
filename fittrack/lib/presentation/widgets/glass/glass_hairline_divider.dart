import 'package:flutter/material.dart';

import '../../theme/glass_tokens.dart';

/// Clean 1px hairline divider tinted with `primary.withOpacity(0.08)` (Light)
/// or `Colors.white.withOpacity(0.08)` (Dark) for frosted glass card separations.
class GlassHairlineDivider extends StatelessWidget {
  const GlassHairlineDivider({
    super.key,
    this.color,
    this.thickness = 1.0,
    this.isVertical = false,
    this.margin,
  });

  final Color? color;
  final double thickness;
  final bool isVertical;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final dividerColor = color ?? GlassTokens.hairlineColor(context);

    Widget divider = Container(
      width: isVertical ? thickness : double.infinity,
      height: isVertical ? double.infinity : thickness,
      color: dividerColor,
    );

    if (margin != null) {
      divider = Padding(padding: margin!, child: divider);
    }

    return divider;
  }
}
