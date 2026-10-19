import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittrack/presentation/providers/theme_provider.dart';
import 'package:fittrack/presentation/screens/dashboard/widgets/ft_pressable.dart';
import 'package:fittrack/presentation/theme/ft_glass.dart';
import 'package:fittrack/presentation/widgets/glass_surface.dart';
import 'package:fittrack/presentation/widgets/modals/modal_backdrop_helper.dart';

/// Modern reusable text input modal bottom sheet with frosted-glass backdrop,
/// autofocusing large styled input field, and dynamic accent save button.
/// Strictly follows global glass transparency (on/off) and blur intensity settings.
class TextInputModal extends ConsumerStatefulWidget {
  final String title;
  final String initialValue;
  final String? subtitle;
  final TextInputType keyboardType;
  final String? suffixText;
  final String? hintText;

  const TextInputModal({
    super.key,
    required this.title,
    required this.initialValue,
    this.subtitle,
    this.keyboardType = TextInputType.text,
    this.suffixText,
    this.hintText,
  });

  static Future<String?> show({
    required BuildContext context,
    required String title,
    required String initialValue,
    String? subtitle,
    TextInputType keyboardType = TextInputType.text,
    String? suffixText,
    String? hintText,
  }) {
    return showBlurBottomSheet<String>(
      context: context,
      child: TextInputModal(
        title: title,
        initialValue: initialValue,
        subtitle: subtitle,
        keyboardType: keyboardType,
        suffixText: suffixText,
        hintText: hintText,
      ),
    );
  }

  @override
  ConsumerState<TextInputModal> createState() => _TextInputModalState();
}

class _TextInputModalState extends ConsumerState<TextInputModal> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.initialValue.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isNotEmpty) {
      Navigator.of(context).pop(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final ink = context.ftInk;
    final muted = context.ftMuted;
    final primary = context.ftPrimary;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    bool enableTransparency = true;
    double blurIntensity = 16.0;
    try {
      final (transparency, intensity) = ref.watch(
        themeNotifierProvider.select(
          (s) => (s.enableGlassTransparency, s.blurIntensity),
        ),
      );
      enableTransparency = transparency;
      blurIntensity = intensity;
    } catch (_) {}

    final double t = enableTransparency
        ? ((blurIntensity - 4.0) / (32.0 - 4.0)).clamp(0.0, 1.0)
        : 1.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(14, 10, 14, bottomInset + 10),
      child: GlassSurface(
        tier: FtGlassTier.glass1,
        radius: 32,
        backdrop: GlassBackdrop.live,
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          bottomPadding > 0 ? bottomPadding : 16,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: !enableTransparency
                        ? (isDark ? Colors.white38 : Colors.black26)
                        : (isDark ? Colors.white24 : Colors.black12),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Modal Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: ink,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            widget.subtitle!,
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: muted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FtPressable(
                    onTap: () => Navigator.of(context).pop(),
                    pressedScale: 0.90,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white12
                            : Colors.black.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: muted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Large Styled Input Field inside frosted glass container
              Container(
                decoration: BoxDecoration(
                  color: !enableTransparency
                      ? (isDark ? const Color(0xFF241D3B) : const Color(0xFFF1F5F9))
                      : (isDark
                          ? Colors.white.withValues(
                              alpha: (0.04 + 0.04 * t).clamp(0.03, 0.10))
                          : Colors.white.withValues(
                              alpha: (0.45 + 0.35 * t).clamp(0.40, 0.85))),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: !enableTransparency
                        ? (isDark ? Colors.white24 : const Color(0xFFCBD5E1))
                        : (isDark
                            ? Colors.white.withValues(
                                alpha: (0.08 + 0.08 * t).clamp(0.06, 0.18))
                            : const Color(0xFFE2E8F0)),
                    width: 1,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  keyboardType: widget.keyboardType,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: muted.withValues(alpha: 0.6),
                    ),
                    suffixText: widget.suffixText,
                    suffixStyle: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Full-Width Dynamic Accent Save Button
              FtPressable(
                onTap: _submit,
                pressedScale: 0.98,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primary.withValues(alpha: 0.95),
                        primary.withValues(alpha: 0.82),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.28),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.38),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Save Changes',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
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
    );
  }
}
