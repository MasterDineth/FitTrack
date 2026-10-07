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

  // Glass Tiers
  // glass1: white 55% / white 75% / 0 8 32 rgba(95,59,220,.08) / white 85%
  static const FtGlassSpec glass1 = FtGlassSpec(
    fill: Color(0x8CFFFFFF), // 55%
    border: Color(0xBFFFFFFF), // 75%
    highlight: Color(0xD9FFFFFF), // 85%
    shadows: [
      BoxShadow(
        color: Color(0x145F3BDC), // rgba(95,59,220, 0.08)
        blurRadius: 32,
        offset: Offset(0, 8),
      ),
    ],
  );

  // glass2: white 65% / white 80% / none / white 85%
  static const FtGlassSpec glass2 = FtGlassSpec(
    fill: Color(0xA6FFFFFF), // 65%
    border: Color(0xCCFFFFFF), // 80%
    highlight: Color(0xD9FFFFFF), // 85%
    shadows: [],
  );

  // glassFloating: white 68% / white 85% / 0 16 36 rgba(95,59,220,.15) / white 90%, blur sigma 28
  static const FtGlassSpec glassFloating = FtGlassSpec(
    fill: Color(0xADFFFFFF), // 68%
    border: Color(0xD9FFFFFF), // 85%
    highlight: Color(0xE6FFFFFF), // 90%
    shadows: [
      BoxShadow(
        color: Color(0x265F3BDC), // rgba(95,59,220, 0.15)
        blurRadius: 36,
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

  static FtGlassSpec specFor(FtGlassTier tier) {
    switch (tier) {
      case FtGlassTier.glass1:
        return glass1;
      case FtGlassTier.glass2:
        return glass2;
      case FtGlassTier.glassFloating:
        return glassFloating;
    }
  }

  @override
  ThemeExtension<FtGlassTheme> copyWith() => this;

  @override
  ThemeExtension<FtGlassTheme> lerp(ThemeExtension<FtGlassTheme>? other, double t) => this;
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
