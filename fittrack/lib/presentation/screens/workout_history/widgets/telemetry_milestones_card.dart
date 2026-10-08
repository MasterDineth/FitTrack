import 'package:flutter/material.dart';
import '../../../providers/workout_history_provider.dart';
import '../../../theme/ft_glass.dart';

/// Card 2: Milestones & Strength Index
class TelemetryMilestonesCard extends StatelessWidget {
  final MonthlyTelemetryData telemetry;

  const TelemetryMilestonesCard({
    super.key,
    required this.telemetry,
  });

  @override
  Widget build(BuildContext context) {
    final t = telemetry;
    final isDark = context.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ── Header: Title & "★ 6 PRs Logged" Badge ───────────────────
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
                      Icons.military_tech_rounded,
                      size: 16,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Milestones & Strength Index',
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

            // Amber PRs Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                    : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
                      : const Color(0xFFFDE68A),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 11,
                    color: Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${t.prsCount} PRs Logged',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ── Row 1: 3 PR Stat Boxes ────────────────────────────────────
        Row(
          children: [
            _PrBox(
              label: 'BENCH PRESS',
              weight: '${t.benchPressWeight.toInt()}',
              prDelta: '+${t.benchPressPrDelta.toInt()} kg PR',
              accentColor: const Color(0xFF7C5CFA),
              bgColor: isDark
                  ? const Color(0xFF7C5CFA).withValues(alpha: 0.15)
                  : const Color(0xFFF5F3FF),
              borderColor: isDark
                  ? const Color(0xFF7C5CFA).withValues(alpha: 0.3)
                  : const Color(0xFFEDE9FE),
            ),
            const SizedBox(width: 6),
            _PrBox(
              label: 'DEADLIFT',
              weight: '${t.deadliftWeight.toInt()}',
              prDelta: '+${t.deadliftPrDelta.toInt()} kg PR',
              accentColor: const Color(0xFF14B8A6),
              bgColor: isDark
                  ? const Color(0xFF14B8A6).withValues(alpha: 0.15)
                  : const Color(0xFFF0FDFA),
              borderColor: isDark
                  ? const Color(0xFF14B8A6).withValues(alpha: 0.3)
                  : const Color(0xFFCCFBF1),
            ),
            const SizedBox(width: 6),
            _PrBox(
              label: 'BACK SQUAT',
              weight: '${t.backSquatWeight.toInt()}',
              prDelta: '+${t.backSquatPrDelta} kg PR',
              accentColor: const Color(0xFFF43F5E),
              bgColor: isDark
                  ? const Color(0xFFF43F5E).withValues(alpha: 0.15)
                  : const Color(0xFFFFF1F2),
              borderColor: isDark
                  ? const Color(0xFFF43F5E).withValues(alpha: 0.3)
                  : const Color(0xFFFFE4E6),
            ),
          ],
        ),

        // ── Row 2: Muscle Readiness Score Banner ──────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF10B981).withValues(alpha: 0.25)
                      : const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${t.muscleReadinessScore}%',
                  style: const TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF047857),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Muscle Readiness Score',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: context.ftInk,
                      ),
                    ),
                    Text(
                      t.readinessVelocity,
                      style: const TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2346) : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  '${t.efficiencyIndex} Eff. Index',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: context.ftInk,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Card Footer: PR Velocity & Top Tier ───────────────────────
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
                    children: [
                      Icon(
                        Icons.speed_rounded,
                        size: 13,
                        color: context.ftPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'PR Velocity: ',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: context.ftMuted,
                        ),
                      ),
                      Text(
                        '+${t.prVelocityVsLastMonth} PRs vs Aug',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: context.ftInk,
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
                  child: Text(
                    t.tierRank,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFFA78BFA) : const Color(0xFF6D28D9),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrBox extends StatelessWidget {
  final String label;
  final String weight;
  final String prDelta;
  final Color accentColor;
  final Color bgColor;
  final Color borderColor;

  const _PrBox({
    required this.label,
    required this.weight,
    required this.prDelta,
    required this.accentColor,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                  color: accentColor,
                ),
              ),
            ),
            const SizedBox(height: 1),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    weight,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                      color: context.ftInk,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'kg',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: context.ftMuted,
                    ),
                  ),
                ],
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                prDelta,
                style: const TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
