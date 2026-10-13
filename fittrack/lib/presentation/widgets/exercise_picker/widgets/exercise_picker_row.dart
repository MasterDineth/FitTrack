import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../domain/entities/exercise.dart';
import '../../../screens/dashboard/widgets/ft_pressable.dart';
import '../../../theme/ft_glass.dart';

/// Single selectable exercise item row in the Add Exercises Picker sheet.
/// Matching Stitch Screen ID 5c82f20a73eb45e9a4f95de877d5b4f9.
class ExercisePickerRow extends StatelessWidget {
  const ExercisePickerRow({
    super.key,
    required this.exercise,
    required this.isSelected,
    required this.onTap,
  });

  final Exercise exercise;
  final bool isSelected;
  final VoidCallback onTap;

  String _formatEnumName(String name) {
    if (name.isEmpty) return '';
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = context.ftPrimary;
    final ink = context.ftInk;
    final muted = context.ftMuted;

    return FtPressable(
      onTap: onTap,
      pressedScale: 0.98,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: isDark ? 0.18 : 0.09)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // 44x44 Thumbnail with border
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? primary.withValues(alpha: 0.35)
                      : (isDark ? const Color(0x33FFFFFF) : Colors.white.withValues(alpha: 0.8)),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: _buildCoverImage(context),
              ),
            ),
            const SizedBox(width: 12),

            // Exercise Title and Subtitle Tags
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: ink,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _formatEnumName(exercise.equipment.name),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: muted,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Container(
                          width: 3.5,
                          height: 3.5,
                          decoration: BoxDecoration(
                            color: muted.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          _formatEnumName(exercise.movementClassification.name),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Checkbox Indicator (28x28)
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? primary
                    : (isDark ? const Color(0x22FFFFFF) : const Color(0xFFF2EBFF)),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? primary
                      : (isDark ? const Color(0x33FFFFFF) : const Color(0xFFCAC4D7)),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    )
                  : Center(
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0x1AFFFFFF) : Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage(BuildContext context) {
    final media = exercise.mediaUrl;
    if (media != null && media.isNotEmpty) {
      if (File(media).existsSync()) {
        return Image.file(
          File(media),
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          cacheWidth: 88,
          cacheHeight: 88,
          errorBuilder: (_, _, _) => _buildFallbackImage(context),
        );
      }
      return Image.asset(
        media,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        cacheWidth: 88,
        cacheHeight: 88,
        errorBuilder: (_, _, _) => _buildFallbackImage(context),
      );
    }
    return _buildFallbackImage(context);
  }

  Widget _buildFallbackImage(BuildContext context) {
    return Image.asset(
      'assets/images/dashboard/coaching_bench.webp',
      width: 44,
      height: 44,
      fit: BoxFit.cover,
      cacheWidth: 88,
      cacheHeight: 88,
      errorBuilder: (_, _, _) {
        return Container(
          width: 44,
          height: 44,
          color: context.ftPrimary.withValues(alpha: 0.12),
          child: Icon(
            Icons.fitness_center_rounded,
            size: 20,
            color: context.ftPrimary,
          ),
        );
      },
    );
  }
}
