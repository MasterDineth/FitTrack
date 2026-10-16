import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/ft_constants.dart';
import '../../providers/dashboard_providers.dart';
import '../../theme/ft_glass.dart';
import '../../widgets/ft_background_painter.dart';
import '../../widgets/glass_surface.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_greeting.dart';
import 'widgets/notification_shade_overlay.dart';
import 'widgets/telemetry_stack.dart';
import 'widgets/featured_workout_card.dart';
import 'widgets/habits_recovery_section.dart';
import 'widgets/lifestyle_masterclass_section.dart';
import 'widgets/weekly_streak_log_section.dart';

/// Flag to ensure the staggered section entrance runs only once per app launch.
bool _kDashboardEntrancePlayed = false;

/// Rebuilt FitTrack Dashboard with Dynamic Island Notification Header & Frosted Shade.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
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
        duration: const Duration(milliseconds: 770),
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
    final isShadeOpen = ref.watch(
      dashboardNotificationsProvider.select((s) => s.isShadeOpen),
    );

    final bottomPadding = (MediaQuery.paddingOf(context).bottom > 0)
        ? MediaQuery.paddingOf(context).bottom + 16.0
        : 90.0;

    final sections = [
      const _NotificationTestStrip(),
      const DashboardHeader(),
      const DashboardGreeting(),
      const TelemetryStack(),
      const FeaturedWorkoutCard(),
      const HabitsRecoverySection(),
      const LifestyleMasterclassSection(),
      const WeeklyStreakLogSection(),
    ];

    return PopScope(
      canPop: !isShadeOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (isShadeOpen) {
          HapticFeedback.lightImpact();
          ref.read(dashboardNotificationsProvider.notifier).closeShade();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // 1. Fixed Non-Scrolling Mesh Background
            const Positioned.fill(
              child: FtMeshBackground(),
            ),

            // 2. Centered Content Max-Width 393 (Scales subtly when Notification Shade opens)
            AnimatedScale(
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutCubic,
              scale: isShadeOpen ? 0.965 : 1.0,
              child: Center(
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
                                if (!_playEntrance ||
                                    _entranceController == null) {
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
            ),

            // 3. Full-Height Frosted Notification Shade Overlay
            const Positioned.fill(
              child: NotificationShadeOverlay(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaggeredSection(Widget child, int index) {
    final start = (index * 60) / 770.0;
    final end = ((index * 60) + 350) / 770.0;

    final animation = CurvedAnimation(
      parent: _entranceController!,
      curve: Interval(
        start.clamp(0.0, 1.0),
        end.clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
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

/// Compact Frosted Test Bar for triggering Dynamic Island & Shade notifications.
class _NotificationTestStrip extends ConsumerWidget {
  const _NotificationTestStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(dashboardNotificationsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: GlassSurface(
        tier: FtGlassTier.glass2,
        radius: 14.0,
        shadow: false,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TEST PUSH',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: context.ftPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTestChip(
                    context,
                    label: 'Hydrate',
                    onTap: () => notifier.pushPreset(FtNotificationType.hydration),
                  ),
                  const SizedBox(width: 4),
                  _buildTestChip(
                    context,
                    label: 'PR',
                    onTap: () => notifier.pushPreset(FtNotificationType.pr),
                  ),
                  const SizedBox(width: 4),
                  _buildTestChip(
                    context,
                    label: 'Strain',
                    onTap: () => notifier.pushPreset(FtNotificationType.strain),
                  ),
                  const SizedBox(width: 4),
                  _buildTestChip(
                    context,
                    label: 'Reset',
                    isAccent: true,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      notifier.resetDemoItems();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestChip(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    bool isAccent = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isAccent
              ? context.ftPrimary.withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: context.isDark ? 0.08 : 0.75),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: FtText.fontFamily,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isAccent ? context.ftPrimary : context.ftInk,
          ),
        ),
      ),
    );
  }
}
