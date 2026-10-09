import 'package:flutter/material.dart';
import '../../../theme/ft_glass.dart';

/// High-performance frosted glass card container for Settings sections.
/// Adheres strictly to AGENTS.md rules: translucent fill, hairline border,
/// soft violet-tinted shadow, and zero per-card blur.
class FtSettingsCard extends StatelessWidget {
  final double radius;
  final EdgeInsetsGeometry padding;
  final Widget child;
  final VoidCallback? onTap;

  const FtSettingsCard({
    super.key,
    this.radius = 20,
    this.padding = EdgeInsets.zero,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final spec = isDark ? FtGlassTheme.glass1Dark : FtGlassTheme.glass1;
    final borderRadius = BorderRadius.circular(radius);

    Widget box = Container(
      decoration: BoxDecoration(
        color: spec.fill,
        borderRadius: borderRadius,
        border: Border.all(
          color: spec.border,
          width: 1.0,
        ),
        boxShadow: spec.shadows,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          splashColor: context.ftPrimary.withValues(alpha: 0.12),
          highlightColor: context.ftPrimary.withValues(alpha: 0.06),
          child: box,
        ),
      );
    }

    return box;
  }
}
