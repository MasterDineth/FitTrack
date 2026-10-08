import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/workout_history_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import 'telemetry_calorie_card.dart';
import 'telemetry_milestones_card.dart';
import 'telemetry_volume_card.dart';

/// Swipable Stacked Telemetry Hub for Workout History matching the Dashboard physics & animations.
class MonthlyTelemetryStack extends ConsumerStatefulWidget {
  const MonthlyTelemetryStack({super.key});

  @override
  ConsumerState<MonthlyTelemetryStack> createState() => _MonthlyTelemetryStackState();
}

class _MonthlyTelemetryStackState extends ConsumerState<MonthlyTelemetryStack> {
  int _activeIndex = 0;
  double _dragDx = 0.0;
  bool _isTransitioning = false;

  void _next() {
    if (_isTransitioning) return;
    _lockTransition();
    HapticFeedback.selectionClick();
    setState(() {
      _activeIndex = (_activeIndex + 1) % 3;
      _dragDx = 0.0;
    });
  }

  void _prev() {
    if (_isTransitioning) return;
    _lockTransition();
    HapticFeedback.selectionClick();
    setState(() {
      _activeIndex = (_activeIndex - 1 + 3) % 3;
      _dragDx = 0.0;
    });
  }

  void _goTo(int index) {
    if (index >= 0 && index < 3 && index != _activeIndex && !_isTransitioning) {
      _lockTransition();
      HapticFeedback.selectionClick();
      setState(() {
        _activeIndex = index;
        _dragDx = 0.0;
      });
    }
  }

  void _lockTransition() {
    _isTransitioning = true;
    Future.delayed(const Duration(milliseconds: 280), () {
      if (mounted) {
        setState(() {
          _isTransitioning = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(workoutHistoryProvider);
    final telemetry = historyState.telemetry;

    // Draw furthest back card first (offset 2), active front card last (offset 0)
    final orderedIndices = [0, 1, 2]..sort((a, b) {
      final offsetA = (a - _activeIndex + 3) % 3;
      final offsetB = (b - _activeIndex + 3) % 3;
      return offsetB.compareTo(offsetA);
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Section Header Row ────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: 6px primary dot + uppercase label
              Expanded(
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'MONTHLY METRICS & TELEMETRY',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.55,
                          color: context.ftMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Right: Glass2 Pill with Prev / Dots / Next
              GlassSurface(
                tier: FtGlassTier.glass2,
                radius: FtGlassTheme.radiusPill,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                shadow: false,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      label: 'Previous metric card',
                      button: true,
                      child: GestureDetector(
                        onTap: _prev,
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Icon(
                            Icons.chevron_left_rounded,
                            size: 18,
                            color: FtGlassTheme.muted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (dotIndex) {
                        final isActive = dotIndex == _activeIndex;
                        return Semantics(
                          label: 'Go to metric card ${dotIndex + 1}',
                          button: true,
                          child: GestureDetector(
                            onTap: () => _goTo(dotIndex),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                width: isActive ? 16 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? context.ftPrimary
                                      : FtGlassTheme.outlineVariant,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 2),
                    Semantics(
                      label: 'Next metric card',
                      button: true,
                      child: GestureDetector(
                        onTap: _next,
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: FtGlassTheme.muted,
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

        // ── Stack Viewport: Height 230px with Drag Physics ────────────
        RepaintBoundary(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (_) {
              if (_isTransitioning) return;
              setState(() => _dragDx = 0.0);
            },
            onHorizontalDragUpdate: (details) {
              if (_isTransitioning) return;
              setState(() => _dragDx += details.primaryDelta ?? 0.0);
            },
            onHorizontalDragEnd: (details) {
              if (_isTransitioning) return;
              final velocity = details.primaryVelocity ?? 0.0;
              if (_dragDx < -35 || velocity < -200) {
                _next();
              } else if (_dragDx > 35 || velocity > 200) {
                _prev();
              } else {
                setState(() => _dragDx = 0.0);
              }
            },
            onHorizontalDragCancel: () => setState(() => _dragDx = 0.0),
            child: SizedBox(
              height: 246,
              child: Stack(
                clipBehavior: Clip.none,
                children: orderedIndices
                    .map((cardIndex) => _buildCard(cardIndex, telemetry))
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(int cardIndex, MonthlyTelemetryData telemetry) {
    final offset = (cardIndex - _activeIndex + 3) % 3;

    final double top = switch (offset) {
      0 => 0.0,
      1 => 8.0,
      _ => 16.0,
    };

    final double horizontalInset = switch (offset) {
      0 => 0.0,
      1 => 6.0,
      _ => 12.0,
    };

    final double borderAlpha = switch (offset) {
      0 => 0.90,
      1 => 0.75,
      _ => 0.60,
    };

    final List<BoxShadow> shadows = switch (offset) {
      0 => const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0x0A5F3BDC),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      1 => const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      _ => const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
    };

    final isInteractive = offset == 0;
    final isTappable = offset != 0;

    final Widget cardWidget = switch (cardIndex) {
      0 => TelemetryVolumeCard(telemetry: telemetry),
      1 => TelemetryCalorieCard(telemetry: telemetry),
      _ => TelemetryMilestonesCard(telemetry: telemetry),
    };

    final dragOffset = offset == 0 ? _dragDx : 0.0;
    final rotationAngle = offset == 0 ? (_dragDx / 600.0).clamp(-0.08, 0.08) : 0.0;

    // Content fade: offset 2 has empty content (only 8px rim peeks out)
    // offset 1 smoothly fades in as front card drags away
    final Widget contentWidget;
    if (offset == 2) {
      contentWidget = const SizedBox.shrink();
    } else if (offset == 1) {
      if (_isTransitioning) {
        contentWidget = cardWidget;
      } else {
        final dragProgress = (_dragDx.abs() / 100.0).clamp(0.0, 1.0);
        contentWidget = Opacity(
          opacity: dragProgress,
          child: cardWidget,
        );
      }
    } else {
      contentWidget = cardWidget;
    }

    return AnimatedPositioned(
      key: ValueKey('monthly_telemetry_card_$cardIndex'),
      duration: _dragDx != 0 && offset == 0
          ? Duration.zero
          : const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      top: top,
      left: horizontalInset,
      right: horizontalInset,
      height: 230,
      child: Transform.translate(
        offset: Offset(dragOffset, 0),
        child: Transform.rotate(
          angle: rotationAngle,
          alignment: Alignment.bottomCenter,
          child: IgnorePointer(
            ignoring: !isInteractive && !isTappable,
            child: GestureDetector(
              onTap: isTappable ? () => _goTo(cardIndex) : null,
              behavior: HitTestBehavior.opaque,
              child: Builder(
                builder: (context) {
                  final isDark = context.isDark;
                  final cardBorder = isDark
                      ? Colors.white.withValues(alpha: 0.12 * borderAlpha)
                      : Colors.white.withValues(alpha: borderAlpha);

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(FtGlassTheme.radiusStackCards),
                      boxShadow: shadows,
                    ),
                    child: GlassSurface(
                      tier: FtGlassTier.glass1,
                      radius: FtGlassTheme.radiusStackCards,
                      borderTint: cardBorder,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shadow: false,
                      child: contentWidget,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
