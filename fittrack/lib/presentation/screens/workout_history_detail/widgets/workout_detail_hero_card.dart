import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../providers/workout_history_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';

/// Hero Banner Card for Workout History Details screen with schedule hero image,
/// floating meta pills, title, focus subtitle, and segmented progress track.
class WorkoutDetailHeroCard extends StatelessWidget {
  final WorkoutSessionDetailData detail;

  const WorkoutDetailHeroCard({
    super.key,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final session = detail.session;
    final schedule = detail.schedule;

    final datePill = DateFormat('MMM d · yyyy').format(session.startTime).toUpperCase();
    final timePill = DateFormat('h:mm a').format(session.startTime);
    final intensityLabel = session.intensity?.isNotEmpty == true
        ? session.intensity!.replaceAll(' (Optimal)', '').replaceAll(' (Heavy)', '')
        : 'Intense Session';

    final scheduleTitle = schedule?.name ??
        (session.scheduleId.toLowerCase().contains('sch1')
            ? 'Day 1 – Chest, Shoulders & Triceps'
            : session.scheduleId.toLowerCase().contains('sch2')
                ? 'Day 2 – Back & Biceps Focus'
                : 'Day 3 – Heavy Leg Day');

    final dayName = DateFormat('EEEE').format(session.startTime);
    final subtitle = 'Completed on $dayName · Hypertrophy Focus';

    final totalEx = detail.totalExercisesCount > 0 ? detail.totalExercisesCount : 7;
    final completedEx = detail.completedExercisesCount;
    final percent = ((completedEx / totalEx) * 100).round();

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cacheWidth = ((screenWidth - 40) * dpr).ceil();

    final isDark = context.isDark;

    return GlassSurface(
      tier: FtGlassTier.glass1,
      radius: FtGlassTheme.radiusCards,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Banner Image with Floating Overlays ───────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(FtGlassTheme.radiusTiles),
            child: SizedBox(
              height: 190,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: ResizeImage(
                      const AssetImage('assets/images/dashboard/hero_workout.webp'),
                      width: cacheWidth,
                    ),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: context.ftPrimary.withValues(alpha: 0.15),
                      child: Icon(
                        Icons.fitness_center_rounded,
                        size: 48,
                        color: context.ftPrimary,
                      ),
                    ),
                  ),

                  // Subtle gradient scrims for contrast
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.55),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.75),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),

                  // Top Badges Row
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Date capsule
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: _ImageBadge(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: context.ftPrimaryLight,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    datePill,
                                    style: const TextStyle(
                                      fontFamily: FtText.fontFamily,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Right: Time capsule
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: _ImageBadge(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 12,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    timePill,
                                    style: const TextStyle(
                                      fontFamily: FtText.fontFamily,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Badges Row
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Intensity Badge
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: _ImageBadge(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.bar_chart_rounded,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    intensityLabel,
                                    style: const TextStyle(
                                      fontFamily: FtText.fontFamily,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Right: Muscle Tags
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _CategoryPill(label: 'Chest', color: context.ftPrimary),
                                const SizedBox(width: 4),
                                _CategoryPill(label: 'Shoulders', color: context.ftPrimaryLight),
                                const SizedBox(width: 4),
                                _CategoryPill(label: 'Triceps', color: const Color(0xFF00D2B4)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ── Title & Focus Subtitle ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scheduleTitle,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 19,
                    height: 24 / 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: context.ftInk,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: context.ftMuted,
                  ),
                ),

                const SizedBox(height: 14),

                // ── Workout Progress Row & Segmented Track ─────────────
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
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: context.ftPrimary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'WORKOUT PROGRESS',
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
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
                          '$percent% · $completedEx of $totalEx logged',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: context.ftPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Continuous Gradient Progress Track with Glowing Tip
                LayoutBuilder(
                  builder: (context, constraints) {
                    final progressWidth = (constraints.maxWidth * (percent / 100.0)).clamp(16.0, constraints.maxWidth);

                    return Container(
                      height: 10,
                      width: double.infinity,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: progressWidth,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF5F3BDC),
                              Color(0xFF7858F6),
                              Color(0xFF2DD4BF),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x665F3BDC),
                              blurRadius: 8,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.only(right: 2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageBadge extends StatelessWidget {
  final Widget child;

  const _ImageBadge({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 0.75,
        ),
      ),
      child: child,
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final Color color;

  const _CategoryPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
        border: Border.all(
          color: color.withValues(alpha: 0.6),
          width: 0.75,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: FtText.fontFamily,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
