import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../dashboard/widgets/ft_pressable.dart';

class RpeGrade {
  const RpeGrade({
    required this.rating,
    required this.label,
    required this.intensityName,
    required this.activeBars,
  });

  final int rating;
  final String label;
  final String intensityName;
  final int activeBars;
}

/// Perceived Exertion (RPE) card with 5-Grade athletic scale (RPE 6 - 10),
/// animated signal bars, dynamic theming, and haptic feedback.
class WorkoutSummaryRpeCard extends StatelessWidget {
  const WorkoutSummaryRpeCard({
    super.key,
    required this.selectedRpe,
    required this.onRpeChanged,
  });

  final int selectedRpe;
  final ValueChanged<int> onRpeChanged;

  static const List<RpeGrade> grades = [
    RpeGrade(
      rating: 6,
      label: 'Moderate',
      intensityName: 'Moderate',
      activeBars: 1,
    ),
    RpeGrade(
      rating: 7,
      label: 'Normal',
      intensityName: 'Normal',
      activeBars: 1,
    ),
    RpeGrade(
      rating: 8,
      label: 'Hard',
      intensityName: 'Hard',
      activeBars: 2,
    ),
    RpeGrade(
      rating: 9,
      label: 'Intense',
      intensityName: 'Intense',
      activeBars: 3,
    ),
    RpeGrade(
      rating: 10,
      label: 'Extreme',
      intensityName: 'Extreme',
      activeBars: 3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = context.ftPrimary;
    final ink = context.ftInk;
    final muted = context.ftMuted;

    final currentGrade = grades.firstWhere(
      (g) => g.rating == selectedRpe,
      orElse: () => grades[3], // Default: RPE 9
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header Row ────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.monitor_heart_rounded,
                      size: 18,
                      color: primary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Perceived Exertion (RPE)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Selected Indicator Pill (Guaranteed Single-Line)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.5, vertical: 3.5),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'RPE ${currentGrade.rating}.0',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: primary,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        '·',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: muted,
                        ),
                      ),
                    ),
                    Text(
                      currentGrade.intensityName,
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ── Main Card with 5-Grade Scale ──────────────────────────────────────
        GlassSurface(
          tier: FtGlassTier.glass1,
          radius: 24,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              for (int i = 0; i < grades.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: _RpeTierButton(
                    grade: grades[i],
                    isSelected: grades[i].rating == selectedRpe,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onRpeChanged(grades[i].rating);
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RpeTierButton extends StatelessWidget {
  const _RpeTierButton({
    required this.grade,
    required this.isSelected,
    required this.onTap,
  });

  final RpeGrade grade;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = context.ftPrimary;
    final ink = context.ftInk;
    final isDark = context.isDark;

    return FtPressable(
      onTap: onTap,
      pressedScale: 0.93,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: 86,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primary.withValues(alpha: 0.95),
                    primary,
                  ],
                )
              : null,
          color: isSelected
              ? null
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.65)),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.4)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.8)),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.38),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Top Cyan Glow Dot for Active Highlight
            if (isSelected)
              Positioned(
                top: 0,
                child: Container(
                  width: 14,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2DD4BF),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xCC2DD4BF),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),

            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Number
                Text(
                  '${grade.rating}',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.white : ink,
                  ),
                ),

                // Athletic Signal Bars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _SignalBar(
                      height: 8,
                      isActive: grade.activeBars >= 1,
                      isSelected: isSelected,
                    ),
                    const SizedBox(width: 2.5),
                    _SignalBar(
                      height: 11,
                      isActive: grade.activeBars >= 2,
                      isSelected: isSelected,
                    ),
                    const SizedBox(width: 2.5),
                    _SignalBar(
                      height: 14,
                      isActive: grade.activeBars >= 3,
                      isSelected: isSelected,
                      isPulse: isSelected && grade.rating >= 9,
                    ),
                  ],
                ),

                // Label (Guaranteed Single-Line with FittedBox)
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      grade.label.toUpperCase(),
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        color: isSelected
                            ? (grade.rating >= 9
                                ? const Color(0xFF2DD4BF)
                                : Colors.white)
                            : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SignalBar extends StatelessWidget {
  const _SignalBar({
    required this.height,
    required this.isActive,
    required this.isSelected,
    this.isPulse = false,
  });

  final double height;
  final bool isActive;
  final bool isSelected;
  final bool isPulse;

  @override
  Widget build(BuildContext context) {
    Color barColor;
    if (isSelected) {
      barColor = isPulse ? const Color(0xFF2DD4BF) : Colors.white;
    } else {
      barColor = isActive
          ? context.ftPrimary.withValues(alpha: 0.5)
          : (context.isDark
              ? Colors.white.withValues(alpha: 0.15)
              : const Color(0xFFCBD5E1));
    }

    return Container(
      width: 3.5,
      height: height,
      decoration: BoxDecoration(
        color: barColor,
        borderRadius: BorderRadius.circular(2),
        boxShadow: isPulse
            ? const [
                BoxShadow(
                  color: Color(0x992DD4BF),
                  blurRadius: 4,
                  spreadRadius: 0.5,
                ),
              ]
            : null,
      ),
    );
  }
}
