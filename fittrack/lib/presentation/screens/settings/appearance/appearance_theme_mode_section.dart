import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/theme_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Segmented theme mode selector (Light, Dark, System) matching Stitch specification.
class AppearanceThemeModeSection extends ConsumerWidget {
  const AppearanceThemeModeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeNotifierProvider);
    final accentColor = themeSettings.accentColor;
    final activeMode = themeSettings.themeMode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final theme = Theme.of(context);
    final textPrimary = theme.colorScheme.onSurface;
    final textMuted = theme.colorScheme.onSurface.withValues(alpha: 0.60);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'THEME MODE',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: textMuted,
              ),
            ),
            Text(
              'Applied Globally',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textMuted.withValues(alpha: 0.80),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Row of 3 Cards
        Row(
          children: [
            Expanded(
              child: _ThemeModeCard(
                mode: ThemeMode.light,
                title: 'Light',
                subtitle: 'Crisp slate',
                icon: Icons.light_mode_outlined,
                isSelected: activeMode == ThemeMode.light,
                accentColor: accentColor,
                textPrimary: textPrimary,
                textMuted: textMuted,
                isDark: isDark,
                onTap: () => ref
                    .read(themeNotifierProvider.notifier)
                    .setThemeMode(ThemeMode.light),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ThemeModeCard(
                mode: ThemeMode.dark,
                title: 'Dark',
                subtitle: 'Low-glare',
                icon: Icons.dark_mode_outlined,
                isSelected: activeMode == ThemeMode.dark,
                accentColor: accentColor,
                textPrimary: textPrimary,
                textMuted: textMuted,
                isDark: isDark,
                onTap: () => ref
                    .read(themeNotifierProvider.notifier)
                    .setThemeMode(ThemeMode.dark),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ThemeModeCard(
                mode: ThemeMode.system,
                title: 'System',
                subtitle: 'Auto sync',
                icon: Icons.brightness_auto_outlined,
                isSelected: activeMode == ThemeMode.system,
                accentColor: accentColor,
                textPrimary: textPrimary,
                textMuted: textMuted,
                isDark: isDark,
                onTap: () => ref
                    .read(themeNotifierProvider.notifier)
                    .setThemeMode(ThemeMode.system),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ThemeModeCard extends StatelessWidget {
  final ThemeMode mode;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final Color accentColor;
  final Color textPrimary;
  final Color textMuted;
  final bool isDark;
  final VoidCallback onTap;

  const _ThemeModeCard({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.accentColor,
    required this.textPrimary,
    required this.textMuted,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FtPressable(
      onTap: onTap,
      pressedScale: 0.96,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0x331E293B)
                  : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? accentColor
                    : (isDark ? const Color(0x33FFFFFF) : const Color(0xFFE2E8F0)),
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.20),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accentColor.withValues(alpha: 0.15)
                        : (isDark
                            ? const Color(0x33FFFFFF)
                            : const Color(0xFFF1F5F9)),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 19,
                    color: isSelected ? accentColor : textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? accentColor : textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                // Subtitle
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Selected Checkmark Pill
          if (isSelected)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 11,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
