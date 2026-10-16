import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/theme_provider.dart';
import '../../theme/glass_tokens.dart';
import 'glass_backdrop.dart';

export 'glass_backdrop.dart';

/// A reusable frosted glass container applying calibrated blur, semi-translucent
/// fill, specular border highlights, and ambient drop shadows based on [GlassTier].
class FrostedGlassBox extends ConsumerWidget {
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
    this.backdrop = GlassBackdrop.auto,
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

  /// Whether to apply BackdropFilter blur. Kept for backward compatibility:
  /// `false` forces flat; `true` defers to [backdrop] (which defaults to `auto`).
  final bool enableBlur;
  final GlassBackdrop backdrop;

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
  Widget build(BuildContext context, WidgetRef ref) {
    bool enableTransparency = true;
    double blurIntensity = 16.0;
    try {
      final (transparency, intensity) = ref.watch(
        themeNotifierProvider.select(
          (s) => (s.enableGlassTransparency, s.blurIntensity),
        ),
      );
      enableTransparency = transparency;
      blurIntensity = intensity;
    } catch (_) {}

    final config = GlassTokens.resolve(
      context,
      tier: tier,
      customFill: fillColor,
      customBorder: border is Border ? border as Border : null,
      customShadow: boxShadow,
    );

    final resolvedRadius = borderRadius ?? _defaultRadius(tier);
    final baseBlur = blur ?? config.blur;

    // Resolve whether this surface creates a real live BackdropFilter.
    // enableBlur: false forces flat for backward compatibility; enableBlur: true defers to backdrop.
    final bool isLive;
    if (!enableTransparency || !enableBlur) {
      isLive = false;
    } else {
      switch (backdrop) {
        case GlassBackdrop.flat:
          isLive = false;
        case GlassBackdrop.live:
          isLive = true;
        case GlassBackdrop.auto:
          isLive = tier == GlassTier.floating;
      }
    }

    final double t = ((blurIntensity - 4.0) / (32.0 - 4.0)).clamp(0.0, 1.0);
    final double effectiveBlur;
    if (!enableTransparency || !isLive) {
      effectiveBlur = 0.0;
    } else if (t <= 0.42857) {
      final progress = t / 0.42857;
      effectiveBlur = 3.0 + (baseBlur - 3.0) * progress;
    } else {
      final progress = (t - 0.42857) / (1.0 - 0.42857);
      final double maxBlur = (baseBlur * 2.0).clamp(32.0, 48.0);
      effectiveBlur = baseBlur + (maxBlur - baseBlur) * progress;
    }

    final double baseAlpha = config.fillColor.a;
    final double effectiveAlpha;
    if (!enableTransparency) {
      effectiveAlpha = baseAlpha;
    } else if (t <= 0.42857) {
      final progress = t / 0.42857;
      final double minAlpha = (baseAlpha * 0.45).clamp(0.18, 0.32);
      effectiveAlpha = minAlpha + (baseAlpha - minAlpha) * progress;
    } else {
      final progress = (t - 0.42857) / (1.0 - 0.42857);
      final double maxAlpha = (baseAlpha * 1.35).clamp(0.76, 0.88);
      effectiveAlpha = baseAlpha + (maxAlpha - baseAlpha) * progress;
    }
    final Color effectiveFill = config.fillColor.withValues(alpha: effectiveAlpha);

    final shouldBlur = isLive && effectiveBlur > 0;

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      alignment: alignment,
      constraints: constraints,
      decoration: BoxDecoration(
        color: effectiveFill,
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
