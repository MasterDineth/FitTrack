import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/ft_constants.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../../providers/dashboard_providers.dart';

class TelemetryStack extends ConsumerStatefulWidget {
  const TelemetryStack({super.key});

  @override
  ConsumerState<TelemetryStack> createState() => _TelemetryStackState();
}

class _TelemetryStackState extends ConsumerState<TelemetryStack> {
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
    // Determine stack paint order: furthest back (offset 2) drawn first, active front (offset 0) drawn last
    final orderedIndices = [0, 1, 2]..sort((a, b) {
      final offsetA = (a - _activeIndex + 3) % 3;
      final offsetB = (b - _activeIndex + 3) % 3;
      return offsetB.compareTo(offsetA);
    });

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row (mb 10)
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
                          'DAILY TELEMETRY & PROGRESS',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FtText.uppercase11.copyWith(color: context.ftMuted),
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
                        label: 'Previous card',
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
                            label: 'Go to card ${dotIndex + 1}',
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
                        label: 'Next card',
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

          // Stack Viewport: Height 224 (accommodates 18px stacked bottom preview)
          RepaintBoundary(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (_) {
                if (_isTransitioning) return;
                setState(() {
                  _dragDx = 0.0;
                });
              },
              onHorizontalDragUpdate: (details) {
                if (_isTransitioning) return;
                setState(() {
                  _dragDx += details.primaryDelta ?? 0.0;
                });
              },
              onHorizontalDragEnd: (details) {
                if (_isTransitioning) return;
                final velocity = details.primaryVelocity ?? 0.0;
                if (_dragDx < -35 || velocity < -200) {
                  _next();
                } else if (_dragDx > 35 || velocity > 200) {
                  _prev();
                } else {
                  setState(() {
                    _dragDx = 0.0;
                  });
                }
              },
              onHorizontalDragCancel: () {
                setState(() {
                  _dragDx = 0.0;
                });
              },
              child: SizedBox(
                height: 232,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: orderedIndices.map((cardIndex) => _buildCard(cardIndex)).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int cardIndex) {
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

    Widget cardWidget = switch (cardIndex) {
      0 => const _BioMetricsBalanceCard(),
      1 => const _WeeklyMomentumCard(),
      _ => const _WeeklyLoadCard(),
    };

    final dragOffset = offset == 0 ? _dragDx : 0.0;
    final rotationAngle = offset == 0 ? (_dragDx / 600.0).clamp(-0.08, 0.08) : 0.0;

    // Inner content rendering:
    // Offset 0: active card, content always 1.0
    // Offset 1: smoothly fade in as front card drags away or during tab transition
    // Offset 2: empty (it only peeks 8px at the bottom edge as a glass layered rim)
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
      key: ValueKey('telemetry_card_$cardIndex'),
      duration: _dragDx != 0 && offset == 0
          ? Duration.zero
          : const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      top: top,
      left: horizontalInset,
      right: horizontalInset,
      height: 212,
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
                      padding: const EdgeInsets.all(16.0),
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

// ==========================================
// CARD 1: Bio-Metrics Balance
// ==========================================
class _BioMetricsBalanceCard extends ConsumerWidget {
  const _BioMetricsBalanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bioMetricsAsync = ref.watch(bioMetricsProvider);
    final bio = bioMetricsAsync.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Bio-Metrics Balance',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: context.ftInk,
                ),
              ),
            ),
            const SizedBox(width: 6),
            if (bio?.isOptimal == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: FtGlassTheme.teal.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                  border: Border.all(
                    color: FtGlassTheme.teal.withValues(alpha: 0.20),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: FtGlassTheme.teal,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Optimal',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: FtGlassTheme.teal,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),

        // 3-Column Grid
        if (bio == null)
          Expanded(
            child: Center(
              child: Text(
                'Connect Health to see movement and recovery',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: context.ftMuted,
                ),
              ),
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: _BioMetricRingTile(
                  name: 'Movement',
                  sub: '${_formatNumber(bio.movementSteps)} steps',
                  tag: bio.movementTag,
                  tagColor: context.ftPrimary,
                  progress: bio.movementPercent,
                  displayValue: '${(bio.movementPercent * 100).round()}%',
                  gradientColors: [context.ftPrimaryLight, context.ftPrimary],
                  trackColor: context.ftPrimary.withValues(alpha: 0.12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _BioMetricRingTile(
                  name: 'Strain',
                  sub: 'Goal ${bio.strainGoal}',
                  tag: bio.strainTag,
                  tagColor: FtGlassTheme.orange,
                  progress: bio.strainPercent,
                  displayValue: bio.strainValue.toStringAsFixed(1),
                  gradientColors: const [Color(0xFFFEB78B), Color(0xFFF97316)],
                  trackColor: const Color.fromRGBO(249, 115, 22, 0.15),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _BioMetricRingTile(
                  name: 'Recovery',
                  sub: bio.recoveryTime,
                  tag: bio.recoveryTag,
                  tagColor: FtGlassTheme.teal,
                  progress: bio.recoveryFraction,
                  displayValue: '${bio.recoveryPercent}%',
                  displayColor: FtGlassTheme.teal,
                  gradientColors: const [Color(0xFF62FAE3), Color(0xFF14B8A6)],
                  trackColor: const Color.fromRGBO(20, 184, 166, 0.15),
                ),
              ),
            ],
          ),
      ],
    );
  }

  String _formatNumber(int number) {
    return NumberFormat('#,###').format(number);
  }
}

class _BioMetricRingTile extends StatelessWidget {
  final String name;
  final String sub;
  final String tag;
  final Color tagColor;
  final double progress;
  final String displayValue;
  final Color? displayColor;
  final List<Color> gradientColors;
  final Color trackColor;

  const _BioMetricRingTile({
    required this.name,
    required this.sub,
    required this.tag,
    required this.tagColor,
    required this.progress,
    required this.displayValue,
    this.displayColor,
    required this.gradientColors,
    required this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDisplayColor = displayColor ?? context.ftInk;

    return GlassSurface(
      tier: FtGlassTier.glass2,
      radius: FtGlassTheme.radiusTiles,
      padding: const EdgeInsets.all(8.0),
      shadow: false,
      enableBlur: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 48x48 Progress Ring
          SizedBox(
            width: 48,
            height: 48,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: kDashboardEntranceMotion ? 0.0 : progress, end: progress),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, animatedProgress, child) {
                return CustomPaint(
                  painter: _RingProgressPainter(
                    progress: animatedProgress,
                    gradientColors: gradientColors,
                    trackColor: trackColor,
                  ),
                  child: Center(
                    child: Text(
                      displayValue,
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: effectiveDisplayColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),

          // Name
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: context.ftInk,
            ),
          ),

          // Subtext
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: context.ftMuted,
            ),
          ),

          // Tag Pill
          Container(
            margin: const EdgeInsets.only(top: 4.0),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: tagColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: tagColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingProgressPainter extends CustomPainter {
  final double progress;
  final List<Color> gradientColors;
  final Color trackColor;

  const _RingProgressPainter({
    required this.progress,
    required this.gradientColors,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 18.0;
    const strokeWidth = 4.0;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    final sweepAngle = (progress.clamp(0.0, 1.0)) * 2 * math.pi;
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    // Soft glow shadow (0 2 4 color@35%)
    final glowPaint = Paint()
      ..color = gradientColors.last.withValues(alpha: 0.35)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawArc(
      arcRect.shift(const Offset(0, 2)),
      -math.pi / 2,
      sweepAngle,
      false,
      glowPaint,
    );

    // Gradient Arc
    final arcPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: gradientColors,
      ).createShader(arcRect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ==========================================
// CARD 2: Weekly Momentum
// ==========================================
class _WeeklyMomentumCard extends ConsumerWidget {
  const _WeeklyMomentumCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final momentumAsync = ref.watch(weeklyMomentumProvider);
    final data = momentumAsync.value;

    final completed = data?.completedSessions ?? 4;
    final target = data?.targetSessions ?? 5;
    final streak = data?.streakPercent ?? 80;
    final routineTitle = data?.todayRoutineTitle ?? 'Push Hypertrophy';
    final points = data?.pointsEarned ?? 320;
    final strip = data?.dayStrip ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Weekly Momentum',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: context.ftInk,
                    ),
                  ),
                  Text(
                    '$completed of $target sessions complete',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: context.ftMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: context.ftPrimary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                border: Border.all(
                  color: context.ftPrimary.withValues(alpha: 0.20),
                  width: 1.0,
                ),
              ),
              child: Text(
                '$streak% Streak',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: context.ftPrimary,
                ),
              ),
            ),
          ],
        ),

        // 7-Column Day Strip
        Row(
          children: List.generate(7, (index) {
            final dayItem = index < strip.length
                ? strip[index]
                : DayStripItem(
                    letter: ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
                    dayNumber: index + 1,
                    status: index < 4 ? DayStripStatus.done : DayStripStatus.scheduled,
                  );

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index < 6 ? 6.0 : 0.0),
                child: _buildDayStripColumn(context, dayItem),
              ),
            );
          }),
        ),

        // Footer Row
        Container(
          padding: const EdgeInsets.only(top: 6.0),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: context.ftPrimary.withValues(alpha: 0.10),
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 10,
                      color: context.ftMuted,
                    ),
                    children: [
                      const TextSpan(text: 'Today: '),
                      TextSpan(
                        text: routineTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: context.ftPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                '+$points pts',
                style: const TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: FtGlassTheme.teal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayStripColumn(BuildContext context, DayStripItem item) {
    final isDark = context.isDark;

    switch (item.status) {
      case DayStripStatus.done:
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.60),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.10 : 0.80),
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.letter,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: context.ftMuted,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: FtGlassTheme.teal,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );

      case DayStripStatus.today:
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          decoration: BoxDecoration(
            color: context.ftPrimary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: context.ftPrimary.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.letter,
                style: const TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );

      case DayStripStatus.scheduled:
        return Opacity(
          opacity: isDark ? 0.95 : 0.8,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.white.withValues(alpha: 0.40),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.white.withValues(alpha: 0.60),
                width: 1.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.letter,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: context.ftMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.16)
                          : FtGlassTheme.outlineVariant,
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    '${item.dayNumber}',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: context.ftSubtext,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case DayStripStatus.rest:
        return Opacity(
          opacity: isDark ? 0.85 : 0.6,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.02)
                  : Colors.white.withValues(alpha: 0.30),
              borderRadius: BorderRadius.circular(12),
              border: isDark
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                      width: 1.0,
                    )
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.letter,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: context.ftMuted,
                  ),
                ),
                const SizedBox(height: 4),
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: Center(
                    child: Text('💤', style: TextStyle(fontSize: 8)),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}

// ==========================================
// CARD 3: Weekly Load & Volume
// ==========================================
class _WeeklyLoadCard extends ConsumerWidget {
  const _WeeklyLoadCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadAsync = ref.watch(weeklyLoadProvider);
    final data = loadAsync.value;

    final volumeText = NumberFormat('#,###').format(data?.totalVolumeKg ?? 24800);
    final volumeDelta = data?.prDelta ?? '↑ 1,450 kg PR';
    final activeDays = data?.activeDaysCount ?? 4;
    final zoneText = data?.trainingLoadZone ?? 'Optimal Zone (72 / 100)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Weekly Load & Volume',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: context.ftInk,
                    ),
                  ),
                  Text(
                    'Cumulative strain target: on track',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: context.ftMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: FtGlassTheme.orange.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                border: Border.all(
                  color: FtGlassTheme.orange.withValues(alpha: 0.20),
                  width: 1.0,
                ),
              ),
              child: const Text(
                '+12% vs LW',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: FtGlassTheme.orange,
                ),
              ),
            ),
          ],
        ),

        // 2-Column Row
        Row(
          children: [
            Expanded(
              child: GlassSurface(
                tier: FtGlassTier.glass2,
                radius: FtGlassTheme.radiusTiles,
                padding: const EdgeInsets.all(10.0),
                shadow: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'TOTAL VOLUME',
                      style: FtText.uppercase9,
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: volumeText,
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: context.ftInk,
                            ),
                          ),
                          TextSpan(
                            text: ' kg',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: context.ftMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      volumeDelta,
                      style: const TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: FtGlassTheme.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GlassSurface(
                tier: FtGlassTier.glass2,
                radius: FtGlassTheme.radiusTiles,
                padding: const EdgeInsets.all(10.0),
                shadow: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'ACTIVE DAYS',
                      style: FtText.uppercase9,
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$activeDays',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: context.ftInk,
                            ),
                          ),
                          TextSpan(
                            text: ' / 5',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: context.ftMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$activeDays active days',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: context.ftPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Footer Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                'Training Load Index',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: context.ftMuted,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                zoneText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: context.ftPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
