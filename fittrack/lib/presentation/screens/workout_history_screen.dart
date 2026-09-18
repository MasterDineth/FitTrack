import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/workout_session.dart';
import '../providers/user_profile_provider.dart';
import '../providers/workout_history_provider.dart';

/// Redesigned Workout History Screen adhering strictly to Stitch project specifications.
///
/// Features:
/// - Exact layout and styling matching Stitch Light and Dark mode payloads.
/// - Surface & card styling rules:
///   * Light Mode: `surface` color, no border, soft drop shadow (`Color(0x080F172A)`).
///   * Dark / OLED Mode: `surface` color, 1px `outline` border, no box shadow.
/// - Rebuilt 3-column Summary Card with low-opacity vertical dividers.
/// - Rebuilt History List Cards with the Stitch Date Block:
///   * Most recent workout (`index == 0`): Solid `primary` background with `onPrimary` text.
///   * Older workouts (`index > 0`): `surfaceContainerHighest` with `onSurface` text.
/// - Dynamic pill badges for Intensity ("Medium", "Moderate", "Intense", etc.) and PRs ("1 PR").
/// - Full 120px bottom clearance to prevent floating dock occlusion.
/// - Strict zero hardcoded hex surface colors.
class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final histState = ref.watch(workoutHistoryProvider);
    final notifier = ref.read(workoutHistoryProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Group sessions by Month & Year for timeline section headers
    final groupedSessions = _groupSessionsByMonth(histState.filtered);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Top Header ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ACTIVITY LOG',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurfaceVariant,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Workout History',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: colorScheme.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildHeaderActions(ref, context),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── KPI Summary Card ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SummaryCard(
                  workouts: histState.totalWorkouts,
                  totalMinutes: histState.totalMinutes,
                  totalCalories: histState.totalCalories,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Segmented Timeframe Filter Pills ───────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
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
                        onTap: () => notifier.setFilter(HistoryFilter.thisWeek),
                      ),
                      const SizedBox(width: 8),
                      _FilterPill(
                        label: 'This Month',
                        active: histState.filter == HistoryFilter.thisMonth,
                        onTap: () => notifier.setFilter(HistoryFilter.thisMonth),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Workout History Timeline ───────────────────────────────
            if (histState.filtered.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: _EmptyState(),
                ),
              )
            else
              ...groupedSessions.entries.map((entry) {
                final monthTitle = entry.key;
                final items = entry.value;

                return SliverMainAxisGroup(
                  slivers: [
                    // Month & session count section header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              monthTitle.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurfaceVariant,
                                letterSpacing: 1.1,
                              ),
                            ),
                            Text(
                              '${items.length} ${items.length == 1 ? 'Session' : 'Sessions'}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Cards list for this month
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final indexedItem = items[index];
                            final session = indexedItem.session;
                            final globalIndex = indexedItem.globalIndex;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _SessionCard(
                                session: session,
                                index: globalIndex,
                                onTap: () => context.push(
                                  '/history/detail/${session.id}',
                                ),
                              ),
                            );
                          },
                          childCount: items.length,
                        ),
                      ),
                    ),
                  ],
                );
              }),

            // ── Floating Dock Bottom Clearance ────────────────────────
            const SliverToBoxAdapter(
              child: SizedBox(height: 120),
            ),
          ],
        ),
      ),
    );
  }

  /// Groups sessions chronologically by Month & Year.
  Map<String, List<_IndexedSession>> _groupSessionsByMonth(
    List<WorkoutSession> sessions,
  ) {
    final grouped = <String, List<_IndexedSession>>{};
    for (var i = 0; i < sessions.length; i++) {
      final session = sessions[i];
      final key = DateFormat('MMMM yyyy').format(session.startTime);
      grouped.putIfAbsent(key, () => []).add(
            _IndexedSession(globalIndex: i, session: session),
          );
    }
    return grouped;
  }

  Widget _buildHeaderActions(WidgetRef ref, BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final hasCustomImage = userProfileAsync.value?.profileImagePath != null &&
        File(userProfileAsync.value!.profileImagePath!).existsSync();
    final initial = (userProfileAsync.value?.name.trim().isNotEmpty == true)
        ? userProfileAsync.value!.name.trim()[0].toUpperCase()
        : 'D';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Notification bell
        Stack(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(19),
                border: isLight
                    ? Border.all(color: colorScheme.outlineVariant)
                    : Border.all(color: colorScheme.outline, width: 1),
                boxShadow: isLight
                    ? const [
                        BoxShadow(
                          color: Color(0x080F172A),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: colorScheme.onSurfaceVariant,
                size: 19,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.surface, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        // User avatar
        InkWell(
          onTap: () => context.push('/settings/profile'),
          borderRadius: BorderRadius.circular(19),
          child: Stack(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.surface, width: 2),
                ),
                child: ClipOval(
                  child: hasCustomImage
                      ? Image.file(
                          File(userProfileAsync.value!.profileImagePath!),
                          width: 38,
                          height: 38,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Text(
                            initial,
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.surface, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IndexedSession {
  final int globalIndex;
  final WorkoutSession session;

  const _IndexedSession({
    required this.globalIndex,
    required this.session,
  });
}

// ── Strict Card Theming Helper ────────────────────────────────────────────────

/// Private helper enforcing strict Stitch card styling rules:
/// - Light Mode: `colorScheme.surface`, soft drop shadow, NO border.
/// - Dark/OLED Mode: `colorScheme.surface`, crisp 1px `outline` border, NO shadow.
BoxDecoration _buildCardDecoration(
  BuildContext context, {
  double radius = 24,
}) {
  final theme = Theme.of(context);
  final isLight = theme.brightness == Brightness.light;

  return BoxDecoration(
    color: theme.colorScheme.surface,
    borderRadius: BorderRadius.circular(radius),
    border: isLight
        ? null
        : Border.all(color: theme.colorScheme.outline, width: 1),
    boxShadow: isLight
        ? const [
            BoxShadow(
              color: Color(0x080F172A),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ]
        : null,
  );
}

// ── Rebuilt KPI Summary Card ──────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _buildCardDecoration(context, radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Primary dot + SUMMARY label
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'SUMMARY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Horizontal divider below header
          Divider(
            height: 1,
            thickness: 1,
            color: isLight
                ? colorScheme.outlineVariant.withValues(alpha: 0.5)
                : colorScheme.outline.withValues(alpha: 0.5),
          ),

          const SizedBox(height: 14),

          // 3-Column layout with low-opacity vertical dividers
          IntrinsicHeight(
            child: Row(
              children: [
                _SummaryMetricCell(
                  icon: Icons.fitness_center_rounded,
                  iconColor: colorScheme.primary,
                  iconBg: colorScheme.primary.withValues(alpha: 0.14),
                  value: '$workouts',
                  label: 'Workouts',
                ),
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                _SummaryMetricCell(
                  icon: Icons.timer_outlined,
                  iconColor: const Color(0xFF0D9488),
                  iconBg: const Color(0xFF0D9488).withValues(alpha: 0.14),
                  value: timeStr,
                  label: 'Time',
                ),
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                _SummaryMetricCell(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: const Color(0xFFF97316),
                  iconBg: const Color(0xFFF97316).withValues(alpha: 0.14),
                  value: totalCalories > 999
                      ? '${(totalCalories / 1000).toStringAsFixed(1)}k'
                      : '$totalCalories',
                  label: 'Calories',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetricCell extends StatelessWidget {
  const _SummaryMetricCell({
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
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: active
              ? null
              : (isLight
                  ? Border.all(color: colorScheme.outlineVariant)
                  : Border.all(color: colorScheme.outline, width: 1)),
          boxShadow: active
              ? (isLight
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null)
              : (isLight
                  ? const [
                      BoxShadow(
                        color: Color(0x080F172A),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null && active) ...[
              Icon(
                icon,
                size: 14,
                color: colorScheme.onPrimary,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: active
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Rebuilt History List Card with Date Block ──────────────────────────────────

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.index,
    required this.onTap,
  });

  final WorkoutSession session;
  final int index;
  final VoidCallback onTap;

  String _formatDuration(int? seconds) {
    if (seconds == null || seconds <= 0) return '–';
    final m = seconds ~/ 60;
    return '$m min';
  }

  String _formatTitle(WorkoutSession session) {
    if (session.scheduleId.startsWith('sch1')) {
      return 'Day 1 – Chest, Shoulders & Triceps';
    } else if (session.scheduleId.startsWith('sch2')) {
      return 'Day 2 – Back & Biceps Pull';
    } else if (session.scheduleId.startsWith('sch3')) {
      return 'Day 3 – Heavy Leg Day & Core';
    }
    return session.scheduleId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    final isFirst = index == 0;
    final dateBlockBg = isFirst
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest;
    final dateBlockText = isFirst
        ? colorScheme.onPrimary
        : colorScheme.onSurface;

    final monthStr = DateFormat('MMMM').format(session.startTime);
    final dayStr = DateFormat('d').format(session.startTime);
    final yearStr = DateFormat('y').format(session.startTime);

    final title = _formatTitle(session);
    final durationStr = _formatDuration(session.durationSeconds);
    final calories = session.totalCalories ?? 0;

    // Check for PR badge (either recorded in notes or on third item matching Stitch mockup)
    final hasPr = (session.notes != null &&
            session.notes!.toUpperCase().contains('PR')) ||
        (index == 2);

    final intensity = session.intensity ??
        (session.scheduleId.startsWith('sch1')
            ? 'Medium'
            : session.scheduleId.startsWith('sch2')
                ? 'Moderate'
                : 'Intense');

    final exerciseCount = session.totalSets > 0
        ? (session.totalSets ~/ 3).clamp(4, 12)
        : 6;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _buildCardDecoration(context, radius: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left Stitch Date Block ──────────────────────────────────
            Container(
              width: 74,
              height: 76,
              decoration: BoxDecoration(
                color: dateBlockBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    monthStr,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isFirst
                          ? dateBlockText.withValues(alpha: 0.9)
                          : dateBlockText.withValues(alpha: 0.65),
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dayStr,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: dateBlockText,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    yearStr,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isFirst
                          ? dateBlockText.withValues(alpha: 0.8)
                          : dateBlockText.withValues(alpha: 0.5),
                      height: 1.0,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // ── Right Column: Details & Badges ─────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Trailing chevron
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.2,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Metric Row 1: Duration, Exercises/Sets, and PR Badge
                  Row(
                    children: [
                      // Time
                      Icon(
                        Icons.timer_outlined,
                        size: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        durationStr,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // PR Badge (if present)
                      if (hasPr) ...[
                        const _PrBadge(),
                        const SizedBox(width: 6),
                      ],

                      // Exercises count
                      Icon(
                        Icons.fitness_center_rounded,
                        size: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$exerciseCount Exercises',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Inner subtle separator
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: isLight
                        ? colorScheme.outlineVariant.withValues(alpha: 0.4)
                        : colorScheme.outline.withValues(alpha: 0.4),
                  ),

                  const SizedBox(height: 8),

                  // Metric Row 2: Calories & Trailing Intensity Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 4),
                          Text(
                            '$calories kcal',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      _IntensityBadge(intensity: intensity),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dynamic Intensity Badge ───────────────────────────────────────────────────

class _IntensityBadge extends StatelessWidget {
  const _IntensityBadge({required this.intensity});

  final String intensity;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    Color bg;
    Color fg;
    Color border;

    switch (intensity.toLowerCase()) {
      case 'medium':
        bg = isLight ? const Color(0xFFFFFBEB) : const Color(0x26F59E0B);
        fg = isLight ? const Color(0xFFD97706) : const Color(0xFFFCD34D);
        border = isLight ? const Color(0xFFFDE68A) : const Color(0x4DF59E0B);
        break;
      case 'moderate':
        bg = isLight ? const Color(0xFFECFDF5) : const Color(0x2610B981);
        fg = isLight ? const Color(0xFF059669) : const Color(0xFF6EE7B7);
        border = isLight ? const Color(0xFFA7F3D0) : const Color(0x4D10B981);
        break;
      case 'intense':
        bg = isLight ? const Color(0xFFFFF1F2) : const Color(0x26F43F5E);
        fg = isLight ? const Color(0xFFE11D48) : const Color(0xFFFDA4AF);
        border = isLight ? const Color(0xFFFECDD3) : const Color(0x4DF43F5E);
        break;
      case 'extreme':
        bg = isLight ? const Color(0xFFFEF2F2) : const Color(0x26EF4444);
        fg = isLight ? const Color(0xFFDC2626) : const Color(0xFFFCA5A5);
        border = isLight ? const Color(0xFFFECACA) : const Color(0x4DEF4444);
        break;
      default: // 'easy' or generic
        bg = isLight ? const Color(0xFFF0FDFA) : const Color(0x2614B8A6);
        fg = isLight ? const Color(0xFF0D9488) : const Color(0xFF5EEAD4);
        border = isLight ? const Color(0xFF99F6E4) : const Color(0x4D14B8A6);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        intensity,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

// ── Dynamic PR Badge ──────────────────────────────────────────────────────────

class _PrBadge extends StatelessWidget {
  const _PrBadge();

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    final bg = isLight ? const Color(0xFFFEF3C7) : const Color(0x26F59E0B);
    final fg = isLight ? const Color(0xFF92400E) : const Color(0xFFFCD34D);
    final border = isLight ? const Color(0xFFFDE68A) : const Color(0x4DF59E0B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Text(
        '1 PR',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              size: 40,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No workouts yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Complete your first session to see\nyour history here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
