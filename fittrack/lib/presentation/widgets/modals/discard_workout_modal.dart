import 'package:flutter/material.dart';

import '../../providers/active_workout_provider.dart';
import 'modal_backdrop_helper.dart';

/// Shows the modern Discard Workout Confirmation Modal from Stitch (ID: a9255ebb92064a47ab69b52063e5e9f9).
Future<void> showDiscardWorkoutModal(
  BuildContext context, {
  required ActiveWorkoutState state,
  required VoidCallback onDiscard,
}) async {
  await showBlurBottomSheet<void>(
    context: context,
    child: _DiscardWorkoutCard(
      state: state,
      onDiscard: onDiscard,
    ),
  );
}

class _DiscardWorkoutCard extends StatefulWidget {
  const _DiscardWorkoutCard({
    required this.state,
    required this.onDiscard,
  });

  final ActiveWorkoutState state;
  final VoidCallback onDiscard;

  @override
  State<_DiscardWorkoutCard> createState() => _DiscardWorkoutCardState();
}

class _DiscardWorkoutCardState extends State<_DiscardWorkoutCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.0, end: 6.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final completedCount = widget.state.entries
        .where(
          (e) => widget.state.completedSets.any((s) => s.exerciseId == e.exerciseId),
        )
        .length;
    final totalCount = widget.state.entries.length;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 460),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 36,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            12,
            22,
            bottomInset + (bottomPadding > 0 ? 8 : 18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Drag Affordance ───────────────────────────────────────────
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ── Top Bar: Warning Badge + Close Button ───────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _pulseAnim,
                          builder: (context, _) => Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: colorScheme.error,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.error.withValues(alpha: 0.5),
                                  blurRadius: _pulseAnim.value,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'WARNING!',
                          style: TextStyle(
                            color: colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w800,
                            fontSize: 10.5,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    splashRadius: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Hero Icon with Subtle Pulse ───────────────────────────────
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) => Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.error.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.error.withValues(alpha: 0.15),
                        blurRadius: 12 + _pulseAnim.value * 2,
                        spreadRadius: _pulseAnim.value * 0.8,
                      ),
                    ],
                  ),
                  child: child,
                ),
                child: Center(
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: colorScheme.onErrorContainer,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Headline & Description ────────────────────────────────────
              Text(
                'Discard workout?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'All progress will be permanently lost. This cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),

              // ── Unsaved Session Stats Card ────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'UNSAVED SESSION STATS',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Will be lost',
                              style: TextStyle(
                                color: colorScheme.error,
                                fontWeight: FontWeight.w600,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Column 1: Time
                        Expanded(
                          child: _DiscardStatColumn(
                            icon: Icons.access_time_rounded,
                            label: 'TIME',
                            value: widget.state.elapsedFormatted,
                          ),
                        ),
                        _verticalDivider(colorScheme.outlineVariant),
                        // Column 2: Sets
                        Expanded(
                          child: _DiscardStatColumn(
                            icon: Icons.repeat_rounded,
                            label: 'SETS',
                            value: '${widget.state.completedSetCount}',
                          ),
                        ),
                        _verticalDivider(colorScheme.outlineVariant),
                        // Column 3: Exercises
                        Expanded(
                          child: _DiscardStatColumn(
                            icon: Icons.fitness_center_rounded,
                            label: 'EXERCISES',
                            richValue: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$completedCount ',
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '/ $totalCount',
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Action Buttons ────────────────────────────────────────────
              // Primary: Keep Training
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.play_arrow_rounded, size: 22, color: colorScheme.onPrimary),
                label: Text(
                  'Keep Training',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15.5,
                    color: colorScheme.onPrimary,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 8),

              // Secondary: Discard Workout
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onDiscard();
                },
                icon: Icon(Icons.delete_outline_rounded, size: 18, color: colorScheme.onErrorContainer),
                label: Text(
                  'Discard Workout',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: colorScheme.onErrorContainer,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: colorScheme.errorContainer,
                  foregroundColor: colorScheme.onErrorContainer,
                  side: BorderSide(color: colorScheme.error.withValues(alpha: 0.3)),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Microcopy ─────────────────────────────────────────────────
              Text(
                'Tap outside or swipe down to cancel',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _verticalDivider(Color color) {
    return Container(
      width: 1,
      height: 32,
      color: color,
    );
  }
}

class _DiscardStatColumn extends StatelessWidget {
  const _DiscardStatColumn({
    required this.icon,
    required this.label,
    this.value,
    this.richValue,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Widget? richValue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: colorScheme.onSurface.withValues(alpha: 0.6)),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        richValue ??
            Text(
              value ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
      ],
    );
  }
}
