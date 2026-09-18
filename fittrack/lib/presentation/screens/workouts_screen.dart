import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/schedules_provider.dart';
import '../providers/user_profile_provider.dart';

/// Redesigned Workouts & Schedules Screen adhering strictly to Stitch MCP specifications.
///
/// Features:
/// - Sticky `SliverAppBar` (`pinned: true`) with search input and header matching `dashboard_screen.dart`.
/// - Filter chips rendered as the first sliver in the scroll view:
///   * Horizontal scrolling row in Default Browse mode.
///   * Multiline `Wrap` layout in Search Active mode.
/// - Conditional rendering:
///   * Default Browse layout when search is inactive.
///   * Search Active layout when search input is focused or a category filter is selected.
/// - Expandable bookmarks with "See All" / "Collapse" toggle (horizontal list vs 2-column grid).
/// - FAB collapsing on scroll down via `ScrollController`.
/// - Full bookmark toggling and routing to `/workouts/detail` with deep extra data.
/// - 120px bottom padding to clear the floating FAB and persistent dock.
class WorkoutsScreen extends ConsumerStatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  ConsumerState<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends ConsumerState<WorkoutsScreen> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late final ScrollController _scrollController;

  bool _isSearchActive = false;
  bool _expandBookmarks = false;
  bool _isFabExtended = true;

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
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _scrollController = ScrollController();

    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus && !_isSearchActive) {
        setState(() {
          _isSearchActive = true;
        });
      } else {
        setState(() {});
      }
    });

    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;
      if (direction == ScrollDirection.reverse && _isFabExtended) {
        setState(() {
          _isFabExtended = false;
        });
      } else if (direction == ScrollDirection.forward && !_isFabExtended) {
        setState(() {
          _isFabExtended = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _exitSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    ref.read(schedulesNotifierProvider.notifier).updateSearchQuery('');
    ref.read(schedulesNotifierProvider.notifier).updateCategoryFilter('All');
    ref.read(schedulesNotifierProvider.notifier).updateSort(SortOption.relevant);
    setState(() {
      _isSearchActive = false;
      _isFabExtended = true;
    });
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
    final isLight = theme.brightness == Brightness.light;
    final colorScheme = theme.colorScheme;
    final state = ref.watch(schedulesNotifierProvider);
    final notifier = ref.read(schedulesNotifierProvider.notifier);
    final userProfileAsync = ref.watch(userProfileProvider);

    final isSearchActive = _isSearchActive;
    final recommended = state.recommendedSchedules;
    final bookmarked = state.bookmarkedSchedules;
    final custom = state.customSchedules;
    final filtered = state.filteredSchedules;

    final isSearching = isSearchActive ||
        _searchController.text.isNotEmpty ||
        _searchFocusNode.hasFocus ||
        state.searchQuery.isNotEmpty ||
        state.selectedCategoryFilter != 'All';

    return PopScope(
      canPop: !isSearching,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (isSearching) {
          _exitSearch();
        }
      },
      child: Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: FloatingActionButton.extended(
          isExtended: _isFabExtended,
          onPressed: () => context.push('/workouts/create-schedule'),
          icon: const Icon(Icons.add, size: 22),
          label: const Text(
            'Create Schedule',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.2),
          ),
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          elevation: 4,
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is UserScrollNotification) {
              if (notification.direction == ScrollDirection.reverse && _isFabExtended) {
                setState(() => _isFabExtended = false);
              } else if (notification.direction == ScrollDirection.forward && !_isFabExtended) {
                setState(() => _isFabExtended = true);
              }
            } else if (notification is ScrollUpdateNotification) {
              final delta = notification.scrollDelta ?? 0;
              if (delta > 2 && _isFabExtended) {
                setState(() => _isFabExtended = false);
              } else if (delta < -2 && !_isFabExtended) {
                setState(() => _isFabExtended = true);
              }
              if (notification.metrics.pixels <= 10 && !_isFabExtended) {
                setState(() => _isFabExtended = true);
              }
            }
            return false;
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ── TOP APP HEADER (EXACTLY MATCHING DASHBOARD SCREEN) ─────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00D68F),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Workout Library',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      // Notification bell matching dashboard_screen.dart
                      Stack(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: isLight
                                  ? Border.all(color: colorScheme.outlineVariant)
                                  : Border.all(color: colorScheme.outline),
                            ),
                            child: Icon(
                              Icons.notifications_none_rounded,
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                              size: 18,
                            ),
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
                                border: Border.all(
                                  color: colorScheme.surface,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      // Profile avatar matching dashboard_screen.dart
                      InkWell(
                        onTap: () => context.push('/settings/profile'),
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: colorScheme.surface, width: 2),
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
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            color: colorScheme.onPrimary,
                                            fontWeight: FontWeight.w800,
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
                                  border: Border.all(
                                    color: colorScheme.surface,
                                    width: 1.5,
                                  ),
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

              // ── PINNED SEARCH BAR (ONLY CONTAINS SEARCH INPUT & FILTER) ───
              SliverAppBar(
                pinned: true,
                floating: false,
                elevation: 0,
                toolbarHeight: 70,
                backgroundColor: theme.scaffoldBackgroundColor,
                surfaceTintColor: Colors.transparent,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: isLight
                                ? const Color(0xFFF2F4F6)
                                : theme.colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: _searchFocusNode.hasFocus ? 0.6 : 0.35,
                              ),
                              width: _searchFocusNode.hasFocus ? 1.5 : 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: _searchFocusNode.hasFocus ? 0.25 : 0.12,
                                ),
                                blurRadius: 10,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                              onChanged: (val) {
                                notifier.updateSearchQuery(val);
                                if (val.trim().isNotEmpty && !_isSearchActive) {
                                  setState(() {
                                    _isSearchActive = true;
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Search splits, goals, or equipment...',
                                hintStyle: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.7),
                                ),
                                prefixIcon: _isSearchActive
                                    ? IconButton(
                                        icon: const Icon(Icons.arrow_back, size: 20),
                                        color: theme.colorScheme.primary,
                                        tooltip: 'Exit search',
                                        onPressed: _exitSearch,
                                      )
                                    : Icon(
                                        Icons.search,
                                        size: 20,
                                        color: _searchFocusNode.hasFocus
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onSurfaceVariant,
                                      ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.close, size: 18),
                                        color: theme.colorScheme.onSurfaceVariant,
                                        onPressed: () {
                                          _searchController.clear();
                                          notifier.updateSearchQuery('');
                                          setState(() {});
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: isLight
                              ? const Color(0xFFF2F4F6)
                              : theme.colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isLight
                                ? const Color(0xFFE2E8F0)
                                : theme.colorScheme.outline,
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.tune,
                            size: 20,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            if (_searchFocusNode.hasFocus) {
                              _searchFocusNode.unfocus();
                            } else {
                              _searchFocusNode.requestFocus();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 1. FILTER CHIPS (FIRST SLIVER AFTER SEARCH BAR) ─────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
                  child: _isSearchActive
                      ? Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: _filterOptions.map((filter) {
                            final isSelected =
                                state.selectedCategoryFilter == filter;
                            return FilterChip(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: const VisualDensity(
                                horizontal: -2,
                                vertical: -2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              label: Text(filter),
                              selected: isSelected,
                              showCheckmark: isSelected,
                              checkmarkColor:
                                  theme.colorScheme.onPrimaryContainer,
                              backgroundColor: isLight
                                  ? const Color(0xFFECEEF0)
                                  : theme.colorScheme.surfaceContainer,
                              selectedColor: theme.colorScheme.primaryContainer,
                              labelStyle: theme.textTheme.labelMedium?.copyWith(
                                color: isSelected
                                    ? theme.colorScheme.onPrimaryContainer
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? Colors.transparent
                                      : (isLight
                                          ? const Color(0xFFE2E8F0)
                                          : theme.colorScheme.outline),
                                ),
                              ),
                              onSelected: (_) {
                                notifier.updateCategoryFilter(filter);
                                if (filter != 'All') {
                                  setState(() {
                                    _isSearchActive = true;
                                  });
                                } else if (_searchController.text.trim().isEmpty &&
                                    !_searchFocusNode.hasFocus) {
                                  setState(() {
                                    _isSearchActive = false;
                                  });
                                }
                              },
                            );
                          }).toList(),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _filterOptions.map((filter) {
                              final isSelected =
                                  state.selectedCategoryFilter == filter;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: const VisualDensity(
                                    horizontal: -2,
                                    vertical: -2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  label: Text(filter),
                                  selected: isSelected,
                                  showCheckmark: isSelected,
                                  checkmarkColor:
                                      theme.colorScheme.onPrimaryContainer,
                                  backgroundColor: isLight
                                      ? const Color(0xFFECEEF0)
                                      : theme.colorScheme.surfaceContainer,
                                  selectedColor:
                                      theme.colorScheme.primaryContainer,
                                  labelStyle:
                                      theme.textTheme.labelMedium?.copyWith(
                                    color: isSelected
                                        ? theme.colorScheme.onPrimaryContainer
                                        : theme.colorScheme.onSurfaceVariant,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: isSelected
                                          ? Colors.transparent
                                          : (isLight
                                              ? const Color(0xFFE2E8F0)
                                              : theme.colorScheme.outline),
                                    ),
                                  ),
                                  onSelected: (_) {
                                    notifier.updateCategoryFilter(filter);
                                    if (filter != 'All') {
                                      setState(() {
                                        _isSearchActive = true;
                                      });
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                ),
              ),

            // ── CONDITIONAL LAYOUTS ────────────────────────────────────────
            if (!isSearchActive) ...[
              // ── 1. Recommended for You Carousel ─────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    children: [
                      Icon(Icons.bolt, color: theme.colorScheme.primary, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        'Recommended for You',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'BASED ON PROFILE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 255,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: recommended.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final schedule = recommended[index];
                      return _RecommendedCarouselCard(
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

              // ── 2. Bookmarked Schedules (Favorites) ─────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'Bookmarked Schedules',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${bookmarked.length}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (bookmarked.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _expandBookmarks = !_expandBookmarks;
                            });
                          },
                          child: Text(
                            _expandBookmarks ? 'Collapse' : 'See All',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: bookmarked.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _EmptyBookmarkPlaceholder(
                          theme: theme,
                          isLight: isLight,
                        ),
                      )
                    : _expandBookmarks
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.82,
                              ),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: bookmarked.length,
                              itemBuilder: (context, index) {
                                final schedule = bookmarked[index];
                                return _BookmarkedCard(
                                  schedule: schedule,
                                  onTap: () => context.push(
                                    '/workouts/detail',
                                    extra: schedule,
                                  ),
                                );
                              },
                            ),
                          )
                        : SizedBox(
                            height: 220,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: bookmarked.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final schedule = bookmarked[index];
                                return SizedBox(
                                  width: 180,
                                  child: _BookmarkedCard(
                                    schedule: schedule,
                                    onTap: () => context.push(
                                      '/workouts/detail',
                                      extra: schedule,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),

              // ── 3. My Custom Routines (Accordion) ───────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: _CustomRoutinesAccordion(
                    customSchedules: custom,
                    theme: theme,
                    isLight: isLight,
                    onScheduleTap: (s) => context.push(
                      '/workouts/detail',
                      extra: s,
                    ),
                    onEditTap: (s) => context.push('/workouts/create-schedule'),
                  ),
                ),
              ),

              // ── 4. Browse All Schedules ─────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Row(
                    children: [
                      Text(
                        'Browse All Schedules',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${state.filteredSchedules.length} Programs',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton<SortOption>(
                        initialValue: state.selectedSort,
                        onSelected: (sort) => notifier.updateSort(sort),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: SortOption.relevant,
                            child: Text('Most Relevant'),
                          ),
                          const PopupMenuItem(
                            value: SortOption.duration,
                            child: Text('Duration (Weeks)'),
                          ),
                          const PopupMenuItem(
                            value: SortOption.title,
                            child: Text('Title (A-Z)'),
                          ),
                        ],
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _sortLabel(state.selectedSort),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.filter_list,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final schedule = state.filteredSchedules[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _BrowseScheduleCard(
                          schedule: schedule,
                          theme: theme,
                          isLight: isLight,
                          onBookmarkTap: () =>
                              notifier.toggleBookmark(schedule.id),
                          onTap: () => context.push(
                            '/workouts/detail',
                            extra: schedule,
                          ),
                        ),
                      );
                    },
                    childCount: state.filteredSchedules.length,
                  ),
                ),
              ),
            ] else ...[
              // ── SEARCH ACTIVE LAYOUT ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    children: [
                      Text(
                        'Search Results',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${filtered.length}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton<SortOption>(
                        initialValue: state.selectedSort,
                        onSelected: (sort) => notifier.updateSort(sort),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: SortOption.relevant,
                            child: Text('Most Relevant'),
                          ),
                          const PopupMenuItem(
                            value: SortOption.duration,
                            child: Text('Duration (Weeks)'),
                          ),
                          const PopupMenuItem(
                            value: SortOption.title,
                            child: Text('Title (A-Z)'),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isLight
                                ? const Color(0xFFF2F4F6)
                                : theme.colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isLight
                                  ? const Color(0xFFE2E8F0)
                                  : theme.colorScheme.outline,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                state.selectedSort == SortOption.duration
                                    ? 'Duration'
                                    : state.selectedSort == SortOption.title
                                        ? 'Title'
                                        : 'Most Relevant',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.expand_more,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (filtered.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 56,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No schedules found',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            state.searchQuery.isNotEmpty
                                ? 'No workouts matching "${state.searchQuery}".\nTry adjusting filters or search terms.'
                                : 'No workouts matching active filter: "${state.selectedCategoryFilter}".',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: _exitSearch,
                            child: const Text('Reset Search & Filters'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final schedule = filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14.0),
                          child: _SearchResultCard(
                            schedule: schedule,
                            searchQuery: state.searchQuery,
                            theme: theme,
                            isLight: isLight,
                            onBookmarkTap: () =>
                                notifier.toggleBookmark(schedule.id),
                            onTap: () => context.push(
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
            ],

            // ── BOTTOM PADDING (CLEAR FLOATING FAB & BOTTOM DOCK) ───────────
            const SliverPadding(padding: EdgeInsets.only(bottom: 120.0)),
          ],
        ),
      ),
    ),
  ),
);
}
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPONENT WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

/// Recommended Carousel Card with Top Gradient Accent Line and responsive sizing.
class _RecommendedCarouselCard extends StatelessWidget {
  const _RecommendedCarouselCard({
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
    final isLight = theme.brightness == Brightness.light;

    return Container(
      width: 290,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLight
              ? const Color(0xFFE2E8F0)
              : theme.colorScheme.outline,
          width: 1,
        ),
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: const Color(0xFF00D68F).withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                const BoxShadow(
                  color: Color(0x080F172A),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onViewTap,
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top decorative gradient bar
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                            theme.colorScheme.tertiary,
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge & Bookmark Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer
                                      .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  schedule.focus == 'Hypertrophy'
                                      ? 'HYPERTROPHY HERO'
                                      : 'STRENGTH FOCUS',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                icon: Icon(
                                  schedule.isFavorite
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  size: 22,
                                  color: theme.colorScheme.primary,
                                ),
                                onPressed: onBookmarkTap,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Title
                          Text(
                            schedule.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Subtitle with 2-line clamp to prevent overflows
                          Text(
                            schedule.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Stats pills
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _StatPill(
                                dotColor: const Color(0xFF00D68F),
                                text: '${schedule.daysPerWeek}d / wk',
                                theme: theme,
                              ),
                              _StatPill(
                                dotColor: theme.colorScheme.tertiary,
                                text: '${schedule.durationWeeks} Weeks',
                                theme: theme,
                              ),
                              if (schedule.targetMuscles.isNotEmpty)
                                _StatPill(
                                  text: schedule.targetMuscles.take(2).join(', '),
                                  theme: theme,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Bottom Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isLight
                        ? const Color(0xFFF8FAFC)
                        : theme.colorScheme.surfaceContainer.withValues(alpha: 0.5),
                    border: Border(
                      top: BorderSide(
                        color: isLight
                            ? const Color(0xFFE2E8F0)
                            : theme.colorScheme.outline,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        schedule.equipment,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: theme.colorScheme.onPrimary,
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
        ),
      ),
    );
  }
}

/// Reusable card component for Bookmarked Favorites (horizontal carousel & 2-column grid).
class _BookmarkedCard extends StatelessWidget {
  const _BookmarkedCard({
    required this.schedule,
    required this.onTap,
  });

  final WorkoutSchedule schedule;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLight
              ? const Color(0xFFE2E8F0)
              : theme.colorScheme.outline,
        ),
        boxShadow: isLight
            ? const [
                BoxShadow(
                  color: Color(0x080F172A),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.star,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isLight
                              ? const Color(0xFFF1F5F9)
                              : theme.colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          schedule.experience.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 9,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          schedule.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${schedule.daysPerWeek}d/wk • ${schedule.exerciseCount} ex',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Placeholder when no bookmarks exist.
class _EmptyBookmarkPlaceholder extends StatelessWidget {
  const _EmptyBookmarkPlaceholder({
    required this.theme,
    required this.isLight,
  });

  final ThemeData theme;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLight ? const Color(0xFFE2E8F0) : theme.colorScheme.outline,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.bookmark_border,
            color: theme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No bookmarked routines yet. Tap bookmark on any schedule to pin it here!',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Accordion container for Custom Routines with safe overflow protection.
class _CustomRoutinesAccordion extends StatelessWidget {
  const _CustomRoutinesAccordion({
    required this.customSchedules,
    required this.theme,
    required this.isLight,
    required this.onScheduleTap,
    required this.onEditTap,
  });

  final List<WorkoutSchedule> customSchedules;
  final ThemeData theme;
  final bool isLight;
  final ValueChanged<WorkoutSchedule> onScheduleTap;
  final ValueChanged<WorkoutSchedule> onEditTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLight ? const Color(0xFFE2E8F0) : theme.colorScheme.outline,
        ),
        boxShadow: isLight
            ? const [
                BoxShadow(
                  color: Color(0x080F172A),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Icon(
            Icons.folder_special,
            color: theme.colorScheme.primary,
            size: 22,
          ),
          title: Row(
            children: [
              Text(
                'My Custom Routines',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${customSchedules.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          children: customSchedules.map((schedule) {
            return Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isLight
                    ? const Color(0xFFF8FAFC)
                    : theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isLight
                      ? const Color(0xFFE2E8F0)
                      : theme.colorScheme.outline,
                ),
              ),
              child: Row(
                children: [
                  // Wrapped in Expanded to prevent right overflow and push actions to edge
                  Expanded(
                    child: InkWell(
                      onTap: () => onScheduleTap(schedule),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  schedule.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'CUSTOM',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSecondaryContainer,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${schedule.exerciseCount} exercises • ${schedule.estimatedMinutes} min • ${schedule.targetMuscles.take(2).join(', ')}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      minimumSize: const Size(48, 30),
                      side: BorderSide(
                        color: isLight
                            ? const Color(0xFFE2E8F0)
                            : theme.colorScheme.outline,
                      ),
                    ),
                    onPressed: () => onEditTap(schedule),
                    child: Text(
                      'Edit',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Standard Routine Card in Browse All section.
class _BrowseScheduleCard extends StatelessWidget {
  const _BrowseScheduleCard({
    required this.schedule,
    required this.theme,
    required this.isLight,
    required this.onBookmarkTap,
    required this.onTap,
  });

  final WorkoutSchedule schedule;
  final ThemeData theme;
  final bool isLight;
  final VoidCallback onBookmarkTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLight ? const Color(0xFFE2E8F0) : theme.colorScheme.outline,
        ),
        boxShadow: isLight
            ? const [
                BoxShadow(
                  color: Color(0x080F172A),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          schedule.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    icon: Icon(
                      schedule.isFavorite
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      size: 22,
                      color: schedule.isFavorite
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: onBookmarkTap,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(
                height: 1,
                color: isLight
                    ? const Color(0xFFF1F5F9)
                    : theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isLight
                          ? const Color(0xFFF1F5F9)
                          : theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      schedule.experience,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    schedule.equipment,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•  ${schedule.estimatedMinutes > 0 ? schedule.estimatedMinutes : 50} min',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Search Result Card with query highlighting and detailed tags.
class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.schedule,
    required this.searchQuery,
    required this.theme,
    required this.isLight,
    required this.onBookmarkTap,
    required this.onTap,
  });

  final WorkoutSchedule schedule;
  final String searchQuery;
  final ThemeData theme;
  final bool isLight;
  final VoidCallback onBookmarkTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
          width: 1.2,
        ),
        boxShadow: isLight
            ? const [
                BoxShadow(
                  color: Color(0x080F172A),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: schedule.isCustom
                                    ? theme.colorScheme.primaryContainer
                                        .withValues(alpha: 0.3)
                                    : theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                schedule.isCustom ? 'CUSTOM ROUTINE' : 'PROGRAM',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.6,
                                  color: schedule.isCustom
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                schedule.focus,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          icon: Icon(
                            schedule.isFavorite
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            size: 22,
                            color: schedule.isFavorite
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          onPressed: onBookmarkTap,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Title with highlighted text
                    _buildHighlightedTitle(
                      schedule.title,
                      searchQuery,
                      theme,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      schedule.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Metrics pills
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _StatPill(
                          dotColor: const Color(0xFF00D68F),
                          text: '${schedule.daysPerWeek}d / wk',
                          theme: theme,
                        ),
                        _StatPill(
                          dotColor: theme.colorScheme.tertiary,
                          text: '${schedule.durationWeeks} Weeks',
                          theme: theme,
                        ),
                        _StatPill(text: schedule.equipment, theme: theme),
                        if (schedule.targetMuscles.isNotEmpty)
                          _StatPill(
                            text: schedule.targetMuscles.join(', '),
                            theme: theme,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Footer Action
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isLight
                      ? const Color(0xFFF8FAFC)
                      : theme.colorScheme.surfaceContainer.withValues(alpha: 0.5),
                  border: Border(
                    top: BorderSide(
                      color: isLight
                          ? const Color(0xFFE2E8F0)
                          : theme.colorScheme.outline,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      schedule.isCustom ? Icons.schedule : Icons.verified,
                      size: 16,
                      color: schedule.isCustom
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      schedule.isCustom
                          ? 'Active Routine'
                          : 'Featured Routine',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: theme.colorScheme.onPrimary,
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
      ),
    );
  }

  Widget _buildHighlightedTitle(
    String fullText,
    String query,
    ThemeData theme,
  ) {
    if (query.trim().isEmpty) {
      return Text(
        fullText,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      );
    }

    final queryLower = query.toLowerCase().trim();
    final textLower = fullText.toLowerCase();
    final matchIndex = textLower.indexOf(queryLower);

    if (matchIndex == -1) {
      return Text(
        fullText,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      );
    }

    final before = fullText.substring(0, matchIndex);
    final match = fullText.substring(matchIndex, matchIndex + queryLower.length);
    final after = fullText.substring(matchIndex + queryLower.length);

    return RichText(
      text: TextSpan(
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(text: before),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                match,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }
}

/// Generic Stat Pill used inside schedule cards.
class _StatPill extends StatelessWidget {
  const _StatPill({
    this.dotColor,
    required this.text,
    required this.theme,
  });

  final Color? dotColor;
  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isLight = theme.brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isLight
            ? const Color(0xFFF1F5F9)
            : theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
