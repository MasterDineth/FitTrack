import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/ft_glass.dart';

/// Presents a bottom sheet modal where the backdrop blur and dark scrim fade in smoothly
/// across the entire screen, while only the bottom sheet card slides up from the bottom.
/// Strictly follows global glass transparency (on/off) and blur intensity from Appearance settings.
Future<T?> showBlurBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
  Duration duration = const Duration(milliseconds: 300),
}) {
  final settings = FtGlassTheme.resolveThemeSettings(context);
  final enableTransparency = settings?.enableGlassTransparency ?? true;
  final blurIntensity = settings?.blurIntensity ?? 16.0;

  final double t = enableTransparency
      ? ((blurIntensity - 4.0) / (32.0 - 4.0)).clamp(0.0, 1.0)
      : 0.0;
  final double effectiveSigma = enableTransparency ? (3.0 + 17.0 * t) : 0.0;

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.transparent, // Handled by custom FadeTransition with blur
    transitionDuration: duration,
    pageBuilder: (ctx, anim, secondaryAnim) => child,
    transitionBuilder: (ctx, anim, secondaryAnim, child) {
      final curvedAnim = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      final scrim = Container(
        color: Colors.black.withValues(
          alpha: enableTransparency ? (0.35 + 0.15 * t) : 0.55,
        ),
      );

      return Stack(
        children: [
          // ── 1. Full-screen backdrop blur & dimmed scrim FADES in/out (no sliding) ──
          Positioned.fill(
            child: FadeTransition(
              opacity: anim,
              child: GestureDetector(
                onTap: barrierDismissible ? () => Navigator.of(ctx).pop() : null,
                behavior: HitTestBehavior.opaque,
                child: effectiveSigma > 0
                    ? BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: effectiveSigma,
                          sigmaY: effectiveSigma,
                        ),
                        child: scrim,
                      )
                    : scrim,
              ),
            ),
          ),

          // ── 2. Only the bottom sheet card SLIDES up from the bottom ────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(curvedAnim),
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: () {}, // Prevent taps inside the card from dismissing
                  onVerticalDragEnd: (details) {
                    if (barrierDismissible &&
                        details.primaryVelocity != null &&
                        details.primaryVelocity! > 250) {
                      Navigator.of(ctx).pop();
                    }
                  },
                  child: child,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

/// Presents a centered modal popup where the backdrop blur and dark scrim fade in smoothly
/// across the entire screen, while the modal card smoothly scales and fades in.
/// Strictly follows global glass transparency (on/off) and blur intensity from Appearance settings.
Future<T?> showBlurModal<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
  Duration duration = const Duration(milliseconds: 280),
}) {
  final settings = FtGlassTheme.resolveThemeSettings(context);
  final enableTransparency = settings?.enableGlassTransparency ?? true;
  final blurIntensity = settings?.blurIntensity ?? 16.0;

  final double t = enableTransparency
      ? ((blurIntensity - 4.0) / (32.0 - 4.0)).clamp(0.0, 1.0)
      : 0.0;
  final double effectiveSigma = enableTransparency ? (3.0 + 17.0 * t) : 0.0;

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.transparent, // Handled by custom FadeTransition with BackdropFilter
    transitionDuration: duration,
    pageBuilder: (ctx, anim, secondaryAnim) => child,
    transitionBuilder: (ctx, anim, secondaryAnim, child) {
      final curvedAnim = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      final scrim = Container(
        color: Colors.black.withValues(
          alpha: enableTransparency ? (0.40 + 0.15 * t) : 0.60,
        ),
      );

      return Stack(
        children: [
          // ── 1. Full-screen backdrop blur & dimmed scrim FADES in/out ──
          Positioned.fill(
            child: FadeTransition(
              opacity: anim,
              child: GestureDetector(
                onTap: barrierDismissible ? () => Navigator.of(ctx).pop() : null,
                behavior: HitTestBehavior.opaque,
                child: effectiveSigma > 0
                    ? BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: effectiveSigma,
                          sigmaY: effectiveSigma,
                        ),
                        child: scrim,
                      )
                    : scrim,
              ),
            ),
          ),

          // ── 2. Modal card centered with smooth scale & fade animation ──
          Center(
            child: FadeTransition(
              opacity: curvedAnim,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.94, end: 1.0).animate(curvedAnim),
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: () {}, // Prevent taps inside the card from dismissing
                    behavior: HitTestBehavior.opaque,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
