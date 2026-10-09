import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/theme_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../dashboard/widgets/ft_pressable.dart';
import 'color_picker_modal.dart';

class _AccentPreset {
  final Color color;
  final String label;
  final String fullName;

  const _AccentPreset({
    required this.color,
    required this.label,
    required this.fullName,
  });
}

const List<_AccentPreset> _presets = [
  _AccentPreset(
    color: Color(0xFF10B981),
    label: 'Mint',
    fullName: 'Kinetic Mint',
  ),
  _AccentPreset(
    color: Color(0xFF7C5CFA),
    label: 'Electric',
    fullName: 'Electric Blue',
  ),
  _AccentPreset(
    color: Color(0xFF4F46E5),
    label: 'Purple',
    fullName: 'Royal Purple',
  ),
  _AccentPreset(
    color: Color(0xFFF97316),
    label: 'Sunset',
    fullName: 'Sunset Orange',
  ),
  _AccentPreset(
    color: Color(0xFF14B8A6),
    label: 'Emerald',
    fullName: 'Emerald Green',
  ),
  _AccentPreset(
    color: Color(0xFFF43F5E),
    label: 'Crimson',
    fullName: 'Crimson Red',
  ),
  _AccentPreset(
    color: Color(0xFF2563EB),
    label: 'Cobalt',
    fullName: 'Cobalt Navy',
  ),
];

/// 4x2 Color Accent Palette section matching Stitch design,
/// including the interactive Custom Color swatch that launches [ColorPickerModal].
class AppearanceColorAccentSection extends ConsumerWidget {
  const AppearanceColorAccentSection({super.key});

  String _getActiveColorName(int colorValue) {
    for (final preset in _presets) {
      if (preset.color.toARGB32() == colorValue) {
        return preset.fullName;
      }
    }
    final hex = Color(colorValue).toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
    return 'Custom (#$hex)';
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeNotifierProvider);
    final accentColor = themeSettings.accentColor;
    final isDynamic = themeSettings.useDynamicAccent;
    final activeColorName = _getActiveColorName(themeSettings.accentColorValue);

    final theme = Theme.of(context);
    final textPrimary = theme.colorScheme.onSurface;
    final textMuted = theme.colorScheme.onSurface.withValues(alpha: 0.60);
    final isDark = theme.brightness == Brightness.dark;

    final isCustomColorActive = !_presets.any(
      (p) => p.color.toARGB32() == themeSettings.accentColorValue,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Header ──────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COLOR ACCENT',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Applies to buttons, activity bars, rings, and active pills.',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Text(
                activeColorName,
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
        const SizedBox(height: 10),

        // ── Accent Grid Card ────────────────────────────────────────────────
        IgnorePointer(
          ignoring: isDynamic,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isDynamic ? 0.40 : 1.0,
            child: GlassSurface(
              tier: FtGlassTier.glass1,
              radius: 20,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Row 1 of Swatches (Mint, Electric, Purple, Sunset)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPresetSwatch(
                        preset: _presets[0],
                        isSelected: themeSettings.accentColorValue == _presets[0].color.toARGB32(),
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        onTap: () => ref.read(themeNotifierProvider.notifier).setAccentColor(_presets[0].color),
                      ),
                      _buildPresetSwatch(
                        preset: _presets[1],
                        isSelected: themeSettings.accentColorValue == _presets[1].color.toARGB32(),
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        onTap: () => ref.read(themeNotifierProvider.notifier).setAccentColor(_presets[1].color),
                      ),
                      _buildPresetSwatch(
                        preset: _presets[2],
                        isSelected: themeSettings.accentColorValue == _presets[2].color.toARGB32(),
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        onTap: () => ref.read(themeNotifierProvider.notifier).setAccentColor(_presets[2].color),
                      ),
                      _buildPresetSwatch(
                        preset: _presets[3],
                        isSelected: themeSettings.accentColorValue == _presets[3].color.toARGB32(),
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        onTap: () => ref.read(themeNotifierProvider.notifier).setAccentColor(_presets[3].color),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Row 2 of Swatches (Emerald, Crimson, Cobalt, Custom)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPresetSwatch(
                        preset: _presets[4],
                        isSelected: themeSettings.accentColorValue == _presets[4].color.toARGB32(),
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        onTap: () => ref.read(themeNotifierProvider.notifier).setAccentColor(_presets[4].color),
                      ),
                      _buildPresetSwatch(
                        preset: _presets[5],
                        isSelected: themeSettings.accentColorValue == _presets[5].color.toARGB32(),
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        onTap: () => ref.read(themeNotifierProvider.notifier).setAccentColor(_presets[5].color),
                      ),
                      _buildPresetSwatch(
                        preset: _presets[6],
                        isSelected: themeSettings.accentColorValue == _presets[6].color.toARGB32(),
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        onTap: () => ref.read(themeNotifierProvider.notifier).setAccentColor(_presets[6].color),
                      ),
                      // 8. Custom Swatch Trigger
                      _buildCustomSwatch(
                        context: context,
                        isSelected: isCustomColorActive,
                        accentColor: accentColor,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Micro-bar: Selected HEX + Spectrum details button
                  Container(
                    padding: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: isDark ? const Color(0x33FFFFFF) : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.colorize_rounded,
                                size: 15,
                                color: accentColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Selected HEX: ',
                                style: TextStyle(
                                  fontFamily: FtText.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: textMuted,
                                ),
                              ),
                              Text(
                                _colorToHex(accentColor),
                                style: TextStyle(
                                  fontFamily: FtText.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 24),
                          FtPressable(
                            onTap: () => ColorPickerModal.show(context),
                            pressedScale: 0.94,
                            child: Row(
                              children: [
                                Text(
                                  'Spectrum details',
                                  style: TextStyle(
                                    fontFamily: FtText.fontFamily,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: accentColor,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 16,
                                  color: accentColor,
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
          ),
        ),
      ],
    );
  }

  Widget _buildPresetSwatch({
    required _AccentPreset preset,
    required bool isSelected,
    required Color textPrimary,
    required Color textMuted,
    required VoidCallback onTap,
  }) {
    final onCheckColor = preset.color.computeLuminance() > 0.55
        ? const Color(0xFF0F172A)
        : Colors.white;

    return FtPressable(
      onTap: onTap,
      pressedScale: 0.92,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: preset.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: preset.color.withValues(alpha: isSelected ? 0.45 : 0.15),
                  blurRadius: isSelected ? 12 : 4,
                  offset: const Offset(0, 2),
                ),
                if (isSelected)
                  BoxShadow(
                    color: preset.color.withValues(alpha: 0.35),
                    spreadRadius: 2,
                    blurRadius: 4,
                  ),
              ],
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    size: 19,
                    color: onCheckColor,
                  )
                : null,
          ),
          const SizedBox(height: 6),
          Text(
            preset.label,
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? textPrimary : textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomSwatch({
    required BuildContext context,
    required bool isSelected,
    required Color accentColor,
    required Color textPrimary,
    required Color textMuted,
    required bool isDark,
  }) {
    return FtPressable(
      onTap: () => ColorPickerModal.show(context),
      pressedScale: 0.92,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rainbow border container
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF472B6), // pink-400
                  Color(0xFF8B5CF6), // violet-500
                  Color(0xFF22D3EE), // cyan-400
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: isSelected ? 0.45 : 0.15),
                  blurRadius: isSelected ? 12 : 4,
                  offset: const Offset(0, 2),
                ),
                if (isSelected)
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.35),
                    spreadRadius: 2,
                    blurRadius: 4,
                  ),
              ],
            ),
            padding: const EdgeInsets.all(2.5),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? accentColor
                    : (isDark ? const Color(0xFF1E1B33) : Colors.white.withValues(alpha: 0.90)),
              ),
              child: Icon(
                isSelected ? Icons.check : Icons.palette_outlined,
                size: 19,
                color: isSelected
                    ? (accentColor.computeLuminance() > 0.55 ? const Color(0xFF0F172A) : Colors.white)
                    : (isDark ? const Color(0xFFC4B5FD) : const Color(0xFF6B21A8)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Custom',
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? textPrimary : textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
