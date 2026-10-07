import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/schedules_provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme/glass_tokens.dart';
import '../widgets/ambient_mesh_background.dart';
import '../widgets/glass/frosted_glass_box.dart';
import '../widgets/glass/glass_hairline_divider.dart';
import '../widgets/glass/glass_icon_button.dart';
import '../widgets/glass/glass_pill_chip.dart';

/// Redesigned FitTrack Workout Library screen adhering strictly to the
/// "Luminous Frosted Kinetic" liquid glass aesthetic and Stitch MCP Screen `c946214d18d6420fb9a1abd022374304`.
///
/// Features:
/// - Header with "Workouts" title, subtitle, GlassIconButton bell with unread dot, and user avatar.
/// - Pill-shaped [GlassTier.elevated] search input routing to `/workouts/search`.
/// - Horizontal scrolling category filter chips with active solid accent state.
/// - "Recommended for you" snap carousel of [GlassTier.surface] cards (24px radius, category chip, bookmark, meta chips, "View >" action).
/// - "Bookmarked" carousel of compact cards (185px width, difficulty badge, frequency).
/// - "My routines" section with `+ New routine` button, custom icon pods, `CUSTOM` chip, and 3-dot overflow menu.
/// - "Browse all" programs list with count, sorting selector, and floating `+ Create Schedule` action button.
/// - 112px bottom inset spacer to clear the floating bottom dock.
class WorkoutsScreen extends ConsumerStatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  ConsumerState<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends ConsumerState<WorkoutsScreen> {
  static const _filterChips = <String>[
    'All',
    'Hypertrophy',
    'Strength',
    'Beginner',
    'Advanced',
    'Full Gym',
    'Dumbbells',
    'Bodyweight',
  ];

  void _onSearchTap() {
    context.push('/workouts/search');
  }

  void _onCategoryTap(String category) {
    ref.read(schedulesNotifierProvider.notifier).updateCategoryFilter(category);
    if (category != 'All') {
      context.push('/workouts/search');
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

  String _sortLabel(SortOption sort) {
    switch (sort) {
      case SortOption.relevant:
        return 'Sort';
      case SortOption.duration:
        return 'Duration';
      case SortOption.title:
        return 'Title';
    }
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

    final recommended = state.recommendedSchedules;
    final bookmarked = state.bookmarkedSchedules;
    final custom = state.customSchedules;
    final allPrograms = state.allSchedules.where((s) => !s.isCustom).toList();

    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientMeshBackground(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── 1. Top Screen Header ──────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Workouts',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 24,
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
                                    fontSize: 12,
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
                            size: 44,
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              size: 20,
                            ),
                            showBadge: true,
                            badgeColor: const Color(0xFFF43F5E),
                            tooltip: 'Notifications',
                            onTap: () =>
                                context.push('/settings/notifications'),
                          ),
                          const SizedBox(width: 10),
                          // Circular profile avatar
                          GestureDetector(
                            onTap: () => context.push('/settings/profile'),
                            child: Container(
                              width: 44,
                              height: 44,
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
                                        File(userProfileAsync
                                                .value!.profileImagePath!)
                                            .existsSync())
                                    ? Image.file(
                                        File(userProfileAsync
                                            .value!.profileImagePath!),
                                        width: 44,
                                        height: 44,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: primary,
                                        alignment: Alignment.center,
                                        child: Text(
                                          (userProfileAsync.value?.name
                                                      .trim()
                                                      .isNotEmpty ==
                                                  true)
                                              ? userProfileAsync.value!.name
                                                  .trim()[0]
                                                  .toUpperCase()
                                              : 'D',
                                          style: const TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 15,
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
                    ),
                  ),

                  // ── 2. Search Field + Filter Trigger ───────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: FrostedGlassBox(
                              tier: GlassTier.elevated,
                              height: 50,
                              borderRadius: BorderRadius.circular(16),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              onTap: _onSearchTap,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search_rounded,
                                    size: 20,
                                    color: primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Search splits, goals or equipment...',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                        color: textMuted.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          FrostedGlassBox(
                            tier: GlassTier.elevated,
                            width: 50,
                            height: 50,
                            borderRadius: BorderRadius.circular(16),
                            onTap: _onSearchTap,
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

                  // ── 3. Filter Chips Carousel ──────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14, bottom: 20),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: _filterChips.map((chip) {
                            final isSelected =
                                state.selectedCategoryFilter == chip;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: isSelected
                                  ? GestureDetector(
                                      onTap: () => _onCategoryTap(chip),
                                      child: Container(
                                        height: 36,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: primary,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                              color: primary.withValues(
                                                alpha: 0.35,
                                              ),
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
                                            const SizedBox(width: 5),
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
                                      height: 36,
                                      borderRadius: BorderRadius.circular(14),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      onTap: () => _onCategoryTap(chip),
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

                  // ── 4. "Recommended for you" Section ───────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Recommended for you',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: textHeading,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  size: 13,
                                  color: primary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'BASED ON PROFILE',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: primary,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 250,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: recommended.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final schedule = recommended[index];
                          return _RecommendedProgramCard(
                            schedule: schedule,
                            onBookmarkTap: () =>
                                notifier.toggleBookmark(schedule.id),
                            onViewTap: () => context.push(
                              '/workouts/detail',
                              extra: schedule,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // ── 5. "Bookmarked" Workouts Section ───────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Bookmarked',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: textHeading,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: primary.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${bookmarked.length}',
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
                            onTap: () => context.push('/workouts/search'),
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              children: [
                                Text(
                                  'See all',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: primary,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 16,
                                  color: primary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 140,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: bookmarked.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final schedule = bookmarked[index];
                          return _CompactBookmarkedCard(
                            schedule: schedule,
                            onTap: () => context.push(
                              '/workouts/detail',
                              extra: schedule,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // ── 6. "My routines" Section ──────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'My routines',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: textHeading,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: primary.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${custom.length}',
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
                          FrostedGlassBox(
                            tier: GlassTier.elevated,
                            height: 32,
                            borderRadius: BorderRadius.circular(12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            onTap: () =>
                                context.push('/workouts/create-schedule'),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_rounded, size: 16, color: primary),
                                const SizedBox(width: 4),
                                Text(
                                  'New routine',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: FrostedGlassBox(
                        tier: GlassTier.surface,
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          children: List.generate(custom.length, (index) {
                            final schedule = custom[index];
                            final isFirst = index == 0;
                            final isLast = index == custom.length - 1;
                            final podBg = isFirst
                                ? (isDark
                                    ? const Color(0xFF065F46).withValues(alpha: 0.4)
                                    : const Color(0xFFE6FBF4))
                                : (isDark
                                    ? const Color(0xFF92400E).withValues(alpha: 0.4)
                                    : const Color(0xFFFEF3C7));
                            final podIconColor = isFirst
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B);
                            final podIcon = isFirst
                                ? Icons.fitness_center_rounded
                                : Icons.bolt_rounded;

                            return Column(
                              children: [
                                InkWell(
                                  onTap: () => context.push(
                                    '/workouts/detail',
                                    extra: schedule,
                                  ),
                                  borderRadius: BorderRadius.vertical(
                                    top: isFirst
                                        ? const Radius.circular(20)
                                        : Radius.zero,
                                    bottom: isLast
                                        ? const Radius.circular(20)
                                        : Radius.zero,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      children: [
                                        // Leading colored pod
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: podBg,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            podIcon,
                                            size: 20,
                                            color: podIconColor,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      schedule.title,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Plus Jakarta Sans',
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: textHeading,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: primary.withValues(
                                                        alpha: 0.12,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Text(
                                                      'CUSTOM',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Plus Jakarta Sans',
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: primary,
                                                        letterSpacing: 0.4,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                '${schedule.exerciseCount} exercises · ${schedule.estimatedMinutes} min · ${schedule.targetMuscles.join(' & ')}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily:
                                                      'Plus Jakarta Sans',
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // 3-dot overflow options
                                        PopupMenuButton<String>(
                                          icon: Icon(
                                            Icons.more_vert_rounded,
                                            size: 18,
                                            color: textMuted,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          onSelected: (val) {
                                            if (val == 'view') {
                                              context.push(
                                                '/workouts/detail',
                                                extra: schedule,
                                              );
                                            } else if (val == 'bookmark') {
                                              notifier.toggleBookmark(
                                                schedule.id,
                                              );
                                            }
                                          },
                                          itemBuilder: (_) => [
                                            const PopupMenuItem(
                                              value: 'view',
                                              child: Text('View Routine'),
                                            ),
                                            PopupMenuItem(
                                              value: 'bookmark',
                                              child: Text(
                                                schedule.isFavorite
                                                    ? 'Remove Bookmark'
                                                    : 'Bookmark Routine',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (!isLast) const GlassHairlineDivider(),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),

                  // ── 7. "Browse all" Programs Section ───────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Browse all',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: textHeading,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${allPrograms.length} programs',
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
                                    color: primary,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.expand_more_rounded,
                                  size: 16,
                                  color: primary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final schedule = allPrograms[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _BrowseProgramCard(
                              schedule: schedule,
                              onBookmarkTap: () =>
                                  notifier.toggleBookmark(schedule.id),
                              onTap: () => context.push(
                                '/workouts/detail',
                                extra: schedule,
                              ),
                            ),
                          );
                        },
                        childCount: allPrograms.length,
                      ),
                    ),
                  ),

                  // ── 8. Bottom Spacer to clear Floating Dock ────────────────
                  SliverToBoxAdapter(
                    child: SizedBox(height: 112 + bottomInset),
                  ),
                ],
              ),

              // ── Floating Action Button: Create Schedule ───────────────────
              Positioned(
                bottom: 84 + bottomInset,
                right: 20,
                child: FrostedGlassBox(
                  tier: GlassTier.elevated,
                  borderRadius: BorderRadius.circular(28),
                  padding: const EdgeInsets.fromLTRB(10, 8, 16, 8),
                  onTap: () => context.push('/workouts/create-schedule'),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.28),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Create Schedule',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Snap-carousel Recommended Program Card (width 295px, Glass-1).
class _RecommendedProgramCard extends StatelessWidget {
  const _RecommendedProgramCard({
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

    final isHypertrophy =
        schedule.focus.toLowerCase().contains('hypertrophy');
    final tagBg = isHypertrophy
        ? primary.withValues(alpha: 0.12)
        : const Color(0xFF06B6D4).withValues(alpha: 0.15);
    final tagColor = isHypertrophy ? primary : const Color(0xFF0891B2);

    return FrostedGlassBox(
      tier: GlassTier.surface,
      width: 295,
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top tag + Bookmark button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: tagBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      schedule.focus.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: tagColor,
                        letterSpacing: 0.5,
                      ),
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
              const SizedBox(height: 8),

              // Title
              Text(
                schedule.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textHeading,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),

              // Description
              Text(
                schedule.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),

              // Meta chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    GlassPillChip(
                      label:
                          '${schedule.daysPerWeek} days/wk · ${schedule.durationWeeks} wks',
                      leading: Icon(
                        Icons.calendar_today_rounded,
                        size: 11,
                        color: tagColor,
                      ),
                      fontSize: 10.5,
                      height: 24,
                      textColor: isDark
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF475569),
                    ),
                    if (schedule.targetMuscles.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      GlassPillChip(
                        label: schedule.targetMuscles.take(3).join(' · '),
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
            ],
          ),

          // Divider + Footer
          Column(
            children: [
              const GlassHairlineDivider(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.fitness_center_rounded,
                        size: 14,
                        color: textMuted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        schedule.equipment,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: onViewTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primary,
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
                          SizedBox(width: 3),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 14,
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
        ],
      ),
    );
  }
}

/// Compact Bookmarked Card (width 185px, Glass-1).
class _CompactBookmarkedCard extends StatelessWidget {
  const _CompactBookmarkedCard({
    required this.schedule,
    required this.onTap,
  });

  final WorkoutSchedule schedule;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final textHeading = isDark ? Colors.white : const Color(0xFF18132B);
    final textMuted = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF6B6882);

    return FrostedGlassBox(
      tier: GlassTier.surface,
      width: 190,
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.bookmark_rounded,
                size: 18,
                color: primary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.70),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.white,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    schedule.experience.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: textMuted,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            schedule.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: textHeading,
              height: 1.3,
            ),
          ),
          Column(
            children: [
              const GlassHairlineDivider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${schedule.daysPerWeek} d/wk · ${schedule.exerciseCount} ex',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: textMuted,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Detailed Program Card for the "Browse all" vertical list.
class _BrowseProgramCard extends StatelessWidget {
  const _BrowseProgramCard({
    required this.schedule,
    required this.onBookmarkTap,
    required this.onTap,
  });

  final WorkoutSchedule schedule;
  final VoidCallback onBookmarkTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final textHeading = isDark ? Colors.white : const Color(0xFF18132B);
    final textMuted = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF6B6882);

    return FrostedGlassBox(
      tier: GlassTier.surface,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  schedule.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: textHeading,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onBookmarkTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
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
          const SizedBox(height: 6),
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
          const GlassHairlineDivider(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.70),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.white,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      schedule.experience,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: textHeading,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    schedule.equipment,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
              Text(
                '${schedule.estimatedMinutes} min',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
