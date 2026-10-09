import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/theme_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';

/// Dynamic wallpaper / OS theme extraction card matching Stitch design.
class AppearanceDynamicAccentSection extends ConsumerWidget {
  const AppearanceDynamicAccentSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeNotifierProvider);
    final accentColor = themeSettings.accentColor;
    final isEnabled = themeSettings.useDynamicAccent;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final theme = Theme.of(context);
    final textPrimary = theme.colorScheme.onSurface;
    final textMuted = theme.colorScheme.onSurface.withValues(alpha: 0.60);

    return GlassSurface(
      tier: FtGlassTier.glass1,
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gradient icon container
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withValues(alpha: 0.25),
                  const Color(0xFFE879F9).withValues(alpha: 0.20),
                  const Color(0xFF2DD4BF).withValues(alpha: 0.20),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.80),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 21,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 12),

          // Title, BETA tag, and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'Dynamic Accent',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'BETA',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Sync palette with OS device wallpaper extraction (Material You & iOS Tint).',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textMuted,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Switch
          Switch(
            value: isEnabled,
            activeThumbColor: accentColor,
            activeTrackColor: accentColor.withValues(alpha: 0.35),
            onChanged: (val) => ref
                .read(themeNotifierProvider.notifier)
                .toggleDynamicAccent(val),
          ),
        ],
      ),
    );
  }
}
