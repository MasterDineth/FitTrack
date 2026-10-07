import 'dart:ui';
import 'package:flutter/material.dart';

import '../../theme/glass_tokens.dart';

/// A reusable frosted glass container applying calibrated blur, semi-translucent
/// fill, specular border highlights, and ambient drop shadows based on [GlassTier].
class FrostedGlassBox extends StatelessWidget {
  const FrostedGlassBox({
    super.key,
    this.child,
    this.tier = GlassTier.surface,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.border,
    this.fillColor,
    this.blur,
    this.boxShadow,
    this.alignment,
    this.constraints,
    this.clipBehavior = Clip.antiAlias,
    this.onTap,
    this.enableBlur = true,
  });

  final Widget? child;
  final GlassTier tier;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BoxBorder? border;
  final Color? fillColor;
  final double? blur;
  final List<BoxShadow>? boxShadow;
  final AlignmentGeometry? alignment;
  final BoxConstraints? constraints;
  final Clip clipBehavior;
  final VoidCallback? onTap;

  /// Whether to apply BackdropFilter blur. Defaults to `false` for card layouts
  /// to eliminate offscreen GPU blur passes and avoid saveLayer allocations.
  /// Only the floating dock sets this to `true`.
  final bool enableBlur;

  BorderRadius _defaultRadius(GlassTier tier) {
    switch (tier) {
      case GlassTier.surface:
        return BorderRadius.circular(20);
      case GlassTier.elevated:
        return BorderRadius.circular(14);
      case GlassTier.floating:
        return BorderRadius.circular(28);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = GlassTokens.resolve(
      context,
      tier: tier,
      customFill: fillColor,
      customBorder: border is Border ? border as Border : null,
      customShadow: boxShadow,
    );

    final resolvedRadius = borderRadius ?? _defaultRadius(tier);
    final effectiveBlur = blur ?? config.blur;
    final shouldBlur = enableBlur;

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      alignment: alignment,
      constraints: constraints,
      decoration: BoxDecoration(
        color: config.fillColor,
        borderRadius: resolvedRadius,
        border: border ?? config.border,
      ),
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: resolvedRadius is BorderRadius
              ? resolvedRadius
              : BorderRadius.circular(20),
          child: content,
        ),
      );
    }

    if (!shouldBlur) {
      return Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: resolvedRadius,
          boxShadow: config.boxShadow,
        ),
        child: content,
      );
    }

    Widget glassCard = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: resolvedRadius,
        boxShadow: config.boxShadow,
      ),
      child: ClipRRect(
        borderRadius: resolvedRadius,
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: effectiveBlur,
            sigmaY: effectiveBlur,
          ),
          child: content,
        ),
      ),
    );

    return glassCard;
  }
}
