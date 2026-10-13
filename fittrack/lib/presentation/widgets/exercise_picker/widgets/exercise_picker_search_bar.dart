import 'package:flutter/material.dart';
import '../../../providers/theme_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../../screens/dashboard/widgets/ft_pressable.dart';

/// Search input bar with search icon, clear button, and glass container.
class ExercisePickerSearchBar extends StatelessWidget {
  const ExercisePickerSearchBar({
    super.key,
    required this.controller,
    required this.query,
    required this.onQueryChanged,
    required this.onClear,
    this.settings,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClear;
  final ThemeSettings? settings;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = context.ftPrimary;
    final ink = context.ftInk;
    final muted = context.ftMuted;

    final settings = this.settings ?? FtGlassTheme.resolveThemeSettings(context);
    final enableTransparency = settings?.enableGlassTransparency ?? true;
    final blurIntensity = settings?.blurIntensity ?? 16.0;
    final double t = enableTransparency
        ? ((blurIntensity - 4.0) / (32.0 - 4.0)).clamp(0.0, 1.0)
        : 1.0;

    final barFill = enableTransparency
        ? (isDark
            ? const Color(0x2EFFFFFF)
            : Colors.white.withValues(alpha: 0.40 + 0.20 * t))
        : (isDark ? const Color(0xFF221C38) : const Color(0xFFF1F5F9));
    final barBorder = enableTransparency
        ? (isDark
            ? const Color(0x33FFFFFF)
            : Colors.white.withValues(alpha: 0.50 + 0.25 * t))
        : (isDark ? const Color(0x33FFFFFF) : const Color(0xFFE2E8F0));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: barFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: barBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: isDark ? 0.08 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              size: 22,
              color: primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onQueryChanged,
                cursorColor: primary,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: ink,
                ),
                decoration: InputDecoration(
                  hintText: 'Search exercises',
                  hintStyle: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: muted.withValues(alpha: 0.7),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  filled: false,
                  fillColor: Colors.transparent,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (query.isNotEmpty)
              FtPressable(
                onTap: onClear,
                pressedScale: 0.90,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: muted,
                  ),
                ),
              )
            else
              Icon(
                Icons.tune_rounded,
                size: 19,
                color: muted.withValues(alpha: 0.7),
              ),
          ],
        ),
      ),
    );
  }
}
