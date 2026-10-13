import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../theme/ft_glass.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Floating Save Panel docked above the bottom screen edge for Create Exercise.
/// Built with frosted glass styling and performance guardrails matching AGENTS.md.
class ExerciseSaveBar extends StatelessWidget {
  const ExerciseSaveBar({
    super.key,
    required this.isValid,
    required this.isSaving,
    required this.onSave,
  });

  final bool isValid;
  final bool isSaving;
  final VoidCallback onSave;

  void _handleTap(BuildContext context) {
    if (isSaving) return;
    if (!isValid) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please enter an exercise name',
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
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
      return;
    }
    onSave();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = context.ftPrimary;

    final settings = FtGlassTheme.resolveThemeSettings(context);
    final enableTransparency = settings?.enableGlassTransparency ?? true;
    final blurIntensity = settings?.blurIntensity ?? 16.0;

    final double t = ((blurIntensity - 4.0) / (32.0 - 4.0)).clamp(0.0, 1.0);
    final double effectiveSigma = enableTransparency ? (12.0 + 24.0 * t) : 0.0;

    final Color dockFill;
    final Color dockBorder;
    final List<BoxShadow> dockShadow;

    if (!enableTransparency) {
      dockFill = isDark ? const Color(0xFF1E1838) : Colors.white;
      dockBorder = isDark ? const Color(0x33FFFFFF) : const Color(0xFFE2E8F0);
      dockShadow = [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
    } else {
      final double fillAlpha = isDark ? (0.75 + 0.15 * t) : (0.72 + 0.14 * t);
      dockFill = isDark
          ? const Color(0xFF1E1838).withValues(alpha: fillAlpha)
          : Colors.white.withValues(alpha: fillAlpha);
      dockBorder = isDark
          ? const Color(0x3DFFFFFF)
          : Colors.white.withValues(alpha: 0.95);
      dockShadow = [
        BoxShadow(
          color: primary.withValues(alpha: isDark ? 0.28 : 0.14),
          blurRadius: 36,
          offset: const Offset(0, 10),
        ),
      ];
    }

    Widget dockContent = Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: dockFill,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: dockBorder,
          width: 1.2,
        ),
        boxShadow: dockShadow,
      ),
      child: FtPressable(
        onTap: () => _handleTap(context),
        pressedScale: 0.98,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isValid
                  ? [
                      context.ftPrimaryLight,
                      primary,
                    ]
                  : [
                      context.ftPrimaryLight.withValues(alpha: 0.85),
                      primary.withValues(alpha: 0.90),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: isValid ? 0.35 : 0.22),
                blurRadius: isValid ? 18 : 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSaving)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else ...[
                const Icon(
                  Icons.check_circle_rounded,
                  size: 22,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Save exercise',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return RepaintBoundary(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 393),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: enableTransparency && effectiveSigma > 0
                  ? BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: effectiveSigma,
                        sigmaY: effectiveSigma,
                      ),
                      child: dockContent,
                    )
                  : dockContent,
            ),
          ),
        ),
      ),
    );
  }
}
