import 'package:flutter/material.dart';
import '../../domain/entities/theme_settings.dart';
import 'app_colors.dart';

/// Style configuration for muscle group pill badges.
@immutable
class MusclePillStyle {
  final Color background;
  final Color foreground;
  final Color border;

  const MusclePillStyle({
    required this.background,
    required this.foreground,
    required this.border,
  });
}

/// Theme extension to provide theme-adaptive styling for muscle tags across Light, Slate, and OLED Dark.
@immutable
class MuscleThemeExtension extends ThemeExtension<MuscleThemeExtension> {
  final Map<String, MusclePillStyle> styles;

  const MuscleThemeExtension({required this.styles});

  MusclePillStyle styleFor(String muscle) {
    return styles[muscle.toLowerCase()] ??
        styles['default'] ??
        const MusclePillStyle(
          background: Colors.transparent,
          foreground: Colors.grey,
          border: Colors.transparent,
        );
  }

  @override
  MuscleThemeExtension copyWith({Map<String, MusclePillStyle>? styles}) {
    return MuscleThemeExtension(styles: styles ?? this.styles);
  }

  @override
  MuscleThemeExtension lerp(ThemeExtension<MuscleThemeExtension>? other, double t) {
    if (other is! MuscleThemeExtension) return this;
    return this;
  }
}

/// Helper extension on [BuildContext] for Stitch card decoration rules:
/// - Light Mode: Pure white background, NO outline border (`border: null`), soft drop shadow (`Color(0x080F172A)`, blur 16, offset (0, 4)).
/// - Dark / OLED Modes: `colorScheme.surface` background, thin border (`colorScheme.outline`), NO harsh shadow.
extension FitTrackCardThemeX on BuildContext {
  BoxDecoration fitTrackCardDecoration({
    BorderRadiusGeometry borderRadius = const BorderRadius.all(Radius.circular(20)),
  }) {
    final theme = Theme.of(this);
    final isLight = theme.brightness == Brightness.light;
    return BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: borderRadius,
      border: isLight ? null : Border.all(color: theme.colorScheme.outline, width: 1),
      boxShadow: isLight
          ? const [
              BoxShadow(
                color: Color(0x080F172A),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ]
          : null,
    );
  }
}

const _lightMuscleTheme = MuscleThemeExtension(
  styles: {
    'chest': MusclePillStyle(
      background: Color(0xFFFFF1F2),
      foreground: Color(0xFFBE123C),
      border: Color(0xFFFECDD3),
    ),
    'shoulders': MusclePillStyle(
      background: Color(0xFFFFFBEB),
      foreground: Color(0xFFB45309),
      border: Color(0xFFFDE68A),
    ),
    'triceps': MusclePillStyle(
      background: Color(0xFFF0FDFA),
      foreground: Color(0xFF0F766E),
      border: Color(0xFF99F6E4),
    ),
    'back': MusclePillStyle(
      background: Color(0xFFF0FDF4),
      foreground: Color(0xFF15803D),
      border: Color(0xFFBBF7D0),
    ),
    'biceps': MusclePillStyle(
      background: Color(0xFFFDF4FF),
      foreground: Color(0xFF7E22CE),
      border: Color(0xFFF5D0FE),
    ),
    'legs': MusclePillStyle(
      background: Color(0xFFEFF6FF),
      foreground: Color(0xFF1D4ED8),
      border: Color(0xFFBFDBFE),
    ),
    'quads': MusclePillStyle(
      background: Color(0xFFEFF6FF),
      foreground: Color(0xFF1D4ED8),
      border: Color(0xFFBFDBFE),
    ),
    'hamstrings': MusclePillStyle(
      background: Color(0xFFFEFCE8),
      foreground: Color(0xFFA16207),
      border: Color(0xFFFEF08A),
    ),
    'core': MusclePillStyle(
      background: Color(0xFFFFF7ED),
      foreground: Color(0xFFC2410C),
      border: Color(0xFFFED7AA),
    ),
    'calves': MusclePillStyle(
      background: Color(0xFFF0FDFA),
      foreground: Color(0xFF0F766E),
      border: Color(0xFF99F6E4),
    ),
    'default': MusclePillStyle(
      background: Color(0xFFF1F5F9),
      foreground: Color(0xFF475569),
      border: Color(0xFFE2E8F0),
    ),
  },
);

const _darkMuscleTheme = MuscleThemeExtension(
  styles: {
    'chest': MusclePillStyle(
      background: Color(0x334C0519),
      foreground: Color(0xFFFDA4AF),
      border: Color(0x4DF43F5E),
    ),
    'shoulders': MusclePillStyle(
      background: Color(0x33451A03),
      foreground: Color(0xFFFCD34D),
      border: Color(0x4DF59E0B),
    ),
    'triceps': MusclePillStyle(
      background: Color(0x33042F2E),
      foreground: Color(0xFF5EEAD4),
      border: Color(0x4D14B8A6),
    ),
    'back': MusclePillStyle(
      background: Color(0x33052E16),
      foreground: Color(0xFF86EFAC),
      border: Color(0x4D22C55E),
    ),
    'biceps': MusclePillStyle(
      background: Color(0x333B0764),
      foreground: Color(0xFFD8B4FE),
      border: Color(0x4DA855F7),
    ),
    'legs': MusclePillStyle(
      background: Color(0x33172554),
      foreground: Color(0xFF93C5FD),
      border: Color(0x4D3B82F6),
    ),
    'quads': MusclePillStyle(
      background: Color(0x33172554),
      foreground: Color(0xFF93C5FD),
      border: Color(0x4D3B82F6),
    ),
    'hamstrings': MusclePillStyle(
      background: Color(0x33422006),
      foreground: Color(0xFFFDE047),
      border: Color(0x4DEAB308),
    ),
    'core': MusclePillStyle(
      background: Color(0x33431407),
      foreground: Color(0xFFFDBA74),
      border: Color(0x4DF97316),
    ),
    'calves': MusclePillStyle(
      background: Color(0x33042F2E),
      foreground: Color(0xFF5EEAD4),
      border: Color(0x4D14B8A6),
    ),
    'default': MusclePillStyle(
      background: Color(0x331E293B),
      foreground: Color(0xFF94A3B8),
      border: Color(0x4D475569),
    ),
  },
);

/// Creates the FitTrack fallback [ThemeData] with the Kinetic Slate system.
ThemeData buildAppTheme([ThemeSettings? settings]) {
  return buildLightTheme(settings ?? const ThemeSettings());
}

/// Builds the Light theme based on [ThemeSettings] and optional [dynamicScheme].
ThemeData buildLightTheme(ThemeSettings settings, [ColorScheme? dynamicScheme]) {
  final seedColor = Color(settings.accentColorValue);
  var colorScheme = (settings.useDynamicAccent && dynamicScheme != null)
      ? dynamicScheme
      : ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        );

  colorScheme = colorScheme.copyWith(
    surface: const Color(0xFFFFFFFF),
    surfaceContainer: const Color(0xFFF1F5F9),
    outline: Colors.transparent,
    outlineVariant: const Color(0xFFE2E8F0),
    shadow: const Color(0xFF0F172A),
    tertiary: const Color(0xFFF97316),
    secondary: const Color(0xFF0D9488),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: const Color(0xFFF7F9FB),
    cardColor: const Color(0xFFFFFFFF),
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFFFFFFFF),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    ),
    extensions: const [
      _lightMuscleTheme,
    ],
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.03 * 36,
        color: AppColors.slateDark,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.02 * 28,
        color: AppColors.slateDark,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 22,
        color: AppColors.slateDark,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.01 * 16,
        color: AppColors.slateDark,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.slateDark,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.slate700,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.slate600,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.06 * 12,
        color: AppColors.slateDark,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.08 * 10,
        color: AppColors.slate500,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.slate200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.slate200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorRed),
      ),
    ),
  );
}

/// Builds the Dark theme based on [ThemeSettings] and optional [dynamicScheme].
/// Configures Slate Dark (#0B131F / #15202E / #1C2A3D) or Pure OLED Black (#000000 / #0C1017 / #141A24).
ThemeData buildDarkTheme(ThemeSettings settings, [ColorScheme? dynamicScheme]) {
  final seedColor = Color(settings.accentColorValue);
  final isOled = settings.useOledBlack;

  var colorScheme = (settings.useDynamicAccent && dynamicScheme != null)
      ? dynamicScheme
      : ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        );

  if (isOled) {
    colorScheme = colorScheme.copyWith(
      surface: const Color(0xFF0C1017),
      surfaceContainer: const Color(0xFF141A24),
      outline: const Color(0xFF1F2633),
      outlineVariant: const Color(0xFF1F2633),
      surfaceTint: Colors.transparent,
      shadow: Colors.transparent,
      tertiary: const Color(0xFFFB923C),
      secondary: const Color(0xFF2DD4BF),
    );
  } else {
    colorScheme = colorScheme.copyWith(
      surface: const Color(0xFF15202E),
      surfaceContainer: const Color(0xFF1C2A3D),
      outline: const Color(0xFF212B3C),
      outlineVariant: const Color(0xFF212B3C),
      shadow: Colors.transparent,
      tertiary: const Color(0xFFFB923C),
      secondary: const Color(0xFF2DD4BF),
    );
  }

  final scaffoldBg = isOled ? const Color(0xFF000000) : const Color(0xFF0B131F);
  final cardColor = isOled ? const Color(0xFF0C1017) : const Color(0xFF15202E);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: scaffoldBg,
    cardColor: cardColor,
    cardTheme: CardThemeData(
      elevation: 0,
      color: cardColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    ),
    extensions: const [
      _darkMuscleTheme,
    ],
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.03 * 36,
        color: Colors.white,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.02 * 28,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 22,
        color: Colors.white,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.01 * 16,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Color(0xFFCBD5E1),
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: Color(0xFF94A3B8),
      ),
      labelLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.06 * 12,
        color: Colors.white,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.08 * 10,
        color: Color(0xFF94A3B8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isOled ? const Color(0xFF141A24) : const Color(0xFF1C2A3D),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isOled ? const Color(0xFF1F2633) : const Color(0xFF212B3C),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isOled ? const Color(0xFF1F2633) : const Color(0xFF212B3C),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorRed),
      ),
    ),
  );
}
