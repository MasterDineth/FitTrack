import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/repository_providers.dart';
import '../providers/workout_logic_providers.dart';
import '../providers/user_profile_provider.dart';
import '../../domain/entities/schedule.dart';

/// Workout Schedules Screen – shows the active cycle, today's recommended
/// workout, upcoming split plan, and a pill FAB for creating custom schedules.
///
/// Wires directly to [splitRecommendationProvider] and [scheduleRepositoryProvider].
class WorkoutSchedulesScreen extends ConsumerStatefulWidget {
  const WorkoutSchedulesScreen({super.key});

  @override
  ConsumerState<WorkoutSchedulesScreen> createState() =>
      _WorkoutSchedulesScreenState();
}

class _WorkoutSchedulesScreenState
    extends ConsumerState<WorkoutSchedulesScreen> {
  bool _fabExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheduleRepo = ref.watch(scheduleRepositoryProvider);
    final sessionRepo = ref.watch(workoutSessionRepositoryProvider);

    final recommendationAsync = ref.watch(
      splitRecommendationProvider(scheduleRepo, sessionRepo),
    );

    // Watch all schedules to build upcoming stack
    final allSchedulesAsync = ref.watch(_allSchedulesProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── App Bar ─────────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildAppBar(context)),

            // ── Cycle Header & Progress ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: allSchedulesAsync.when(
                  data: (schedules) => _CycleProgressSection(
                    schedules: schedules,
                    recommendedSchedule:
                        recommendationAsync.value,
                  ),
                  loading: () => const SizedBox(height: 60),
                  error: (err, trace) => const SizedBox.shrink(),
                ),
              ),
            ),

            // ── Hero: Recommended for Today ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: recommendationAsync.when(
                  data: (schedule) =>
                      _HeroRecommendedCard(schedule: schedule),
                  loading: () => const _HeroLoading(),
                  error: (err, trace) =>
                      const _HeroRecommendedCard(schedule: null),
                ),
              ),
            ),

            // ── Upcoming Split Stack ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: allSchedulesAsync.when(
                  data: (schedules) => _UpcomingSplitSection(
                    schedules: schedules,
                    todaySchedule: recommendationAsync.value,
                    onScheduleTap: (s) =>
                        context.push('/workouts/detail/${s.id}'),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (err, trace) => const SizedBox.shrink(),
                ),
              ),
            ),

            // Bottom padding for FAB + nav bar
            const SliverToBoxAdapter(
              child: SizedBox(height: 140),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
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
              const SizedBox(width: 10),
              Text(
                'Workouts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Notification bell
          Stack(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colorScheme.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Icon(Icons.notifications_outlined,
                    color: colorScheme.onSurface.withValues(alpha: 0.6), size: 18),
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
                    border: Border.all(color: colorScheme.surface, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          // User avatar
          Builder(
            builder: (context) {
              final userProfileAsync = ref.watch(userProfileProvider);
              final hasCustomImage =
                  userProfileAsync.value?.profileImagePath != null &&
                      File(userProfileAsync.value!.profileImagePath!)
                          .existsSync();
              final initial =
                  (userProfileAsync.value?.name.trim().isNotEmpty == true)
                      ? userProfileAsync.value!.name.trim()[0].toUpperCase()
                      : 'D';

              return InkWell(
                onTap: () => context.push('/settings/profile'),
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primaryContainer,
                            colorScheme.primary.withValues(alpha: 0.7),
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
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                              )
                            : Center(
                                child: Text(
                                  initial,
                                  style: TextStyle(
                                    color: colorScheme.onPrimary,
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
                          border: Border.all(color: colorScheme.surface, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Pill FAB ─────────────────────────────────────────────────────────────
  Widget _buildFAB(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Transform.translate(
      offset: const Offset(0, 12),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          if (_fabExpanded) {
            context.push('/workouts/create-schedule');
          } else {
            setState(() => _fabExpanded = true);
            // Auto-collapse after 3 seconds
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) setState(() => _fabExpanded = false);
            });
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 56,
          padding: _fabExpanded
              ? const EdgeInsets.symmetric(horizontal: 20)
              : const EdgeInsets.all(0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withValues(alpha: 0.85),
                colorScheme.primary,
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.45),
                blurRadius: 24,
                spreadRadius: -4,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 12,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 16),
                Icon(Icons.add_rounded,
                    color: colorScheme.onPrimary, size: 26),
                if (_fabExpanded) ...[
                  const SizedBox(width: 8),
                  Text(
                    'Create Custom Schedule',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// All Schedules Provider – watches scheduleRepositoryProvider internally.
final _allSchedulesProvider = FutureProvider.autoDispose<List<Schedule>>(
  (ref) async {
    final scheduleRepo = ref.watch(scheduleRepositoryProvider);
    final schedules = await scheduleRepo.getAllSchedules();
    final active = schedules.where((s) => !s.isArchived).toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return active;
  },
);

// ── Cycle Progress Section ───────────────────────────────────────────────────
class _CycleProgressSection extends StatelessWidget {
  const _CycleProgressSection({
    required this.schedules,
    required this.recommendedSchedule,
  });

  final List<Schedule> schedules;
  final Schedule? recommendedSchedule;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final total = schedules.length;
    final currentIdx = recommendedSchedule?.orderIndex ?? 0;
    final progressFraction = total == 0 ? 0.0 : currentIdx / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'WEEK 3 · PUSH-PULL-LEGS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onPrimaryContainer,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Progress card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Circular progress
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: CircularProgressIndicator(
                        value: progressFraction,
                        strokeWidth: 4,
                        backgroundColor: colorScheme.outlineVariant,
                        color: colorScheme.primary,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '${currentIdx + 1}/$total',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendedSchedule?.name ?? 'Monday Ignition',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '3 sessions remaining in active cycle',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Streak pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department_rounded,
                        size: 14, color: colorScheme.primary),
                    const SizedBox(width: 3),
                    Text(
                      '4d streak',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
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

// ── Hero Recommended Card ────────────────────────────────────────────────────
class _HeroRecommendedCard extends ConsumerWidget {
  const _HeroRecommendedCard({required this.schedule});

  final Schedule? schedule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.bolt_rounded, color: colorScheme.primary, size: 20),
                const SizedBox(width: 4),
                Text(
                  'Recommended for Today',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            Text(
              'SCHEDULED',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Card
        if (schedule == null)
          _RestCard()
        else
          _HeroCard(schedule: schedule!, ref: ref),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.schedule, required this.ref});
  final Schedule schedule;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => context.push('/workouts/detail/${schedule.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.15),
              blurRadius: 28,
              spreadRadius: -6,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.7),
                    colorScheme.primary,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'TODAY • DAY ${schedule.orderIndex + 1}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onPrimaryContainer,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.trending_up_rounded,
                              size: 14, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                          const SizedBox(width: 4),
                          Text(
                            'Hypertrophy',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Title
                  Text(
                    schedule.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (schedule.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      schedule.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),

                  // Muscle chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: schedule.targetMuscles
                        .map((m) => _MuscleChip(muscle: m))
                        .toList(),
                  ),
                ],
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              color: colorScheme.surfaceContainerHighest,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.fitness_center_rounded,
                          size: 16, color: colorScheme.onSurface),
                      const SizedBox(width: 6),
                      Text(
                        '7 Exercises',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time_rounded,
                          size: 16, color: colorScheme.onSurface),
                      const SizedBox(width: 6),
                      Text(
                        '45 min',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context
                        .push('/workouts/detail/${schedule.id}'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary
                                .withValues(alpha: 0.25),
                            blurRadius: 12,
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
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.play_arrow_rounded,
                              size: 16, color: colorScheme.onPrimary),
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
    );
  }
}

class _RestCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.bedtime_rounded, size: 36, color: colorScheme.onSurface.withValues(alpha: 0.5)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rest & Deep Recovery',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Muscle repair, mobility session, and 8h sleep target.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.5), size: 20),
        ],
      ),
    );
  }
}

// ── Upcoming Split Section ───────────────────────────────────────────────────
class _UpcomingSplitSection extends StatefulWidget {
  const _UpcomingSplitSection({
    required this.schedules,
    required this.todaySchedule,
    required this.onScheduleTap,
  });

  final List<Schedule> schedules;
  final Schedule? todaySchedule;
  final ValueChanged<Schedule> onScheduleTap;

  @override
  State<_UpcomingSplitSection> createState() => _UpcomingSplitSectionState();
}

class _UpcomingSplitSectionState extends State<_UpcomingSplitSection> {
  int? _expandedIndex;

  // Return schedules after (and excluding) today's
  List<Schedule> get _upcomingSchedules {
    if (widget.todaySchedule == null) return widget.schedules;
    return widget.schedules
        .where((s) => s.orderIndex > widget.todaySchedule!.orderIndex)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final upcoming = _upcomingSchedules;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Upcoming Split Plan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${upcoming.length} days',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Reorder',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Schedule cards
        ...upcoming.asMap().entries.map((entry) {
          final index = entry.key;
          final schedule = entry.value;
          final isExpanded = _expandedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _UpcomingScheduleCard(
              schedule: schedule,
              isExpanded: isExpanded,
              onTap: () {
                setState(() {
                  _expandedIndex = isExpanded ? null : index;
                });
              },
              onStartTap: () => widget.onScheduleTap(schedule),
            ),
          );
        }),

        // Rest & Recovery static card
        const _RestRecoveryCard(),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _UpcomingScheduleCard extends StatelessWidget {
  const _UpcomingScheduleCard({
    required this.schedule,
    required this.isExpanded,
    required this.onTap,
    required this.onStartTap,
  });

  final Schedule schedule;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onStartTap;

  static const _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday'
  ];

  String get _dayLabel {
    if (schedule.assignedWeekdays.isNotEmpty) {
      final wd = schedule.assignedWeekdays.first;
      return wd >= 1 && wd <= 7 ? _weekdays[wd - 1] : 'Day';
    }
    return 'Day ${schedule.orderIndex + 1}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_dayLabel • Day ${schedule.orderIndex + 1}'.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        schedule.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.more_horiz_rounded,
                      size: 18, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Muscle badges
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: schedule.targetMuscles
                  .map((m) => _MuscleChip(muscle: m))
                  .toList(),
            ),

            // Footer stats
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.fitness_center_rounded,
                          size: 14, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                      const SizedBox(width: 4),
                      Text(
                        '7 Exercises',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.timer_outlined, size: 14, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                      const SizedBox(width: 4),
                      Text(
                        '45 min',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.chevron_right_rounded,
                        size: 20, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),

            // Expanded detail
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Column(
                        children: [
                          Divider(height: 1, color: colorScheme.outlineVariant),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  schedule.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: onStartTap,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'View',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestRecoveryCard extends StatelessWidget {
  const _RestRecoveryCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.bedtime_rounded,
                size: 24, color: colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Rest & Deep Recovery',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Friday',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Muscle repair, mobility session, and 8h sleep target.',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                )
              ],
            ),
            child: Icon(Icons.arrow_forward_rounded,
                size: 16, color: colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}

// ── Muscle Chip ──────────────────────────────────────────────────────────────
class _MuscleChip extends StatelessWidget {
  const _MuscleChip({required this.muscle});
  final String muscle;

  static const _muscleColors = {
    'chest': [Color(0xFFef4444)],
    'shoulders': [Color(0xFF0ea5e9)],
    'triceps': [Color(0xFF00d68f)],
    'back': [Color(0xFF55c7ff)],
    'biceps': [Color(0xFFbec6e0)],
    'quads': [Color(0xFF00d68f)],
    'hamstrings': [Color(0xFF0ea5e9)],
    'core': [Color(0xFFf97316)],
    'calves': [Color(0xFF64748b)],
    'posterior chain': [Color(0xFF64748b)],
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final key = muscle.toLowerCase();
    final dotColor =
        _muscleColors[key]?.first ?? colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            muscle,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroLoading extends StatelessWidget {
  const _HeroLoading();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
