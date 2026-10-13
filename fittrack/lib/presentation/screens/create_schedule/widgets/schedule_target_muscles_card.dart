import 'package:flutter/material.dart';
import '../../../theme/ft_glass.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Target Muscles Section Card allowing up to 3 selected muscle groups.
/// Matching Stitch Screen ID 378f56a0b632436289e53841eb67b6fb.
class ScheduleTargetMusclesCard extends StatelessWidget {
  const ScheduleTargetMusclesCard({
    super.key,
    required this.selectedMuscles,
    required this.onToggleMuscle,
  });

  final List<String> selectedMuscles;
  final bool Function(String muscle) onToggleMuscle;

  static const List<String> allMuscles = [
    'Chest',
    'Shoulders',
    'Triceps',
    'Back',
    'Biceps',
    'Forearms',
    'Core',
    'Quads',
    'Hamstrings',
    'Glutes',
    'Calves',
  ];

  void _handleTap(BuildContext context, String muscle) {
    final success = onToggleMuscle(muscle);
    if (!success) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Maximum 3 target muscles allowed',
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          backgroundColor: context.ftPrimary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = context.ftPrimary;
    final ink = context.ftInk;
    final muted = context.ftMuted;

    final settings = FtGlassTheme.resolveThemeSettings(context);
    final enableTransparency = settings?.enableGlassTransparency ?? true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: FtGlassTheme.cardDecoration(
        context,
        radius: 24,
        settings: settings,
        customShadows: [
          BoxShadow(
            color: primary.withValues(alpha: isDark ? 0.12 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0x22FFFFFF)
                            : const Color(0xFFE6DEFF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.adjust_rounded,
                        size: 20,
                        color: primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'Target muscles',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedMuscles.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? primary.withValues(alpha: 0.3)
                        : const Color(0xFFE6DEFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${selectedMuscles.length} selected',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Text(
              'Pick all that apply (up to 3)',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: muted,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Chips Wrap Grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allMuscles.map((muscle) {
              final isSelected = selectedMuscles.contains(muscle);
              final unselectedChipFill = enableTransparency
                  ? (isDark ? const Color(0x1FFFFFFF) : Colors.white.withValues(alpha: 0.6))
                  : (isDark ? const Color(0xFF221C38) : const Color(0xFFF1F5F9));
              final unselectedChipBorder = enableTransparency
                  ? (isDark ? const Color(0x26FFFFFF) : Colors.white.withValues(alpha: 0.8))
                  : (isDark ? const Color(0x33FFFFFF) : const Color(0xFFE2E8F0));

              return FtPressable(
                onTap: () => _handleTap(context, muscle),
                pressedScale: 0.95,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primary
                        : unselectedChipFill,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? primary
                          : unselectedChipBorder,
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        muscle,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? Colors.white : ink,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.check_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
