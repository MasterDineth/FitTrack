import 'package:flutter/material.dart';
import '../../../screens/dashboard/widgets/ft_pressable.dart';
import '../../../theme/ft_glass.dart';

/// Floating Glass Footer with "Create new" and "Add X exercises" buttons.
/// Matching Stitch Screen ID 5c82f20a73eb45e9a4f95de877d5b4f9.
class ExercisePickerFooter extends StatelessWidget {
  const ExercisePickerFooter({
    super.key,
    required this.selectedCount,
    required this.onAddSelected,
    required this.onCreateNew,
  });

  final int selectedCount;
  final VoidCallback onAddSelected;
  final VoidCallback onCreateNew;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = context.ftPrimary;
    final ink = context.ftInk;

    final String addLabel = selectedCount <= 0
        ? 'Select exercises'
        : (selectedCount == 1 ? 'Add 1 exercise' : 'Add $selectedCount exercises');

    final bool canAdd = selectedCount > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xE61A162D)
              : Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? const Color(0x33FFFFFF)
                : Colors.white.withValues(alpha: 0.95),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: isDark ? 0.25 : 0.14),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            // "Create new" Button
            Expanded(
              child: FtPressable(
                onTap: onCreateNew,
                pressedScale: 0.96,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0x22FFFFFF)
                        : const Color(0xFFF7F1FF),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: primary.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        size: 18,
                        color: primary,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'Create new',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // "Add X exercises" Button
            Expanded(
              child: FtPressable(
                onTap: canAdd ? onAddSelected : null,
                pressedScale: canAdd ? 0.96 : 1.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: canAdd
                        ? LinearGradient(
                            colors: [
                              context.ftPrimaryLight,
                              primary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: canAdd
                        ? null
                        : (isDark ? const Color(0x1AFFFFFF) : const Color(0xFFECE4FF)),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: canAdd
                        ? [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.library_add_check_rounded,
                        size: 19,
                        color: canAdd
                            ? Colors.white
                            : (isDark ? const Color(0x66FFFFFF) : const Color(0xFF797586)),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          addLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: canAdd
                                ? Colors.white
                                : (isDark ? const Color(0x66FFFFFF) : const Color(0xFF797586)),
                          ),
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
    );
  }
}
