import 'dart:ui';
import 'package:flutter/material.dart';
import '../../providers/custom_exercise_notifier.dart';
import '../../screens/dashboard/widgets/ft_pressable.dart';
import '../../theme/ft_glass.dart';

/// Completely redesigned Add Form Cue Modal matching Stitch Screen ID 191021f928214acfa7c872d81df2b8e1.
///
/// Features:
/// - Frosted glass backdrop blur honoring Appearance settings.
/// - Top decorative gradient glow pill.
/// - Header with psychology_alt icon badge, title, and close button.
/// - Subtitle prompt guidance for coaching vs safety cues.
/// - Segmented Control (DO vs DON'T) with dynamic classification badge ("Correct Technique" vs "Common Fault / Risk").
/// - Instruction text input with live character counter (120 max), "Actionable voice" badge, and instant "Clear" action.
/// - Gradient CTA "Add Form Cue" and "Dismiss" button.
/// - Returns [FormCueDraft] on submit, or `null` when dismissed.
class AddFormCueDialog extends StatefulWidget {
  const AddFormCueDialog({super.key});

  /// Displays the modal with frosted background blur and returns [FormCueDraft]?
  static Future<FormCueDraft?> show(BuildContext context) async {
    final settings = FtGlassTheme.resolveThemeSettings(context);
    final enableTransparency = settings?.enableGlassTransparency ?? true;
    final blurIntensity = settings?.blurIntensity ?? 16.0;

    final double t = ((blurIntensity - 4.0) / (32.0 - 4.0)).clamp(0.0, 1.0);
    final double effectiveSigma = enableTransparency ? (8.0 + 16.0 * t) : 0.0;

    final result = await showDialog<FormCueDraft>(
      context: context,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.45),
      builder: (dialogContext) {
        Widget dialogWidget = const AddFormCueDialog();

        if (enableTransparency && effectiveSigma > 0) {
          dialogWidget = BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: effectiveSigma,
              sigmaY: effectiveSigma,
            ),
            child: dialogWidget,
          );
        }

        return dialogWidget;
      },
    );

    return result;
  }

  @override
  State<AddFormCueDialog> createState() => _AddFormCueDialogState();
}

class _AddFormCueDialogState extends State<AddFormCueDialog> {
  bool _isPositive = true;
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      _focusNode.requestFocus();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please enter cue instructions',
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          backgroundColor: const Color(0xFFF43F5E),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      FormCueDraft(
        isPositive: _isPositive,
        description: text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = context.ftPrimary;
    final ink = context.ftInk;
    final muted = context.ftMuted;
    final settings = FtGlassTheme.resolveThemeSettings(context);

    const tealColor = Color(0xFF2DD4BF);
    const roseColor = Color(0xFFF43F5E);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 350,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: FtGlassTheme.cardDecoration(
            context,
            radius: 28,
            settings: settings,
            customShadows: [
              BoxShadow(
                color: primary.withValues(alpha: isDark ? 0.35 : 0.16),
                blurRadius: 36,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top Decorative Pill ─────────────────────────────────────────
              Center(
                child: Container(
                  width: 56,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, tealColor],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Header Row ──────────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: isDark ? 0.20 : 0.10),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.psychology_alt_rounded,
                      color: primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Add Form Cue',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: ink,
                      ),
                    ),
                  ),
                  FtPressable(
                    onTap: () => Navigator.of(context).pop(),
                    pressedScale: 0.90,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0x1AFFFFFF)
                            : Colors.black.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: muted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Guidance Subtitle ───────────────────────────────────────────
              Text(
                'Equip athletes with vital biomechanical reminders. Toggle between coaching execution cues or safety faults.',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: muted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),

              // ── Cue Classification (Segmented DO vs DON'T) ───────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'CUE CLASSIFICATION',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: muted,
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _isPositive ? 'Correct Technique' : 'Common Fault / Risk',
                      key: ValueKey(_isPositive),
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _isPositive ? tealColor : roseColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Segmented Tabs Container
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0x1AFFFFFF)
                      : const Color(0xFFF1EDFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // DO Tab
                    Expanded(
                      child: FtPressable(
                        onTap: () => setState(() => _isPositive = true),
                        pressedScale: 0.97,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 38,
                          decoration: BoxDecoration(
                            color: _isPositive
                                ? (isDark ? const Color(0xFF2A2244) : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _isPositive
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 17,
                                color: _isPositive ? tealColor : muted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'DO',
                                style: TextStyle(
                                  fontFamily: FtText.fontFamily,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: _isPositive
                                      ? (_isPositive && isDark ? Colors.white : const Color(0xFF0F766E))
                                      : muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),

                    // DON'T Tab
                    Expanded(
                      child: FtPressable(
                        onTap: () => setState(() => _isPositive = false),
                        pressedScale: 0.97,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 38,
                          decoration: BoxDecoration(
                            color: !_isPositive
                                ? (isDark ? const Color(0xFF2A2244) : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: !_isPositive
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cancel_rounded,
                                size: 17,
                                color: !_isPositive ? roseColor : muted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "DON'T",
                                style: TextStyle(
                                  fontFamily: FtText.fontFamily,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: !_isPositive ? roseColor : muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── Instruction Text Input Area ─────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'INSTRUCTION TEXT',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: primary,
                    ),
                  ),
                  Text(
                    '${_controller.text.length} / 120',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0x1F1E1838)
                      : Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? const Color(0x33FFFFFF)
                        : Colors.white.withValues(alpha: 0.90),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLength: 120,
                      maxLines: 3,
                      minLines: 2,
                      buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ink,
                        height: 1.45,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: _isPositive
                            ? 'e.g. Keep chest up and pin shoulders back throughout movement'
                            : "e.g. Don't flare elbows out past 60 degrees",
                        hintStyle: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: muted.withValues(alpha: 0.65),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.tips_and_updates_rounded,
                              size: 15,
                              color: primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Actionable voice',
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                        if (_controller.text.isNotEmpty)
                          FtPressable(
                            onTap: () {
                              _controller.clear();
                              _focusNode.requestFocus();
                            },
                            pressedScale: 0.92,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Text(
                                'Clear',
                                style: TextStyle(
                                  fontFamily: FtText.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: roseColor,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // ── Action Buttons Footer ───────────────────────────────────────
              FtPressable(
                onTap: _submit,
                pressedScale: 0.98,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, primary.withValues(alpha: 0.88)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_rounded,
                        size: 19,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Add Form Cue',
                        style: TextStyle(
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
              const SizedBox(height: 8),

              FtPressable(
                onTap: () => Navigator.of(context).pop(),
                pressedScale: 0.96,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    'Dismiss',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: muted,
                    ),
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
