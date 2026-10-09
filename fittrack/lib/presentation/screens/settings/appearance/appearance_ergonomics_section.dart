import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/theme_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Ergonomics and Accessibility switches, including Frosted Glass Transparency,
/// real-time Blur Intensity interactive telemetry plate, OLED mode, and workout display controls.
class AppearanceErgonomicsSection extends ConsumerWidget {
  const AppearanceErgonomicsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeNotifierProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    final accentColor = themeSettings.accentColor;
    final isLightMode = themeSettings.themeMode == ThemeMode.light;

    final theme = Theme.of(context);
    final textPrimary = theme.colorScheme.onSurface;
    final textMuted = theme.colorScheme.onSurface.withValues(alpha: 0.60);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Text(
          'ERGONOMICS & ACCESSIBILITY',
          style: TextStyle(
            fontFamily: FtText.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: textMuted,
          ),
        ),
        const SizedBox(height: 10),

        // Settings Container Card
        GlassSurface(
          tier: FtGlassTier.glass1,
          radius: 20,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // 1. Frosted Glass Transparency Row
              _buildSwitchRow(
                icon: Icons.blur_on_rounded,
                title: 'Frosted Glass Transparency',
                subtitle:
                    'Render translucent frosted glass surfaces with real-time backdrop blur.',
                value: themeSettings.enableGlassTransparency,
                accentColor: accentColor,
                textPrimary: textPrimary,
                textMuted: textMuted,
                isDark: isDark,
                onChanged: (val) => themeNotifier.toggleGlassTransparency(val),
              ),

              // 2. Blur Intensity Slider & Live Frosted Blur Plate
              if (themeSettings.enableGlassTransparency) ...[
                _buildDivider(isDark),
                _buildBlurIntensityControls(
                  themeSettings: themeSettings,
                  themeNotifier: themeNotifier,
                  accentColor: accentColor,
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  isDark: isDark,
                ),
              ],

              _buildDivider(isDark),

              // 3. Pure Black OLED Mode (Disabled in Light Mode)
              IgnorePointer(
                ignoring: isLightMode,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLightMode ? 0.35 : 1.0,
                  child: _buildSwitchRow(
                    icon: Icons.contrast_rounded,
                    title: 'Pure Black OLED Mode',
                    subtitle:
                        'Turns dark slate into #000000 to maximize pixel power saving.',
                    value: themeSettings.useOledBlack,
                    accentColor: accentColor,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    isDark: isDark,
                    onChanged: (val) => themeNotifier.toggleOledBlack(val),
                  ),
                ),
              ),

              _buildDivider(isDark),

              // 4. High Contrast Text
              _buildSwitchRow(
                icon: Icons.text_fields_rounded,
                title: 'High Contrast Text',
                subtitle:
                    'Strengthen label contrast against subtle slate containers.',
                value: themeSettings.useHighContrast,
                accentColor: accentColor,
                textPrimary: textPrimary,
                textMuted: textMuted,
                isDark: isDark,
                onChanged: (val) => themeNotifier.toggleHighContrast(val),
              ),

              _buildDivider(isDark),

              // 5. Auto-Dark During Workouts
              _buildSwitchRow(
                icon: Icons.bedtime_outlined,
                title: 'Auto-Dark During Workouts',
                subtitle:
                    'Automatically switch to Dark Mode while an active workout is running.',
                value: themeSettings.autoDarkWorkout,
                accentColor: accentColor,
                textPrimary: textPrimary,
                textMuted: textMuted,
                isDark: isDark,
                onChanged: (val) => themeNotifier.toggleAutoDarkWorkout(val),
              ),

              _buildDivider(isDark),

              // 6. Keep Screen Awake
              _buildSwitchRow(
                icon: Icons.stay_current_portrait_outlined,
                title: 'Keep Screen Awake',
                subtitle:
                    'Prevent screen from sleeping or dimming while an active workout is in progress.',
                value: themeSettings.keepScreenAwake,
                accentColor: accentColor,
                textPrimary: textPrimary,
                textMuted: textMuted,
                isDark: isDark,
                onChanged: (val) => themeNotifier.toggleKeepScreenAwake(val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? const Color(0x26FFFFFF) : const Color(0xFFF1F5F9),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color accentColor,
    required Color textPrimary,
    required Color textMuted,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 19,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textMuted,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            activeThumbColor: accentColor,
            activeTrackColor: accentColor.withValues(alpha: 0.35),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildBlurIntensityControls({
    required ThemeSettings themeSettings,
    required ThemeNotifier themeNotifier,
    required Color accentColor,
    required Color textPrimary,
    required Color textMuted,
    required bool isDark,
  }) {
    final intensity = themeSettings.blurIntensity;
    final String intensityLabel = switch (intensity) {
      <= 8.0 => 'Subtle',
      <= 20.0 => 'Standard',
      _ => 'Intense',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        size: 17,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Blur Intensity',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.30),
                    ),
                  ),
                  child: Text(
                    '${intensity.round()}px · $intensityLabel',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Live Frosted Blur Diffusion Plate Swatch ───────────────────────
          _buildLiveFrostedBlurPlate(
            intensity: intensity,
            accentColor: accentColor,
            textPrimary: textPrimary,
            textMuted: textMuted,
          ),
          const SizedBox(height: 12),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: accentColor,
              inactiveTrackColor: accentColor.withValues(alpha: 0.20),
              thumbColor: accentColor,
              overlayColor: accentColor.withValues(alpha: 0.15),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: intensity.clamp(4.0, 32.0),
              min: 4.0,
              max: 32.0,
              divisions: 14,
              onChanged: (val) => themeNotifier.setBlurIntensity(val),
            ),
          ),

          // Scale Labels
          const FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '4px Subtle',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                SizedBox(width: 80),
                Text(
                  '16px Standard',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                SizedBox(width: 80),
                Text(
                  '32px Intense',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Interactive Preset Buttons ─────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _buildPresetButton(
                  label: 'Subtle',
                  pixelLabel: '4px',
                  isSelected: intensity <= 8.0,
                  accentColor: accentColor,
                  textMuted: textMuted,
                  onTap: () => themeNotifier.setBlurIntensity(4.0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPresetButton(
                  label: 'Standard',
                  pixelLabel: '16px',
                  isSelected: intensity > 8.0 && intensity <= 20.0,
                  accentColor: accentColor,
                  textMuted: textMuted,
                  onTap: () => themeNotifier.setBlurIntensity(16.0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPresetButton(
                  label: 'Intense',
                  pixelLabel: '32px',
                  isSelected: intensity > 20.0,
                  accentColor: accentColor,
                  textMuted: textMuted,
                  onTap: () => themeNotifier.setBlurIntensity(32.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Telemetry canvas with live diffusion plate that dynamically updates its translucency and blur.
  Widget _buildLiveFrostedBlurPlate({
    required double intensity,
    required Color accentColor,
    required Color textPrimary,
    required Color textMuted,
  }) {
    final plateAlpha = (0.35 + ((intensity - 4.0) / 28.0) * 0.45).clamp(0.20, 0.85);

    return Container(
      width: double.infinity,
      height: 136,
      decoration: BoxDecoration(
        color: const Color(0xFF0F111A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF334155).withValues(alpha: 0.6),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background Orbs
            Positioned(
              top: -20,
              right: -10,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.28),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -10,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x3314B8A6),
                ),
              ),
            ),

            // Telemetry Background Elements
            Positioned(
              top: 10,
              left: 14,
              right: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF43F5E).withValues(alpha: 0.20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                size: 14,
                                color: Color(0xFFFB7185),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '142 BPM',
                                  style: TextStyle(
                                    fontFamily: FtText.fontFamily,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Heart Rate',
                                  style: TextStyle(
                                    fontFamily: FtText.fontFamily,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Set 4/5',
                                style: TextStyle(
                                  fontFamily: FtText.fontFamily,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFCBD5E1),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.20),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'High Tempo',
                                style: TextStyle(
                                  fontFamily: FtText.fontFamily,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFFCD34D),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'FITTRACK ACTIVE TELEMETRY 8,420 STEPS',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            // Foreground Diffusion Plate Overlaid
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: plateAlpha * 0.22),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: (0.15 + plateAlpha * 0.25).clamp(0.2, 0.6)),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.insights_rounded,
                        size: 17,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Frosted Glass Preview',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Real-time diffusion plate',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.40),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 6,
                            color: Color(0xFF34D399),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'ACTIVE',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF6EE7B7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetButton({
    required String label,
    required String pixelLabel,
    required bool isSelected,
    required Color accentColor,
    required Color textMuted,
    required VoidCallback onTap,
  }) {
    return FtPressable(
      onTap: onTap,
      pressedScale: 0.94,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? accentColor
                : textMuted.withValues(alpha: 0.25),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : textMuted,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '($pixelLabel)',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.85)
                      : textMuted.withValues(alpha: 0.70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
