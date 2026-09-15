import 'package:flutter/material.dart';

import '../../providers/active_workout_provider.dart';
import 'modal_backdrop_helper.dart';

/// Shows the modern Discard Workout Confirmation Modal from Stitch (ID: a9255ebb92064a47ab69b52063e5e9f9).
/// Features:
///   - Full-screen stationary dimmed backdrop blur
///   - Warning badge with pulsing dot and close button
///   - Subtle pulsing rose trash hero icon
///   - Unsaved session telemetry summary
///   - "Keep Training" primary button and "Discard Workout" destructive button
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

  static const Color _mint = Color(0xFF00D68F);
  static const Color _slate900 = Color(0xFF0F172A);
  static const Color _slate800 = Color(0xFF1E293B);
  static const Color _slate500 = Color(0xFF64748B);
  static const Color _slate400 = Color(0xFF94A3B8);
  static const Color _rose500 = Color(0xFFEF4444);
  static const Color _rose600 = Color(0xFFE11D48);

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 36,
            offset: Offset(0, 14),
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
                    color: const Color(0xFFE2E8F0),
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
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFE4E6)),
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
                              color: _rose500,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _rose500.withValues(alpha: 0.5),
                                  blurRadius: _pulseAnim.value,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'WARNING!',
                          style: TextStyle(
                            color: _rose600,
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
                    icon: const Icon(Icons.close_rounded),
                    color: _slate400,
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
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFECDD3)),
                    boxShadow: [
                      BoxShadow(
                        color: _rose500.withValues(alpha: 0.15),
                        blurRadius: 12 + _pulseAnim.value * 2,
                        spreadRadius: _pulseAnim.value * 0.8,
                      ),
                    ],
                  ),
                  child: child,
                ),
                child: const Center(
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: _rose500,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Headline & Description ────────────────────────────────────
              const Text(
                'Discard workout?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _slate900,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'All progress will be permanently lost. This cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _slate500,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),

              // ── Unsaved Session Stats Card ────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'UNSAVED SESSION STATS',
                          style: TextStyle(
                            color: _slate400,
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
                              decoration: const BoxDecoration(
                                color: _rose500,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Will be lost',
                              style: TextStyle(
                                color: _rose500,
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
                        _verticalDivider(),
                        // Column 2: Sets
                        Expanded(
                          child: _DiscardStatColumn(
                            icon: Icons.repeat_rounded,
                            label: 'SETS',
                            value: '${widget.state.completedSetCount}',
                          ),
                        ),
                        _verticalDivider(),
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
                                    style: const TextStyle(
                                      color: _slate800,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '/ $totalCount',
                                    style: const TextStyle(
                                      color: _slate400,
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
                icon: const Icon(Icons.play_arrow_rounded, size: 22),
                label: const Text(
                  'Keep Training',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15.5,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _mint,
                  foregroundColor: _slate900,
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
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text(
                  'Discard Workout',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF1F2),
                  foregroundColor: _rose600,
                  side: const BorderSide(color: Color(0xFFFECDD3)),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Microcopy ─────────────────────────────────────────────────
              const Text(
                'Tap outside or swipe down to cancel',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _slate400,
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

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 32,
      color: const Color(0xFFE2E8F0),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: const Color(0xFF94A3B8)),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
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
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
      ],
    );
  }
}
