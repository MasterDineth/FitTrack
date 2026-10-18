import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittrack/presentation/providers/theme_provider.dart';
import 'package:fittrack/presentation/screens/dashboard/widgets/ft_pressable.dart';
import 'package:fittrack/presentation/theme/ft_glass.dart';
import 'package:fittrack/presentation/widgets/glass_surface.dart';

/// Floating Frosted Action Dock for Account Details screen.
///
/// Only visible when an existing field is edited or new data is inserted.
/// Fully follows global frosted glass transparency toggle and blur intensity.
/// Provides:
/// - "Save changes" primary translucent gradient button
/// - "Discard changes" frosted glass translucent pill button
class AccountFloatingDock extends ConsumerWidget {
  final bool isVisible;
  final VoidCallback onSave;
  final VoidCallback onDiscard;

  const AccountFloatingDock({
    super.key,
    required this.isVisible,
    required this.onSave,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isVisible) return const SizedBox.shrink();
    final isDark = context.isDark;
    final primary = context.ftPrimary;

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

    final discardFill = !enableTransparency
        ? (isDark ? const Color(0xFF272042) : const Color(0xFFF1F5F9))
        : (isDark
            ? Colors.white.withValues(alpha: (0.05 + 0.08 * t).clamp(0.04, 0.16))
            : Colors.white.withValues(alpha: (0.45 + 0.35 * t).clamp(0.40, 0.85)));

    final discardBorder = !enableTransparency
        ? (isDark ? Colors.white24 : const Color(0xFFCBD5E1))
        : (isDark
            ? Colors.white.withValues(alpha: (0.10 + 0.10 * t).clamp(0.08, 0.25))
            : Colors.white.withValues(alpha: (0.60 + 0.35 * t).clamp(0.50, 0.95)));

    return AnimatedSlide(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      offset: isVisible ? Offset.zero : const Offset(0, 1.4),
      child: IgnorePointer(
        ignoring: !isVisible,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: GlassSurface(
            tier: FtGlassTier.glass1,
            radius: 28,
            backdrop: GlassBackdrop.live,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Save Changes Button ────────────────────────────────
                  FtPressable(
                    onTap: onSave,
                    pressedScale: 0.98,
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primary.withValues(alpha: 0.95),
                            primary.withValues(alpha: 0.82),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(100),
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
                            size: 19,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Save changes',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Discard Changes Frosted Translucent Pill ───────────
                  FtPressable(
                    onTap: onDiscard,
                    pressedScale: 0.98,
                    child: Container(
                      width: double.infinity,
                      height: 38,
                      decoration: BoxDecoration(
                        color: discardFill,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: discardBorder,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.20 : 0.04,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Discard changes',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xFFE2E8F0)
                                  : const Color(0xFF334155),
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
      );
    }
}
