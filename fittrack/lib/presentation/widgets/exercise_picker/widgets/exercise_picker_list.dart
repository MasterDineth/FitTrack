import 'package:flutter/material.dart';
import '../../../../domain/entities/exercise.dart';
import '../../../providers/theme_provider.dart';
import '../../../theme/ft_glass.dart';
import 'exercise_picker_row.dart';

/// List container displaying filtered selectable exercises or empty/loading state.
class ExercisePickerList extends StatelessWidget {
  const ExercisePickerList({
    super.key,
    required this.exercises,
    required this.selectedExerciseIds,
    required this.existingExerciseIds,
    required this.onToggleExercise,
    this.settings,
  });

  final List<Exercise> exercises;
  final Set<String> selectedExerciseIds;
  final Set<String> existingExerciseIds;
  final ValueChanged<Exercise> onToggleExercise;
  final ThemeSettings? settings;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final ink = context.ftInk;
    final muted = context.ftMuted;

    if (exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 40,
              color: muted.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 8),
            Text(
              'No exercises found',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try another search term or filter',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 12,
                color: muted,
              ),
            ),
          ],
        ),
      );
    }

    final settings = this.settings ?? FtGlassTheme.resolveThemeSettings(context);
    final enableTransparency = settings?.enableGlassTransparency ?? true;
    final blurIntensity = settings?.blurIntensity ?? 16.0;
    final double t = enableTransparency
        ? ((blurIntensity - 4.0) / (32.0 - 4.0)).clamp(0.0, 1.0)
        : 1.0;

    final listFill = enableTransparency
        ? (isDark
            ? const Color(0x1AFFFFFF)
            : Colors.white.withValues(alpha: 0.35 + 0.20 * t))
        : (isDark ? const Color(0xFF1E1838) : const Color(0xFFF8F6FF));
    final listBorder = enableTransparency
        ? (isDark
            ? const Color(0x22FFFFFF)
            : Colors.white.withValues(alpha: 0.45 + 0.25 * t))
        : (isDark ? const Color(0x33FFFFFF) : const Color(0xFFE2E8F0));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: listFill,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: listBorder,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 4),
          physics: const BouncingScrollPhysics(),
          itemCount: exercises.length,
          separatorBuilder: (_, _) => Divider(
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
            color: isDark
                ? const Color(0x1AFFFFFF)
                : const Color(0xFFF2EBFF),
          ),
          itemBuilder: (context, i) {
            final ex = exercises[i];
            final isSelected = selectedExerciseIds.contains(ex.id);
            final isAlreadyAdded = existingExerciseIds.contains(ex.id);
            return ExercisePickerRow(
              exercise: ex,
              isSelected: isSelected,
              isAlreadyInSchedule: isAlreadyAdded,
              onTap: () => onToggleExercise(ex),
            );
          },
        ),
      ),
    );
  }
}
