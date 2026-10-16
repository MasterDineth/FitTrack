import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/active_workout_provider.dart';
import '../../screens/dashboard/widgets/ft_pressable.dart';
import '../../theme/ft_glass.dart';
import '../glass_surface.dart';
import 'modal_backdrop_helper.dart';

/// Shows the redesigned FitTrack Skip Exercise Modal matching Stitch Screen `14c79f52735a4de3a0ecd84ac2598e9d`.
///
/// Features:
/// - Frosted glass modal card with proper dark theme adaptation.
/// - Current Exercise Card (Skipping From) with completed sets badge and remaining unfinished sets.
/// - Animated downward transition orb bridge.
/// - Next Exercise Card (Skipping Into) with immediate target sets, reps & weight.
/// - Smart queue toggle to move remaining sets to the end of the session.
/// - Primary Skip CTA & Secondary Stay CTA.
/// - Clean layout alignments without text clipping or overflowing badges.
Future<void> showSkipExerciseModal(
  BuildContext context, {
  required ActiveWorkoutState state,
  required ActiveWorkoutNotifier notifier,
}) async {
  await showBlurModal<void>(
    context: context,
    barrierDismissible: true,
    child: _SkipExerciseModalCard(
      state: state,
      notifier: notifier,
    ),
  );
}

class _SkipExerciseModalCard extends ConsumerStatefulWidget {
  const _SkipExerciseModalCard({
    required this.state,
    required this.notifier,
  });

  final ActiveWorkoutState state;
  final ActiveWorkoutNotifier notifier;

  @override
  ConsumerState<_SkipExerciseModalCard> createState() => _SkipExerciseModalCardState();
}

class _SkipExerciseModalCardState extends ConsumerState<_SkipExerciseModalCard>
    with SingleTickerProviderStateMixin {
  bool _moveToEnd = true;
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0.0, end: 4.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _onSkipConfirm() {
    Navigator.of(context).pop();
    widget.notifier.skipExercise(
      reason: _moveToEnd ? 'Moved to end of workout' : 'Skipped exercise',
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentEntry = widget.state.currentEntry;
    final currentName = currentEntry?.name ?? 'Current Exercise';
    final currentSets = currentEntry?.totalSets ?? 4;
    final currentDone = widget.state.currentSetIndex;
    final unfinishedSets = (currentSets - currentDone).clamp(1, 99);

    final upcoming = widget.state.upcomingEntries;
    final nextEntry = upcoming.isNotEmpty ? upcoming.first : null;
    final nextName = nextEntry?.name ?? 'Next Exercise';
    final nextSets = nextEntry?.totalSets ?? 3;
    final nextReps = nextEntry?.targetReps ?? 10;
    final nextWeight = nextEntry?.targetWeightKg ?? 30.0;

    final currentIndex = widget.state.currentExerciseIndex + 1;
    final nextIndex = currentIndex + 1;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: GlassSurface(
        tier: FtGlassTier.glassFloating,
        radius: 28,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 1. Modal Header ─────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: context.ftPrimary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.ftPrimary.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.skip_next_rounded,
                      size: 22,
                      color: context.ftPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Skip Exercise?',
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: context.isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: context.isDark
                                      ? Colors.white.withValues(alpha: 0.10)
                                      : Colors.white,
                                ),
                              ),
                              child: Text(
                                'QUEUE',
                                style: TextStyle(
                                  fontFamily: FtText.fontFamily,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: context.ftMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Jump ahead to your next queued movement',
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
              const SizedBox(height: 12),

              // ── 2. Current Exercise Card (Skipping From) ────────────────────
              _buildCurrentCard(
                context,
                currentName,
                currentIndex,
                currentDone,
                currentSets,
                unfinishedSets,
              ),

              // ── 3. Visual Transition Bridge (Bouncing Orb) ──────────────────
              Center(
                child: AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, _bounceAnimation.value - 2),
                    child: child,
                  ),
                  child: Container(
                    width: 30,
                    height: 30,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? context.ftPrimary.withValues(alpha: 0.20)
                          : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.ftPrimary.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.ftPrimary.withValues(alpha: 0.16),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_downward_rounded,
                      size: 16,
                      color: context.ftPrimary,
                    ),
                  ),
                ),
              ),

              // ── 4. Next Exercise Card (Skipping Into) ────────────────────────
              _buildNextCard(
                context,
                nextName,
                nextIndex,
                nextSets,
                nextReps,
                nextWeight,
              ),
              const SizedBox(height: 10),

              // ── 5. Smart Queue Option Row ────────────────────────────────────
              InkWell(
                onTap: () => setState(() => _moveToEnd = !_moveToEnd),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: context.isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.sync_rounded, size: 17, color: context.ftPrimary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Move remaining sets to end of workout',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: context.ftInk,
                          ),
                        ),
                      ),
                      Checkbox(
                        value: _moveToEnd,
                        activeColor: context.ftPrimary,
                        onChanged: (val) => setState(() => _moveToEnd = val ?? true),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── 6. Primary Action Button ────────────────────────────────────
              FtPressable(
                onTap: _onSkipConfirm,
                pressedScale: 0.98,
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.ftPrimary,
                        Color.lerp(context.ftPrimary, Colors.white, 0.12) ?? context.ftPrimary,
                        Color.lerp(context.ftPrimary, Colors.black, 0.15) ?? context.ftPrimary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: context.ftPrimary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'Skip to $nextName',
                          style: const TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── 7. Secondary Action Button ──────────────────────────────────
              FtPressable(
                onTap: () => Navigator.of(context).pop(),
                pressedScale: 0.98,
                child: Container(
                  width: double.infinity,
                  height: 42,
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: context.isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.white,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Stay on $currentName',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: context.ftInk,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentCard(
    BuildContext context,
    String currentName,
    int currentIndex,
    int currentDone,
    int currentSets,
    int unfinishedSets,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.isDark ? Colors.white.withValues(alpha: 0.10) : Colors.white,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD97706),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'CURRENT EXERCISE',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: context.ftMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_rounded, size: 11, color: Color(0xFFD97706)),
                    const SizedBox(width: 3),
                    Text(
                      '$currentDone of $currentSets Sets Done',
                      style: const TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white,
                    width: 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/dashboard/coaching_bench.webp',
                      fit: BoxFit.cover,
                      cacheWidth: 92,
                      cacheHeight: 92,
                    ),
                    Positioned(
                      top: 2,
                      left: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '#$currentIndex',
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentName,
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: context.ftInk,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Chest · Compound Movement',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: context.ftMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: context.ftPrimary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Set ${currentDone + 1} Pending',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: context.ftPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF43F5E).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$unfinishedSets Unfinished',
                            style: const TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFE11D48),
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
        ],
      ),
    );
  }

  Widget _buildNextCard(
    BuildContext context,
    String nextName,
    int nextIndex,
    int nextSets,
    int nextReps,
    double nextWeight,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.ftPrimary.withValues(alpha: 0.40),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: context.ftPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'SKIPPING INTO NEXT',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: context.ftPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: context.ftPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Up Immediately',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: context.ftPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white,
                    width: 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/dashboard/hero_workout.webp',
                      fit: BoxFit.cover,
                      cacheWidth: 92,
                      cacheHeight: 92,
                    ),
                    Positioned(
                      top: 2,
                      left: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: context.ftPrimary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '#$nextIndex',
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nextName,
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: context.ftInk,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '$nextSets sets × $nextReps reps',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: context.ftMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Target Weight: ${nextWeight % 1 == 0 ? nextWeight.toInt() : nextWeight} kg',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: context.ftPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
