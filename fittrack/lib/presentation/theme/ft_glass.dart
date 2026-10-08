import 'package:flutter/material.dart';

/// Tier definition for FitTrack glass surfaces.
enum FtGlassTier {
  glass1,
  glass2,
  glassFloating,
}

/// Resolved tokens for a glass tier.
class FtGlassSpec {
  final Color fill;
  final Color border;
  final Color highlight;
  final List<BoxShadow> shadows;
  final double blurSigma;

  const FtGlassSpec({
    required this.fill,
    required this.border,
    required this.highlight,
    this.shadows = const [],
    this.blurSigma = 0,
  });
}

/// FitTrack Design Tokens and ThemeExtension for Glass and Stitch Styling.
@immutable
class FtGlassTheme extends ThemeExtension<FtGlassTheme> {
  // Brand Colors
  static const Color primary = Color(0xFF5F3BDC);
  static const Color primaryPressed = Color(0xFF491AC6);
  static const Color light = Color(0xFF9B7BFF);
  static const Color ink = Color(0xFF1D1735);
  static const Color muted = Color(0xFF6B6785);
  static const Color teal = Color(0xFF14B8A6);
  static const Color peach = Color(0xFFFEB78B);
  static const Color orange = Color(0xFFF97316);
  static const Color rose = Color(0xFFF43F5E);
  static const Color outlineVariant = Color(0xFFCAC4D7);
  static const Color canvas = Color(0xFFF6F4FF);

  // Amber Chip Tokens
  static const Color amberText = Color(0xFF92400E);
  static const Color amberFill = Color(0xFFFEF3C7);
  static const Color amberBorder = Color(0xFFFCD34D);

  // ── Light Mode Glass Tiers ────────────────────────────────────────────────
  // glass1: white 72% / white 85% / 0 8 32 rgba(95,59,220,.08) / white 90%
  static const FtGlassSpec glass1 = FtGlassSpec(
    fill: Color(0xB8FFFFFF), // 72%
    border: Color(0xD9FFFFFF), // 85%
    highlight: Color(0xE6FFFFFF), // 90%
    shadows: [
      BoxShadow(
        color: Color(0x145F3BDC), // rgba(95,59,220, 0.08)
        blurRadius: 32,
        offset: Offset(0, 8),
      ),
    ],
  );

  // glass2: white 80% / white 85% / none / white 90%
  static const FtGlassSpec glass2 = FtGlassSpec(
    fill: Color(0xCCFFFFFF), // 80%
    border: Color(0xD9FFFFFF), // 85%
    highlight: Color(0xE6FFFFFF), // 90%
    shadows: [],
  );

  // glassFloating: white 78% / white 90% / 0 16 36 rgba(124,92,250,.12) / white 95%, blur sigma 24
  static const FtGlassSpec glassFloating = FtGlassSpec(
    fill: Color(0xC7FFFFFF), // 78%
    border: Color(0xE6FFFFFF), // 90%
    highlight: Color(0xF2FFFFFF), // 95%
    shadows: [
      BoxShadow(
        color: Color(0x1F7C5CFA), // rgba(124,92,250, 0.12)
        blurRadius: 36,
        offset: Offset(0, 16),
      ),
    ],
    blurSigma: 24.0,
  );

  // ── Slate Dark Mode Glass Tiers (#0C0A18 / #0B131F) ────────────────────────
  // glass1Dark: rgba(22, 18, 38, 0.65) / border rgba(255,255,255,0.12) / shadow 0 12 36 rgba(0,0,0,0.5)
  static const FtGlassSpec glass1Dark = FtGlassSpec(
    fill: Color(0xA6161226), // rgba(22, 18, 38, 0.65)
    border: Color(0x1FFFFFFF), // rgba(255, 255, 255, 0.12)
    highlight: Color(0x24FFFFFF), // rgba(255, 255, 255, 0.14)
    shadows: [
      BoxShadow(
        color: Color(0x80000000), // rgba(0, 0, 0, 0.50)
        blurRadius: 36,
        offset: Offset(0, 12),
      ),
    ],
  );

  // glass2Dark: rgba(28, 22, 48, 0.75) / border rgba(255,255,255,0.10)
  static const FtGlassSpec glass2Dark = FtGlassSpec(
    fill: Color(0xBF1C1630), // rgba(28, 22, 48, 0.75)
    border: Color(0x1AFFFFFF), // rgba(255, 255, 255, 0.10)
    highlight: Color(0x24FFFFFF),
    shadows: [],
  );

  // glassFloatingDark: rgba(18, 14, 34, 0.76) / border rgba(255,255,255,0.14) / blur sigma 26
  static const FtGlassSpec glassFloatingDark = FtGlassSpec(
    fill: Color(0xC2120E22), // rgba(18, 14, 34, 0.76)
    border: Color(0x24FFFFFF), // rgba(255, 255, 255, 0.14)
    highlight: Color(0x29FFFFFF), // rgba(255, 255, 255, 0.16)
    shadows: [
      BoxShadow(
        color: Color(0x99000000), // rgba(0, 0, 0, 0.60)
        blurRadius: 40,
        offset: Offset(0, 16),
      ),
    ],
    blurSigma: 26.0,
  );

  // ── Pure AMOLED OLED Dark Mode Glass Tiers (#000000) ────────────────────────
  // glass1Oled: rgba(14, 14, 20, 0.72) / border rgba(255,255,255,0.09) / shadow 0 8 32 rgba(0,0,0,0.55)
  static const FtGlassSpec glass1Oled = FtGlassSpec(
    fill: Color(0xB80E0E14), // rgba(14, 14, 20, 0.72)
    border: Color(0x17FFFFFF), // rgba(255, 255, 255, 0.09)
    highlight: Color(0x1AFFFFFF),
    shadows: [
      BoxShadow(
        color: Color(0x8C000000), // rgba(0, 0, 0, 0.55)
        blurRadius: 32,
        offset: Offset(0, 8),
      ),
    ],
  );

  // glass2Oled: rgba(22, 22, 32, 0.65) / border rgba(255,255,255,0.07)
  static const FtGlassSpec glass2Oled = FtGlassSpec(
    fill: Color(0xA6161620), // rgba(22, 22, 32, 0.65)
    border: Color(0x12FFFFFF), // rgba(255, 255, 255, 0.07)
    highlight: Color(0x14FFFFFF),
    shadows: [],
  );

  // glassFloatingOled: rgba(12, 12, 18, 0.82) / border rgba(255,255,255,0.12) / blur sigma 28
  static const FtGlassSpec glassFloatingOled = FtGlassSpec(
    fill: Color(0xD10C0C12), // rgba(12, 12, 18, 0.82)
    border: Color(0x1FFFFFFF), // rgba(255, 255, 255, 0.12)
    highlight: Color(0x26FFFFFF),
    shadows: [
      BoxShadow(
        color: Color(0xCC000000), // rgba(0, 0, 0, 0.80)
        blurRadius: 40,
        offset: Offset(0, 16),
      ),
    ],
    blurSigma: 28.0,
  );

  // Corner Radii
  static const double radiusHero = 26.0;
  static const double radiusStackCards = 22.0;
  static const double radiusCards = 20.0;
  static const double radiusTiles = 12.0;
  static const double radiusIconTiles = 12.0;
  static const double radiusPill = 999.0;

  const FtGlassTheme();

  /// Resolves the glass specification for a given [tier] and optional [context].
  /// When [context] is provided, dynamically adapts between Light, Slate Dark,
  /// and Pure OLED Dark based on theme brightness and scaffold background.
  static FtGlassSpec specFor(FtGlassTier tier, [BuildContext? context]) {
    if (context == null) {
      switch (tier) {
        case FtGlassTier.glass1:
          return glass1;
        case FtGlassTier.glass2:
          return glass2;
        case FtGlassTier.glassFloating:
          return glassFloating;
      }
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isOled = isDark &&
        (theme.scaffoldBackgroundColor == Colors.black ||
            theme.scaffoldBackgroundColor == const Color(0xFF000000));

    if (!isDark) {
      switch (tier) {
        case FtGlassTier.glass1:
          return glass1;
        case FtGlassTier.glass2:
          return glass2;
        case FtGlassTier.glassFloating:
          return glassFloating;
      }
    }

    if (isOled) {
      switch (tier) {
        case FtGlassTier.glass1:
          return glass1Oled;
        case FtGlassTier.glass2:
          return glass2Oled;
        case FtGlassTier.glassFloating:
          return glassFloatingOled;
      }
    }

    // Default Dark: Slate Dark
    switch (tier) {
      case FtGlassTier.glass1:
        return glass1Dark;
      case FtGlassTier.glass2:
        return glass2Dark;
      case FtGlassTier.glassFloating:
        return glassFloatingDark;
    }
  }

  /// Theme-adaptive primary ink color for titles and strong text.
  static Color inkColor([BuildContext? context]) {
    if (context != null && Theme.of(context).brightness == Brightness.dark) {
      return Colors.white;
    }
    return ink;
  }

  /// Theme-adaptive muted text color for subtitles and captions.
  static Color mutedColor([BuildContext? context]) {
    if (context != null && Theme.of(context).brightness == Brightness.dark) {
      return const Color(0xFF94A3B8);
    }
    return muted;
  }

  @override
  ThemeExtension<FtGlassTheme> copyWith() => this;

  @override
  ThemeExtension<FtGlassTheme> lerp(ThemeExtension<FtGlassTheme>? other, double t) => this;
}

/// Convenience extension on [BuildContext] to access theme-adaptive tokens.
extension FtThemeContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  bool get isOled =>
      isDark &&
      (Theme.of(this).scaffoldBackgroundColor == Colors.black ||
          Theme.of(this).scaffoldBackgroundColor == const Color(0xFF000000));

  Color get ftPrimary => Theme.of(this).colorScheme.primary;

  Color get ftPrimaryLight => HSLColor.fromColor(ftPrimary)
      .withLightness((HSLColor.fromColor(ftPrimary).lightness + 0.20).clamp(0.0, 1.0))
      .toColor();

  Color get ftInk => isDark ? Colors.white : FtGlassTheme.ink;

  Color get ftMuted => isDark ? const Color(0xFF94A3B8) : FtGlassTheme.muted;

  Color get ftSubtext => isDark ? const Color(0xFFCBD5E1) : FtGlassTheme.muted;

  Color get ftCanvas => isDark
      ? Theme.of(this).scaffoldBackgroundColor
      : FtGlassTheme.canvas;

  FtGlassSpec glassSpec(FtGlassTier tier) => FtGlassTheme.specFor(tier, this);
}

/// Scalable Typography Hierarchy for FitTrack (Plus Jakarta Sans).
abstract final class FtText {
  static const String fontFamily = 'Plus Jakarta Sans';

  /// H1: 26/32, w800, tracking -0.025em (-0.65px)
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    height: 32 / 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.65,
    color: FtGlassTheme.ink,
  );

  /// Section Title: 20, w700
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: FtGlassTheme.ink,
  );

  /// Card Title: 12, w700
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: FtGlassTheme.ink,
  );

  /// Body: 12, w500
  static const TextStyle body12 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: FtGlassTheme.ink,
  );

  /// Body: 10, w500
  static const TextStyle body10 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: FtGlassTheme.ink,
  );

  /// Subtitle / Subtext: 14, w500, muted
  static const TextStyle sub14Muted = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: FtGlassTheme.muted,
  );

  /// Subtitle: 10, w500, muted
  static const TextStyle sub10Muted = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: FtGlassTheme.muted,
  );

  /// Micro Label: 11, w700
  static const TextStyle micro11 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: FtGlassTheme.ink,
  );

  /// Micro Label: 10, w700
  static const TextStyle micro10 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: FtGlassTheme.ink,
  );

  /// Micro Label: 9, w700
  static const TextStyle micro9 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 9,
    fontWeight: FontWeight.w700,
    color: FtGlassTheme.ink,
  );

  /// Uppercase Label: 11, w700, tracking 0.05em (+0.55px)
  static const TextStyle uppercase11 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.55,
    color: FtGlassTheme.muted,
  );

  /// Uppercase Label: 10, w700, tracking 0.05em (+0.50px)
  static const TextStyle uppercase10 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.50,
    color: FtGlassTheme.muted,
  );

  /// Uppercase Label: 9, w700, tracking 0.05em (+0.45px)
  static const TextStyle uppercase9 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 9,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.45,
    color: FtGlassTheme.muted,
  );

  /// Numbers: w800
  static TextStyle number(double size, {Color color = FtGlassTheme.ink}) => TextStyle(
    fontFamily: fontFamily,
    fontSize: size,
    fontWeight: FontWeight.w800,
    color: color,
  );

  /// Unit span inside number: smaller w700 muted
  static TextStyle unit(double size, {Color color = FtGlassTheme.muted}) => TextStyle(
    fontFamily: fontFamily,
    fontSize: size,
    fontWeight: FontWeight.w700,
    color: color,
  );
}
