import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/dashboard_providers.dart';
import '../providers/schedules_provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme/ft_glass.dart';
import '../widgets/ft_background_painter.dart';
import '../widgets/glass_surface.dart';
import 'dashboard/widgets/ft_pressable.dart';

/// Completely redesigned FitTrack Workout Library screen adhering strictly to
/// Stitch Screen `96ee402291a749399d62ddb8e047db55` and AGENTS.md.
///
/// Features:
/// - Exact Dashboard header alignment (Title, Subtitle, 40x40 circle glass2 notification bell, 36x36 avatar).
/// - Dynamic mesh background and frosted glass design system (`FtGlassTier`).
/// - Search input pill and filter sliders button routing to `/workouts/search`.
/// - Horizontally scrolling filter chips (`All Goals`, `Hypertrophy`, `Strength Peak`, etc.).
/// - Trending Programs carousel with athlete badges, ratings, tags, and bookmark toggle.
/// - Today's Routine Spotlight card featuring top 3 exercises from SQLite database,
///   stats columns (Time, Burn, 5-bar Intensity meter), and circular play button.
/// - My Saved & Custom routines section with progress bars, badges, and overflow menu.
/// - Browse All Schedules section loading up to 5 schedules from SQLite database with
///   tags, cadence, duration, and `View Split >` actions.
/// - Full bookmarking system integrated with SQLite persistence.
/// - Dock clearance padding for floating bottom navigation.
class WorkoutsScreen extends ConsumerStatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  ConsumerState<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends ConsumerState<WorkoutsScreen> {
  static const _filterChips = <String>[
    'All Goals',
    'Hypertrophy',
    'Strength Peak',
    'Agility & Core',
    'Endurance',
    'Bodyweight',
    'Full Gym',
  ];

  @override
  void initState() {
    super.initState();
    // Synchronize schedules with local SQLite database on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(schedulesNotifierProvider.notifier).loadFromDatabase();
    });
  }

  void _onSearchTap() {
    context.push('/workouts/search');
  }

  void _onCategoryTap(String category) {
    final queryCategory = category == 'All Goals' ? 'All' : category;
    ref.read(schedulesNotifierProvider.notifier).updateCategoryFilter(queryCategory);
    context.push('/workouts/search');
  }

  void _cycleSort(SortOption current) {
    final next = switch (current) {
      SortOption.relevant => SortOption.duration,
      SortOption.duration => SortOption.title,
      SortOption.title => SortOption.relevant,
    };
    ref.read(schedulesNotifierProvider.notifier).updateSort(next);
  }

  String _sortLabel(SortOption sort) {
    return switch (sort) {
      SortOption.relevant => 'Sort',
      SortOption.duration => 'Duration',
      SortOption.title => 'Title',
    };
  }

  @override
  Widget build(BuildContext context) {
    final schedulesState = ref.watch(schedulesNotifierProvider);
    final trending = ref.watch(trendingProgramsProvider);
    final spotlightAsync = ref.watch(routineSpotlightProvider);
    final customRoutines = ref.watch(customRoutinesProvider);
    final dbSchedulesAsync = ref.watch(dbBrowseSchedulesProvider);

    final bottomPadding = (MediaQuery.paddingOf(context).bottom > 0)
        ? MediaQuery.paddingOf(context).bottom + 16.0
        : 90.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Dynamic Mesh Gradient Background
          const Positioned.fill(
            child: FtMeshBackground(),
          ),

          // 2. Centered Content Viewport
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 393),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverSafeArea(
                    top: true,
                    bottom: false,
                    sliver: SliverPadding(
                      padding: EdgeInsets.only(
                        left: 20.0,
                        right: 20.0,
                        bottom: bottomPadding,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Header (Uniform with Dashboard)
                          const _WorkoutsHeader(),
                          const SizedBox(height: 16),

                          // Search Bar & Filter Button
                          _buildSearchBar(),
                          const SizedBox(height: 14),

                          // Filter Chips Row
                          _buildFilterChips(schedulesState.selectedCategoryFilter),
                          const SizedBox(height: 24),

                          // Trending Programs Carousel
                          _buildTrendingSection(trending),
                          const SizedBox(height: 28),

                          // Today's Routine Spotlight
                          _buildSpotlightSection(spotlightAsync),
                          const SizedBox(height: 28),

                          // My Saved & Custom Section
                          _buildSavedCustomSection(customRoutines),
                          const SizedBox(height: 28),

                          // Browse All Schedules Section (Loaded from DB up to 5)
                          _buildBrowseSchedulesSection(
                            dbSchedulesAsync,
                            schedulesState.selectedSort,
                          ),
                          const SizedBox(height: 20),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search & Filter Row ───────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: FtPressable(
            onTap: _onSearchTap,
            pressedScale: 0.98,
            child: GlassSurface(
              tier: FtGlassTier.glass2,
              radius: 18,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: context.ftPrimary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Search splits, goals or equipment...',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: context.ftMuted.withValues(alpha: 0.85),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        FtPressable(
          onTap: _onSearchTap,
          pressedScale: 0.95,
          child: GlassSurface(
            tier: FtGlassTier.glass2,
            radius: 18,
            width: 50,
            height: 50,
            alignment: Alignment.center,
            child: Icon(
              Icons.tune_rounded,
              size: 22,
              color: context.ftInk,
            ),
          ),
        ),
      ],
    );
  }

  // ── Horizontally Scrolling Filter Chips ───────────────────────────────────
  Widget _buildFilterChips(String selectedCategory) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none,
      child: Row(
        children: _filterChips.map((chip) {
          final isSelected = (chip == 'All Goals' &&
                  (selectedCategory == 'All' || selectedCategory == 'All Goals')) ||
              chip.toLowerCase() == selectedCategory.toLowerCase();

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FtPressable(
              onTap: () => _onCategoryTap(chip),
              pressedScale: 0.95,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.ftPrimary
                      : context.isDark
                          ? const Color(0x33251E3E)
                          : const Color(0x66FFFFFF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? context.ftPrimary
                        : context.isDark
                            ? const Color(0x2EFFFFFF)
                            : const Color(0x80FFFFFF),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: context.ftPrimary.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      chip,
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : context.ftInk,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Trending Programs Section ─────────────────────────────────────────────
  Widget _buildTrendingSection(List<TrendingProgram> trending) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Trending Programs',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: context.ftInk,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'HOT',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Top-tier verified athlete protocols',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: context.ftMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FtPressable(
              onTap: () => context.push('/workouts/search'),
              pressedScale: 0.95,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Explore',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: context.ftPrimary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: context.ftPrimary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal Carousel
        SizedBox(
          height: 335,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            itemCount: trending.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final program = trending[index];
              return _TrendingProgramCard(
                program: program,
                onBookmarkTap: () {
                  ref
                      .read(schedulesNotifierProvider.notifier)
                      .toggleBookmark(program.id);
                },
                onStartTap: () {
                  context.push('/workouts/active/sch1');
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Today's Routine Spotlight Section ─────────────────────────────────────
  Widget _buildSpotlightSection(AsyncValue<RoutineSpotlight> spotlightAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF43F5E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "Today's Routine Spotlight",
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: context.ftInk,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: context.ftPrimary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: context.ftPrimary.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Text(
                'Day 14',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: context.ftPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            'Follow 3 explosive conditioning circuits',
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.ftMuted,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Spotlight Card
        spotlightAsync.when(
          data: (spotlight) => _SpotlightCard(
            spotlight: spotlight,
            onPlayTap: () => context.push('/workouts/active/${spotlight.scheduleId}'),
          ),
          loading: () => GlassSurface(
            tier: FtGlassTier.glass1,
            radius: 24,
            height: 200,
            alignment: Alignment.center,
            child: Text(
              'Loading Spotlight...',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 12,
                color: context.ftMuted,
              ),
            ),
          ),
          error: (error, stack) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  // ── My Saved & Custom Section ─────────────────────────────────────────────
  Widget _buildSavedCustomSection(List<CustomWorkoutRoutine> customRoutines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      'My Saved & Custom',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 18,
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
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.ftPrimary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${customRoutines.length}',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: context.ftPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FtPressable(
              onTap: () => context.push('/workouts/create-schedule'),
              pressedScale: 0.95,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_rounded,
                    size: 16,
                    color: context.ftPrimary,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'New routine',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: context.ftPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // List of Custom Cards
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: customRoutines.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final routine = customRoutines[index];
            return _CustomRoutineCard(
              routine: routine,
              onTap: () => context.push('/workouts/detail/sch1'),
              onBookmarkToggle: () {
                ref
                    .read(schedulesNotifierProvider.notifier)
                    .toggleBookmark(routine.id);
              },
            );
          },
        ),
      ],
    );
  }

  // ── Browse All Schedules Section (Loaded from DB) ─────────────────────────
  Widget _buildBrowseSchedulesSection(
    AsyncValue<List<WorkoutSchedule>> schedulesAsync,
    SortOption sort,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      'Browse All Schedules',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: context.ftInk,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  schedulesAsync.when(
                    data: (schedules) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.ftPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${schedules.length} Programs',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: context.ftPrimary,
                        ),
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (error, stack) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FtPressable(
              onTap: () => _cycleSort(sort),
              pressedScale: 0.95,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: context.ftMuted,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    _sortLabel(sort),
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.ftMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // List of DB Schedules (up to 5)
        schedulesAsync.when(
          data: (schedules) {
            final displaySchedules = schedules.take(5).toList();
            return Stack(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displaySchedules.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final schedule = displaySchedules[index];
                    return _BrowseScheduleCard(
                      schedule: schedule,
                      onTap: () => context.push('/workouts/detail/${schedule.id}'),
                    );
                  },
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: FtPressable(
                    onTap: () => context.push('/workouts/create-schedule'),
                    pressedScale: 0.95,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: context.ftPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: context.ftPrimary.withValues(alpha: 0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => GlassSurface(
            tier: FtGlassTier.glass1,
            radius: 20,
            height: 120,
            alignment: Alignment.center,
            child: Text(
              'Loading Schedules...',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 12,
                color: context.ftMuted,
              ),
            ),
          ),
          error: (e, _) => Center(
            child: Text(
              'Failed to load schedules: $e',
              style: TextStyle(color: context.ftMuted),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Uniform Header Widget matching DashboardHeader ─────────────────────────
class _WorkoutsHeader extends ConsumerWidget {
  const _WorkoutsHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.value;

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Screen Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workouts',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.55,
                    color: context.ftInk,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Explore splits, routines & programs',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.ftMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Right: Notification Bell (40x40) + Avatar (36x36)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FtPressable(
                onTap: () {},
                pressedScale: 0.95,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GlassSurface(
                        tier: FtGlassTier.glass2,
                        radius: 20,
                        width: 40,
                        height: 40,
                        shadow: false,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.notifications_outlined,
                          size: 20,
                          color: context.ftInk,
                        ),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF43F5E),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FtPressable(
                onTap: () => context.push('/settings/profile'),
                pressedScale: 0.95,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _buildAvatarImage(
                      profile?.profileImagePath,
                      profile?.name,
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

  Widget _buildAvatarImage(String? path, String? name) {
    if (path != null && path.isNotEmpty) {
      return Image.file(
        File(path),
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        cacheWidth: 72,
        errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(),
      );
    }
    return _buildFallbackAvatar();
  }

  Widget _buildFallbackAvatar() {
    return Image.asset(
      'assets/images/dashboard/sample_avatar.webp',
      width: 36,
      height: 36,
      fit: BoxFit.cover,
      cacheWidth: 72,
    );
  }
}

// ── Trending Program Carousel Card ──────────────────────────────────────────
class _TrendingProgramCard extends StatelessWidget {
  final TrendingProgram program;
  final VoidCallback onBookmarkTap;
  final VoidCallback onStartTap;

  const _TrendingProgramCard({
    required this.program,
    required this.onBookmarkTap,
    required this.onStartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
      ),
      child: GlassSurface(
        tier: FtGlassTier.glass1,
        radius: 24,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Athlete Banner Image with Dark Scrim
            Container(
              height: 125,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/images/dashboard/hero_workout.webp'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  // Top Row: Category Tag & Bookmark
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                program.categoryTag,
                                style: const TextStyle(
                                  fontFamily: FtText.fontFamily,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FtPressable(
                          onTap: onBookmarkTap,
                          pressedScale: 0.90,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              program.isBookmarked
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              size: 16,
                              color: program.isBookmarked
                                  ? const Color(0xFFFBBF24)
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Overlay Row: Rating & Duration
                  Positioned(
                    bottom: 8,
                    left: 10,
                    right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: Color(0xFFFBBF24),
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  '${program.rating} (${program.reviewCount})',
                                  style: const TextStyle(
                                    fontFamily: FtText.fontFamily,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${program.durationWeeks} Weeks · ${program.daysPerWeek}d/wk',
                            style: const TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Title & Description
            Text(
              program.title,
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: context.ftInk,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              program.description,
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: context.ftMuted,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            // Tags Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: program.tags.map((tag) {
                  return Container(
                    margin: const EdgeInsets.only(right: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? const Color(0x33251E3E)
                          : const Color(0x66FFFFFF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: context.isDark
                            ? const Color(0x2EFFFFFF)
                            : const Color(0x80FFFFFF),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: context.ftInk,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Spacer(),

            // Bottom CTA Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: context.ftPrimary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          program.intensityLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: context.ftPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FtPressable(
                  onTap: onStartTap,
                  pressedScale: 0.95,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: context.ftPrimary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: context.ftPrimary.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Start Split',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 3),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 15,
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
    );
  }
}

// ── Today's Routine Spotlight Card with top 3 exercises ────────────────────
class _SpotlightCard extends StatelessWidget {
  final RoutineSpotlight spotlight;
  final VoidCallback onPlayTap;

  const _SpotlightCard({
    required this.spotlight,
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      tier: FtGlassTier.glass1,
      radius: 24,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Image with Title & Play Button
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              image: const DecorationImage(
                image: AssetImage('assets/images/dashboard/coaching_bench.webp'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF43F5E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      spotlight.categoryTag,
                      style: const TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 60,
                  child: Text(
                    spotlight.title,
                    style: const TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 12,
                  child: FtPressable(
                    onTap: onPlayTap,
                    pressedScale: 0.90,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.ftPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: context.ftPrimary.withValues(alpha: 0.5),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3 Stats Columns Row
          Row(
            children: [
              Expanded(
                child: _buildStatColumn(
                  context,
                  label: 'TIME',
                  value: '${spotlight.durationMinutes} min',
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  context,
                  label: 'BURN',
                  value: '~${spotlight.estimatedCalories} kcal',
                  valueColor: const Color(0xFFF97316),
                ),
              ),
              Expanded(
                child: _buildIntensityColumn(
                  context,
                  level: spotlight.intensityLevel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Hairline Divider
          Container(
            height: 1,
            color: context.isDark
                ? const Color(0x2EFFFFFF)
                : const Color(0x33CAC4D7),
          ),
          const SizedBox(height: 12),

          // DRILL CIRCUIT PREVIEW Header
          Text(
            'DRILL CIRCUIT PREVIEW',
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: context.ftMuted,
            ),
          ),
          const SizedBox(height: 8),

          // Top 3 Drill Exercises from Schedule
          ...spotlight.drills.map((drill) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: context.ftPrimary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${drill.stepNumber}',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: context.ftPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      drill.exerciseName,
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.ftInk,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    drill.prescription,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: context.ftMuted,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: FtText.fontFamily,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: context.ftMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: FtText.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: valueColor ?? context.ftInk,
          ),
        ),
      ],
    );
  }

  Widget _buildIntensityColumn(BuildContext context, {required int level}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'INTENSITY',
          style: TextStyle(
            fontFamily: FtText.fontFamily,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: context.ftMuted,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final isFilled = index < level;
            return Container(
              width: 3.5,
              height: 10 + (index * 1.5),
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: isFilled
                    ? context.ftPrimary
                    : context.ftMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ── Custom Workout Routine Card ─────────────────────────────────────────────
class _CustomRoutineCard extends StatelessWidget {
  final CustomWorkoutRoutine routine;
  final VoidCallback onTap;
  final VoidCallback onBookmarkToggle;

  const _CustomRoutineCard({
    required this.routine,
    required this.onTap,
    required this.onBookmarkToggle,
  });

  @override
  Widget build(BuildContext context) {
    return FtPressable(
      onTap: onTap,
      pressedScale: 0.98,
      child: GlassSurface(
        tier: FtGlassTier.glass1,
        radius: 20,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                image: const DecorationImage(
                  image: AssetImage('assets/images/dashboard/hero_workout.webp'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Content Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          routine.title,
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: context.ftInk,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: (routine.badgeColor ?? context.ftPrimary)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          routine.badgeText,
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            color: routine.badgeColor ?? context.ftPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    routine.subtitle,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: context.ftMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Progress Bar & Label
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: routine.progressPercent,
                            backgroundColor: context.isDark
                                ? const Color(0x33FFFFFF)
                                : const Color(0x225F3BDC),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              routine.badgeColor ?? context.ftPrimary,
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        routine.progressLabel,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: context.ftMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Trailing Kebab Menu
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                size: 18,
                color: context.ftMuted,
              ),
              onSelected: (value) {
                if (value == 'bookmark') onBookmarkToggle();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'bookmark',
                  child: Text(routine.isBookmarked ? 'Unbookmark' : 'Bookmark'),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit Routine'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Browse All Schedules Card (Loaded from DB) ──────────────────────────────
class _BrowseScheduleCard extends StatelessWidget {
  final WorkoutSchedule schedule;
  final VoidCallback onTap;

  const _BrowseScheduleCard({
    required this.schedule,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FtPressable(
      onTap: onTap,
      pressedScale: 0.98,
      child: GlassSurface(
        tier: FtGlassTier.glass1,
        radius: 20,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title + Focus Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    schedule.title,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: context.ftInk,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: _focusColor(schedule.focus).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _focusColor(schedule.focus).withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    schedule.focus.toUpperCase(),
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: _focusColor(schedule.focus),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Metadata Row: Cadence · Weeks · Gear
            Text(
              '${schedule.daysPerWeek}d/wk · ${schedule.durationWeeks} Weeks · ${schedule.equipment}',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: context.ftMuted,
              ),
            ),
            const SizedBox(height: 8),

            // Bottom Row: Program Type / View Split > Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  schedule.experience,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.ftMuted,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Split',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: context.ftPrimary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: context.ftPrimary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _focusColor(String focus) {
    switch (focus.toLowerCase()) {
      case 'hypertrophy':
        return const Color(0xFF7C5CFA);
      case 'strength':
        return const Color(0xFF0284C7);
      case 'advanced':
        return const Color(0xFFE11D48);
      default:
        return const Color(0xFF059669);
    }
  }
}
