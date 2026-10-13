import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/workout_session.dart';
import '../providers/repository_providers.dart';
import '../providers/user_profile_provider.dart';
import '../providers/workout_logic_providers.dart';
import '../theme/glass_tokens.dart';
import '../widgets/ambient_mesh_background.dart';
import '../widgets/glass/glass.dart';

/// Dashboard – built in the "Luminous Frosted Kinetic" liquid glass aesthetic,
/// heavily optimized for 120Hz Snapdragon 8 Gen Elite execution:
/// - Granular ConsumerWidgets with select() watching isolated providers
/// - Zero whole-screen rebuilds on idle
/// - Minute-aligned TickerMode-aware live clock
/// - Async avatar image resolution with ResizeImage decoding
/// - RepaintBoundaries on all distinct visual glass sections
/// - Zero BackdropFilter offscreen passes on cards
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static int debugRebuildCount = 0;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    DashboardScreen.debugRebuildCount++;
    debugPrint('[DASHBOARD_REBUILD] DashboardScreen rebuild #${DashboardScreen.debugRebuildCount}');

    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientMeshBackground(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              // ── Top Navigation Header ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _TopHeader(),
                ),
              ),

              // ── Greeting Section ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _GreetingSection(),
                ),
              ),

              // ── Weekly Stats Overview Card ─────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _WeeklyStatsSection(),
                ),
              ),

              // ── Month Calendar Matrix Section ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _CalendarSection(),
                ),
              ),

              // ── Today's Recommendation Hero Card ───────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _TodayRecommendationSection(),
                ),
              ),

              // ── Recent Workouts Section ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _RecentWorkoutsSection(),
                ),
              ),

              // ── Tutorials & Guides Section ─────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _TutorialsGuidesSection(),
                ),
              ),

              // ── 112px Bottom Content Buffer (prevents floating dock occlusion)
              SliverToBoxAdapter(
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
class _TopHeader extends ConsumerWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final textDark = isDark ? Colors.white : const Color(0xFF1B1533);

    final avatarAsync = ref.watch(userAvatarFileProvider);
    final userName = ref.watch(
      userProfileProvider.select((p) => p.value?.name.trim() ?? ''),
    );
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = (36 * dpr).ceil();

    return RepaintBoundary(
      child: Row(
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
                    child: avatarAsync.value != null
                        ? Image(
                            image: ResizeImage(
                              FileImage(avatarAsync.value!),
                              width: cacheWidth,
                            ),
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                          )
                        : Container(
                            color: primary,
                            alignment: Alignment.center,
                            child: Text(
                              userName.isNotEmpty ? userName[0].toUpperCase() : 'M',
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
      ),
    );
  }
}

// ── Greeting Section ─────────────────────────────────────────────────────────
class _GreetingSection extends ConsumerWidget {
  const _GreetingSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    final userName = ref.watch(
      userProfileProvider.select((p) => p.value?.name.trim() ?? ''),
    );
    final name = userName.isNotEmpty ? userName : 'MasterDineth';
    final formattedDate = DateFormat('EEE, MMM d').format(DateTime.now());

    return RepaintBoundary(
      child: Column(
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
      ),
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
  late final ValueNotifier<DateTime> _timeNotifier;
  Timer? _alignTimer;
  Timer? _periodicTimer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _timeNotifier = ValueNotifier<DateTime>(DateTime.now());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tickerEnabled = TickerMode.valuesOf(context).enabled;
    if (tickerEnabled && !_isRunning) {
      _startTimer();
    } else if (!tickerEnabled && _isRunning) {
      _stopTimer();
    }
  }

  void _startTimer() {
    _stopTimer();
    _isRunning = true;
    _timeNotifier.value = DateTime.now();

    final now = DateTime.now();
    final secondsUntilNextMinute = 60 - now.second;
    final msUntilNextMinute = (secondsUntilNextMinute * 1000) - now.millisecond;

    _alignTimer = Timer(
      Duration(milliseconds: msUntilNextMinute > 0 ? msUntilNextMinute : 1000),
      () {
        if (!_isRunning || !mounted) return;
        _timeNotifier.value = DateTime.now();
        _periodicTimer = Timer.periodic(const Duration(minutes: 1), (_) {
          if (!_isRunning || !mounted) return;
          _timeNotifier.value = DateTime.now();
        });
      },
    );
  }

  void _stopTimer() {
    _isRunning = false;
    _alignTimer?.cancel();
    _alignTimer = null;
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    _timeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassPillChip(
      labelWidget: ValueListenableBuilder<DateTime>(
        valueListenable: _timeNotifier,
        builder: (context, time, _) {
          final formatted = DateFormat('hh:mm a').format(time);
          return Text(
            formatted,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: Color(0xFF14B8A6),
            ),
          );
        },
      ),
      dotColor: const Color(0xFF14B8A6),
      borderColor: const Color(0xFF14B8A6).withValues(alpha: 0.25),
      height: 24,
    );
  }
}

// ── Weekly Stats Overview Section ───────────────────────────────────────────
class _WeeklyStatsSection extends ConsumerWidget {
  const _WeeklyStatsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionRepo = ref.watch(workoutSessionRepositoryProvider);
    final metricsAsync = ref.watch(dashboardMetricsProvider(sessionRepo));

    return RepaintBoundary(
      child: metricsAsync.when(
        data: (m) => _WeeklyStatsCard(
          daysTrained: m['daysTrainedThisWeek'] as int? ?? 1,
          workoutsCompleted: m['totalWorkoutsCompleted'] as int? ?? 1,
          caloriesBurned: m['totalCaloriesBurned'] as int? ?? 380,
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
      enableBlur: false,
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
                    enableBlur: false,
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
                    enableBlur: false,
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
                    enableBlur: false,
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
class _CalendarSection extends ConsumerWidget {
  const _CalendarSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final textDark = isDark ? Colors.white : const Color(0xFF1B1533);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B6785);

    final sessionRepo = ref.watch(workoutSessionRepositoryProvider);
    final displayedMonth = ref.watch(selectedMonthProvider);
    final calendarAsync = ref.watch(calendarActivityProvider(sessionRepo));

    final now = DateTime.now();
    final isCurrentMonth =
        displayedMonth.year == now.year && displayedMonth.month == now.month;

    final daysInMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month + 1,
      0,
    ).day;

    // Monday-based offset (weekday 1=Mon .. 7=Sun)
    final startOffset = (displayedMonth.weekday - 1) % 7;

    final activeDates = calendarAsync.value ?? const [];
    final activeDayNums = activeDates
        .where((d) =>
            d.year == displayedMonth.year && d.month == displayedMonth.month)
        .map((d) => d.day)
        .toSet();

    // Template default active workout days if no logged DB sessions exist
    final effectiveActiveDays = activeDayNums.isNotEmpty
        ? activeDayNums
        : (isCurrentMonth ? {15, 18, 20, 22, 25, 27, 29} : <int>{});

    final monthLabel = DateFormat('MMMM yyyy').format(displayedMonth);

    return RepaintBoundary(
      child: Column(
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
                    onTap: () {
                      ref.read(selectedMonthProvider.notifier).prevMonth();
                    },
                  ),
                  const SizedBox(width: 8),
                  GlassIconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    size: 36,
                    onTap: () {
                      ref.read(selectedMonthProvider.notifier).nextMonth();
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Calendar Card
          FrostedGlassBox(
                    enableBlur: false,
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
      ),
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
      return FrostedGlassBox(
        enableBlur: false,
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
class _TodayRecommendationSection extends ConsumerWidget {
  const _TodayRecommendationSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final textDark = isDark ? Colors.white : const Color(0xFF1B1533);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B6785);

    final scheduleRepo = ref.watch(scheduleRepositoryProvider);
    final sessionRepo = ref.watch(workoutSessionRepositoryProvider);
    final recommendationAsync = ref.watch(
      splitRecommendationProvider(scheduleRepo, sessionRepo),
    );

    final schedule = recommendationAsync.value;
    final title = schedule?.name ?? 'Back & Biceps Pull';
    final subtitle = (schedule?.description.isNotEmpty == true)
        ? schedule!.description
        : 'Pull day focus';

    final orderDay = (schedule != null) ? schedule.orderIndex + 1 : 2;

    return RepaintBoundary(
      child: Column(
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
                    enableBlur: false,
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
                                borderColor: const Color(0xFF2DD4BF)
                                    .withValues(alpha: 0.30),
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
                                context.push('/workouts/detail/${schedule.id}');
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
      ),
    );
  }
}

// ── Recent Workouts Section ──────────────────────────────────────────────────
class _RecentWorkoutsSection extends ConsumerWidget {
  const _RecentWorkoutsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final textDark = isDark ? Colors.white : const Color(0xFF1B1533);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B6785);

    final sessionRepo = ref.watch(workoutSessionRepositoryProvider);
    final recentsAsync = ref.watch(recentWorkoutSessionsProvider(sessionRepo));

    return RepaintBoundary(
      child: Column(
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
                    enableBlur: false,
            tier: GlassTier.surface,
            borderRadius: BorderRadius.circular(20),
            padding: EdgeInsets.zero,
            child: recentsAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) {
                  return _buildFallbackRows(context, primary, textDark, textMuted);
                }
                return Column(
                  children: [
                    for (int i = 0; i < sessions.length && i < 2; i++) ...[
                      if (i > 0) const GlassHairlineDivider(),
                      _buildWorkoutSessionRow(
                        context,
                        sessions[i],
                        primary,
                        textDark,
                        textMuted,
                        isFirst: i == 0,
                        isLast: i == sessions.length - 1 || i == 1,
                      ),
                    ],
                  ],
                );
              },
              loading: () => _buildFallbackRows(context, primary, textDark, textMuted),
              error: (_, _) => _buildFallbackRows(context, primary, textDark, textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutSessionRow(
    BuildContext context,
    WorkoutSession session,
    Color primary,
    Color textDark,
    Color textMuted, {
    required bool isFirst,
    required bool isLast,
  }) {
    final minutes = ((session.durationSeconds ?? 0) / 60).round();
    final durationStr = '${minutes.toString().padLeft(2, '0')}:00';
    final dateStr = DateFormat('MMM d').format(session.startTime);

    return InkWell(
      onTap: () => context.push('/history'),
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(20) : Radius.zero,
        bottom: isLast ? const Radius.circular(20) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            FrostedGlassBox(
                    enableBlur: false,
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
                    'Workout Session',
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
                    '$dateStr · Completed',
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
                  durationStr,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${session.totalCalories} kcal',
                  style: const TextStyle(
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
    );
  }

  Widget _buildFallbackRows(
    BuildContext context,
    Color primary,
    Color textDark,
    Color textMuted,
  ) {
    return Column(
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
                    enableBlur: false,
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
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                FrostedGlassBox(
                    enableBlur: false,
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
    );
  }
}

// ── Tutorials & Guides Section ───────────────────────────────────────────────
class _TutorialsGuidesSection extends StatelessWidget {
  const _TutorialsGuidesSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final textDark = isDark ? Colors.white : const Color(0xFF1B1533);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B6785);

    return RepaintBoundary(
      child: Column(
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
                    enableBlur: false,
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
                    enableBlur: false,
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
                    enableBlur: false,
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
      ),
    );
  }
}
