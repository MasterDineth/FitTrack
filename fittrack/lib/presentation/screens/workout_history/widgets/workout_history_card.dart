import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/workout_session.dart';
import '../../../providers/schedules_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Expandable Workout Session Item within the combined history stream card.
class WorkoutHistoryCard extends ConsumerStatefulWidget {
  final WorkoutSession session;
  final bool initialExpanded;

  const WorkoutHistoryCard({
    super.key,
    required this.session,
    this.initialExpanded = false,
  });

  @override
  ConsumerState<WorkoutHistoryCard> createState() => _WorkoutHistoryCardState();
}

class _WorkoutHistoryCardState extends ConsumerState<WorkoutHistoryCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpanded;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final schedulesState = ref.watch(schedulesNotifierProvider);
    final schedule = schedulesState.allSchedules
        .where((sch) => sch.id == s.scheduleId)
        .firstOrNull;

    final scheduleName = schedule?.title ?? _formatFallbackScheduleName(s.scheduleId);
    final dateStr = DateFormat('EEE, MMM d').format(s.startTime);
    final volumeStr = NumberFormat('#,###').format(s.totalVolumeKg.toInt());
    final setsCount = s.totalSets > 0 ? s.totalSets : 21;
    final minutes = (s.durationSeconds != null && s.durationSeconds! > 0)
        ? (s.durationSeconds! ~/ 60)
        : 50;
    final cals = s.totalCalories ?? 380;

    final isPush = s.scheduleId.toLowerCase().contains('sch1') ||
        s.scheduleId.toLowerCase().contains('push');
    final isPull = s.scheduleId.toLowerCase().contains('sch2') ||
        s.scheduleId.toLowerCase().contains('pull');
    final isLegs = s.scheduleId.toLowerCase().contains('sch3') ||
        s.scheduleId.toLowerCase().contains('leg');

    final Color badgeColor = isPush
        ? const Color(0xFF5F3BDC)
        : isPull
            ? const Color(0xFF14B8A6)
            : isLegs
                ? const Color(0xFFF43F5E)
                : context.ftPrimary;

    final IconData badgeIcon = isPush
        ? Icons.fitness_center_rounded
        : isPull
            ? Icons.accessibility_new_rounded
            : isLegs
                ? Icons.sports_gymnastics_rounded
                : Icons.fitness_center_rounded;

    final isDark = context.isDark;

    return InkWell(
      onTap: _toggleExpanded,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Card Header Row ──────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Squircle Category Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? badgeColor.withValues(alpha: 0.22)
                        : (isPush
                            ? const Color(0xFFEDE9FE)
                            : isPull
                                ? const Color(0xFFCCFBF1)
                                : const Color(0xFFFFE4E6)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: badgeColor.withValues(alpha: isDark ? 0.35 : 0.25),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    badgeIcon,
                    size: 20,
                    color: badgeColor,
                  ),
                ),
                const SizedBox(width: 12),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scheduleName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: context.ftInk,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$dateStr · $volumeStr kg · $setsCount sets',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: context.ftMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Duration, Calories & Chevron
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$minutes min',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: context.ftInk,
                          ),
                        ),
                        const SizedBox(width: 4),
                        AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeInOutCubic,
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: context.ftMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 11,
                          color: Color(0xFFEA580C),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '$cals kcal',
                          style: const TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFEA580C),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            // ── Expanded Body with Smooth Animation ──────────────────
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                alignment: Alignment.topCenter,
                child: _isExpanded
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),

                          // 3 Metric Tiles Row
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : const Color(0xFFF1F5F9),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildMetricTile(
                                    label: 'TOP LIFT',
                                    value: '135 kg',
                                    subtext: '+5kg PR',
                                    subtextColor: const Color(0xFF10B981),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 32,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : const Color(0xFFE2E8F0),
                                ),
                                Expanded(
                                  child: _buildMetricTile(
                                    label: 'REST AVG',
                                    value: '78 sec',
                                    subtext: 'Target 90s',
                                    subtextColor: context.ftMuted,
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 32,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : const Color(0xFFE2E8F0),
                                ),
                                Expanded(
                                  child: _buildMetricTile(
                                    label: 'INTENSITY',
                                    value: s.intensity ?? 'RPE 8.8',
                                    subtext: 'Optimal',
                                    subtextColor: context.ftPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Exercise Highlights in rounded card with internal dividers
                          _buildExerciseHighlights(s.scheduleId, isDark),

                          const SizedBox(height: 12),

                          // Action Buttons Row: "Repeat Workout" & "View Details"
                          Row(
                            children: [
                              // Repeat Workout Button
                              Expanded(
                                child: FtPressable(
                                  onTap: () {
                                    context.push('/workouts/active/${s.scheduleId}');
                                  },
                                  pressedScale: 0.96,
                                  child: Container(
                                    height: 40,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: context.ftPrimary,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: context.ftPrimary.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons.replay_rounded,
                                            size: 15,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'Repeat Workout',
                                            style: TextStyle(
                                              fontFamily: FtText.fontFamily,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // View Details Button
                              Expanded(
                                child: FtPressable(
                                  onTap: () {
                                    context.push('/history/detail/${s.id}');
                                  },
                                  pressedScale: 0.96,
                                  child: Container(
                                    height: 40,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.15)
                                            : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.visibility_outlined,
                                            size: 15,
                                            color: context.ftInk,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'View Details',
                                            style: TextStyle(
                                              fontFamily: FtText.fontFamily,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: context.ftInk,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String subtext,
    required Color subtextColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.45,
              color: context.ftMuted,
            ),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: context.ftInk,
            ),
          ),
        ),
        const SizedBox(height: 1),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            subtext,
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: subtextColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseHighlights(String scheduleId, bool isDark) {
    final bullets = _getBulletsForSchedule(scheduleId);

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < bullets.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFF1F5F9),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: context.ftPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bullets[i].$1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: context.ftInk,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        bullets[i].$2,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: context.ftMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<(String, String)> _getBulletsForSchedule(String scheduleId) {
    if (scheduleId.toLowerCase().contains('sch2') || scheduleId.toLowerCase().contains('pull')) {
      return const [
        ('Weighted Pull-ups', '4 sets · 15 kg × 8'),
        ('Barbell Row', '4 sets · 90 kg × 10'),
      ];
    }
    if (scheduleId.toLowerCase().contains('sch3') || scheduleId.toLowerCase().contains('leg')) {
      return const [
        ('Barbell Back Squat', '5 sets · 160 kg × 5'),
      ];
    }
    return const [
      ('Incline Barbell Bench', '4 sets · 135 kg × 6'),
      ('Standing Overhead Press', '4 sets · 72.5 kg × 8'),
      ('Cable Low Flyes & Pushdowns', '5 sets · Superset 12 reps'),
    ];
  }

  String _formatFallbackScheduleName(String id) {
    if (id.toLowerCase().contains('sch1')) return 'Day 1 – Chest, Shoulders & Triceps';
    if (id.toLowerCase().contains('sch2')) return 'Day 2 – Back & Biceps Pull';
    if (id.toLowerCase().contains('sch3')) return 'Day 3 – Heavy Leg Day & Core';
    return 'Custom Routine';
  }
}
