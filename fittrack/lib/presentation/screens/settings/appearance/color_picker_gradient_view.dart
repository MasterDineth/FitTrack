import 'package:flutter/material.dart';

import '../../../theme/ft_glass.dart';
import '../../dashboard/widgets/ft_pressable.dart';
import 'color_picker_single_view.dart';

/// Gradient Studio preview mode showcasing dual-stop ribbon, tactile Hue & Saturation
/// sliders for active stop customization, angle selector, and preset gradient palettes.
class ColorPickerGradientView extends StatelessWidget {
  final Color stop1;
  final Color stop2;
  final int activeStopIndex;
  final int angle;
  final ValueChanged<int> onSelectStop;
  final ValueChanged<double> onHueChanged;
  final ValueChanged<double> onSaturationChanged;
  final VoidCallback onSwap;
  final ValueChanged<int> onAngleChanged;
  final void Function(Color s1, Color s2) onPresetSelected;
  final TextEditingController hexController;
  final ValueChanged<String> onHexSubmitted;

  final bool enableGlass;

  const ColorPickerGradientView({
    super.key,
    required this.stop1,
    required this.stop2,
    required this.activeStopIndex,
    required this.angle,
    required this.onSelectStop,
    required this.onHueChanged,
    required this.onSaturationChanged,
    required this.onSwap,
    required this.onAngleChanged,
    required this.onPresetSelected,
    required this.hexController,
    required this.onHexSubmitted,
    this.enableGlass = true,
  });

  static const List<List<Color>> _presetGradients = [
    [Color(0xFF7C5CFA), Color(0xFF38BDF8)],
    [Color(0xFFF97316), Color(0xFFF43F5E)],
    [Color(0xFF10B981), Color(0xFF06B6D4)],
    [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    [Color(0xFFF59E0B), Color(0xFFEF4444)],
    [Color(0xFF2563EB), Color(0xFF38BDF8)],
  ];

  static String colorToHex(Color color) {
    final v = color.toARGB32();
    return '#${(v & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
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

    final activeColor = activeStopIndex == 0 ? stop1 : stop2;
    final hsv = HSVColor.fromColor(activeColor);
    final activeHue = hsv.hue;
    final activeSat = hsv.saturation;
    final activeVal = hsv.value.clamp(0.2, 0.98);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Dual-Stop Color Ribbon Card ──────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: cardBorderColor,
            ),
          ),
          child: Row(
            children: [
              // Stop 1
              Flexible(
                child: FtPressable(
                  onTap: () => onSelectStop(0),
                  pressedScale: 0.95,
                  child: _buildGradientStopPill(
                    stopNum: '1',
                    label: 'STOP 1',
                    color: stop1,
                    isSelected: activeStopIndex == 0,
                    textPrimary: textPrimary,
                    isDark: isDark,
                  ),
                ),
              ),
              // Center Flow Ribbon & Swap Button
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: LinearGradient(
                            colors: [stop1, stop2],
                          ),
                        ),
                      ),
                      FtPressable(
                        onTap: onSwap,
                        pressedScale: 0.90,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? const Color(0xFF334155) : Colors.white,
                            border: Border.all(
                              color: isDark ? const Color(0x33FFFFFF) : const Color(0xFFCBD5E1),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1A000000),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.swap_horiz_rounded,
                            size: 16,
                            color: isDark ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Stop 2
              Flexible(
                child: FtPressable(
                  onTap: () => onSelectStop(1),
                  pressedScale: 0.95,
                  child: _buildGradientStopPill(
                    stopNum: '2',
                    label: 'STOP 2',
                    color: stop2,
                    isSelected: activeStopIndex == 1,
                    textPrimary: textPrimary,
                    isDark: isDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Gradient Angle Selector ──────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0x331E293B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0x33FFFFFF) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Angle',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: textMuted,
                ),
              ),
              Row(
                children: [45, 90, 135, 180].map((a) {
                  final isSelected = angle == a;
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: FtPressable(
                      onTap: () => onAngleChanged(a),
                      pressedScale: 0.92,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? activeColor
                              : (isDark ? const Color(0xFF334155) : Colors.white),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? activeColor
                                : (isDark ? const Color(0x33FFFFFF) : const Color(0xFFCBD5E1)),
                          ),
                        ),
                        child: Text(
                          '$a°',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? Colors.white : textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Active Stop Hue Spectrum Slider ──────────────────────────────────
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
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.palette_outlined,
                          size: 15,
                          color: activeColor,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Hue (Stop ${activeStopIndex + 1})',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: activeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${activeHue.round()}° · ${ColorPickerSingleView.getHueFamily(activeHue)}',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: activeColor,
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
                            left: ((activeHue / 360.0) * (constraints.maxWidth - 20))
                                .clamp(0.0, constraints.maxWidth - 20),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: activeColor,
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
                                  color: activeColor,
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

        // ── Active Stop Saturation & Vibrancy Slider ─────────────────────────
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
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 15,
                          color: activeColor,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Saturation (Stop ${activeStopIndex + 1})',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: activeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${(activeSat * 100).round()}%',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: activeColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              LayoutBuilder(
                builder: (context, constraints) {
                  final fullySaturatedColor =
                      HSVColor.fromAHSV(1.0, activeHue, 1.0, activeVal).toColor();
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
                            left: (activeSat * (constraints.maxWidth - 20))
                                .clamp(0.0, constraints.maxWidth - 20),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: activeColor,
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
                                  color: activeColor,
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

        // ── Active Stop HEX Bar ──────────────────────────────────────────────
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
        const SizedBox(height: 12),

        // ── Preset Gradients ─────────────────────────────────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GRADIENT PRESETS',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _presetGradients.map((grad) {
                final isSelected = stop1 == grad[0] && stop2 == grad[1];
                return FtPressable(
                  onTap: () => onPresetSelected(grad[0], grad[1]),
                  pressedScale: 0.92,
                  child: Container(
                    width: 44,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: grad),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: grad[0].withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGradientStopPill({
    required String stopNum,
    required String label,
    required Color color,
    required bool isSelected,
    required Color textPrimary,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? color : (isDark ? const Color(0x33FFFFFF) : const Color(0xFFE2E8F0)),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                stopNum,
                style: const TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? color : const Color(0xFF7C5CFA),
                  ),
                ),
                Text(
                  colorToHex(color),
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
