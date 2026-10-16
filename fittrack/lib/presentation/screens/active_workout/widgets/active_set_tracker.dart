import 'package:flutter/material.dart';

import '../../../providers/active_workout_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Unified Set Tracker Row matching Stitch Screen `7e785328b1f24951adf11ae52e15b460`.
///
/// Features:
/// - Visual track row with horizontal connecting line.
/// - Completed set nodes with checkmark and "Done" status (displaying individual completed set's logged weight).
/// - Active set node with highlighting ring and "Next" status (displaying current set's adjusted weight).
/// - Upcoming set nodes with set numbers and scheduled weight.
/// - Per-set weights are strictly preserved so editing the next set does not affect completed sets.
/// - Dashed "+ Set" button that quickly adds an extra set to the exercise.
/// - Full dark mode theme adaptation.
class ActiveSetTracker extends StatelessWidget {
  const ActiveSetTracker({
    super.key,
    required this.totalSets,
    required this.currentSetIndex,
    required this.entry,
    required this.completedSets,
    required this.onAddSet,
  });

  final int totalSets;
  final int currentSetIndex;
  final LiveExerciseEntry entry;
  final List<CompletedSetEntry> completedSets;
  final VoidCallback onAddSet;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      tier: FtGlassTier.glass1,
      radius: 24,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Center(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Background Connecting Line (strictly between 1st circle and last circle)
                    if (totalSets > 1)
                      Positioned(
                        left: 16,
                        top: 15,
                        width: (totalSets - 1) * 46.0,
                        child: Container(
                          height: 2,
                          color: context.isDark
                              ? Colors.white.withValues(alpha: 0.15)
                              : Colors.white.withValues(alpha: 0.75),
                        ),
                      ),

                    // Nodes Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < totalSets; i++) ...[
                          if (i > 0) const SizedBox(width: 14),
                          _buildNodeForIndex(context, i),
                        ],
                        const SizedBox(width: 14),

                        // "+ Set" Action Node
                        _buildAddSetNode(context),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNodeForIndex(BuildContext context, int i) {
    final isCompleted = i < currentSetIndex;
    final isActive = i == currentSetIndex;

    double setWeight;
    if (isCompleted) {
      final logged = completedSets.where((c) =>
        c.exerciseId == entry.exerciseId && c.setNumber == (i + 1)
      ).lastOrNull;
      setWeight = logged?.actualWeightKg ?? entry.weightForSet(i);
    } else {
      setWeight = entry.weightForSet(i);
    }

    final weightStr = setWeight % 1 == 0
        ? '${setWeight.toInt()} kg'
        : '${setWeight.toStringAsFixed(1)} kg';

    return _buildSetNode(
      context: context,
      setNumber: i + 1,
      isCompleted: isCompleted,
      isActive: isActive,
      weightStr: weightStr,
    );
  }

  Widget _buildSetNode({
    required BuildContext context,
    required int setNumber,
    required bool isCompleted,
    required bool isActive,
    required String weightStr,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isCompleted)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.ftPrimary,
              shape: BoxShape.circle,
              border: Border.all(
                color: context.isDark ? Colors.white.withValues(alpha: 0.3) : Colors.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.ftPrimary.withValues(alpha: 0.40),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 18,
              color: Colors.white,
            ),
          )
        else if (isActive)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.isDark ? const Color(0xFF221A38) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: context.ftPrimary,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.ftPrimary.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              '$setNumber',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: context.ftPrimary,
              ),
            ),
          )
        else
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.85),
              shape: BoxShape.circle,
              border: Border.all(
                color: context.isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.white,
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$setNumber',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: context.ftMuted,
              ),
            ),
          ),
        const SizedBox(height: 4),
        Text(
          weightStr,
          style: TextStyle(
            fontFamily: FtText.fontFamily,
            fontSize: 10.5,
            fontWeight: isCompleted || isActive ? FontWeight.w800 : FontWeight.w600,
            color: isCompleted
                ? context.ftPrimary
                : isActive
                    ? context.ftInk
                    : context.ftMuted,
          ),
        ),
        Text(
          isCompleted
              ? 'DONE'
              : isActive
                  ? 'NEXT'
                  : '·',
          style: TextStyle(
            fontFamily: FtText.fontFamily,
            fontSize: 8.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: isCompleted || isActive ? context.ftPrimary : Colors.transparent,
          ),
        ),
      ],
    );
  }

  Widget _buildAddSetNode(BuildContext context) {
    return FtPressable(
      onTap: onAddSet,
      pressedScale: 0.92,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.5),
              shape: BoxShape.circle,
              border: Border.all(
                color: context.ftPrimary.withValues(alpha: context.isDark ? 0.35 : 0.5),
                style: BorderStyle.solid,
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.add_rounded,
              size: 18,
              color: context.ftPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '+ Set',
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: context.ftPrimary,
            ),
          ),
          const Text(
            '·',
            style: TextStyle(
              fontSize: 8.5,
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
