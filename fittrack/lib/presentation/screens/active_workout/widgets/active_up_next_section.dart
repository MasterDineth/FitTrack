import 'package:flutter/material.dart';

import '../../../providers/active_workout_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';

/// Up Next Section for Active Workout matching Stitch Screen `7e785328b1f24951adf11ae52e15b460`.
///
/// Features:
/// - Section header with remaining exercises count pill.
/// - Unified frosted glass container with hairline divider.
/// - Displays each upcoming exercise with photographic thumbnail, #2, #3 badge, name,
///   muscle category badge, sets × reps · weight, and grab handle.
class ActiveUpNextSection extends StatelessWidget {
  const ActiveUpNextSection({
    super.key,
    required this.upcomingEntries,
    required this.pastEntries,
    required this.skippedExerciseIds,
    required this.currentExerciseIndex,
  });

  final List<LiveExerciseEntry> upcomingEntries;
  final List<LiveExerciseEntry> pastEntries;
  final Set<String> skippedExerciseIds;
  final int currentExerciseIndex;

  @override
  Widget build(BuildContext context) {
    if (upcomingEntries.isEmpty && pastEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Header ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  upcomingEntries.isNotEmpty ? 'Up next in workout' : 'Finished exercises',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: context.ftInk,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.white,
                  ),
                ),
                child: Text(
                  upcomingEntries.isNotEmpty
                      ? '${upcomingEntries.length} ${upcomingEntries.length == 1 ? 'exercise' : 'exercises'} remaining'
                      : '${pastEntries.length} completed/skipped',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: context.ftMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ── Combined Unified Glass Card ─────────────────────────────────────
        GlassSurface(
          tier: FtGlassTier.glass1,
          radius: 24,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // 1. Upcoming entries
              for (int i = 0; i < upcomingEntries.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: context.isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                _buildUpcomingRow(
                  context,
                  upcomingEntries[i],
                  currentExerciseIndex + 2 + i,
                ),
              ],

              // Divider between upcoming and past
              if (upcomingEntries.isNotEmpty && pastEntries.isNotEmpty)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: context.isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                ),

              // 2. Past entries (completed / skipped)
              for (int i = 0; i < pastEntries.length; i++) ...[
                if (i > 0 || upcomingEntries.isNotEmpty)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: context.isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                _buildPastRow(
                  context,
                  pastEntries[i],
                  skippedExerciseIds.contains(pastEntries[i].exerciseId),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingRow(BuildContext context, LiveExerciseEntry entry, int rankIndex) {
    final weight = entry.liveWeightKg;
    final weightStr = weight % 1 == 0 ? weight.toInt().toString() : weight.toStringAsFixed(1);
    final muscle = _resolveMuscle(entry.exerciseId);
    final muscleColor = _resolveMuscleColor(muscle);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Thumbnail with Rank Badge
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white,
                width: 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/dashboard/hero_workout.webp',
                  fit: BoxFit.cover,
                  cacheWidth: 92,
                  cacheHeight: 92,
                ),
                Positioned(
                  bottom: 2,
                  left: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.70),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '#$rankIndex',
                      style: const TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Exercise Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: context.ftInk,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: context.isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: muscleColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            muscle,
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: muscleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${entry.totalSets} sets × ${entry.targetReps} reps · $weightStr kg',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: context.ftMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Drag / Reorder Affordance
          Icon(
            Icons.drag_handle_rounded,
            size: 18,
            color: context.ftMuted.withValues(alpha: 0.45),
          ),
        ],
      ),
    );
  }

  Widget _buildPastRow(BuildContext context, LiveExerciseEntry entry, bool isSkipped) {
    final weight = entry.liveWeightKg;
    final weightStr = weight % 1 == 0 ? weight.toInt().toString() : weight.toStringAsFixed(1);
    final statusColor = isSkipped ? const Color(0xFFF59E0B) : const Color(0xFF10B981);

    return Opacity(
      opacity: 0.55,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white,
                  width: 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Colors.grey,
                  BlendMode.saturation,
                ),
                child: Image.asset(
                  'assets/images/dashboard/hero_workout.webp',
                  fit: BoxFit.cover,
                  cacheWidth: 92,
                  cacheHeight: 92,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Exercise Details with Strikethrough
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: context.ftInk,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: context.ftInk.withValues(alpha: 0.7),
                      decorationThickness: 1.8,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isSkipped ? 'Skipped' : 'Completed',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '${entry.totalSets} sets · $weightStr kg',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: context.ftMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status trailing icon
            Icon(
              isSkipped ? Icons.redo_rounded : Icons.check_circle_rounded,
              size: 20,
              color: statusColor,
            ),
          ],
        ),
      ),
    );
  }

  String _resolveMuscle(String exerciseId) {
    final lower = exerciseId.toLowerCase();
    if (lower.contains('bench') || lower.contains('chest') || lower.contains('fly')) {
      return 'Chest';
    }
    if (lower.contains('overhead') || lower.contains('press') || lower.contains('lateral') || lower.contains('shoulder')) {
      return 'Shoulders';
    }
    if (lower.contains('tricep') || lower.contains('extension')) {
      return 'Triceps';
    }
    if (lower.contains('pull') || lower.contains('row') || lower.contains('back')) {
      return 'Back';
    }
    if (lower.contains('squat') || lower.contains('leg') || lower.contains('deadlift')) {
      return 'Legs';
    }
    return 'Core';
  }

  Color _resolveMuscleColor(String muscle) {
    switch (muscle.toLowerCase()) {
      case 'chest':
        return const Color(0xFFF43F5E);
      case 'shoulders':
        return const Color(0xFFF59E0B);
      case 'triceps':
        return const Color(0xFF14B8A6);
      case 'back':
        return const Color(0xFF3B82F6);
      case 'legs':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF10B981);
    }
  }
}
