import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../domain/entities/schedule.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';

/// Hero Card for Workout Summary with cinematic cover, routine focus badge,
/// date/time chips, title overlay, and exercise completion progress bar.
class WorkoutSummaryHeroCard extends StatelessWidget {
  const WorkoutSummaryHeroCard({
    super.key,
    required this.schedule,
    required this.completedExercisesCount,
    required this.totalExercisesCount,
    this.completedAt,
  });

  final Schedule schedule;
  final int completedExercisesCount;
  final int totalExercisesCount;
  final DateTime? completedAt;

  @override
  Widget build(BuildContext context) {
    final now = completedAt ?? DateTime.now();
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final dateStr = '${dateFormat.format(now)} · ${timeFormat.format(now)}';

    final effectiveTotal = totalExercisesCount > 0 ? totalExercisesCount : 6;
    final effectiveCompleted = completedExercisesCount > 0
        ? completedExercisesCount.clamp(0, effectiveTotal)
        : effectiveTotal;
    final progressFraction = (effectiveCompleted / effectiveTotal).clamp(0.0, 1.0);
    final percentage = (progressFraction * 100).round();

    final title = schedule.name.isNotEmpty
        ? schedule.name
        : 'Day 1 – Chest, Shoulders & Triceps';

    final focusTag = schedule.targetMuscles.isNotEmpty
        ? '${schedule.targetMuscles.first} Split'
        : 'Hypertrophy Split';

    final primary = context.ftPrimary;
    final muted = context.ftMuted;

    return GlassSurface(
      tier: FtGlassTier.glass1,
      radius: 28,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cinematic Image Banner ──────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: SizedBox(
              height: 176,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover Image
                  Image.asset(
                    'assets/images/dashboard/hero_workout.webp',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: primary.withValues(alpha: 0.2),
                      child: Icon(Icons.fitness_center_rounded, size: 48, color: primary),
                    ),
                  ),

                  // Atmospheric Dark Overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.15),
                          Colors.black.withValues(alpha: 0.35),
                          Colors.black.withValues(alpha: 0.82),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),

                  // Top Floating Badges
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Routine Focus Chip with Emerald Pulse (Frosted Transparent like dashboard)
                        Flexible(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.22),
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
                                        color: Color(0xFF34D399),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0x8034D399),
                                            blurRadius: 4,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        focusTag,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: FtText.fontFamily,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Right: Date & Time Chip (Frosted Transparent like dashboard)
                        Flexible(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.22),
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_rounded,
                                      size: 12,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        dateStr,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: FtText.fontFamily,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Title & Completed State Overlay
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: Color(0xFF2DD4BF), // Brand Teal
                            ),
                            SizedBox(width: 4),
                            Text(
                              'COMPLETED WORKOUT',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: Color(0xFF2DD4BF),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                offset: Offset(0, 1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Progress & Exercise Logging Info Segment ─────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          '$effectiveCompleted of $effectiveTotal Exercises Logged',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // 100% Completed Badge (Guaranteed single line)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 13,
                        color: primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$percentage% Completed',
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 11,
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

          // Linear Gradient Progress Track
          Container(
            height: 9,
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progressFraction,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      primary,
                      const Color(0xFF7C5CFA),
                      const Color(0xFF2DD4BF),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2DD4BF).withValues(alpha: 0.5),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
