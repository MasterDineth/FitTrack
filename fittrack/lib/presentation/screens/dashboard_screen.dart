import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/repository_providers.dart';
import '../providers/workout_logic_providers.dart';
import '../providers/user_profile_provider.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/user_profile.dart';

/// Dashboard – the home hub screen shown after onboarding.
///
/// Displays a dynamic greeting, a 3-column metrics banner, a monthly activity
/// calendar, a "Today's Recommendation" hero card wired to [splitRecommendation],
/// a recent workouts list, and a guides/tutorials list.
///
/// All data is pulled strictly through Riverpod providers per AGENTS.md.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  // ── Brand colours ──────────────────────────────────────────────────────
  static const Color _mint = Color(0xFF00d68f);
  static const Color _dark = Color(0xFF0f172a);
  static const Color _cardBg = Colors.white;
  static const Color _muted = Color(0xFF64748b);
  static const Color _softBorder = Color(0xFFe2e8f0);

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── App Header ─────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader(context, userProfileAsync)),

            // ── Greeting ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: _buildGreeting(userProfileAsync),
              ),
            ),

            // ── Metrics Banner ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: metricsAsync.when(
                  data: (m) => _MetricsBanner(
                    daysTrained: m['daysTrainedThisWeek'] as int,
                    workoutsCompleted: m['totalWorkoutsCompleted'] as int,
                    caloriesBurned: m['totalCaloriesBurned'] as int,
                  ),
                  loading: () => _MetricsBanner(
                      daysTrained: 0, workoutsCompleted: 0, caloriesBurned: 0),
                  error: (_, _) => _MetricsBanner(
                      daysTrained: 0, workoutsCompleted: 0, caloriesBurned: 0),
                ),
              ),
            ),

            // ── Activity Calendar ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: calendarAsync.when(
                  data: (dates) => _ActivityCalendar(activeDates: dates),
                  loading: () => _ActivityCalendar(activeDates: const []),
                  error: (_, _) => _ActivityCalendar(activeDates: const []),
                ),
              ),
            ),

            // ── Today's Recommendation ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: recommendationAsync.when(
                  data: (schedule) =>
                      _TodayRecommendationCard(schedule: schedule),
                  loading: () => const _RecommendationLoading(),
                  error: (_, _) =>
                      const _TodayRecommendationCard(schedule: null),
                ),
              ),
            ),

            // ── Recent Workouts ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _buildSectionHeader(context, 'Recent Workouts', 'See All'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _RecentWorkoutCard(
                    title: 'Back & Biceps',
                    timeAgo: '23 hours ago',
                    duration: '45:00',
                    calories: '350.5 kcal',
                    accentColor: colorScheme.primary,
                  ),
                  const SizedBox(height: 10),
                  _RecentWorkoutCard(
                    title: 'Legs & Posterior Chain',
                    timeAgo: '3 days ago',
                    duration: '52:00',
                    calories: '410.0 kcal',
                    accentColor: const Color(0xFF64748b),
                  ),
                ]),
              ),
            ),

            // ── Tutorials & Guides ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _buildSectionHeader(context, 'Tutorials & Guides', 'See All'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _TutorialCard(
                    title: 'Mastering the Bench Press',
                    description: 'Shoulder blade retraction, bar path, and leg drive for max power.',
                    badge: 'Video',
                    badgeColor: _mint,
                    readTime: '5 min read & watch',
                    iconColor: const Color(0xFFecfdf5),
                  ),
                  const SizedBox(height: 10),
                  _TutorialCard(
                    title: 'Proper Hip Hinge Guide',
                    description: 'Protect your lower spine while engaging hamstrings and glutes safely.',
                    badge: 'Guide',
                    badgeColor: const Color(0xFF0d9488),
                    readTime: '4 min read',
                    iconColor: const Color(0xFFf0fdfa),
                  ),
                  const SizedBox(height: 10),
                  _TutorialCard(
                    title: 'Breathing & Core Bracing',
                    description: 'Valsalva maneuver basics for heavy squats, deadlifts, and overhead presses.',
                    badge: 'Technique',
                    badgeColor: const Color(0xFF64748b),
                    readTime: '3 min read',
                    iconColor: const Color(0xFFf8fafc),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header Builder ──────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, AsyncValue<UserProfile> userProfileAsync) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          // Brand logo
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.fitness_center_rounded,
                color: colorScheme.primary, size: 18),
          ),
          const SizedBox(width: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _dark,
                letterSpacing: -0.5,
              ),
              children: [
                const TextSpan(text: 'Fit'),
                TextSpan(
                    text: 'Track',
                    style: TextStyle(color: colorScheme.primary)),
              ],
            ),
          ),
          const Spacer(),
          // Notification bell
          Stack(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _softBorder),
                  boxShadow: [
                    BoxShadow(
                      color: _dark.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: const Icon(Icons.notifications_outlined,
                    color: _muted, size: 18),
              ),
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          // User avatar
          InkWell(
            onTap: () => context.push('/settings/profile'),
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1e293b), Color(0xFF334155)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: (userProfileAsync.value?.profileImagePath != null &&
                            File(userProfileAsync.value!.profileImagePath!)
                                .existsSync())
                        ? Image.file(
                            File(userProfileAsync.value!.profileImagePath!),
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Text(
                              (userProfileAsync.value?.name.trim().isNotEmpty ==
                                      true)
                                  ? userProfileAsync.value!.name
                                      .trim()[0]
                                      .toUpperCase()
                                  : 'D',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
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

  // ── Greeting ────────────────────────────────────────────────────────────
  Widget _buildGreeting(AsyncValue<UserProfile> profileAsync) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    final name = profileAsync.value?.name ?? 'Dineth';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, $name!',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: _dark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              _formatDate(DateTime.now()),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _muted,
              ),
            ),
            const SizedBox(width: 6),
            const _LiveClockPill(),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime now) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Widget _buildSectionHeader(BuildContext context, String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _dark,
            letterSpacing: -0.2,
          ),
        ),
        Text(
          action,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

// ── Live Clock Pill ──────────────────────────────────────────────────────────
class _LiveClockPill extends StatefulWidget {
  const _LiveClockPill();

  @override
  State<_LiveClockPill> createState() => _LiveClockPillState();
}

class _LiveClockPillState extends State<_LiveClockPill> {
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _now = DateTime.now());
        _tick();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');
    final s = _now.second.toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFecfdf5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00d68f).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF00d68f),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '$h:$m:$s',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF047857),
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Metrics Banner ───────────────────────────────────────────────────────────
class _MetricsBanner extends StatelessWidget {
  const _MetricsBanner({
    required this.daysTrained,
    required this.workoutsCompleted,
    required this.caloriesBurned,
  });

  final int daysTrained;
  final int workoutsCompleted;
  final int caloriesBurned;

  static const Color _mint = Color(0xFF00d68f);
  static const Color _dark = Color(0xFF0f172a);
  static const Color _softBorder = Color(0xFFe2e8f0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _softBorder.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: _dark.withValues(alpha: 0.04),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Days
            Expanded(
              child: _MetricCell(
                icon: Icons.calendar_today_outlined,
                iconColor: _mint,
                label: 'Days',
                value: '$daysTrained',
                suffix: '/4',
              ),
            ),
            const VerticalDivider(
                width: 1, color: Color(0xFFf1f5f9), thickness: 1),
            // Workouts
            Expanded(
              child: _MetricCell(
                icon: Icons.bolt_rounded,
                iconColor: _mint,
                label: 'Workouts',
                value: '$workoutsCompleted',
              ),
            ),
            const VerticalDivider(
                width: 1, color: Color(0xFFf1f5f9), thickness: 1),
            // Calories
            Expanded(
              child: _MetricCell(
                icon: Icons.local_fire_department_rounded,
                iconColor: const Color(0xFFf97316),
                label: 'Burned',
                value: caloriesBurned > 0
                    ? (caloriesBurned / 10.0).toStringAsFixed(1)
                    : '0',
                suffix: 'kcal',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.suffix,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? suffix;

  static const Color _dark = Color(0xFF0f172a);
  static const Color _muted = Color(0xFF64748b);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _muted,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _dark,
                letterSpacing: -0.5,
              ),
            ),
            if (suffix != null) ...[
              const SizedBox(width: 2),
              Text(
                suffix!,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _muted,
                ),
              ),
            ]
          ],
        ),
      ],
    );
  }
}

// ── Activity Calendar ────────────────────────────────────────────────────────
class _ActivityCalendar extends StatelessWidget {
  const _ActivityCalendar({required this.activeDates});

  final List<DateTime> activeDates;

  static const Color _dark = Color(0xFF0f172a);
  static const Color _softBorder = Color(0xFFe2e8f0);
  static const Color _muted = Color(0xFF64748b);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    // weekday: 1=Mon..7=Sun. We want Mon=0 offset
    final startOffset = (firstDayOfMonth.weekday - 1) % 7;

    final activeDayNums = activeDates
        .where((d) => d.year == now.year && d.month == now.month)
        .map((d) => d.day)
        .toSet();

    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This Month',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _dark,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  '${monthNames[now.month - 1]} ${now.year}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _muted,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _CalendarNavBtn(icon: Icons.chevron_left_rounded),
                const SizedBox(width: 6),
                _CalendarNavBtn(icon: Icons.chevron_right_rounded),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Calendar card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _softBorder.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: _dark.withValues(alpha: 0.04),
                blurRadius: 24,
                spreadRadius: -4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Day-of-week header
              Row(
                children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _muted,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              // Days grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 1,
                ),
                itemCount: startOffset + daysInMonth,
                itemBuilder: (context, index) {
                  if (index < startOffset) return const SizedBox.shrink();
                  final day = index - startOffset + 1;
                  final isToday = day == now.day;
                  final isActive = activeDayNums.contains(day);

                  final colorScheme = Theme.of(context).colorScheme;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isActive
                          ? colorScheme.primary
                          : isToday
                              ? colorScheme.primary.withValues(alpha: 0.15)
                              : const Color(0xFFf8fafc),
                      borderRadius: BorderRadius.circular(10),
                      border: isToday
                          ? Border.all(color: colorScheme.primary, width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isToday || isActive
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isActive
                                ? colorScheme.onPrimary
                                : isToday
                                    ? colorScheme.primary
                                    : const Color(0xFF475569),
                          ),
                        ),
                        if (isActive || isToday)
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? colorScheme.onPrimary
                                  : colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CalendarNavBtn extends StatelessWidget {
  const _CalendarNavBtn({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFe2e8f0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Icon(icon, size: 16, color: const Color(0xFF64748b)),
    );
  }
}

// ── Today's Recommendation Card ──────────────────────────────────────────────
class _TodayRecommendationCard extends ConsumerWidget {
  const _TodayRecommendationCard({required this.schedule});

  final Schedule? schedule;

  static const Color _dark = Color(0xFF0f172a);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with pulse indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  "Today's Recommendation",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _dark,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFecfdf5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: const Text(
                'SCHEDULED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF047857),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Hero card
        if (schedule == null)
          _RestDayCard()
        else
          _ScheduleHeroCard(schedule: schedule!),
      ],
    );
  }
}

class _ScheduleHeroCard extends ConsumerWidget {
  const _ScheduleHeroCard({required this.schedule});
  final Schedule schedule;

  static const Color _dark = Color(0xFF0f172a);
  static const Color _muted = Color(0xFF64748b);
  static const Color _softBorder = Color(0xFFe2e8f0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(
      _scheduleExercisesProvider(schedule.id),
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _softBorder.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: _dark.withValues(alpha: 0.04),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient accent bar
          Container(
            height: 6,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF00d68f),
                  Color(0xFF0d9488),
                  Color(0xFF06b6d4),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day badge + type
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFecfdf5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'TODAY • DAY ${schedule.orderIndex + 1}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.trending_up_rounded,
                            size: 14, color: _muted),
                        SizedBox(width: 4),
                        Text(
                          'Hypertrophy',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  schedule.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _dark,
                    letterSpacing: -0.4,
                  ),
                ),
                if (schedule.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    schedule.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _muted,
                    ),
                  ),
                ],

                // Muscle pills
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: schedule.targetMuscles
                        .map((m) => _MusclePill(muscle: m))
                        .toList(),
                  ),
                ),

                // Footer stats + CTA
                Container(
                  padding: const EdgeInsets.only(top: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFf1f5f9)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Stats
                      exercisesAsync.when(
                        data: (exercises) => Row(
                          children: [
                            const Icon(Icons.list_alt_rounded,
                                size: 14, color: _muted),
                            const SizedBox(width: 4),
                            Text(
                              '${exercises.length} Exercises',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _muted,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.access_time_rounded,
                                size: 14, color: _muted),
                            const SizedBox(width: 4),
                            Text(
                              '~${_estimateMinutes(exercises)} min',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _muted,
                              ),
                            ),
                          ],
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                      // Start button
                      GestureDetector(
                        onTap: () => context
                            .push('/workouts/detail/${schedule.id}'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
                                blurRadius: 20,
                                spreadRadius: -2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Start',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.play_arrow_rounded,
                                  size: 14, color: Theme.of(context).colorScheme.onPrimary),
                            ],
                          ),
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
    );
  }

  int _estimateMinutes(List<dynamic> exercises) {
    if (exercises.isEmpty) return 0;
    return ((exercises.length * 60 + exercises.length * 90) / 60).round();
  }
}

// Local provider for schedule exercises within dashboard card.
// Key is "repoHashCode:scheduleId" to avoid record type requirements.
final _scheduleExercisesProvider = FutureProvider.family<List<dynamic>, String>(
  (ref, key) async {
    final scheduleRepo = ref.watch(scheduleRepositoryProvider);
    final scheduleId = key.contains(':') ? key.split(':').last : key;
    return scheduleRepo.getScheduleExercises(scheduleId);
  },
);

class _RestDayCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFe2e8f0).withValues(alpha: 0.7)),
      ),
      child: const Row(
        children: [
          Icon(Icons.bedtime_rounded,
              size: 36, color: Color(0xFF94a3b8)),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rest & Recovery Day',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0f172a),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'All scheduled workouts completed this week. Rest up!',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748b),
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

class _RecommendationLoading extends StatelessWidget {
  const _RecommendationLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFe2e8f0).withValues(alpha: 0.7)),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00d68f),
          strokeWidth: 2,
        ),
      ),
    );
  }
}

// ── Muscle Pill ──────────────────────────────────────────────────────────────
class _MusclePill extends StatelessWidget {
  const _MusclePill({required this.muscle});

  final String muscle;

  static const _muscleColors = {
    'chest': [Color(0xFFfff1f2), Color(0xFFef4444)],
    'shoulders': [Color(0xFFfffbeb), Color(0xFFd97706)],
    'triceps': [Color(0xFFf0f9ff), Color(0xFF0ea5e9)],
    'back': [Color(0xFFf0fdf4), Color(0xFF22c55e)],
    'biceps': [Color(0xFFfdf4ff), Color(0xFFa855f7)],
    'quads': [Color(0xFFeff6ff), Color(0xFF3b82f6)],
    'hamstrings': [Color(0xFFfefce8), Color(0xFFeab308)],
    'core': [Color(0xFFfff7ed), Color(0xFFf97316)],
    'calves': [Color(0xFFf0fdfa), Color(0xFF14b8a6)],
  };

  @override
  Widget build(BuildContext context) {
    final key = muscle.toLowerCase();
    final colors = _muscleColors[key] ??
        [const Color(0xFFf1f5f9), const Color(0xFF64748b)];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors[0],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors[1].withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: colors[1],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            muscle,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors[1],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recent Workout Card ──────────────────────────────────────────────────────
class _RecentWorkoutCard extends StatelessWidget {
  const _RecentWorkoutCard({
    required this.title,
    required this.timeAgo,
    required this.duration,
    required this.calories,
    required this.accentColor,
  });

  final String title;
  final String timeAgo;
  final String duration;
  final String calories;
  final Color accentColor;

  static const Color _dark = Color(0xFF0f172a);
  static const Color _muted = Color(0xFF64748b);
  static const Color _softBorder = Color(0xFFe2e8f0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _softBorder.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: _dark.withValues(alpha: 0.03),
            blurRadius: 16,
            spreadRadius: -4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accentColor.withValues(alpha: 0.2)),
            ),
            child: Icon(Icons.fitness_center_rounded,
                color: accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _muted,
                      ),
                    ),
                    const Text(
                      ' • ',
                      style: TextStyle(fontSize: 11, color: _muted),
                    ),
                    const Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                duration,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _dark,
                ),
              ),
              Text(
                calories,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Tutorial Card ────────────────────────────────────────────────────────────
class _TutorialCard extends StatelessWidget {
  const _TutorialCard({
    required this.title,
    required this.description,
    required this.badge,
    required this.badgeColor,
    required this.readTime,
    required this.iconColor,
  });

  final String title;
  final String description;
  final String badge;
  final Color badgeColor;
  final String readTime;
  final Color iconColor;

  static const Color _dark = Color(0xFF0f172a);
  static const Color _muted = Color(0xFF64748b);
  static const Color _softBorder = Color(0xFFe2e8f0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _softBorder.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: _dark.withValues(alpha: 0.03),
            blurRadius: 16,
            spreadRadius: -4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: badgeColor.withValues(alpha: 0.2)),
            ),
            child: Icon(Icons.play_circle_outline_rounded,
                color: badgeColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _dark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border:
                            Border.all(color: badgeColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        badge.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: badgeColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _muted,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 11, color: _muted),
                    const SizedBox(width: 3),
                    Text(
                      readTime,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: _muted, size: 20),
        ],
      ),
    );
  }
}
