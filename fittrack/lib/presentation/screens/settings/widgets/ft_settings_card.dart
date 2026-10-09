import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/theme_provider.dart';
import '../../../theme/ft_glass.dart';

/// High-performance frosted glass card container for Settings sections.
/// Adheres strictly to AGENTS.md rules while dynamically following
/// [ThemeSettings.enableGlassTransparency] (on/off) and
/// [ThemeSettings.blurIntensity] (intensity adjustments).
class FtSettingsCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    ThemeSettings? settings;
    try {
      settings = ref.watch(themeNotifierProvider);
    } catch (_) {
      // Graceful fallback for scope-less widget test environments
    }

    final decoration = FtGlassTheme.cardDecoration(
      context,
      radius: radius,
      settings: settings,
    );
    final borderRadius = BorderRadius.circular(radius);

    Widget box = Container(
      decoration: decoration,
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
