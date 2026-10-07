import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/daily_habit.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../../providers/dashboard_providers.dart';

class HabitsRecoverySection extends ConsumerWidget {
  const HabitsRecoverySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final habits = habitsAsync.value ?? const [];

    final totalCount = habits.length;
    final doneCount = habits.where((h) => h.isCompleted).length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Text(
                    'Habits & Recovery',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: FtGlassTheme.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // {done} of {total} complete chip (AnimatedSwitcher on count change)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: FtGlassTheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Text(
                      '$doneCount of $totalCount complete',
                      key: ValueKey<int>(doneCount),
                      style: const TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: FtGlassTheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Container: glass1, radius 20, padding 12, row gap 8
          GlassSurface(
            tier: FtGlassTier.glass1,
            radius: FtGlassTheme.radiusCards,
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(habits.length, (index) {
                final habit = habits[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: index < habits.length - 1 ? 8.0 : 0.0),
                  child: _HabitItemRow(
                    habit: habit,
                    onToggle: () {
                      ref.read(habitsProvider.notifier).toggle(habit.id);
                    },
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitItemRow extends StatelessWidget {
  final DailyHabit habit;
  final VoidCallback onToggle;

  const _HabitItemRow({
    required this.habit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = habit.isCompleted;
    final isPending = !isDone && habit.status == HabitChipStatus.pending;

    // Emphasised pending row: white 75% fill, primary@25% border, small shadow
    // Regular row: glass2 (white 65% fill, white 80% border)
    final decoration = BoxDecoration(
      color: isPending
          ? Colors.white.withValues(alpha: 0.75)
          : Colors.white.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(FtGlassTheme.radiusTiles),
      border: Border.all(
        color: isPending
            ? FtGlassTheme.primary.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.80),
        width: 1.0,
      ),
      boxShadow: isPending
          ? const [
              BoxShadow(
                color: Color(0x0F5F3BDC),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ]
          : null,
    );

    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: decoration,
        child: Row(
          children: [
            // 24x24 Checkbox (radius 8) with 180ms easeOutBack scale
            _AnimatedHabitCheckbox(
              isCompleted: isDone,
              isPending: isPending,
            ),
            const SizedBox(width: 12),

            // Title & Subtitle with Left-to-Right 200ms animated strikethrough
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StrikethroughText(
                    text: habit.title,
                    isStrikethrough: isDone,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    habit.subtitle,
                    style: const TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: FtGlassTheme.muted,
                    ),
                  ),
                ],
              ),
            ),

            // Trailing Status Chip (Done, Pending, Tonight) with crossfade
            _AnimatedTrailingChip(status: isDone ? HabitChipStatus.done : habit.status),
          ],
        ),
      ),
    );
  }
}

/// 24x24 Checkbox with scale in 180ms easeOutBack.
class _AnimatedHabitCheckbox extends StatelessWidget {
  final bool isCompleted;
  final bool isPending;

  const _AnimatedHabitCheckbox({
    required this.isCompleted,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: isCompleted
              ? null
              : Border.all(
                  color: isPending
                      ? FtGlassTheme.primary
                      : FtGlassTheme.outlineVariant,
                  width: 2.0,
                ),
        ),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: isCompleted ? 1.0 : 0.0, end: isCompleted ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            if (scale <= 0.05) return const SizedBox.shrink();
            return Transform.scale(
              scale: scale,
              child: Container(
                decoration: BoxDecoration(
                  color: FtGlassTheme.primary,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Draws an animated left-to-right strikethrough line over the title text in 200ms.
class _StrikethroughText extends StatelessWidget {
  final String text;
  final bool isStrikethrough;

  const _StrikethroughText({
    required this.text,
    required this.isStrikethrough,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: isStrikethrough ? 1.0 : 0.0,
        end: isStrikethrough ? 1.0 : 0.0,
      ),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      builder: (context, progress, child) {
        return CustomPaint(
          foregroundPainter: progress > 0
              ? _StrikethroughPainter(progress: progress, color: FtGlassTheme.ink)
              : null,
          child: Opacity(
            opacity: 1.0 - (progress * 0.3), // Opacity .7 when done
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: FtGlassTheme.ink,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StrikethroughPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _StrikethroughPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || size.width <= 0) return;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final y = size.height * 0.52;
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width * progress, y),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _StrikethroughPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Trailing chip with crossfade animation between states.
class _AnimatedTrailingChip extends StatelessWidget {
  final HabitChipStatus status;

  const _AnimatedTrailingChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, textColor, bg, border) = switch (status) {
      HabitChipStatus.done => (
          'Done',
          FtGlassTheme.teal,
          FtGlassTheme.teal.withValues(alpha: 0.10),
          FtGlassTheme.teal.withValues(alpha: 0.20),
        ),
      HabitChipStatus.pending => (
          'Pending',
          FtGlassTheme.orange,
          FtGlassTheme.orange.withValues(alpha: 0.10),
          FtGlassTheme.orange.withValues(alpha: 0.20),
        ),
      HabitChipStatus.tonight => (
          'Tonight',
          FtGlassTheme.muted,
          Colors.white.withValues(alpha: 0.60),
          Colors.white.withValues(alpha: 0.80),
        ),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey<HabitChipStatus>(status),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
          border: Border.all(color: border, width: 1.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: FtText.fontFamily,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
