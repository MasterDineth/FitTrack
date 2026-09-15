import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/workout_history_provider.dart';
import '../../domain/entities/workout_session.dart';

class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});

  static const Color _bg = Color(0xFFf8fafc);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final histState = ref.watch(workoutHistoryProvider);
    final notifier = ref.read(workoutHistoryProvider.notifier);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ACTIVITY LOG',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF94a3b8),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Workout History',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0f172a),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _IconBtn(
                        icon: Icons.search_rounded,
                        onTap: () {},
                        tooltip: 'Search',
                      ),
                      const SizedBox(width: 6),
                      _IconBtn(
                        icon: Icons.calendar_month_rounded,
                        onTap: () {},
                        tooltip: 'Calendar',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── KPI Summary Banner ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _KpiBanner(
                workouts: histState.totalWorkouts,
                totalMinutes: histState.totalMinutes,
                totalCalories: histState.totalCalories,
              ),
            ),

            const SizedBox(height: 12),

            // ── Filter pills ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterPill(
                      label: 'All',
                      icon: Icons.check_rounded,
                      active: histState.filter == HistoryFilter.all,
                      onTap: () => notifier.setFilter(HistoryFilter.all),
                    ),
                    const SizedBox(width: 8),
                    _FilterPill(
                      label: 'This Week',
                      active: histState.filter == HistoryFilter.thisWeek,
                      onTap: () =>
                          notifier.setFilter(HistoryFilter.thisWeek),
                    ),
                    const SizedBox(width: 8),
                    _FilterPill(
                      label: 'This Month',
                      active: histState.filter == HistoryFilter.thisMonth,
                      onTap: () =>
                          notifier.setFilter(HistoryFilter.thisMonth),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Session list ────────────────────────────────────────────
            Expanded(
              child: histState.filtered.isEmpty
                  ? _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: histState.filtered.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        final session = histState.filtered[i];
                        return _SessionCard(
                          session: session,
                          onTap: () => context.push(
                            '/history/detail/${session.id}',
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── KPI Banner ────────────────────────────────────────────────────────────────

class _KpiBanner extends StatelessWidget {
  const _KpiBanner({
    required this.workouts,
    required this.totalMinutes,
    required this.totalCalories,
  });

  final int workouts;
  final int totalMinutes;
  final int totalCalories;

  @override
  Widget build(BuildContext context) {
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    final timeStr = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFe2e8f0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF00d68f),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'SUMMARY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF94a3b8),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFf1f5f9)),
          const SizedBox(height: 14),
          Row(
            children: [
              _KpiCell(
                icon: Icons.fitness_center_rounded,
                iconColor: const Color(0xFF00d68f),
                iconBg: const Color(0xFFf0fdf4),
                value: '$workouts',
                label: 'Workouts',
              ),
              _vDiv(),
              _KpiCell(
                icon: Icons.timer_outlined,
                iconColor: const Color(0xFF0d9488),
                iconBg: const Color(0xFFf0fdfa),
                value: timeStr,
                label: 'Time',
              ),
              _vDiv(),
              _KpiCell(
                icon: Icons.local_fire_department_rounded,
                iconColor: const Color(0xFFf97316),
                iconBg: const Color(0xFFfff7ed),
                value: totalCalories > 999
                    ? '${(totalCalories / 1000).toStringAsFixed(1)}k'
                    : '$totalCalories',
                label: 'Calories',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vDiv() => Container(
        width: 1,
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: const Color(0xFFf1f5f9),
      );
}

class _KpiCell extends StatelessWidget {
  const _KpiCell({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0f172a),
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94a3b8),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter Pill ───────────────────────────────────────────────────────────────

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.active,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF00d68f) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? const Color(0xFF00d68f) : const Color(0xFFe2e8f0),
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFF00d68f).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null && active) ...[
              Icon(
                icon,
                size: 13,
                color: const Color(0xFF0f172a),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: active
                    ? const Color(0xFF0f172a)
                    : const Color(0xFF64748b),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Session Card ──────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.onTap,
  });

  final WorkoutSession session;
  final VoidCallback onTap;

  Color get _intensityColor {
    switch (session.intensity) {
      case 'Extreme':
        return const Color(0xFFef4444);
      case 'Intense':
        return const Color(0xFFf97316);
      case 'Easy':
        return const Color(0xFF22c55e);
      default:
        return const Color(0xFF3b82f6);
    }
  }

  Color get _intensityBg {
    switch (session.intensity) {
      case 'Extreme':
        return const Color(0xFFfef2f2);
      case 'Intense':
        return const Color(0xFFfff7ed);
      case 'Easy':
        return const Color(0xFFf0fdf4);
      default:
        return const Color(0xFFeff6ff);
    }
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return '–';
    final m = seconds ~/ 60;
    return '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('EEE, MMM d').format(session.startTime);
    final timeStr = DateFormat('h:mm a').format(session.startTime);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFf1f5f9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left accent + date column
            Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFf0fdf4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: Color(0xFF00d68f),
                    size: 20,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 12),

            // Main info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + intensity badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          session.scheduleId.startsWith('sch1')
                              ? 'Day 1 – Chest, Shoulders & Triceps'
                              : session.scheduleId.startsWith('sch2')
                                  ? 'Day 2 – Back & Biceps'
                                  : session.scheduleId.startsWith('sch3')
                                      ? 'Day 3 – Legs & Posterior Chain'
                                      : session.scheduleId,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(0xFF0f172a),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (session.intensity != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _intensityBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            session.intensity!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: _intensityColor,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Date/time
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 11,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$dateStr · $timeStr',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Quick stats row
                  Row(
                    children: [
                      _QuickChip(
                        Icons.timer_outlined,
                        _formatDuration(session.durationSeconds),
                        const Color(0xFF0d9488),
                      ),
                      const SizedBox(width: 8),
                      _QuickChip(
                        Icons.local_fire_department_rounded,
                        '${session.totalCalories ?? 0} kcal',
                        const Color(0xFFf97316),
                      ),
                      const SizedBox(width: 8),
                      _QuickChip(
                        Icons.repeat_rounded,
                        '${session.totalSets} sets',
                        const Color(0xFF8b5cf6),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFcbd5e1),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip(this.icon, this.label, this.color);

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ── Icon Button ───────────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.tooltip = '',
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFe2e8f0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF64748b)),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFf0fdf4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_rounded,
              size: 40,
              color: Color(0xFF00d68f),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No workouts yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0f172a),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Complete your first session to see\nyour history here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF94a3b8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
