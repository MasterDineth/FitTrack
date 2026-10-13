import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';
import '../theme/glass_tokens.dart';

/// Fixed, high-performance liquid mesh ambient background canvas.
///
/// Paints a luminous multi-point radial mesh underglow based on the user's
/// dynamic primary accent, current brightness, and AMOLED OLED pure dark setting.
class AmbientMeshBackground extends ConsumerWidget {
  const AmbientMeshBackground({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    bool isPureDark = isDark &&
        (theme.scaffoldBackgroundColor == const Color(0xFF000000) ||
            theme.scaffoldBackgroundColor == Colors.black);

    try {
      final themeSettings = ref.watch(themeNotifierProvider);
      isPureDark = isDark && themeSettings.useOledBlack;
    } catch (_) {
      // Fallback smoothly to Theme properties in isolated tests
    }

    final palette = MeshPalette.fromPrimary(
      primary,
      theme.brightness,
      isPureDark,
    );

    return RepaintBoundary(
      child: CustomPaint(
        painter: _MeshCanvasPainter(palette: palette),
        child: child ?? const SizedBox.expand(),
      ),
    );
  }
}

class _MeshCanvasPainter extends CustomPainter {
  final MeshPalette palette;

  const _MeshCanvasPainter({required this.palette});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    // 1. Draw base canvas fill
    final bgPaint = Paint()..color = palette.canvasColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 2. Layer radial light blooms
    final maxDim = math.max(size.width, size.height);

    for (final glow in palette.glows) {
      final center = Offset(
        size.width * glow.xPercent,
        size.height * glow.yPercent,
      );
      final radius = maxDim * glow.radiusPercent;
      if (radius <= 0) continue;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            glow.color,
            glow.color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MeshCanvasPainter oldDelegate) {
    if (oldDelegate.palette.canvasColor != palette.canvasColor ||
        oldDelegate.palette.glows.length != palette.glows.length) {
      return true;
    }
    for (int i = 0; i < palette.glows.length; i++) {
      final a = oldDelegate.palette.glows[i];
      final b = palette.glows[i];
      if (a.color != b.color ||
          a.xPercent != b.xPercent ||
          a.yPercent != b.yPercent ||
          a.radiusPercent != b.radiusPercent) {
        return true;
      }
    }
    return false;
  }
}
