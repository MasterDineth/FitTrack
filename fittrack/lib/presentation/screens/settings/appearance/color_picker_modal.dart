import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/theme_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../dashboard/widgets/ft_pressable.dart';
import 'color_picker_gradient_view.dart';
import 'color_picker_single_view.dart';

/// Modal bottom sheet implementing the "FitTrack Color Picker - Fluid Dual Mode Studio"
/// from Stitch specification (ID: 0573f10ce2534515bcdef7a9953bfc47).
class ColorPickerModal extends ConsumerStatefulWidget {
  const ColorPickerModal({super.key});

  /// Static convenience launcher for the modal bottom sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) => const ColorPickerModal(),
    );
  }

  @override
  ConsumerState<ColorPickerModal> createState() => _ColorPickerModalState();
}

class _ColorPickerModalState extends ConsumerState<ColorPickerModal> {
  // Mode: 'single' (false) or 'gradient' (true)
  bool _isGradientMode = false;

  // Single color state (HSV)
  late double _hue; // 0.0 to 360.0
  late double _saturation; // 0.0 to 1.0
  final double _value = 0.96;

  // Gradient state
  Color _gradientStop1 = const Color(0xFF7C5CFA);
  Color _gradientStop2 = const Color(0xFF38BDF8);
  int _activeGradientStopIndex = 0; // 0 for Stop 1, 1 for Stop 2
  int _gradientAngle = 135;

  late final TextEditingController _singleHexController;
  late final TextEditingController _gradientHexController;

  @override
  void initState() {
    super.initState();
    final currentAccent = ref.read(themeNotifierProvider).accentColor;
    final hsv = HSVColor.fromColor(currentAccent);
    _hue = hsv.hue.clamp(0.0, 360.0);
    _saturation = hsv.saturation.clamp(0.05, 1.0);
    _singleHexController = TextEditingController(text: _colorToHex(_currentColor));
    _gradientHexController = TextEditingController(text: _colorToHex(_gradientStop1));
  }

  @override
  void dispose() {
    _singleHexController.dispose();
    _gradientHexController.dispose();
    super.dispose();
  }

  Color get _currentColor {
    return HSVColor.fromAHSV(1.0, _hue, _saturation, _value).toColor();
  }

  static String _colorToHex(Color color) {
    final v = color.toARGB32();
    return '#${(v & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  void _setSingleColorFromHex(String value) {
    String clean = value.replaceAll('#', '').trim();
    if (clean.length == 6) {
      final intVal = int.tryParse('FF$clean', radix: 16);
      if (intVal != null) {
        final col = Color(intVal);
        final hsv = HSVColor.fromColor(col);
        setState(() {
          _hue = hsv.hue.clamp(0.0, 360.0);
          _saturation = hsv.saturation.clamp(0.05, 1.0);
        });
      }
    }
  }

  void _applyAccent() {
    final colorToApply = _isGradientMode ? _gradientStop1 : _currentColor;
    ref.read(themeNotifierProvider.notifier).setAccentColor(colorToApply);
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      try {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Custom accent applied: ${_colorToHex(colorToApply)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } on Object catch (_) {
        // Ignored if test tree lacks active Scaffold
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final textPrimary = theme.colorScheme.onSurface;
    final textMuted = theme.colorScheme.onSurface.withValues(alpha: 0.60);
    final currentColor = _currentColor;
    final currentHex = _colorToHex(currentColor);
    final activeGradientColor = _activeGradientStopIndex == 0 ? _gradientStop1 : _gradientStop2;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: bottomInset),
      duration: const Duration(milliseconds: 150),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 412),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xB8151329)
                      : Colors.white.withValues(alpha: 0.88),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border.all(
                    color: isDark
                        ? const Color(0x33FFFFFF)
                        : const Color(0xF0FFFFFF),
                    width: 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x2E5F3BDC),
                      blurRadius: 40,
                      offset: Offset(0, -10),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag Handle Pill
                        Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: textMuted.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Header: Title & Segmented Mode Switch
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Custom Accent',
                                    style: TextStyle(
                                      fontFamily: FtText.fontFamily,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.3,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    'Configure theme tone & dynamic accents',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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

                            // Segmented Mode Toggle (Single vs Gradient) with Dynamic Accent Colors
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E1B33)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0x33FFFFFF)
                                      : const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildSegmentedTab(
                                    label: 'Single',
                                    isActive: !_isGradientMode,
                                    activeColor: currentColor,
                                    onTap: () => setState(() => _isGradientMode = false),
                                  ),
                                  _buildSegmentedTab(
                                    label: 'Gradient',
                                    isActive: _isGradientMode,
                                    activeColor: activeGradientColor,
                                    onTap: () => setState(() => _isGradientMode = true),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Main View: Single Mode vs Gradient Mode
                        if (!_isGradientMode)
                          ColorPickerSingleView(
                            hue: _hue,
                            saturation: _saturation,
                            value: _value,
                            currentColor: currentColor,
                            currentHex: currentHex,
                            hexController: _singleHexController,
                            onHueChanged: (newHue) {
                              setState(() {
                                _hue = newHue;
                                _singleHexController.text = _colorToHex(_currentColor);
                              });
                            },
                            onSaturationChanged: (newSat) {
                              setState(() {
                                _saturation = newSat;
                                _singleHexController.text = _colorToHex(_currentColor);
                              });
                            },
                            onColorSelected: (col) {
                              final hsv = HSVColor.fromColor(col);
                              setState(() {
                                _hue = hsv.hue.clamp(0.0, 360.0);
                                _saturation = hsv.saturation.clamp(0.05, 1.0);
                                _singleHexController.text = _colorToHex(col);
                              });
                            },
                            onHexSubmitted: _setSingleColorFromHex,
                          )
                        else
                          ColorPickerGradientView(
                            stop1: _gradientStop1,
                            stop2: _gradientStop2,
                            activeStopIndex: _activeGradientStopIndex,
                            angle: _gradientAngle,
                            onSelectStop: (idx) {
                              setState(() {
                                _activeGradientStopIndex = idx;
                                final activeCol = idx == 0 ? _gradientStop1 : _gradientStop2;
                                _gradientHexController.text = _colorToHex(activeCol);
                              });
                            },
                            onHueChanged: (newHue) {
                              setState(() {
                                final activeCol = _activeGradientStopIndex == 0 ? _gradientStop1 : _gradientStop2;
                                final oldHsv = HSVColor.fromColor(activeCol);
                                final newColor = HSVColor.fromAHSV(
                                  1.0,
                                  newHue,
                                  oldHsv.saturation,
                                  oldHsv.value.clamp(0.2, 0.98),
                                ).toColor();
                                if (_activeGradientStopIndex == 0) {
                                  _gradientStop1 = newColor;
                                } else {
                                  _gradientStop2 = newColor;
                                }
                                _gradientHexController.text = _colorToHex(newColor);
                              });
                            },
                            onSaturationChanged: (newSat) {
                              setState(() {
                                final activeCol = _activeGradientStopIndex == 0 ? _gradientStop1 : _gradientStop2;
                                final oldHsv = HSVColor.fromColor(activeCol);
                                final newColor = HSVColor.fromAHSV(
                                  1.0,
                                  oldHsv.hue,
                                  newSat,
                                  oldHsv.value.clamp(0.2, 0.98),
                                ).toColor();
                                if (_activeGradientStopIndex == 0) {
                                  _gradientStop1 = newColor;
                                } else {
                                  _gradientStop2 = newColor;
                                }
                                _gradientHexController.text = _colorToHex(newColor);
                              });
                            },
                            onSwap: () {
                              setState(() {
                                final tmp = _gradientStop1;
                                _gradientStop1 = _gradientStop2;
                                _gradientStop2 = tmp;
                                final activeCol = _activeGradientStopIndex == 0 ? _gradientStop1 : _gradientStop2;
                                _gradientHexController.text = _colorToHex(activeCol);
                              });
                            },
                            onAngleChanged: (a) => setState(() => _gradientAngle = a),
                            onPresetSelected: (s1, s2) {
                              setState(() {
                                _gradientStop1 = s1;
                                _gradientStop2 = s2;
                                final activeCol = _activeGradientStopIndex == 0 ? _gradientStop1 : _gradientStop2;
                                _gradientHexController.text = _colorToHex(activeCol);
                              });
                            },
                            hexController: _gradientHexController,
                            onHexSubmitted: (val) {
                              String clean = val.replaceAll('#', '').trim();
                              if (clean.length == 6) {
                                final intVal = int.tryParse('FF$clean', radix: 16);
                                if (intVal != null) {
                                  setState(() {
                                    final col = Color(intVal);
                                    if (_activeGradientStopIndex == 0) {
                                      _gradientStop1 = col;
                                    } else {
                                      _gradientStop2 = col;
                                    }
                                  });
                                }
                              }
                            },
                          ),

                        const SizedBox(height: 16),

                        // ── Primary Action Buttons ───────────────────────────
                        FtPressable(
                          onTap: _applyAccent,
                          pressedScale: 0.98,
                          child: Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isGradientMode
                                    ? [_gradientStop1, _gradientStop2]
                                    : [
                                        currentColor,
                                        currentColor.withValues(alpha: 0.85),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: currentColor.withValues(alpha: 0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 19,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isGradientMode ? 'Apply Solid Accent (Stop 1)' : 'Apply Accent',
                                    style: const TextStyle(
                                      fontFamily: FtText.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FtPressable(
                          onTap: () => Navigator.of(context).pop(),
                          pressedScale: 0.98,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: textMuted,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedTab({
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return FtPressable(
      onTap: onTap,
      pressedScale: 0.94,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive) ...[
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
