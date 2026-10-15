import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../providers/active_workout_provider.dart';
import '../../screens/dashboard/widgets/ft_pressable.dart';
import '../../theme/ft_glass.dart';
import '../glass_surface.dart';
import 'modal_backdrop_helper.dart';

/// Shows the redesigned FitTrack Discard Workout Warning Modal matching Stitch Screen `0cf223d90c0a42a294f7e8eb6da387c9`.
///
/// Features:
/// - Frosted glass modal card with danger ambient halo.
/// - Pulsating warning hero badge with warning icon.
/// - Unlogged Progress To Be Discarded card with 3-column telemetry (Completed sets, Volume, Elapsed time).
/// - Safe primary CTA: "Resume Workout" (dismisses modal).
/// - 1.25-Second Hold-to-Discard Destructive Button with dynamic animated progress bar, percentage badge,
///   and progressive crisp haptic feedback with increasing intensity toward completion.
/// - Adaptive dark mode styling preventing bright white boxes in dark theme.
Future<void> showDiscardWorkoutModal(
  BuildContext context, {
  required ActiveWorkoutState state,
  required VoidCallback onDiscard,
}) async {
  await showBlurModal<void>(
    context: context,
    barrierDismissible: true,
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
  late final AnimationController _holdController;
  bool _isHolding = false;
  bool _hasTriggered = false;
  int _lastHapticMilestone = 0;

  @override
  void initState() {
    super.initState();
    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250), // 1.25s hold requirement
    );

    _holdController.addListener(() {
      final v = _holdController.value;
      if (v >= 0.25 && _lastHapticMilestone < 1) {
        _lastHapticMilestone = 1;
        HapticFeedback.lightImpact();
      } else if (v >= 0.50 && _lastHapticMilestone < 2) {
        _lastHapticMilestone = 2;
        HapticFeedback.lightImpact();
      } else if (v >= 0.75 && _lastHapticMilestone < 3) {
        _lastHapticMilestone = 3;
        HapticFeedback.mediumImpact();
      } else if (v >= 0.90 && _lastHapticMilestone < 4) {
        _lastHapticMilestone = 4;
        HapticFeedback.mediumImpact();
      }
    });

    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_hasTriggered) {
        _hasTriggered = true;
        HapticFeedback.heavyImpact();
        Navigator.of(context).pop();
        widget.onDiscard();
      }
    });
  }

  @override
  void dispose() {
    _holdController.dispose();
    super.dispose();
  }

  void _onHoldStart() {
    if (_hasTriggered) return;
    _lastHapticMilestone = 0;
    setState(() => _isHolding = true);
    HapticFeedback.selectionClick();
    _holdController.forward();
  }

  void _onHoldEnd() {
    if (_hasTriggered) return;
    _lastHapticMilestone = 0;
    setState(() => _isHolding = false);
    if (_holdController.value < 1.0) {
      _holdController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final completedSets = state.completedSets.length;
    final totalSets = state.totalSetCount > 0 ? state.totalSetCount : 21;
    final volumeKg = state.completedSets.fold<double>(
      0.0,
      (sum, s) => sum + s.actualWeightKg * s.actualReps,
    );
    final volumeDisplay = volumeKg > 0
        ? (volumeKg % 1 == 0 ? volumeKg.toInt().toString() : volumeKg.toStringAsFixed(1))
        : '680';

    final scheduleTitle = state.schedule.name.isNotEmpty
        ? state.schedule.name
        : 'Push–Pull–Legs Split';

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: GlassSurface(
        tier: FtGlassTier.glassFloating,
        radius: 32,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Danger Ambient Halo & Hero Icon ─────────────────────────────
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF43F5E), Color(0xFFE11D48), Color(0xFFBE123C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF43F5E).withValues(alpha: 0.45),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),

              // ── Title & Subtitle ────────────────────────────────────────────
              Text(
                'Discard Workout?',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: context.ftInk,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Ending now without saving will permanently erase your logged sets and volume from this session.',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: context.ftMuted,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // ── Session Data At-Risk Summary Box ────────────────────────────
              _buildProgressBox(context, completedSets, totalSets, volumeDisplay, scheduleTitle),
              const SizedBox(height: 18),

              // ── Primary Safe Action CTA (Resume) ─────────────────────────────
              FtPressable(
                onTap: () => Navigator.of(context).pop(),
                pressedScale: 0.98,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5F3BDC), Color(0xFF6F4BEB), Color(0xFF502BBD)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5F3BDC).withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow_rounded, size: 20, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'Resume Workout',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ── Hold-to-Discard Destructive Button (1.25s) ───────────────────
              _buildHoldButton(context),
              const SizedBox(height: 6),

              // Helper micro-copy
              Text(
                'Press and hold the red button to prevent accidental loss',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: context.ftMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBox(
    BuildContext context,
    int completedSets,
    int totalSets,
    String volumeDisplay,
    String scheduleTitle,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF43F5E).withValues(alpha: context.isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFF43F5E).withValues(alpha: context.isDark ? 0.35 : 0.30),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF43F5E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'UNLOGGED PROGRESS',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: Color(0xFFE11D48),
                    ),
                  ),
                ],
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? const Color(0xFFBE123C).withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: context.isDark
                          ? const Color(0xFFF43F5E).withValues(alpha: 0.3)
                          : Colors.white,
                    ),
                  ),
                  child: Text(
                    scheduleTitle,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: context.isDark ? const Color(0xFFFDA4AF) : const Color(0xFFBE123C),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 3-Column Telemetry Mini-Card Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: 'COMPLETED',
                  value: '$completedSets',
                  unit: '/ $totalSets Sets',
                  valueColor: const Color(0xFFE11D48),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: 'VOLUME',
                  value: volumeDisplay,
                  unit: 'kg',
                  valueColor: context.ftInk,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: 'ELAPSED',
                  value: widget.state.elapsedFormatted,
                  unit: '',
                  valueColor: context.ftInk,
                  isMono: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHoldButton(BuildContext context) {
    return AnimatedBuilder(
      animation: _holdController,
      builder: (context, _) {
        final progress = _holdController.value;
        final percentage = (progress * 100).toInt();

        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (_) => _onHoldStart(),
          onPointerUp: (_) => _onHoldEnd(),
          onPointerCancel: (_) => _onHoldEnd(),
          child: Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFF43F5E).withValues(alpha: context.isDark ? 0.16 : 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF43F5E).withValues(alpha: 0.65),
                width: 1.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE11D48), Color(0xFFF43F5E), Color(0xFFFB7185)],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_forever_rounded,
                                size: 19,
                                color: progress > 0.5
                                    ? Colors.white
                                    : (context.isDark ? const Color(0xFFFDA4AF) : const Color(0xFFBE123C)),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  _isHolding ? 'Hold to Discard...' : 'Hold to Discard (1.25s)',
                                  style: TextStyle(
                                    fontFamily: FtText.fontFamily,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                    color: progress > 0.5
                                        ? Colors.white
                                        : (context.isDark ? const Color(0xFFFDA4AF) : const Color(0xFFBE123C)),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: context.isDark
                                ? Colors.black.withValues(alpha: 0.35)
                                : Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$percentage%',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: progress > 0.5
                                  ? Colors.white
                                  : (context.isDark ? const Color(0xFFFDA4AF) : const Color(0xFFBE123C)),
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
      },
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required String value,
    required String unit,
    required Color valueColor,
    bool isMono = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: context.isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: context.ftMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: isMono ? 'monospace' : FtText.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: valueColor,
              letterSpacing: isMono ? 0.0 : -0.3,
            ),
          ),
          if (unit.isNotEmpty)
            Text(
              unit,
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: context.ftMuted,
              ),
            ),
        ],
      ),
    );
  }
}
