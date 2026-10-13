import 'package:flutter/material.dart';
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
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = context.ftPrimary;
    final ink = context.ftInk;
    final muted = context.ftMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0x2EFFFFFF)
              : const Color(0xFFF7F1FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? const Color(0x26FFFFFF)
                : Colors.white.withValues(alpha: 0.9),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              size: 20,
              color: primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onQueryChanged,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ink,
                ),
                decoration: InputDecoration(
                  hintText: 'Search exercises',
                  hintStyle: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: muted.withValues(alpha: 0.8),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (query.isNotEmpty)
              FtPressable(
                onTap: onClear,
                pressedScale: 0.90,
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: muted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
