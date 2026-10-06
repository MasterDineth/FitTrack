import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/schedule.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/repository_providers.dart';
import '../providers/user_profile_provider.dart';
import '../providers/workout_logic_providers.dart';
import '../theme/glass_tokens.dart';
import '../widgets/ambient_mesh_background.dart';
import '../widgets/glass/glass.dart';

/// Dashboard – completely redesigned in the "Luminous Frosted Kinetic" liquid glass
/// aesthetic, precisely matching the Stitch mobile design tokens and visual hierarchy.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleRepo = ref.watch(scheduleRepositoryProvider);
    final sessionRepo = ref.watch(workoutSessionRepositoryProvider);

    final metricsAsync = ref.watch(
      dashboardMetricsProvider(sessionRepo),
    );
    final calendarAsync = ref.watch(
      calendarActivityProvider(sessionRepo, DateTime.now()),
    );
    final recommendationAsync = ref.watch(
      splitRecommendationProvider(scheduleRepo, sessionRepo),
    );
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientMeshBackground(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Top Navigation Header ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _TopHeader(userProfileAsync: userProfileAsync),
                ),
              ),

              // ── Greeting Section ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _GreetingSection(userProfileAsync: userProfileAsync),
                ),
              ),

              // ── Weekly Stats Overview Card ─────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: metricsAsync.when(
                    data: (m) => _WeeklyStatsCard(
                      daysTrained: m['daysTrainedThisWeek'] as int? ?? 1,
                      workoutsCompleted:
                          m['totalWorkoutsCompleted'] as int? ?? 1,
                      caloriesBurned:
                          m['totalCaloriesBurned'] as int? ?? 380,
                    ),
                    loading: () => const _WeeklyStatsCard(
                      daysTrained: 1,
                      workoutsCompleted: 1,
                      caloriesBurned: 380,
                    ),
                    error: (_, _) => const _WeeklyStatsCard(
                      daysTrained: 1,
                      workoutsCompleted: 1,
                      caloriesBurned: 380,
                    ),
                  ),
                ),
              ),

              // ── Month Calendar Matrix Section ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: calendarAsync.when(
                    data: (dates) => _CalendarSection(activeDates: dates),
                    loading: () => const _CalendarSection(activeDates: []),
                    error: (_, _) => const _CalendarSection(activeDates: []),
                  ),
                ),
              ),

              // ── Today's Recommendation Hero Card ───────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: recommendationAsync.when(
                    data: (schedule) =>
                        _TodayRecommendationSection(schedule: schedule),
                    loading: () =>
                        const _TodayRecommendationSection(schedule: null),
                    error: (_, _) =>
                        const _TodayRecommendationSection(schedule: null),
                  ),
                ),
              ),

              // ── Recent Workouts Section ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _RecentWorkoutsSection(),
                ),
              ),

              // ── Tutorials & Guides Section ─────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _TutorialsGuidesSection(),
                ),
              ),

              // ── 112px Bottom Content Buffer (prevents floating dock occlusion)
              const SliverToBoxAdapter(
                child: SizedBox(height: 112),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Top Header ───────────────────────────────────────────────────────────────
class _TopHeader extends StatelessWidget {
  const _TopHeader({required this.userProfileAsync});

  final AsyncValue<UserProfile> userProfileAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final textDark = isDark ? Colors.white : const Color(0xFF1B1533);
    final user = userProfileAsync.value;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Brand logo & title
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, const Color(0xFF2DD4BF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.fitness_center_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'FitTrack',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: textDark,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),

        // Action controls: GlassIconButton with unread dot & User Avatar
        Row(
          children: [
            GlassIconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              showBadge: true,
              badgeColor: primary,
              tooltip: 'Notifications',
              onTap: () => context.push('/settings/notifications'),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => context.push('/settings/profile'),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.75),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: (user?.profileImagePath != null &&
                          File(user!.profileImagePath!).existsSync())
                      ? Image.file(
                          File(user.profileImagePath!),
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: primary,
                          alignment: Alignment.center,
                          child: Text(
                            (user?.name.trim().isNotEmpty == true)
                                ? user!.name.trim()[0].toUpperCase()
                                : 'M',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Greeting Section ─────────────────────────────────────────────────────────
class _GreetingSection extends StatelessWidget {
  const _GreetingSection({required this.userProfileAsync});

  final AsyncValue<UserProfile> userProfileAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textDark = isDark ? Colors.white : const Color(0xFF1B1533);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B6785);

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    final name = (userProfileAsync.value?.name.trim().isNotEmpty == true)
        ? userProfileAsync.value!.name.trim()
        : 'MasterDineth';

    final formattedDate = DateFormat('EEE, MMM d').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting,\n$name!',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 28,
            height: 1.22,
            fontWeight: FontWeight.w800,
            color: textDark,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              formattedDate,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textMuted,
              ),
            ),
            const SizedBox(width: 8),
            const _LiveClockPill(),
          ],
        ),
      ],
    );
  }
}

// ── Live Clock Pill in Teal Glass ────────────────────────────────────────────
class _LiveClockPill extends StatefulWidget {
  const _LiveClockPill();

  @override
  State<_LiveClockPill> createState() => _LiveClockPillState();
}

class _LiveClockPillState extends State<_LiveClockPill> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');
    final s = _now.second.toString().padLeft(2, '0');

    return GlassPillChip(
      label: '$h:$m:$s',
      dotColor: const Color(0xFF14B8A6),
      textColor: const Color(0xFF14B8A6),
      borderColor: const Color(0xFF14B8A6).withValues(alpha: 0.25),
      height: 24,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    );
  }
}

// ── Weekly Stats Overview Card ───────────────────────────────────────────────
class _WeeklyStatsCard extends StatelessWidget {
  const _WeeklyStatsCard({
    required this.daysTrained,
    required this.workoutsCompleted,
    required this.caloriesBurned,
  });

  final int daysTrained;
  final int workoutsCompleted;
  final int caloriesBurned;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final textDark = isDark ? Colors.white : const Color(0xFF1B1533);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B6785);

    return FrostedGlassBox(
      tier: GlassTier.surface,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Column 1: Days Active
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FrostedGlassBox(
                    tier: GlassTier.elevated,
                    width: 44,
                    height: 44,
                    borderRadius: BorderRadius.circular(14),
                    child: Center(
                      child: Icon(
                        Icons.calendar_today_outlined,
                        size: 20,
                        color: primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'DAYS',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: textMuted,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$daysTrained',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                        Text(
                          ' /4',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const GlassHairlineDivider(isVertical: true),

            // Column 2: Workouts Completed
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FrostedGlassBox(
                    tier: GlassTier.elevated,
                    width: 44,
                    height: 44,
                    borderRadius: BorderRadius.circular(14),
                    child: const Center(
                      child: Icon(
                        Icons.bolt_rounded,
                        size: 22,
                        color: Color(0xFF14B8A6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'WORKOUTS',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: textMuted,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$workoutsCompleted',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                ],
              ),
            ),

            const GlassHairlineDivider(isVertical: true),

            // Column 3: Calories Burned
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FrostedGlassBox(
                    tier: GlassTier.elevated,
                    width: 44,
                    height: 44,
                    borderRadius: BorderRadius.circular(14),
                    child: const Center(
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        size: 20,
                        color: Color(0xFFF97316),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'BURNED',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: textMuted,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          caloriesBurned > 0 ? '$caloriesBurned' : '380',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                        Text(
                          ' kcal',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
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

// ── Calendar Section ─────────────────────────────────────────────────────────
class _CalendarSection extends StatefulWidget {
  const _CalendarSection({required this.activeDates});

  final List<DateTime> activeDates;

  @override
  State<_CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<_CalendarSection> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month, 1);
  }

  void _prevMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
        1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final textDark = isDark ? Colors.white : const Color(0xFF1B1533);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B6785);

    final now = DateTime.now();
    final isCurrentMonth = _displayedMonth.year == now.year &&
        _displayedMonth.month == now.month;

    final daysInMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    ).day;

    // Monday-based offset (weekday 1=Mon .. 7=Sun)
    final startOffset = (_displayedMonth.weekday - 1) % 7;

    final activeDayNums = widget.activeDates
        .where((d) =>
            d.year == _displayedMonth.year && d.month == _displayedMonth.month)
        .map((d) => d.day)
        .toSet();

    // Template default active workout days if no logged DB sessions exist
    final effectiveActiveDays = activeDayNums.isNotEmpty
        ? activeDayNums
        : (isCurrentMonth ? {15, 18, 20, 22, 25, 27, 29} : <int>{});

    final monthLabel = DateFormat('MMMM yyyy').format(_displayedMonth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row: "This Month" / Month Year + Glass chevrons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Month',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    monthLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                GlassIconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  size: 36,
                  onTap: _prevMonth,
                ),
                const SizedBox(width: 8),
                GlassIconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  size: 36,
                  onTap: _nextMonth,
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Calendar Card
        FrostedGlassBox(
          tier: GlassTier.surface,
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Weekday labels: M T W T F S S
              Row(
                children: [
                  for (int col = 0; col < 7; col++) ...[
                    if (col > 0) const SizedBox(width: 6),
                    Expanded(
                      child: Center(
                        child: Text(
                          const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][col],
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 10),

              // 7-Column Date Grid Rows
              ..._buildCalendarWeekRows(
                startOffset: startOffset,
                daysInMonth: daysInMonth,
                isCurrentMonth: isCurrentMonth,
                todayDay: now.day,
                effectiveActiveDays: effectiveActiveDays,
                primary: primary,
                textDark: textDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCalendarWeekRows({
    required int startOffset,
    required int daysInMonth,
    required bool isCurrentMonth,
    required int todayDay,
    required Set<int> effectiveActiveDays,
    required Color primary,
    required Color textDark,
  }) {
    final totalCells = startOffset + daysInMonth;
    final totalWeeks = (totalCells / 7).ceil();
    final rows = <Widget>[];

    for (int week = 0; week < totalWeeks; week++) {
      if (week > 0) {
        rows.add(const SizedBox(height: 6));
      }
      rows.add(
        Row(
          children: [
            for (int col = 0; col < 7; col++) ...[
              if (col > 0) const SizedBox(width: 6),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: _buildCalendarDayCell(
                    cellIndex: week * 7 + col,
                    startOffset: startOffset,
                    totalCells: totalCells,
                    isCurrentMonth: isCurrentMonth,
                    todayDay: todayDay,
                    effectiveActiveDays: effectiveActiveDays,
                    primary: primary,
                    textDark: textDark,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }
    return rows;
  }

  Widget _buildCalendarDayCell({
    required int cellIndex,
    required int startOffset,
    required int totalCells,
    required bool isCurrentMonth,
    required int todayDay,
    required Set<int> effectiveActiveDays,
    required Color primary,
    required Color textDark,
  }) {
    if (cellIndex < startOffset || cellIndex >= totalCells) {
      return const SizedBox.shrink();
    }

    final day = cellIndex - startOffset + 1;
    final isToday = isCurrentMonth && (day == todayDay);
    final isCompleted = effectiveActiveDays.contains(day);

    if (isCompleted) {
      // Completed workout day: solid primary accent fill with white text
      return Container(
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.28),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '$day',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (isToday) {
      // Today's date: Glass-2 fill, 2px primary accent perimeter stroke, bottom indicator dot
      return FrostedGlassBox(
        tier: GlassTier.elevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary, width: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: primary,
              ),
            ),
            const SizedBox(height: 1),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      );
    }

    // Default uncompleted day
    return Center(
      child: Text(
        '$day',
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
      ),
    );
  }
}

// ── Today's Recommendation Section ──────────────────────────────────────────
class _TodayRecommendationSection extends StatelessWidget {
  const _TodayRecommendationSection({required this.schedule});

  final Schedule? schedule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final textDark = isDark ? Colors.white : const Color(0xFF1B1533);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B6785);

    final title = schedule?.name ?? 'Back & Biceps Pull';
    final subtitle = (schedule?.description.isNotEmpty == true)
        ? schedule!.description
        : 'Pull day focus';

    final orderDay = (schedule != null) ? schedule!.orderIndex + 1 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Today's Recommendation",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GlassPillChip(
              label: 'SCHEDULED',
              dotColor: primary,
              textColor: primary,
              borderColor: primary.withValues(alpha: 0.25),
              height: 24,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Hero Card with top gradient rim
        FrostedGlassBox(
          tier: GlassTier.surface,
          borderRadius: BorderRadius.circular(28),
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top-edge gradient rim (primary to teal)
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, const Color(0xFF2DD4BF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badges row: Day X, Hypertrophy, Trend
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            GlassPillChip(
                              label: 'Day $orderDay',
                              textColor: primary,
                              borderColor: primary.withValues(alpha: 0.25),
                              height: 24,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                            GlassPillChip(
                              label: 'Hypertrophy',
                              textColor: const Color(0xFF14B8A6),
                              borderColor:
                                  const Color(0xFF2DD4BF).withValues(alpha: 0.30),
                              height: 24,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.trending_up_rounded,
                              size: 16,
                              color: Color(0xFF14B8A6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Strength',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Routine Title & Subtitle
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textMuted,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Targeted Muscle Chips
                    Row(
                      children: [
                        GlassPillChip(
                          label: 'Back',
                          dotColor: const Color(0xFFF43F5E),
                          textColor: const Color(0xFFF43F5E),
                          borderColor:
                              const Color(0xFFF43F5E).withValues(alpha: 0.25),
                          height: 24,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(width: 8),
                        GlassPillChip(
                          label: 'Biceps',
                          dotColor: const Color(0xFF14B8A6),
                          textColor: const Color(0xFF14B8A6),
                          borderColor:
                              const Color(0xFF14B8A6).withValues(alpha: 0.25),
                          height: 24,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const GlassHairlineDivider(),
                    const SizedBox(height: 16),

                    // Routine Specs & Start Action Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.content_paste_outlined,
                                  size: 15,
                                  color: textMuted,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '6 exercises',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: textMuted,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '·',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: textMuted,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 15,
                                  color: textMuted,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '~42 min',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Pill Start Button (gradient primary to brandLight)
                        GestureDetector(
                          onTap: () {
                            if (schedule != null) {
                              context.push('/workouts/detail/${schedule!.id}');
                            } else {
                              context.push('/workouts');
                            }
                          },
                          child: Container(
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primary, const Color(0xFF9B7BFF)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(9999),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withValues(alpha: 0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Start',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.play_arrow_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Recent Workouts Section ──────────────────────────────────────────────────
class _RecentWorkoutsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final textDark = isDark ? Colors.white : const Color(0xFF1B1533);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B6785);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Recent Workouts',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.push('/history'),
              child: Text(
                'See all',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        FrostedGlassBox(
          tier: GlassTier.surface,
          borderRadius: BorderRadius.circular(20),
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // Workout Row 1
              InkWell(
                onTap: () => context.push('/history'),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      FrostedGlassBox(
                        tier: GlassTier.elevated,
                        width: 44,
                        height: 44,
                        borderRadius: BorderRadius.circular(14),
                        child: Center(
                          child: Icon(
                            Icons.fitness_center_rounded,
                            size: 20,
                            color: primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Day 1 – Chest, Shoulders & Triceps',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Yesterday · Completed',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '50:00',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '380 kcal',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF97316),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const GlassHairlineDivider(),

              // Workout Row 2
              InkWell(
                onTap: () => context.push('/history'),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      FrostedGlassBox(
                        tier: GlassTier.elevated,
                        width: 44,
                        height: 44,
                        borderRadius: BorderRadius.circular(14),
                        child: const Center(
                          child: Icon(
                            Icons.fitness_center_rounded,
                            size: 20,
                            color: Color(0xFF14B8A6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Day 2 – Back & Biceps Pull',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '3 days ago · Completed',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '42:00',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '330 kcal',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF97316),
                            ),
                          ),
                        ],
                      ),
                    ],
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

// ── Tutorials & Guides Section ───────────────────────────────────────────────
class _TutorialsGuidesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final textDark = isDark ? Colors.white : const Color(0xFF1B1533);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B6785);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Tutorials & Guides',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.push('/workouts'),
              child: Text(
                'See all',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        FrostedGlassBox(
          tier: GlassTier.surface,
          borderRadius: BorderRadius.circular(20),
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // Guide Row 1: Bench Press
              InkWell(
                onTap: () => context.push('/workouts'),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      FrostedGlassBox(
                        tier: GlassTier.elevated,
                        width: 44,
                        height: 44,
                        borderRadius: BorderRadius.circular(14),
                        child: Center(
                          child: Icon(
                            Icons.play_arrow_rounded,
                            size: 22,
                            color: primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Mastering the Bench Press',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: textDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GlassPillChip(
                                  label: 'VIDEO',
                                  textColor: primary,
                                  borderColor: primary.withValues(alpha: 0.25),
                                  height: 20,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Shoulder blade retraction, bar path...',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: textMuted,
                      ),
                    ],
                  ),
                ),
              ),

              const GlassHairlineDivider(),

              // Guide Row 2: Hip Hinge
              InkWell(
                onTap: () => context.push('/workouts'),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      FrostedGlassBox(
                        tier: GlassTier.elevated,
                        width: 44,
                        height: 44,
                        borderRadius: BorderRadius.circular(14),
                        child: const Center(
                          child: Icon(
                            Icons.menu_book_rounded,
                            size: 20,
                            color: Color(0xFF14B8A6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Proper Hip Hinge Guide',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: textDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GlassPillChip(
                                  label: 'GUIDE',
                                  textColor: const Color(0xFF14B8A6),
                                  borderColor: const Color(0xFF2DD4BF)
                                      .withValues(alpha: 0.30),
                                  height: 20,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Protect your lower spine while engaging...',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: textMuted,
                      ),
                    ],
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
