import 'package:flutter/material.dart';
import '../../../core/constants/ft_constants.dart';
import '../../widgets/ft_background_painter.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_greeting.dart';
import 'widgets/hydration_banner.dart';
import 'widgets/telemetry_stack.dart';
import 'widgets/featured_workout_card.dart';
import 'widgets/habits_recovery_section.dart';
import 'widgets/lifestyle_masterclass_section.dart';
import 'widgets/weekly_streak_log_section.dart';

/// Flag to ensure the staggered section entrance runs only once per app launch.
bool _kDashboardEntrancePlayed = false;

/// Rebuilt FitTrack Dashboard matching the Stitch design system exactly.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late final AnimationController? _entranceController;
  bool _playEntrance = false;

  @override
  void initState() {
    super.initState();
    if (kDashboardEntranceMotion && !_kDashboardEntrancePlayed) {
      _playEntrance = true;
      _kDashboardEntrancePlayed = true;
      _entranceController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 770), // 7 sections * 60ms + 350ms
      )..forward();
    } else {
      _entranceController = null;
    }
  }

  @override
  void dispose() {
    _entranceController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dock height 58 + bottom margin 16 = 74.0. With BottomNavShell extending body,
    // MediaQuery.paddingOf(context).bottom already includes the dock clearance (74.0 + inset).
    // Adding 16.0 gives clean, balanced breathing room above the dock without dead space.
    final bottomPadding = (MediaQuery.paddingOf(context).bottom > 0)
        ? MediaQuery.paddingOf(context).bottom + 16.0
        : 90.0;

    final sections = [
      const DashboardHeader(),
      const DashboardGreeting(),
      const HydrationBanner(initialVisible: true),
      const TelemetryStack(),
      const FeaturedWorkoutCard(),
      const HabitsRecoverySection(),
      const LifestyleMasterclassSection(),
      const WeeklyStreakLogSection(),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Fixed Non-Scrolling Mesh Background (Rasterised once)
          const Positioned.fill(
            child: FtMeshBackground(),
          ),

          // 2. Centered Content Max-Width 393
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 393),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverSafeArea(
                    top: true,
                    bottom: false,
                    sliver: SliverPadding(
                      padding: EdgeInsets.only(
                        left: 20.0,
                        right: 20.0,
                        top: 0.0,
                        bottom: bottomPadding,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final widget = sections[index];
                            if (!_playEntrance || _entranceController == null) {
                              return widget;
                            }
                            return _buildStaggeredSection(widget, index);
                          },
                          childCount: sections.length,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaggeredSection(Widget child, int index) {
    final start = (index * 60) / 770.0;
    final end = ((index * 60) + 350) / 770.0;

    final animation = CurvedAnimation(
      parent: _entranceController!,
      curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, staticChild) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1.0 - animation.value)),
            child: staticChild,
          ),
        );
      },
      child: child,
    );
  }
}
