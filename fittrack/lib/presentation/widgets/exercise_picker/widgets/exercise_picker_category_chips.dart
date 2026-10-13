import 'package:flutter/material.dart';
import '../../../theme/ft_glass.dart';
import '../../../screens/dashboard/widgets/ft_pressable.dart';

/// Horizontal scrolling ChoiceChips row for filtering exercises by category.
class ExercisePickerCategoryChips extends StatelessWidget {
  const ExercisePickerCategoryChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = context.ftPrimary;
    final ink = context.ftInk;

    final settings = FtGlassTheme.resolveThemeSettings(context);
    final enableTransparency = settings?.enableGlassTransparency ?? true;

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final cat = categories[i];
            final isSelected = cat == selectedCategory;

            final unselectedFill = enableTransparency
                ? (isDark ? const Color(0x22FFFFFF) : Colors.white.withValues(alpha: 0.7))
                : (isDark ? const Color(0xFF221C38) : const Color(0xFFF1F5F9));
            final unselectedBorder = enableTransparency
                ? (isDark ? const Color(0x22FFFFFF) : Colors.white.withValues(alpha: 0.85))
                : (isDark ? const Color(0x33FFFFFF) : const Color(0xFFE2E8F0));

            return FtPressable(
              onTap: () => onCategorySelected(cat),
              pressedScale: 0.94,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? primary
                      : unselectedFill,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : unselectedBorder,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? const Color(0xDDFFFFFF) : ink),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
