import 'package:flutter/material.dart';

/// The calibrated frosted glass tier hierarchy from the FitTrack Design System.
enum GlassTier {
  /// Glass-1: Base standard canvas cards (26px blur, border highlight).
  surface,

  /// Glass-2: Nested & elevated pods, status chips, segmented controls (20px blur).
  elevated,

  /// Glass-Floating: Detached bottom dock, floating action pills, modals (28px blur, deep shadow).
  floating,
}

/// Resolved parameters for rendering a frosted glass tier in the current theme.
class GlassTierConfig {
  final double blur;
  final Color fillColor;
  final Border border;
  final List<BoxShadow> boxShadow;

  const GlassTierConfig({
    required this.blur,
    required this.fillColor,
    required this.border,
    required this.boxShadow,
  });
}

/// Represents a single radial light bloom within the dynamic ambient mesh.
class MeshGlow {
  final double xPercent;
  final double yPercent;
  final Color color;
  final double radiusPercent;

  const MeshGlow({
    required this.xPercent,
    required this.yPercent,
    required this.color,
    this.radiusPercent = 0.55,
  });
}

/// Multi-point radial light mesh background palette.
class MeshPalette {
  final Color canvasColor;
  final List<MeshGlow> glows;

  const MeshPalette({
    required this.canvasColor,
    required this.glows,
  });

  /// Computes the dynamic liquid mesh palette based on the active primary accent,
  /// brightness, and whether OLED Pure Dark mode is enabled.
  static MeshPalette fromPrimary(
    Color primary,
    Brightness brightness,
    bool isPureDark,
  ) {
    if (brightness == Brightness.light) {
      return MeshPalette(
        canvasColor: const Color(0xFFF6F4FF),
        glows: [
          MeshGlow(
            xPercent: 0.08,
            yPercent: 0.10,
            color: primary.withValues(alpha: 0.25),
            radiusPercent: 0.55,
          ),
          MeshGlow(
            xPercent: 0.92,
            yPercent: 0.22,
            color: const Color(0xFF2DD4BF).withValues(alpha: 0.22),
            radiusPercent: 0.52,
          ),
          MeshGlow(
            xPercent: 0.15,
            yPercent: 0.72,
            color: const Color(0xFFFFB88C).withValues(alpha: 0.18),
            radiusPercent: 0.55,
          ),
          MeshGlow(
            xPercent: 0.88,
            yPercent: 0.85,
            color: primary.withValues(alpha: 0.22),
            radiusPercent: 0.60,
          ),
        ],
      );
    } else if (isPureDark) {
      // AMOLED Pure Black: pure #000000 canvas with restrained ambient halos
      return MeshPalette(
        canvasColor: const Color(0xFF000000),
        glows: [
          MeshGlow(
            xPercent: 0.15,
            yPercent: 0.12,
            color: primary.withValues(alpha: 0.22),
            radiusPercent: 0.48,
          ),
          MeshGlow(
            xPercent: 0.90,
            yPercent: 0.25,
            color: const Color(0xFF38BDF8).withValues(alpha: 0.16),
            radiusPercent: 0.45,
          ),
          MeshGlow(
            xPercent: 0.20,
            yPercent: 0.65,
            color: primary.withValues(alpha: 0.18),
            radiusPercent: 0.50,
          ),
          MeshGlow(
            xPercent: 0.85,
            yPercent: 0.82,
            color: const Color(0xFFF97316).withValues(alpha: 0.12),
            radiusPercent: 0.45,
          ),
        ],
      );
    } else {
      // Slate Dark Navy
      return MeshPalette(
        canvasColor: const Color(0xFF0C0F17),
        glows: [
          MeshGlow(
            xPercent: 0.10,
            yPercent: 0.12,
            color: primary.withValues(alpha: 0.22),
            radiusPercent: 0.55,
          ),
          MeshGlow(
            xPercent: 0.90,
            yPercent: 0.20,
            color: const Color(0xFF06B6D4).withValues(alpha: 0.18),
            radiusPercent: 0.52,
          ),
          MeshGlow(
            xPercent: 0.15,
            yPercent: 0.72,
            color: const Color(0xFF6366F1).withValues(alpha: 0.15),
            radiusPercent: 0.55,
          ),
          MeshGlow(
            xPercent: 0.85,
            yPercent: 0.85,
            color: primary.withValues(alpha: 0.20),
            radiusPercent: 0.60,
          ),
        ],
      );
    }
  }
}

/// Design system tokens and tier resolver for Frosted Glass surfaces.
abstract final class GlassTokens {
  /// Resolves the styling configuration for a given [GlassTier].
  static GlassTierConfig resolve(
    BuildContext context, {
    required GlassTier tier,
    Color? customFill,
    Border? customBorder,
    List<BoxShadow>? customShadow,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    final isPureDark = isDark &&
        (theme.scaffoldBackgroundColor == const Color(0xFF000000) ||
            theme.scaffoldBackgroundColor == Colors.black);

    switch (tier) {
      case GlassTier.surface: // Glass-1
        return GlassTierConfig(
          blur: isDark ? 24.0 : 26.0,
          fillColor: customFill ??
              (isPureDark
                  ? const Color.fromRGBO(22, 20, 34, 0.38)
                  : isDark
                      ? const Color.fromRGBO(19, 26, 42, 0.38)
                      : const Color.fromRGBO(255, 255, 255, 0.35)),
          border: customBorder ??
              Border.all(
                color: isPureDark
                    ? const Color.fromRGBO(255, 255, 255, 0.14)
                    : isDark
                        ? const Color.fromRGBO(255, 255, 255, 0.15)
                        : const Color.fromRGBO(255, 255, 255, 0.65),
                width: 1,
              ),
          boxShadow: customShadow ??
              (isPureDark
                  ? const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.40),
                        blurRadius: 32,
                        offset: Offset(0, 8),
                      ),
                    ]
                  : isDark
                      ? const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.25),
                            blurRadius: 32,
                            offset: Offset(0, 8),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.08),
                            blurRadius: 32,
                            offset: const Offset(0, 8),
                          ),
                        ]),
        );

      case GlassTier.elevated: // Glass-2
        return GlassTierConfig(
          blur: 20.0,
          fillColor: customFill ??
              (isDark
                  ? const Color.fromRGBO(255, 255, 255, 0.05)
                  : const Color.fromRGBO(255, 255, 255, 0.45)),
          border: customBorder ??
              Border.all(
                color: isDark
                    ? const Color.fromRGBO(255, 255, 255, 0.12)
                    : const Color.fromRGBO(255, 255, 255, 0.60),
                width: 1,
              ),
          boxShadow: customShadow ??
              (isDark
                  ? const []
                  : const [
                      BoxShadow(
                        color: Color.fromRGBO(255, 255, 255, 0.75),
                        blurRadius: 1,
                        offset: Offset(0, 0.5),
                      ),
                    ]),
        );

      case GlassTier.floating: // Glass-Floating
        return GlassTierConfig(
          blur: 28.0,
          fillColor: customFill ??
              (isPureDark
                  ? const Color.fromRGBO(14, 13, 24, 0.45)
                  : isDark
                      ? const Color.fromRGBO(15, 20, 32, 0.45)
                      : const Color.fromRGBO(255, 255, 255, 0.35)),
          border: customBorder ??
              Border.all(
                color: isPureDark
                    ? const Color.fromRGBO(255, 255, 255, 0.18)
                    : isDark
                        ? const Color.fromRGBO(255, 255, 255, 0.18)
                        : const Color.fromRGBO(255, 255, 255, 0.70),
                width: 1,
              ),
          boxShadow: customShadow ??
              (isPureDark
                  ? const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.60),
                        blurRadius: 48,
                        offset: Offset(0, 20),
                      ),
                    ]
                  : isDark
                      ? const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.35),
                            blurRadius: 36,
                            offset: Offset(0, 16),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.15),
                            blurRadius: 36,
                            offset: const Offset(0, 16),
                          ),
                        ]),
        );
    }
  }

  /// Tinted 1px hairline color resolving to `primary.withOpacity(0.08)` in light mode,
  /// and `Colors.white.withOpacity(0.08)` in dark mode.
  static Color hairlineColor(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    if (isDark) {
      return const Color.fromRGBO(255, 255, 255, 0.08);
    }
    return theme.colorScheme.primary.withValues(alpha: 0.08);
  }
}
