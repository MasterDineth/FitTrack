import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../theme/ft_glass.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Frosted Glass Discard Confirmation Dialog with blurred backdrop.
/// Displayed when the user attempts to exit the Create Schedule screen
/// with unsaved changes.
class ScheduleDiscardDialog extends StatelessWidget {
  const ScheduleDiscardDialog({super.key});

  /// Shows the dialog and returns true if the user confirmed discard, false otherwise.
  static Future<bool> show(BuildContext context) async {
    final settings = FtGlassTheme.resolveThemeSettings(context);
    final enableTransparency = settings?.enableGlassTransparency ?? true;
    final blurIntensity = settings?.blurIntensity ?? 16.0;

    final double t = ((blurIntensity - 4.0) / (32.0 - 4.0)).clamp(0.0, 1.0);
    final double effectiveSigma = enableTransparency ? (10.0 + 16.0 * t) : 0.0;

    final result = await showDialog<bool>(
      context: context,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.45),
      builder: (dialogContext) {
        Widget dialogWidget = const ScheduleDiscardDialog();

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

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final ink = context.ftInk;
    final muted = context.ftMuted;

    final settings = FtGlassTheme.resolveThemeSettings(context);
    final enableTransparency = settings?.enableGlassTransparency ?? true;
    final blurIntensity = settings?.blurIntensity ?? 16.0;
    final double t = enableTransparency
        ? ((blurIntensity - 4.0) / (32.0 - 4.0)).clamp(0.0, 1.0)
        : 1.0;

    final cancelBtnFill = isDark
        ? const Color(0x1FFFFFFF)
        : (enableTransparency
            ? Colors.white.withValues(alpha: 0.40 + 0.20 * t)
            : Colors.white.withValues(alpha: 0.85));
    final cancelBtnBorder = isDark
        ? const Color(0x33FFFFFF)
        : (enableTransparency
            ? Colors.white.withValues(alpha: 0.50 + 0.25 * t)
            : const Color(0xFFE2E8F0));

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 330,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: FtGlassTheme.cardDecoration(
            context,
            radius: 28,
            settings: settings,
            customShadows: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Warning Icon Badge ───────────────────────────────────────
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFBA1A1A).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFBA1A1A),
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),

              // ── Dialog Title ─────────────────────────────────────────────
              Text(
                'Discard schedule?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: ink,
                ),
              ),
              const SizedBox(height: 8),

              // ── Dialog Description ───────────────────────────────────────
              Text(
                'You have unsaved changes in this schedule. Discarding will lose all exercises and configurations.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: muted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),

              // ── Action Buttons ───────────────────────────────────────────
              Row(
                children: [
                  // Cancel / Keep editing
                  Expanded(
                    child: FtPressable(
                      onTap: () => Navigator.of(context).pop(false),
                      pressedScale: 0.96,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: cancelBtnFill,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: cancelBtnBorder,
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Keep editing',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: ink,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Discard button
                  Expanded(
                    child: FtPressable(
                      onTap: () => Navigator.of(context).pop(true),
                      pressedScale: 0.96,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFBA1A1A),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFBA1A1A).withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Discard',
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
