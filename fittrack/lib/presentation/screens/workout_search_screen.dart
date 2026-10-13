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

/// Completely redesigned FitTrack Workout Library Search Results screen adhering
/// strictly to Stitch Screen `7759fa4d78f943e090ede6cfbc6efca7` and AGENTS.md.
///
/// Features:
/// - Smooth back navigation via header back button and back gesture ([PopScope]).
/// - Top header with Back button, "Search Workouts", subtitle, 40x40 notification bell, and 36x36 profile avatar.
/// - Live search text field with instant clear (`✕`) button and 50x50 filter sliders button.
/// - Horizontally scrolling filter chips (`All`, `Hypertrophy`, `Strength`, `Beginner`, `Advanced`, `Full Gym`).
/// - Results header with live item count, sort dropdown (`Most Relevant`, `Duration`, `Title`),
///   and expand-all / collapse-all toggle button.
/// - Top / most relevant result expands with `98% MATCH` emerald badge, hero media,
///   4-metric grid (Cadence, Duration, Target RPE, Gear), muscles pills, and `View Program & Schedule ->` action.
/// - Remaining items render as collapsed cards with thumbnail, difficulty badges, bookmark ribbon, and `Preview Split ->` button.
/// - Tapping any individual card toggles its expansion state.
/// - Full bookmarking system persisting to SQLite database.
/// - Bottom "Can't find your ideal split? ... + Build Routine" CTA card.
/// - Dock clearance padding for floating bottom navigation.
class WorkoutSearchScreen extends ConsumerStatefulWidget {
  const WorkoutSearchScreen({super.key});

  @override
  ConsumerState<WorkoutSearchScreen> createState() => _WorkoutSearchScreenState();
}

class _WorkoutSearchScreenState extends ConsumerState<WorkoutSearchScreen> {
  late final TextEditingController _searchController;

  static const _filterChips = <String>[
    'All',
    'Hypertrophy',
    'Strength',
    'Beginner',
    'Advanced',
    'Full Gym',
  ];

  @override
  void initState() {
    super.initState();
    final initialQuery = ref.read(schedulesNotifierProvider).searchQuery;
    _searchController = TextEditingController(text: initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onBackTap() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/workouts');
    }
  }

  void _onQueryChanged(String query) {
    ref.read(schedulesNotifierProvider.notifier).updateSearchQuery(query);
  }

  void _clearQuery() {
    _searchController.clear();
    ref.read(schedulesNotifierProvider.notifier).updateSearchQuery('');
  }

  void _onCategoryTap(String category) {
    ref.read(schedulesNotifierProvider.notifier).updateCategoryFilter(category);
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
      SortOption.relevant => 'Most Relevant',
      SortOption.duration => 'Duration',
      SortOption.title => 'Title',
    };
  }

  @override
  Widget build(BuildContext context) {
    final schedulesState = ref.watch(schedulesNotifierProvider);
    final notifier = ref.read(schedulesNotifierProvider.notifier);
    final filteredResults = schedulesState.filteredSchedules;

    final bottomPadding = (MediaQuery.paddingOf(context).bottom > 0)
        ? MediaQuery.paddingOf(context).bottom + 16.0
        : 90.0;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onBackTap();
      },
      child: Scaffold(
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
                            // Header with Back button
                            _SearchHeader(onBackTap: _onBackTap),
                            const SizedBox(height: 16),

                            // Search Input Field & Filter Tune Button
                            _buildSearchInputRow(),
                            const SizedBox(height: 14),

                            // Filter Chips Row
                            _buildFilterChips(
                              schedulesState.selectedCategoryFilter,
                            ),
                            const SizedBox(height: 20),

                            // Results Meta Bar (Count, Sort dropdown, Expand/Collapse all)
                            _buildResultsMetaBar(
                              resultCount: filteredResults.length,
                              selectedSort: schedulesState.selectedSort,
                              allExpanded: schedulesState.allExpanded,
                              onSortTap: () =>
                                  _cycleSort(schedulesState.selectedSort),
                              onToggleExpandAll: notifier.toggleExpandAll,
                            ),
                            const SizedBox(height: 14),

                            // Results List
                            if (filteredResults.isEmpty)
                              _buildEmptyResults()
                            else
                              ..._buildResultsList(
                                filteredResults,
                                schedulesState,
                                notifier,
                              ),

                            const SizedBox(height: 24),

                            // Bottom "Can't find your ideal split?" CTA Card
                            _buildCustomRoutineCta(),
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
      ),
    );
  }

  // ── Search Input Row ──────────────────────────────────────────────────────
  Widget _buildSearchInputRow() {
    return Row(
      children: [
        Expanded(
          child: GlassSurface(
            tier: FtGlassTier.glass2,
            radius: 18,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: context.ftPrimary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onQueryChanged,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.ftInk,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search splits, goals or equipment...',
                      hintStyle: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: context.ftMuted.withValues(alpha: 0.8),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  FtPressable(
                    onTap: _clearQuery,
                    pressedScale: 0.90,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: context.ftMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        FtPressable(
          onTap: () {
            // Focus search field
          },
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

  // ── Filter Chips Row ──────────────────────────────────────────────────────
  Widget _buildFilterChips(String selectedCategory) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none,
      child: Row(
        children: _filterChips.map((chip) {
          final isSelected = chip.toLowerCase() == selectedCategory.toLowerCase();

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

  // ── Results Meta Bar ──────────────────────────────────────────────────────
  Widget _buildResultsMetaBar({
    required int resultCount,
    required SortOption selectedSort,
    required bool allExpanded,
    required VoidCallback onSortTap,
    required VoidCallback onToggleExpandAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'Showing $resultCount Results',
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
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sort Dropdown Pill
            FtPressable(
              onTap: onSortTap,
              pressedScale: 0.95,
              child: GlassSurface(
                tier: FtGlassTier.glass2,
                radius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _sortLabel(selectedSort),
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.ftInk,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 15,
                      color: context.ftMuted,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Expand / Collapse All Toggle Button
            FtPressable(
              onTap: onToggleExpandAll,
              pressedScale: 0.90,
              child: GlassSurface(
                tier: FtGlassTier.glass2,
                radius: 12,
                width: 34,
                height: 34,
                alignment: Alignment.center,
                child: Icon(
                  allExpanded
                      ? Icons.unfold_less_rounded
                      : Icons.unfold_more_rounded,
                  size: 18,
                  color: context.ftInk,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Results List Builder ──────────────────────────────────────────────────
  List<Widget> _buildResultsList(
    List<WorkoutSchedule> results,
    SchedulesState state,
    SchedulesNotifier notifier,
  ) {
    final widgets = <Widget>[];

    for (int i = 0; i < results.length; i++) {
      final schedule = results[i];
      final isExpanded = state.isExpanded(schedule.id);
      final isBookmarked = state.bookmarkedIds.contains(schedule.id);

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 14.0),
          child: isExpanded
              ? _ExpandedResultCard(
                  schedule: schedule,
                  isBookmarked: isBookmarked,
                  matchPercent: (i == 0) ? 98 : 92 - (i * 3),
                  onCardTap: () => notifier.toggleExpand(schedule.id),
                  onBookmarkTap: () => notifier.toggleBookmark(schedule.id),
                  onViewScheduleTap: () =>
                      context.push('/workouts/detail/${schedule.id}'),
                )
              : _CollapsedResultCard(
                  schedule: schedule,
                  isBookmarked: isBookmarked,
                  onCardTap: () => notifier.toggleExpand(schedule.id),
                  onBookmarkTap: () => notifier.toggleBookmark(schedule.id),
                  onPreviewTap: () =>
                      context.push('/workouts/detail/${schedule.id}'),
                ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: context.ftMuted.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            Text(
              'No workout splits match your criteria',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: context.ftInk,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try clearing filters or search for another term',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 12,
                color: context.ftMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Custom Routine CTA Card ────────────────────────────────────────
  Widget _buildCustomRoutineCta() {
    return GlassSurface(
      tier: FtGlassTier.glass1,
      radius: 22,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.ftPrimary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.tune_rounded,
              size: 22,
              color: context.ftPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Can't find your ideal split?",
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: context.ftInk,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Create a custom routine tailored to your specific gear & schedule',
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: context.ftMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FtPressable(
            onTap: () => context.push('/workouts/create-schedule'),
            pressedScale: 0.96,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: context.isDark
                    ? const Color(0x33251E3E)
                    : Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: context.ftPrimary.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: context.ftPrimary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Build Routine',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: context.ftPrimary,
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
}

// ── Header Widget with Back Button ──────────────────────────────────────────
class _SearchHeader extends ConsumerWidget {
  final VoidCallback onBackTap;

  const _SearchHeader({required this.onBackTap});

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
          // Left: Back button + Title & Subtitle
          Expanded(
            child: Row(
              children: [
                FtPressable(
                  onTap: onBackTap,
                  pressedScale: 0.90,
                  child: GlassSurface(
                    tier: FtGlassTier.glass2,
                    radius: 18,
                    width: 40,
                    height: 40,
                    shadow: false,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 20,
                      color: context.ftInk,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Search Workouts',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: context.ftInk,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Explore splits, routines & programs',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: context.ftMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
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

// ── Expanded Search Result Card (Top Featured Result) ──────────────────────
class _ExpandedResultCard extends StatelessWidget {
  final WorkoutSchedule schedule;
  final bool isBookmarked;
  final int matchPercent;
  final VoidCallback onCardTap;
  final VoidCallback onBookmarkTap;
  final VoidCallback onViewScheduleTap;

  const _ExpandedResultCard({
    required this.schedule,
    required this.isBookmarked,
    required this.matchPercent,
    required this.onCardTap,
    required this.onBookmarkTap,
    required this.onViewScheduleTap,
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
          // Top Badges Row: Match Badge, Cadence Pill, Bookmark
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.35),
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
                      '$matchPercent% MATCH',
                      style: const TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
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
                    '${schedule.durationWeeks} Weeks · ${schedule.daysPerWeek}d/wk',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: context.ftInk,
                    ),
                  ),
                ),
              ),
              FtPressable(
                onTap: onBookmarkTap,
                pressedScale: 0.90,
                child: Icon(
                  isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: 20,
                  color: isBookmarked
                      ? const Color(0xFFFBBF24)
                      : context.ftMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Hero Media Banner with Gradient Scrim
          FtPressable(
            onTap: onCardTap,
            pressedScale: 0.99,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                image: const DecorationImage(
                  image: AssetImage('assets/images/dashboard/hero_workout.webp'),
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
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.75),
                        ],
                      ),
                    ),
                  ),
                  // Rating Pill & FEATURED Badge
                  Positioned(
                    bottom: 10,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: Color(0xFFFBBF24),
                                ),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    '4.9 (2.4k reviews)',
                                    style: TextStyle(
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
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: context.ftPrimary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'FEATURED',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
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
          ),
          const SizedBox(height: 12),

          // Title & Description
          GestureDetector(
            onTap: onCardTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.title,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: context.ftInk,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  schedule.description,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: context.ftMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4-Metric Grid (2x2)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.isDark
                  ? const Color(0x33251E3E)
                  : const Color(0x66FFFFFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.isDark
                    ? const Color(0x2EFFFFFF)
                    : const Color(0x80FFFFFF),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricItem(
                        context,
                        icon: Icons.calendar_today_rounded,
                        label: 'Cadence',
                        value: '${schedule.daysPerWeek}d / wk',
                      ),
                    ),
                    Expanded(
                      child: _buildMetricItem(
                        context,
                        icon: Icons.timer_outlined,
                        label: 'Duration',
                        value: '${schedule.estimatedMinutes} min/session',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricItem(
                        context,
                        icon: Icons.speed_rounded,
                        label: 'Target RPE',
                        value: '8.5 / 10',
                      ),
                    ),
                    Expanded(
                      child: _buildMetricItem(
                        context,
                        icon: Icons.fitness_center_rounded,
                        label: 'Gear',
                        value: schedule.equipment,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // MUSCLES: Tag Pills
          Row(
            children: [
              Text(
                'MUSCLES:',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: context.ftMuted,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  children: schedule.targetMuscles.map((muscle) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: context.isDark
                            ? const Color(0x33251E3E)
                            : const Color(0x80FFFFFF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        muscle,
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
            ],
          ),
          const SizedBox(height: 16),

          // View Program & Schedule Action Button
          FtPressable(
            onTap: onViewScheduleTap,
            pressedScale: 0.97,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: context.ftPrimary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.ftPrimary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      'View Program & Schedule',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: context.ftPrimary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: context.ftMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: context.ftInk,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Collapsed Search Result Card ────────────────────────────────────────────
class _CollapsedResultCard extends StatelessWidget {
  final WorkoutSchedule schedule;
  final bool isBookmarked;
  final VoidCallback onCardTap;
  final VoidCallback onBookmarkTap;
  final VoidCallback onPreviewTap;

  const _CollapsedResultCard({
    required this.schedule,
    required this.isBookmarked,
    required this.onCardTap,
    required this.onBookmarkTap,
    required this.onPreviewTap,
  });

  @override
  Widget build(BuildContext context) {
    return FtPressable(
      onTap: onCardTap,
      pressedScale: 0.98,
      child: GlassSurface(
        tier: FtGlassTier.glass1,
        radius: 20,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail on left
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/dashboard/coaching_bench.webp'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    margin: const EdgeInsets.only(bottom: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${schedule.durationWeeks} Wks',
                      style: const TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Middle Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge Row
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: _badgeColor(schedule.experience)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          schedule.experience.toUpperCase(),
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            color: _badgeColor(schedule.experience),
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Title
                      Text(
                        schedule.title,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: context.ftInk,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),

                      // Subtitle
                      Text(
                        '${schedule.description} · ${schedule.daysPerWeek}d/wk',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: context.ftMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Bookmark Ribbon Button
                FtPressable(
                  onTap: onBookmarkTap,
                  pressedScale: 0.90,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Icon(
                      isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      size: 18,
                      color: isBookmarked
                          ? const Color(0xFFFBBF24)
                          : context.ftMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Bottom Action Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    schedule.targetMuscles.isNotEmpty
                        ? schedule.targetMuscles.take(2).join(' & ')
                        : schedule.equipment,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: context.ftMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FtPressable(
                  onTap: onPreviewTap,
                  pressedScale: 0.95,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.ftPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Preview Split',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: context.ftPrimary,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 14,
                          color: context.ftPrimary,
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

  Color _badgeColor(String exp) {
    switch (exp.toLowerCase()) {
      case 'advanced':
        return const Color(0xFFEF4444);
      case 'intermediate':
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF10B981);
    }
  }
}
