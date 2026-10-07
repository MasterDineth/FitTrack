import 'dart:math' as math;
import 'package:flutter/material.dart';
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
  Offset _panStart = Offset.zero;

  void _next() {
    setState(() {
      _activeIndex = (_activeIndex + 1) % 3;
    });
  }

  void _prev() {
    setState(() {
      _activeIndex = (_activeIndex - 1 + 3) % 3;
    });
  }

  void _goTo(int index) {
    if (index >= 0 && index < 3 && index != _activeIndex) {
      setState(() {
        _activeIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                      decoration: const BoxDecoration(
                        color: FtGlassTheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'DAILY TELEMETRY & PROGRESS',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FtText.uppercase11,
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
                                      ? FtGlassTheme.primary
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

        // Stack Viewport: Height 208
        RepaintBoundary(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (details) {
              _panStart = details.localPosition;
            },
            onHorizontalDragEnd: (details) {
              final dx = details.primaryVelocity ?? 0;
              if (dx < -50) {
                _next();
              } else if (dx > 50) {
                _prev();
              }
            },
            onHorizontalDragUpdate: (details) {
              final dx = details.localPosition.dx - _panStart.dx;
              final dy = details.localPosition.dy - _panStart.dy;
              if (dx.abs() > 25 && dx.abs() > dy.abs()) {
                if (dx < 0) {
                  _next();
                } else {
                  _prev();
                }
                _panStart = details.localPosition; // reset to avoid multi-triggers
              }
            },
            child: SizedBox(
              height: 208,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildStackedCard(2),
                  _buildStackedCard(1),
                  _buildStackedCard(0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStackedCard(int offset) {
    // Determine which card index maps to this offset
    final cardIndex = (_activeIndex + offset) % 3;

    final double opacity = switch (offset) {
      0 => 1.0,
      1 => 0.75,
      _ => 0.40,
    };

    final double scale = switch (offset) {
      0 => 1.0,
      1 => 0.96,
      _ => 0.92,
    };

    final double translateY = switch (offset) {
      0 => 0.0,
      1 => 8.0,
      _ => 16.0,
    };

    final isInteractive = offset == 0;
    final isTappable = offset == 1;

    Widget cardWidget = switch (cardIndex) {
      0 => const _BioMetricsBalanceCard(),
      1 => const _WeeklyMomentumCard(),
      _ => const _WeeklyLoadCard(),
    };

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      top: translateY,
      left: 0,
      right: 0,
      bottom: -translateY + (offset * 8.0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.center,
          child: IgnorePointer(
            ignoring: !isInteractive && !isTappable,
            child: GestureDetector(
              onTap: isTappable ? () => _goTo(cardIndex) : null,
              behavior: HitTestBehavior.opaque,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(FtGlassTheme.radiusStackCards),
                ),
                child: GlassSurface(
                  tier: FtGlassTier.glass1,
                  radius: FtGlassTheme.radiusStackCards,
                  borderTint: Colors.white.withValues(alpha: 0.85),
                  padding: const EdgeInsets.all(16.0),
                  child: offset == 0 ? cardWidget : const SizedBox.shrink(),
                ),
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
            const Expanded(
              child: Text(
                'Bio-Metrics Balance',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: FtGlassTheme.ink,
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
          const Expanded(
            child: Center(
              child: Text(
                'Connect Health to see movement and recovery',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: FtGlassTheme.muted,
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
                  tagColor: FtGlassTheme.primary,
                  progress: bio.movementPercent,
                  displayValue: '${(bio.movementPercent * 100).round()}%',
                  gradientColors: const [Color(0xFF9B7BFF), Color(0xFF5F3BDC)],
                  trackColor: const Color.fromRGBO(95, 59, 220, 0.12),
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
  final Color displayColor;
  final List<Color> gradientColors;
  final Color trackColor;

  const _BioMetricRingTile({
    required this.name,
    required this.sub,
    required this.tag,
    required this.tagColor,
    required this.progress,
    required this.displayValue,
    this.displayColor = FtGlassTheme.ink,
    required this.gradientColors,
    required this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      tier: FtGlassTier.glass2,
      radius: FtGlassTheme.radiusTiles,
      padding: const EdgeInsets.all(8.0),
      shadow: false,
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
                        color: displayColor,
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
            style: const TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: FtGlassTheme.ink,
            ),
          ),

          // Subtext
          Text(
            sub,
            style: const TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: FtGlassTheme.muted,
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
                  const Text(
                    'Weekly Momentum',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: FtGlassTheme.ink,
                    ),
                  ),
                  Text(
                    '$completed of $target sessions complete',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: FtGlassTheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                border: Border.all(
                  color: FtGlassTheme.primary.withValues(alpha: 0.20),
                  width: 1.0,
                ),
              ),
              child: Text(
                '$streak% Streak',
                style: const TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: FtGlassTheme.primary,
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
                child: _buildDayStripColumn(dayItem),
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
                color: FtGlassTheme.primary.withValues(alpha: 0.10),
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 10,
                    color: FtGlassTheme.muted,
                  ),
                  children: [
                    const TextSpan(text: 'Today: '),
                    TextSpan(
                      text: routineTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: FtGlassTheme.primary,
                      ),
                    ),
                  ],
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

  Widget _buildDayStripColumn(DayStripItem item) {
    switch (item.status) {
      case DayStripStatus.done:
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.60),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.80),
              width: 1.0,
            ),
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
                  color: FtGlassTheme.muted,
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
            color: FtGlassTheme.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: FtGlassTheme.primary.withValues(alpha: 0.30),
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
          opacity: 0.8,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.40),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.60),
                width: 1.0,
              ),
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
                    color: FtGlassTheme.muted,
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
                      color: FtGlassTheme.outlineVariant,
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    '${item.dayNumber}',
                    style: const TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: FtGlassTheme.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case DayStripStatus.rest:
        return Opacity(
          opacity: 0.6,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.30),
              borderRadius: BorderRadius.circular(12),
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
                    color: FtGlassTheme.muted,
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
            const Expanded(
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
                      color: FtGlassTheme.ink,
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
                      color: FtGlassTheme.muted,
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
                            style: const TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: FtGlassTheme.ink,
                            ),
                          ),
                          const TextSpan(
                            text: ' kg',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: FtGlassTheme.muted,
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
                            style: const TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: FtGlassTheme.ink,
                            ),
                          ),
                          const TextSpan(
                            text: ' / 5',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: FtGlassTheme.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$activeDays active days',
                      style: const TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: FtGlassTheme.primary,
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
            const Flexible(
              child: Text(
                'Training Load Index',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: FtGlassTheme.muted,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                zoneText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: FtGlassTheme.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
