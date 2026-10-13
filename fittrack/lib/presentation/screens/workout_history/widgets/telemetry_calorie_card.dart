import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../providers/workout_history_provider.dart';
import '../../../theme/ft_glass.dart';

enum CalorieViewMode { bars, ring }

/// Card 1: Calorie & Output Dynamics with interactive Bars / Ring toggle
class TelemetryCalorieCard extends StatefulWidget {
  final MonthlyTelemetryData telemetry;

  const TelemetryCalorieCard({
    super.key,
    required this.telemetry,
  });

  @override
  State<TelemetryCalorieCard> createState() => _TelemetryCalorieCardState();
}

class _TelemetryCalorieCardState extends State<TelemetryCalorieCard> {
  CalorieViewMode _viewMode = CalorieViewMode.bars;

  @override
  Widget build(BuildContext context) {
    final t = widget.telemetry;
    final isDark = context.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ── Header: Title & [Bars | Ring] Toggle ─────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 16,
                      color: Color(0xFFF97316),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Calorie & Output Dynamics',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: context.ftInk,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Toggle Capsule [Bars | Ring]
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ToggleItem(
                    label: 'Bars',
                    isSelected: _viewMode == CalorieViewMode.bars,
                    onTap: () => setState(() => _viewMode = CalorieViewMode.bars),
                  ),
                  _ToggleItem(
                    label: 'Ring',
                    isSelected: _viewMode == CalorieViewMode.ring,
                    onTap: () => setState(() => _viewMode = CalorieViewMode.ring),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ── 4-Grid Metrics Summary ───────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFF1F5F9),
            ),
          ),
          child: Row(
            children: [
              _StatColumn(
                label: 'TOTAL BURN',
                value: '2,840',
                subtext: '+12%',
                subtextColor: const Color(0xFF10B981),
              ),
              _StatColumn(
                label: 'ACTIVE TIME',
                value: t.activeTimeFormatted,
                subtext: '${t.activeSessionsCount} sesh',
                subtextColor: context.ftMuted,
              ),
              _StatColumn(
                label: 'AVG/SESSION',
                value: '${t.avgCaloriesPerSession}',
                valueColor: const Color(0xFFEA580C),
                subtext: 'kcal',
                subtextColor: context.ftMuted,
              ),
              _StatColumn(
                label: 'AVG PULSE',
                value: '${t.avgPulseBpm}',
                valueColor: const Color(0xFFE11D48),
                subtext: 'bpm',
                subtextColor: context.ftMuted,
              ),
            ],
          ),
        ),

        // ── Interactive Chart Area (Bars vs Concentric Ring) ──────────
        SizedBox(
          height: 70,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _viewMode == CalorieViewMode.bars
                ? _buildBarsView(context)
                : _buildRingView(context),
          ),
        ),

        // ── Card Footer: Pace & Peak ──────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: const [
                      Icon(
                        Icons.trending_up_rounded,
                        size: 13,
                        color: Color(0xFF10B981),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Pace: +340 kcal ahead of goal',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    children: [
                      Text(
                        'Peak: ',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: context.ftMuted,
                        ),
                      ),
                      const Text(
                        'Sat 620 kcal',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFEA580C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarsView(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const burns = [380, 410, 290, 430, 490, 620, 220];
    const maxBurn = 650.0;

    return Row(
      key: const ValueKey('bars_view'),
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final day = days[index];
        final val = burns[index];
        final isPeak = index == 5; // Saturday
        final barHeight = (val / maxBurn * 32.0).clamp(12.0, 36.0);

        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$val',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 8,
                  fontWeight: isPeak ? FontWeight.w900 : FontWeight.w600,
                  color: isPeak ? const Color(0xFFEA580C) : context.ftMuted,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 14,
                height: barHeight,
                decoration: BoxDecoration(
                  gradient: isPeak
                      ? const LinearGradient(
                          colors: [Color(0xFFF97316), Color(0xFFF43F5E)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        )
                      : null,
                  color: isPeak
                      ? null
                      : (index == 4
                          ? context.ftPrimary
                          : context.ftPrimary.withValues(alpha: 0.35 + (val / maxBurn * 0.45))),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  boxShadow: isPeak
                      ? [
                          BoxShadow(
                            color: const Color(0xFFF97316).withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                day,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 9,
                  fontWeight: isPeak ? FontWeight.w900 : FontWeight.w700,
                  color: isPeak ? const Color(0xFFEA580C) : context.ftMuted,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRingView(BuildContext context) {
    return Row(
      key: const ValueKey('ring_view'),
      children: [
        // Concentric Rings
        SizedBox(
          width: 58,
          height: 58,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(58, 58),
                painter: _ConcentricRingsPainter(
                  outerProgress: 0.86,
                  innerProgress: 0.87,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '86%',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                      color: context.ftInk,
                    ),
                  ),
                  Text(
                    'GOAL',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      color: context.ftMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),

        // Legend Column
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RingLegendItem(
                color: const Color(0xFFF97316),
                title: 'Caloric Target: ',
                value: '2,840 / 3,300',
              ),
              const SizedBox(height: 3),
              _RingLegendItem(
                color: const Color(0xFF14B8A6),
                title: 'Duration: ',
                value: '5h 40m / 6h 30m',
              ),
              const SizedBox(height: 3),
              _RingLegendItem(
                color: const Color(0xFFF43F5E),
                title: 'Cardio Zone 4: ',
                value: '80% in range',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF2A2346) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: FtText.fontFamily,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? context.ftInk
                : context.ftMuted,
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final String subtext;
  final Color subtextColor;

  const _StatColumn({
    required this.label,
    required this.value,
    this.valueColor,
    required this.subtext,
    required this.subtextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: context.ftMuted,
              ),
            ),
          ),
          const SizedBox(height: 1),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
                color: valueColor ?? context.ftInk,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              subtext,
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: subtextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingLegendItem extends StatelessWidget {
  final Color color;
  final String title;
  final String value;

  const _RingLegendItem({
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: context.ftMuted,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: context.ftInk,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConcentricRingsPainter extends CustomPainter {
  final double outerProgress;
  final double innerProgress;

  const _ConcentricRingsPainter({
    required this.outerProgress,
    required this.innerProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 3.5;
    final innerRadius = outerRadius - 6.5;

    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..color = const Color(0xFFEDE9FE);

    // Draw background tracks
    canvas.drawCircle(center, outerRadius, bgPaint);
    canvas.drawCircle(center, innerRadius, bgPaint..color = const Color(0xFFCCFBF1));

    // Outer progress: Orange
    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFF97316);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      -math.pi / 2,
      2 * math.pi * outerProgress,
      false,
      outerPaint,
    );

    // Inner progress: Teal
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF14B8A6);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      -math.pi / 2,
      2 * math.pi * innerProgress,
      false,
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ConcentricRingsPainter oldDelegate) =>
      oldDelegate.outerProgress != outerProgress ||
      oldDelegate.innerProgress != innerProgress;
}
