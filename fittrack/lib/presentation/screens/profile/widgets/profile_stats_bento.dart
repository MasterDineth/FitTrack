import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fittrack/domain/entities/user_profile.dart';
import 'package:fittrack/presentation/theme/ft_glass.dart';

/// Bento Grid Section displaying monthly athlete metrics and dynamic BMI.
///
/// Features:
/// - "THIS MONTH" header with dynamic month label and cycle period
/// - 2x2 Glass Bento Grid:
///   1. Total Calories with pacing progress bar
///   2. Body Mass (BMI) with dynamic multi-segment range bar
///   3. Workout Time with goal progress bar
///   4. Total Volume moved with pacing progress bar
class ProfileStatsBento extends StatelessWidget {
  final UserProfile profile;
  final Map<String, dynamic>? metrics;

  const ProfileStatsBento({
    super.key,
    required this.profile,
    this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final ink = context.ftInk;
    final muted = context.ftMuted;
    final primary = context.ftPrimary;
    final settings = FtGlassTheme.resolveThemeSettings(context);

    final now = DateTime.now();
    final monthLabel = DateFormat('MMMM yyyy').format(now);

    final rawBmi = profile.calculateBMI;
    final bmi = rawBmi > 0 ? rawBmi : 24.1;
    final bmiCategory = profile.getBMICategory;

    final totalCaloriesBurned =
        (metrics?['totalCaloriesBurned'] as int?) ?? 3450;
    final workoutsCompleted =
        (metrics?['totalWorkoutsCompleted'] as int?) ?? 6;

    final formattedCalories = NumberFormat('#,###').format(totalCaloriesBurned);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE2E8F0).withValues(alpha: 0.65);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Header ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'THIS MONTH',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: muted,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '· $monthLabel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '30d cycle',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ── 2x2 Frosted Glass Bento Card ───────────────────────────────
        Container(
          decoration: FtGlassTheme.cardDecoration(
            context,
            radius: 24,
            settings: settings,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Row 1: Calories & BMI
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top-Left: Total Calories
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: borderColor, width: 1),
                            bottom: BorderSide(color: borderColor, width: 1),
                          ),
                        ),
                        child: _buildCaloriesTile(
                          calories: formattedCalories,
                          ink: ink,
                          muted: muted,
                          primary: primary,
                          isDark: isDark,
                        ),
                      ),
                    ),

                    // Top-Right: Body Mass (BMI)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: borderColor, width: 1),
                          ),
                        ),
                        child: _buildBmiTile(
                          bmi: bmi,
                          category: bmiCategory,
                          ink: ink,
                          muted: muted,
                          isDark: isDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Row 2: Workout Time & Total Volume
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Bottom-Left: Workout Time
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: borderColor, width: 1),
                          ),
                        ),
                        child: _buildWorkoutTimeTile(
                          sessions: workoutsCompleted,
                          ink: ink,
                          muted: muted,
                          primary: primary,
                          isDark: isDark,
                        ),
                      ),
                    ),

                    // Bottom-Right: Total Volume
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        child: _buildVolumeTile(
                          ink: ink,
                          muted: muted,
                          isDark: isDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCaloriesTile({
    required String calories,
    required Color ink,
    required Color muted,
    required Color primary,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Total Calories',
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
            const SizedBox(width: 4),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFF97316).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                size: 17,
                color: Color(0xFFF97316),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  calories,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: ink,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'kcal',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: const Row(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    size: 13,
                    color: Color(0xFF059669),
                  ),
                  SizedBox(width: 3),
                  Text(
                    '+8.2% vs Feb',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF059669),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: 5,
                color: isDark ? Colors.white12 : Colors.black12,
                child: Row(
                  children: [
                    Expanded(
                      flex: 78,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFFB88C), Color(0xFFF43F5E)],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 22),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pace',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: muted,
                  ),
                ),
                Text(
                  '78%',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBmiTile({
    required double bmi,
    required String category,
    required Color ink,
    required Color muted,
    required bool isDark,
  }) {
    final isNormal = category == 'NORMAL';
    final isOver = category == 'OVERWEIGHT';
    final isUnder = category == 'UNDERWEIGHT';

    final label = isNormal
        ? 'Normal'
        : (isOver ? 'Elevated' : 'Low');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Body Mass (BMI)',
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
            const SizedBox(width: 4),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.monitor_heart_rounded,
                size: 17,
                color: Color(0xFF14B8A6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              bmi.toStringAsFixed(1),
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: ink,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF059669),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: isUnder
                          ? const Color(0xFFF59E0B)
                          : (isDark ? Colors.white12 : Colors.black12),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: isNormal
                          ? const Color(0xFF10B981)
                          : (isDark ? Colors.white12 : Colors.black12),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: isOver
                          ? const Color(0xFFF43F5E)
                          : (isDark ? Colors.white12 : Colors.black12),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Under',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 9,
                    fontWeight: isUnder ? FontWeight.w700 : FontWeight.w500,
                    color: isUnder ? const Color(0xFFF59E0B) : muted,
                  ),
                ),
                Text(
                  'Normal',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 9,
                    fontWeight: isNormal ? FontWeight.w700 : FontWeight.w500,
                    color: isNormal ? const Color(0xFF059669) : muted,
                  ),
                ),
                Text(
                  'Over',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 9,
                    fontWeight: isOver ? FontWeight.w700 : FontWeight.w500,
                    color: isOver ? const Color(0xFFF43F5E) : muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkoutTimeTile({
    required int sessions,
    required Color ink,
    required Color muted,
    required Color primary,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Workout Time',
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
            const SizedBox(width: 4),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.schedule_rounded,
                size: 17,
                color: primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '5h 40m',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$sessions completed sessions',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: 5,
                color: isDark ? Colors.white12 : Colors.black12,
                child: Row(
                  children: [
                    Expanded(
                      flex: 70,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primary.withValues(alpha: 0.6),
                              primary,
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 30),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Goal',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: muted,
                  ),
                ),
                Text(
                  '70%',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVolumeTile({
    required Color ink,
    required Color muted,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Total Volume',
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
            const SizedBox(width: 4),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                size: 17,
                color: Color(0xFF6366F1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '52.4',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: ink,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'tons',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '14,280 kg moved',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: 5,
                color: isDark ? Colors.white12 : Colors.black12,
                child: Row(
                  children: [
                    Expanded(
                      flex: 85,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2DD4BF), Color(0xFF006B5F)],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 15),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pacing',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: muted,
                  ),
                ),
                Text(
                  '85%',
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
