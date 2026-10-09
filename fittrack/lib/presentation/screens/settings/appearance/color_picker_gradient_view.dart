import 'package:flutter/material.dart';

import '../../../theme/ft_glass.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Gradient Studio preview mode showcasing dual-stop ribbon, angle selector,
/// and preset gradient palettes.
class ColorPickerGradientView extends StatelessWidget {
  final Color stop1;
  final Color stop2;
  final int angle;
  final VoidCallback onSwap;
  final ValueChanged<int> onAngleChanged;
  final void Function(Color s1, Color s2) onPresetSelected;

  const ColorPickerGradientView({
    super.key,
    required this.stop1,
    required this.stop2,
    required this.angle,
    required this.onSwap,
    required this.onAngleChanged,
    required this.onPresetSelected,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Notice banner explaining single color support in current version
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF7C5CFA).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF7C5CFA).withValues(alpha: 0.25),
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF7C5CFA)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Gradient preview engine: FitTrack currently applies solid single accents. Selecting Stop 1 will set your primary accent.',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7C5CFA),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Dual-Stop Color Ribbon Card ──────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0x331E293B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? const Color(0x33FFFFFF) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              // Stop 1
              Flexible(
                child: _buildGradientStopPill(
                  stopNum: '1',
                  label: 'STOP 1',
                  color: stop1,
                  textPrimary: textPrimary,
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
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1A000000),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.swap_horiz_rounded,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Stop 2
              Flexible(
                child: _buildGradientStopPill(
                  stopNum: '2',
                  label: 'STOP 2',
                  color: stop2,
                  textPrimary: textPrimary,
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
                              ? const Color(0xFF7C5CFA)
                              : (isDark ? const Color(0xFF334155) : Colors.white),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF7C5CFA)
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
    required Color textPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
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
                  style: const TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7C5CFA),
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
}
