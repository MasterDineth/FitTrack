import 'package:flutter/material.dart';

import 'package:fittrack/domain/entities/schedule.dart';
import 'package:fittrack/domain/entities/workout_schedule.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';

/// Hero section for Workout Details matching Stitch Screen `fc32d4d5a15441178564c24cb5dad0f4`.
///
/// Features:
/// - Routine focus pill with animated pulsating dot ("Push–Pull–Legs Split · Week 3")
/// - Large bold routine title ("Day 1 – Chest, Shoulders & Triceps")
/// - Schedule preview hero card with athletic image, top frosted tags ("Hypertrophy Focus", "Full Gym", "4 Days/Wk"),
///   and bottom frosted summary badge ("Est. 60m · 21 Sets · ~390 kcal", "Active").
class WorkoutDetailHero extends StatelessWidget {
  const WorkoutDetailHero({
    super.key,
    required this.schedule,
    this.workoutSchedule,
    required this.totalSets,
    required this.exerciseCount,
  });

  final Schedule schedule;
  final WorkoutSchedule? workoutSchedule;
  final int totalSets;
  final int exerciseCount;

  @override
  Widget build(BuildContext context) {
    final title = workoutSchedule?.title.isNotEmpty == true
        ? workoutSchedule!.title
        : schedule.name.isNotEmpty
            ? schedule.name
            : 'Push–Pull–Legs Routine';

    final focus = workoutSchedule?.focus.isNotEmpty == true
        ? workoutSchedule!.focus
        : schedule.targetMuscles.isNotEmpty
            ? schedule.targetMuscles.join(', ')
            : 'Hypertrophy Focus';

    final days = workoutSchedule?.daysPerWeek ??
        (schedule.assignedWeekdays.isNotEmpty ? schedule.assignedWeekdays.length : 4);

    final estMinutes = workoutSchedule?.estimatedMinutes != null &&
            workoutSchedule!.estimatedMinutes > 0
        ? workoutSchedule!.estimatedMinutes
        : (totalSets * 2.5 + exerciseCount * 2).clamp(30, 90).toInt();

    final estCalories = (estMinutes * 6.5).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Top Focus Pill ──────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: context.ftPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: context.ftPrimary.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: context.ftPrimary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  '${title.toUpperCase()} · WEEK 3',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: context.ftPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ── Main Schedule Title ─────────────────────────────────────────────
        Text(
          title,
          style: TextStyle(
            fontFamily: FtText.fontFamily,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            height: 1.15,
            color: context.ftInk,
          ),
        ),
        const SizedBox(height: 14),

        // ── Schedule Preview Hero Card ──────────────────────────────────────
        Container(
          height: 190,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.85),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: context.ftPrimary.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                Image.asset(
                  'assets/images/dashboard/hero_workout.webp',
                  fit: BoxFit.cover,
                  cacheWidth: 800,
                  errorBuilder: (_, _, _) => Container(
                    color: const Color(0xFF1E1B4B),
                  ),
                ),

                // Ambient gradient scrims
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.45),
                        Colors.black.withValues(alpha: 0.10),
                        Colors.black.withValues(alpha: 0.75),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),

                // Top frosted tags row
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            GlassSurface(
                              tier: FtGlassTier.glass2,
                              radius: 12,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4.5,
                              ),
                              child: Text(
                                focus.toUpperCase(),
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: context.ftInk,
                              ),
                            ),
                          ),
                          GlassSurface(
                            tier: FtGlassTier.glass2,
                            radius: 12,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4.5,
                            ),
                            child: Text(
                              (workoutSchedule?.equipment ?? 'Full Gym').toUpperCase(),
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: context.ftInk,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GlassSurface(
                        tier: FtGlassTier.glass2,
                        radius: 12,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4.5,
                        ),
                        child: Text(
                          '$days Days/Wk',
                          style: TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: context.ftInk,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom frosted session summary bar
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 15,
                                color: Color(0xFFC9C0FA),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Est. ${estMinutes}m · $totalSets Sets · ~$estCalories kcal',
                                  style: const TextStyle(
                                    fontFamily: FtText.fontFamily,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF065F46).withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF34D399).withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              fontFamily: FtText.fontFamily,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: Color(0xFF6EE7B7),
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
        ),
      ],
    );
  }
}
