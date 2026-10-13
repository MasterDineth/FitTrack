import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/ft_glass.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Single-mode color picker view featuring interactive Hue & Saturation
/// tactile sliders, active solid color card, presets, and HEX input.
class ColorPickerSingleView extends StatelessWidget {
  final double hue;
  final double saturation;
  final double value;
  final Color currentColor;
  final String currentHex;
  final TextEditingController hexController;
  final ValueChanged<double> onHueChanged;
  final ValueChanged<double> onSaturationChanged;
  final ValueChanged<Color> onColorSelected;
  final ValueChanged<String> onHexSubmitted;

  final bool enableGlass;

  const ColorPickerSingleView({
    super.key,
    required this.hue,
    required this.saturation,
    required this.value,
    required this.currentColor,
    required this.currentHex,
    required this.hexController,
    required this.onHueChanged,
    required this.onSaturationChanged,
    required this.onColorSelected,
    required this.onHexSubmitted,
    this.enableGlass = true,
  });

  static const List<Color> _presetColors = [
    Color(0xFF7C5CFA), // Violet
    Color(0xFFF97316), // Solar Flare
    Color(0xFF10B981), // Turbo Mint
    Color(0xFF8B5CF6), // Hyper Violet
    Color(0xFFF59E0B), // Nitro Gold
    Color(0xFF2563EB), // Cyber Ice
  ];

  static String getHueToneName(double hue) {
    if (hue < 15 || hue >= 345) return 'Red Bold';
    if (hue < 45) return 'Orange Warm';
    if (hue < 75) return 'Gold Kinetic';
    if (hue < 160) return 'Mint Fresh';
    if (hue < 195) return 'Teal Oceanic';
    if (hue < 240) return 'Electric Blue';
    if (hue < 290) return 'Violet Bold';
    return 'Magenta Flow';
  }

  static String getHueFamily(double hue) {
    if (hue < 15 || hue >= 345) return 'Red';
    if (hue < 45) return 'Orange';
    if (hue < 75) return 'Yellow';
    if (hue < 160) return 'Green';
    if (hue < 195) return 'Cyan';
    if (hue < 240) return 'Blue';
    if (hue < 290) return 'Violet';
    return 'Magenta';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = theme.colorScheme.onSurface;
    final textMuted = theme.colorScheme.onSurface.withValues(alpha: 0.60);

    final cardColor = enableGlass
        ? (isDark ? const Color(0x331E293B) : Colors.white.withValues(alpha: 0.70))
        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC));
    final cardBorderColor = enableGlass
        ? (isDark ? const Color(0x33FFFFFF) : const Color(0x66FFFFFF))
        : (isDark ? const Color(0x33FFFFFF) : const Color(0xFFE2E8F0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. Active Solid Color Card ───────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: cardBorderColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Swatch
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: currentColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: currentColor.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.palette_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              // Labels
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ACTIVE SOLID COLOR',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: Color(0xFF7C5CFA),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          currentHex,
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            getHueToneName(hue),
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Copy Button
              FtPressable(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: currentHex));
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Copied $currentHex to clipboard'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                pressedScale: 0.92,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0x33FFFFFF) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Icon(
                    Icons.content_copy_rounded,
                    size: 16,
                    color: textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── 2. Hue Spectrum Slider ───────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: cardBorderColor,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.palette_outlined,
                        size: 15,
                        color: Color(0xFF7C5CFA),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Hue Spectrum',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C5CFA).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${hue.round()}° · ${getHueFamily(hue)}',
                      style: const TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7C5CFA),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Rainbow Track Slider
              LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: (details) {
                      final dx = details.localPosition.dx.clamp(0.0, constraints.maxWidth);
                      final ratio = dx / constraints.maxWidth;
                      onHueChanged((ratio * 360.0).clamp(0.0, 360.0));
                    },
                    onTapDown: (details) {
                      final dx = details.localPosition.dx.clamp(0.0, constraints.maxWidth);
                      final ratio = dx / constraints.maxWidth;
                      onHueChanged((ratio * 360.0).clamp(0.0, 360.0));
                    },
                    child: SizedBox(
                      height: 24,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            height: 12,
                            width: constraints.maxWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFF0000),
                                  Color(0xFFFFFF00),
                                  Color(0xFF00FF00),
                                  Color(0xFF00FFFF),
                                  Color(0xFF0000FF),
                                  Color(0xFFFF00FF),
                                  Color(0xFFFF0000),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: ((hue / 360.0) * (constraints.maxWidth - 20))
                                .clamp(0.0, constraints.maxWidth - 20),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFF7C5CFA),
                                  width: 2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: currentColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildScaleLabel('0° Red'),
                  _buildScaleLabel('120° Green'),
                  _buildScaleLabel('240° Blue'),
                  _buildScaleLabel('360°'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── 3. Saturation & Vibrancy Slider ──────────────────────────────────
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: cardBorderColor,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.tune_rounded,
                        size: 15,
                        color: Color(0xFF7C5CFA),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Saturation & Vibrancy',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C5CFA).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${(saturation * 100).round()}%',
                      style: const TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7C5CFA),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              LayoutBuilder(
                builder: (context, constraints) {
                  final fullySaturatedColor =
                      HSVColor.fromAHSV(1.0, hue, 1.0, value).toColor();
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: (details) {
                      final dx = details.localPosition.dx.clamp(0.0, constraints.maxWidth);
                      final ratio = dx / constraints.maxWidth;
                      onSaturationChanged(ratio.clamp(0.05, 1.0));
                    },
                    onTapDown: (details) {
                      final dx = details.localPosition.dx.clamp(0.0, constraints.maxWidth);
                      final ratio = dx / constraints.maxWidth;
                      onSaturationChanged(ratio.clamp(0.05, 1.0));
                    },
                    child: SizedBox(
                      height: 24,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            height: 12,
                            width: constraints.maxWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF94A3B8),
                                  fullySaturatedColor,
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: (saturation * (constraints.maxWidth - 20))
                                .clamp(0.0, constraints.maxWidth - 20),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFF7C5CFA),
                                  width: 2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: currentColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildScaleLabel('0% Muted'),
                  _buildScaleLabel('50%'),
                  _buildScaleLabel('100% Kinetic'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── 4. Athletic Presets Swatches ─────────────────────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PRESETS',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: textMuted,
                  ),
                ),
                const Text(
                  'Palettes',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7C5CFA),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _presetColors.map((col) {
                final isSelected = col.toARGB32() == currentColor.toARGB32();
                return FtPressable(
                  onTap: () => onColorSelected(col),
                  pressedScale: 0.92,
                  child: Container(
                    width: 44,
                    height: 36,
                    decoration: BoxDecoration(
                      color: col,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: col.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ── 5. Hex Input & Pipette Bar ───────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: enableGlass
                      ? (isDark ? const Color(0x331E293B) : Colors.white.withValues(alpha: 0.85))
                      : (isDark ? const Color(0xFF1E293B) : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0x33FFFFFF) : const Color(0xFFCBD5E1),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'HEX',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: hexController,
                        onChanged: onHexSubmitted,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: textPrimary,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0x33FFFFFF) : const Color(0xFFCBD5E1),
                ),
              ),
              child: Icon(
                Icons.colorize_rounded,
                size: 18,
                color: textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScaleLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: FtText.fontFamily,
        fontSize: 9,
        fontWeight: FontWeight.w600,
        color: Color(0xFF94A3B8),
      ),
    );
  }
}
