import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../domain/entities/schedule.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/workout_logic_providers.dart';
import 'ft_pressable.dart';

class FeaturedWorkoutCard extends ConsumerStatefulWidget {
  const FeaturedWorkoutCard({super.key});

  @override
  ConsumerState<FeaturedWorkoutCard> createState() => _FeaturedWorkoutCardState();
}

class _FeaturedWorkoutCardState extends ConsumerState<FeaturedWorkoutCard> {
  bool _isHeroPressed = false;

  @override
  Widget build(BuildContext context) {
    final scheduleRepo = ref.watch(scheduleRepositoryProvider);
    final sessionRepo = ref.watch(workoutSessionRepositoryProvider);
    final recAsync = ref.watch(splitRecommendationProvider(scheduleRepo, sessionRepo));

    final schedule = recAsync.value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Featured Workout',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 18.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: context.ftInk,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GlassSurface(
                  tier: FtGlassTier.glass2,
                  radius: FtGlassTheme.radiusPill,
                  borderTint: context.ftPrimary.withValues(alpha: 0.20),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  shadow: false,
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
                      const SizedBox(width: 4),
                      Text(
                        'RECOMMENDED · TODAY',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.25,
                          color: context.ftPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Workout Card (Radius 26, clipped, adaptive border & shadow)
          RepaintBoundary(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(FtGlassTheme.radiusHero),
                border: Border.all(
                  color: context.isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : Colors.white.withValues(alpha: 0.60),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.isDark ? const Color(0x66000000) : const Color(0x1F1D1735),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(FtGlassTheme.radiusHero),
                child: schedule != null
                    ? _buildActiveWorkoutCard(schedule)
                    : _buildRestDayCard(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveWorkoutCard(Schedule schedule) {
    final title = schedule.name;
    final sub = schedule.description.isNotEmpty
        ? schedule.description
        : 'Compound strength · Hypertrophy stimulus';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 224px Image Area with Press-and-Hold zoom (scale 1 -> 1.05 over 500ms)
        GestureDetector(
          onTapDown: (_) => setState(() => _isHeroPressed = true),
          onTapUp: (_) => setState(() => _isHeroPressed = false),
          onTapCancel: () => setState(() => _isHeroPressed = false),
          child: SizedBox(
            height: 224,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Scalable Photo
                AnimatedScale(
                  scale: _isHeroPressed ? 1.05 : 1.0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  child: Image.asset(
                    'assets/images/dashboard/hero_workout.webp',
                    fit: BoxFit.cover,
                    cacheWidth: 706,
                  ),
                ),

                // Scrim: LinearGradient bottom->top: #1D1735 @0, #1D1735@65% @50%, black@20% @100%
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: const [0.0, 0.50, 1.0],
                      colors: [
                        const Color(0xFF1D1735),
                        const Color(0xFF1D1735).withValues(alpha: 0.65),
                        Colors.black.withValues(alpha: 0.20),
                      ],
                    ),
                  ),
                ),

                // Top Badges at 14
                Positioned(
                  top: 14,
                  left: 14,
                  right: 14,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left: STRENGTH FOCUS
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.30),
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
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'STRENGTH FOCUS',
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right: Moderate-High
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.40),
                          borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.20),
                            width: 1.0,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🔥', style: TextStyle(fontSize: 12)),
                            SizedBox(width: 4),
                            Text(
                              'Moderate-High',
                              style: TextStyle(
                                fontFamily: FtText.fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xF2FFFFFF), // 95%
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Text inside image area (left/right 16, bottom 14)
                Positioned(
                  bottom: 14,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.50, // -0.025em
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.90),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Footer Bar (adaptive glass background and border)
        Container(
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: context.isDark
                ? (context.isOled ? const Color(0xD90E0E14) : const Color(0xD9161226))
                : Colors.white.withValues(alpha: 0.75),
            border: Border(
              top: BorderSide(
                color: context.isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.white.withValues(alpha: 0.60),
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Stats
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: context.ftPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '45 min',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: context.ftInk,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Text(
                        '·',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: context.ftMuted,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 16,
                      color: FtGlassTheme.orange,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '~390 kcal',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: FtGlassTheme.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Primary CTA Button
              FtPressable(
                onTap: () {
                  // Navigate to workouts tab or start active session
                  context.go('/workouts');
                },
                pressedScale: 0.95,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: context.ftPrimary,
                    borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                    boxShadow: [
                      BoxShadow(
                        color: context.ftPrimary.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Start Workout',
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Colors.white,
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

  Widget _buildRestDayCard() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 180,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/dashboard/hero_workout.webp',
                fit: BoxFit.cover,
                cacheWidth: 706,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: const [0.0, 0.6, 1.0],
                    colors: [
                      const Color(0xFF1D1735),
                      const Color(0xFF1D1735).withValues(alpha: 0.8),
                      Colors.black.withValues(alpha: 0.4),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: FtGlassTheme.teal.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                    border: Border.all(
                      color: FtGlassTheme.teal.withValues(alpha: 0.4),
                      width: 1.0,
                    ),
                  ),
                  child: const Text(
                    'ACTIVE RECOVERY',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Positioned(
                bottom: 14,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Rest & Recovery Protocol',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'All scheduled workouts completed for the week. Prioritize mobility and sleep.',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xE6FFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: context.isDark
                ? (context.isOled ? const Color(0xD90E0E14) : const Color(0xD9161226))
                : Colors.white.withValues(alpha: 0.75),
            border: Border(
              top: BorderSide(
                color: context.isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.white.withValues(alpha: 0.60),
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Ready for your next cycle',
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
              const SizedBox(width: 8),
              FtPressable(
                onTap: () => context.go('/workouts'),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: FtGlassTheme.teal,
                    borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                  ),
                  child: const Text(
                    'Explore Routines',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
