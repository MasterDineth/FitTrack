import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/theme_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Bottom action buttons: Save Appearance Preferences and Reset to System Defaults.
class AppearanceActionsSection extends ConsumerWidget {
  const AppearanceActionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeNotifierProvider);
    final accentColor = themeSettings.accentColor;
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

    final onAccentColor = accentColor.computeLuminance() > 0.55
        ? const Color(0xFF0F172A)
        : Colors.white;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textMuted = theme.colorScheme.onSurface.withValues(alpha: 0.70);

    return Column(
      children: [
        // 1. Save Appearance Preferences CTA
        FtPressable(
          onTap: () {
            HapticFeedback.lightImpact();
          },
          pressedScale: 0.98,
          child: Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_rounded,
                      size: 19,
                      color: onAccentColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Save Appearance Preferences',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: onAccentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // 2. Reset to System Defaults
        FtPressable(
          onTap: () async {
            HapticFeedback.mediumImpact();
            await themeNotifier.resetToDefaults();
          },
          pressedScale: 0.98,
          child: Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? const Color(0x331E293B) : Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0x33FFFFFF) : const Color(0xFFCBD5E1),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restart_alt_rounded,
                      size: 17,
                      color: textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Reset to System Defaults',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
