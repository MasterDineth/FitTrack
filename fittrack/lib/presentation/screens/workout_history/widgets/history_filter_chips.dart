import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/workout_history_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Segmented category filter chips for Workout History (All, Push, Pull, Legs, PRs only).
class HistoryFilterChips extends ConsumerWidget {
  const HistoryFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(workoutHistoryProvider);
    final currentFilter = historyState.categoryFilter;
    final notifier = ref.read(workoutHistoryProvider.notifier);
    final monthSessions = historyState.monthSessions;
    final totalCount = monthSessions.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: HistoryCategoryFilter.values.map((filter) {
          final isSelected = filter == currentFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FtPressable(
              onTap: () => notifier.setCategoryFilter(filter),
              pressedScale: 0.95,
              child: isSelected
                  ? Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.ftPrimary,
                            context.ftPrimaryLight,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                        boxShadow: [
                          BoxShadow(
                            color: context.ftPrimary.withValues(alpha: 0.28),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (filter == HistoryCategoryFilter.prsOnly) ...[
                            const Icon(
                              Icons.star_rounded,
                              size: 15,
                              color: Color(0xFFFDE047),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            filter == HistoryCategoryFilter.all ? 'All' : filter.label,
                            style: const TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          if (filter == HistoryCategoryFilter.all) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.24),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$totalCount',
                                style: const TextStyle(
                                  fontFamily: FtText.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : GlassSurface(
                      tier: FtGlassTier.glass2,
                      radius: FtGlassTheme.radiusPill,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 38,
                      shadow: false,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (filter == HistoryCategoryFilter.prsOnly) ...[
                            const Icon(
                              Icons.star_rounded,
                              size: 15,
                              color: Color(0xFFD97706),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            filter.label,
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: filter == HistoryCategoryFilter.prsOnly
                                  ? const Color(0xFFD97706)
                                  : context.ftMuted,
                            ),
                          ),
                          if (filter == HistoryCategoryFilter.all) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: context.ftPrimary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$totalCount',
                                style: TextStyle(
                                  fontFamily: FtText.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: context.ftPrimary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
