import 'package:flutter/material.dart';
import '../../../providers/workout_history_provider.dart';
import '../../../theme/ft_glass.dart';

/// Card 0: Volume & Muscle Load
class TelemetryVolumeCard extends StatelessWidget {
  final MonthlyTelemetryData telemetry;

  const TelemetryVolumeCard({
    super.key,
    required this.telemetry,
  });

  @override
  Widget build(BuildContext context) {
    final tonsStr = telemetry.volumeLiftedTons.toStringAsFixed(1);
    final isDark = context.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ── Card Header Row ──────────────────────────────────────────
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
                    Icon(
                      Icons.auto_graph_rounded,
                      size: 16,
                      color: context.ftPrimary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Volume & Muscle Load',
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
              decoration: BoxDecoration(
                color: isDark
                    ? context.ftPrimary.withValues(alpha: 0.25)
                    : const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? context.ftPrimary.withValues(alpha: 0.4)
                      : const Color(0xFFDDD6FE),
                  width: 1,
                ),
              ),
              child: Text(
                'Optimal',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFFC4B5FD) : const Color(0xFF6D28D9),
                ),
              ),
            ),
          ],
        ),

        // ── Row 1: 2 Stat Tiles ──────────────────────────────────────
        Row(
          children: [
            // Volume Lifted
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: isDark
                                ? context.ftPrimary.withValues(alpha: 0.2)
                                : const Color(0xFFEDE9FE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.fitness_center_rounded,
                            size: 12,
                            color: isDark ? const Color(0xFFA78BFA) : const Color(0xFF6D28D9),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'VOLUME LIFTED',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: context.ftMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          tonsStr,
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.6,
                            color: context.ftInk,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'tons',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.ftMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 1),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.trending_up_rounded,
                          size: 13,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '+${telemetry.volumeChangePercent.toInt()}% vs last mo',
                          style: const TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              width: 1,
              height: 48,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFF1B1533).withValues(alpha: 0.06),
            ),
            const SizedBox(width: 14),

            // Active Streak
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFFF97316).withValues(alpha: 0.2)
                                : const Color(0xFFFFEDD5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.local_fire_department_rounded,
                            size: 13,
                            color: Color(0xFFEA580C),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'ACTIVE STREAK',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: context.ftMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${telemetry.activeStreakDays}',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.6,
                            color: context.ftInk,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'days',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.ftMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 1),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          telemetry.streakStatus,
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: context.ftMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ── Muscle Split Load ────────────────────────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MUSCLE SPLIT LOAD',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: context.ftMuted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    telemetry.dominantMuscle,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: context.ftMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 7,
                child: Row(
                  children: const [
                    Expanded(flex: 35, child: ColoredBox(color: Color(0xFF7C5CFA))),
                    SizedBox(width: 2),
                    Expanded(flex: 30, child: ColoredBox(color: Color(0xFF14B8A6))),
                    SizedBox(width: 2),
                    Expanded(flex: 25, child: ColoredBox(color: Color(0xFFF43F5E))),
                    SizedBox(width: 2),
                    Expanded(flex: 10, child: ColoredBox(color: Color(0xFFF59E0B))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  _DotLegend(color: const Color(0xFF7C5CFA), label: 'Chest', value: '35%'),
                  const SizedBox(width: 12),
                  _DotLegend(color: const Color(0xFF14B8A6), label: 'Back', value: '30%'),
                  const SizedBox(width: 12),
                  _DotLegend(color: const Color(0xFFF43F5E), label: 'Legs', value: '25%'),
                  const SizedBox(width: 12),
                  _DotLegend(color: const Color(0xFFF59E0B), label: 'Shldr', value: '10%'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DotLegend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _DotLegend({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label ',
          style: TextStyle(
            fontFamily: FtText.fontFamily,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: context.ftMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: FtText.fontFamily,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: context.ftInk,
          ),
        ),
      ],
    );
  }
}
