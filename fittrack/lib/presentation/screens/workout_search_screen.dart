import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/schedules_provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme/glass_tokens.dart';
import '../widgets/glass/frosted_glass_box.dart';
import '../widgets/glass/glass_hairline_divider.dart';
import '../widgets/glass/glass_icon_button.dart';
import '../widgets/glass/glass_pill_chip.dart';

/// Full-fidelity "Luminous Frosted Kinetic" liquid glass Workout Search Screen.
///
/// Corresponds to Stitch MCP Screen `366b0b19fc3d41bbab94f89e401bafb4`.
///
/// Features:
/// - Leading back arrow [GlassIconButton], title, notification bell & profile avatar.
/// - Active [GlassTier.elevated] pill search bar with real-time query sync and clear (✕) button.
/// - Horizontally scrolling category filter pills matching the Library screen.
/// - Live reactive results feed bound to [schedulesNotifierProvider].
/// - Rich [GlassTier.surface] cards with type badge (`PROGRAM` / `CUSTOM ROUTINE`),
///   difficulty/goal tag, status indicator (`✦ Featured Routine` / `◷ Active Routine`),
///   and high-contrast gradient "View →" action pill.
/// - Empty state feedback when no routines match query parameters.
class WorkoutSearchScreen extends ConsumerStatefulWidget {
  const WorkoutSearchScreen({
    super.key,
    this.initialQuery,
    this.initialCategory,
  });

  final String? initialQuery;
  final String? initialCategory;

  @override
  ConsumerState<WorkoutSearchScreen> createState() =>
      _WorkoutSearchScreenState();
}

class _WorkoutSearchScreenState extends ConsumerState<WorkoutSearchScreen> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  static const _filterOptions = <String>[
    'All',
    'Hypertrophy',
    'Strength',
    'Beginner',
    'Advanced',
    'Full Gym',
    'Dumbbells',
    'Bodyweight',
  ];

  @override
  void initState() {
    super.initState();
    final initialQ = widget.initialQuery ??
        ref.read(schedulesNotifierProvider).searchQuery;
    _searchController = TextEditingController(text: initialQ);
    _searchFocusNode = FocusNode();

    if (widget.initialCategory != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(schedulesNotifierProvider.notifier)
            .updateCategoryFilter(widget.initialCategory!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(schedulesNotifierProvider.notifier).updateSearchQuery('');
    setState(() {});
  }

  void _resetAllFilters() {
    _clearSearch();
    ref.read(schedulesNotifierProvider.notifier).updateCategoryFilter('All');
    ref
        .read(schedulesNotifierProvider.notifier)
        .updateSort(SortOption.relevant);
  }

  String _sortLabel(SortOption sort) {
    switch (sort) {
      case SortOption.relevant:
        return 'Most Relevant';
      case SortOption.duration:
        return 'Duration';
      case SortOption.title:
        return 'Alphabetical';
    }
  }

  void _cycleSort(SortOption current) {
    final next = switch (current) {
      SortOption.relevant => SortOption.duration,
      SortOption.duration => SortOption.title,
      SortOption.title => SortOption.relevant,
    };
    ref.read(schedulesNotifierProvider.notifier).updateSort(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final textHeading = isDark ? Colors.white : const Color(0xFF18132B);
    final textMuted = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF6B6882);

    final state = ref.watch(schedulesNotifierProvider);
    final notifier = ref.read(schedulesNotifierProvider.notifier);
    final userProfileAsync = ref.watch(userProfileProvider);
    final filtered = state.filteredSchedules;

    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── 1. Top Bar: Back Action, Title, Notification & Profile ─────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                  child: Row(
                    children: [
                      GlassIconButton(
                        size: 40,
                        icon: const Icon(Icons.arrow_back_rounded, size: 20),
                        tooltip: 'Back to Workouts',
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/workouts');
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Search Workouts',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: textHeading,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Explore splits, routines & programs',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Notification bell with unread dot
                      GlassIconButton(
                        size: 40,
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          size: 19,
                        ),
                        showBadge: true,
                        badgeColor: const Color(0xFFF43F5E),
                        tooltip: 'Notifications',
                        onTap: () => context.push('/settings/notifications'),
                      ),
                      const SizedBox(width: 8),
                      // Circular Profile Avatar
                      GestureDetector(
                        onTap: () => context.push('/settings/profile'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.25)
                                  : Colors.white.withValues(alpha: 0.85),
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
                            child: (userProfileAsync.value?.profileImagePath !=
                                        null &&
                                    userProfileAsync.value!.profileImagePath!
                                        .isNotEmpty)
                                ? Image.file(
                                    File(userProfileAsync
                                        .value!.profileImagePath!),
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    cacheWidth: 80,
                                    errorBuilder: (_, _, _) =>
                                        _buildAvatarFallback(
                                      primary,
                                      userProfileAsync.value?.name,
                                    ),
                                  )
                                : _buildAvatarFallback(
                                    primary,
                                    userProfileAsync.value?.name,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 2. Active Search Bar + Filter Toggle ──────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // Search Input Pill
                      Expanded(
                        child: FrostedGlassBox(
                          tier: GlassTier.elevated,
                          height: 48,
                          borderRadius: BorderRadius.circular(16),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search_rounded,
                                size: 20,
                                color: primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: textHeading,
                                  ),
                                  onChanged: (val) {
                                    notifier.updateSearchQuery(val);
                                    setState(() {});
                                  },
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText:
                                        'Search splits, goals, or equipment...',
                                    hintStyle: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: textMuted.withValues(alpha: 0.8),
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              if (_searchController.text.isNotEmpty)
                                GestureDetector(
                                  onTap: _clearSearch,
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: textMuted,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Squircle Filter Parameter Trigger
                      FrostedGlassBox(
                        tier: GlassTier.elevated,
                        width: 48,
                        height: 48,
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          // Quick cycle sort or trigger category dropdown
                          _cycleSort(state.selectedSort);
                        },
                        child: Center(
                          child: Icon(
                            Icons.tune_rounded,
                            size: 20,
                            color: textHeading,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 3. Horizontal Scrollable Category Filter Chips ───────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: _filterOptions.map((chip) {
                        final isSelected =
                            state.selectedCategoryFilter == chip;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: isSelected
                              ? GestureDetector(
                                  onTap: () =>
                                      notifier.updateCategoryFilter(chip),
                                  child: Container(
                                    height: 32,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: primary,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primary.withValues(alpha: 0.35),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.check_rounded,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          chip,
                                          style: const TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : FrostedGlassBox(
                                  tier: GlassTier.elevated,
                                  height: 32,
                                  borderRadius: BorderRadius.circular(16),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  onTap: () =>
                                      notifier.updateCategoryFilter(chip),
                                  child: Center(
                                    child: Text(
                                      chip,
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? const Color(0xFFCBD5E1)
                                            : const Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // ── 4. Search Results Subheader & Sort ────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Search Results',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: textHeading,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${filtered.length}',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _cycleSort(state.selectedSort),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            Text(
                              _sortLabel(state.selectedSort),
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: textMuted,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.expand_more_rounded,
                              size: 16,
                              color: textMuted,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 5. Search Results Card Feed or Empty State ─────────────────
              if (filtered.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: FrostedGlassBox(
                      tier: GlassTier.surface,
                      borderRadius: BorderRadius.circular(24),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 36,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.search_off_rounded,
                              size: 32,
                              color: primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No workouts found',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: textHeading,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'We couldn\'t find routines matching your filters or search keywords.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: textMuted,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: _resetAllFilters,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: primary,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: primary.withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Clear Search & Filters',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final schedule = filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _SearchResultCard(
                            schedule: schedule,
                            onBookmarkTap: () =>
                                notifier.toggleBookmark(schedule.id),
                            onViewTap: () => context.push(
                              '/workouts/detail',
                              extra: schedule,
                            ),
                          ),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),

              // ── 6. Bottom clearance for floating bottom navigation dock ──
              SliverToBoxAdapter(
                child: SizedBox(height: 112 + bottomInset),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildAvatarFallback(Color primary, String? name) {
    return Container(
      color: primary,
      alignment: Alignment.center,
      child: Text(
        (name != null && name.trim().isNotEmpty)
            ? name.trim()[0].toUpperCase()
            : 'D',
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Rich Frosted Glass Result Card matching Stitch SCREEN_211 layout specs.
class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.schedule,
    required this.onBookmarkTap,
    required this.onViewTap,
  });

  final WorkoutSchedule schedule;
  final VoidCallback onBookmarkTap;
  final VoidCallback onViewTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final textHeading = isDark ? Colors.white : const Color(0xFF18132B);
    final textMuted = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF6B6882);

    final isCustom = schedule.isCustom;
    final typeLabel = isCustom ? 'CUSTOM ROUTINE' : 'PROGRAM';
    final typeBg = isCustom
        ? (isDark
            ? const Color(0xFF0F766E).withValues(alpha: 0.35)
            : const Color(0xFFCCFBF1))
        : (isDark
            ? const Color(0xFFBE123C).withValues(alpha: 0.30)
            : const Color(0xFFFFE4E6));
    final typeTextColor = isCustom
        ? (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E))
        : (isDark ? const Color(0xFFFB7185) : const Color(0xFFE11D48));

    final isHypertrophy =
        schedule.focus.toLowerCase().contains('hypertrophy');
    final goalBg = isHypertrophy
        ? (isDark
            ? primary.withValues(alpha: 0.25)
            : primary.withValues(alpha: 0.12))
        : (isDark
            ? const Color(0xFF38BDF8).withValues(alpha: 0.22)
            : const Color(0xFFE0F2FE));
    final goalTextColor = isHypertrophy
        ? primary
        : (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7));

    return FrostedGlassBox(
      tier: GlassTier.surface,
      enableBlur: false,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Type Chip + Goal Badge + Bookmark toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: typeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        typeLabel,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: typeTextColor,
                          letterSpacing: 0.4,
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
                        color: goalBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        schedule.focus,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: goalTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onBookmarkTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    schedule.isFavorite
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    size: 20,
                    color: schedule.isFavorite ? primary : textMuted,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Routine Title
          Text(
            schedule.title,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textHeading,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 5),

          // Description
          Text(
            schedule.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textMuted,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          // Specs Badges Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                // Days / wk badge
                GlassPillChip(
                  label: '${schedule.daysPerWeek}d / wk',
                  dotColor: const Color(0xFF10B981),
                  fontSize: 11,
                  height: 24,
                  textColor: isDark ? Colors.white70 : const Color(0xFF475569),
                ),
                const SizedBox(width: 6),

                // Duration badge
                GlassPillChip(
                  label: '${schedule.durationWeeks} Weeks',
                  dotColor: const Color(0xFFF59E0B),
                  fontSize: 11,
                  height: 24,
                  textColor: isDark ? Colors.white70 : const Color(0xFF475569),
                ),
                const SizedBox(width: 6),

                // Equipment tier
                GlassPillChip(
                  label: schedule.equipment,
                  fontSize: 11,
                  height: 24,
                  textColor: isDark ? Colors.white70 : const Color(0xFF475569),
                ),
                if (schedule.targetMuscles.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  GlassPillChip(
                    label: schedule.targetMuscles.take(3).join(', '),
                    fontSize: 10.5,
                    height: 24,
                    textColor: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),
          const GlassHairlineDivider(),
          const SizedBox(height: 12),

          // Footer: Status indicator + "View →" Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status Indicator
              if (!isCustom)
                Row(
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      size: 15,
                      color: Color(0xFFF43F5E),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Featured Routine',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF43F5E),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: Color(0xFF10B981),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Active Routine',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),

              // View Pill Action Button
              GestureDetector(
                onTap: onViewTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primary,
                        primary.withValues(alpha: 0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.30),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 13,
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
    );
  }
}
