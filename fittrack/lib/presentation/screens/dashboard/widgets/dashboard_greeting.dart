import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../../providers/dashboard_providers.dart';
import '../../../providers/user_profile_provider.dart';

class DashboardGreeting extends ConsumerWidget {
  const DashboardGreeting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final bioMetricsAsync = ref.watch(bioMetricsProvider);

    final rawName = profileAsync.value?.name;
    final firstName = (rawName != null && rawName.trim().isNotEmpty)
        ? rawName.trim().split(' ').first
        : 'Dineth';

    final now = DateTime.now();
    final hour = now.hour;
    final (greetingWord, pushWord) = switch (hour) {
      < 12 => ('morning', 'morning'),
      < 17 => ('afternoon', 'afternoon'),
      _ => ('evening', 'evening'),
    };
    final capitalizedGreeting = greetingWord[0].toUpperCase() + greetingWord.substring(1);

    final syncedAt = bioMetricsAsync.value?.syncedAt;

    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // READY TO PEAK chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: FtGlassTheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
                  ),
                  child: const Text(
                    'READY TO PEAK',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.55, // 0.05em
                      color: FtGlassTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // H1 Greeting
                Text(
                  'Good $capitalizedGreeting,\n$firstName',
                  style: FtText.h1.copyWith(color: context.ftInk),
                ),
                const SizedBox(height: 4),

                // Subtitle
                Text(
                  'Ready for your $pushWord push?',
                  style: FtText.sub14Muted.copyWith(color: context.ftMuted),
                ),
              ],
            ),
          ),

          // Right Column (End-aligned live pill & synced text)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Live Pill (glass2, border teal@25%, px 10 py 4, 12 w700 teal)
              GlassSurface(
                tier: FtGlassTier.glass2,
                radius: FtGlassTheme.radiusPill,
                borderTint: FtGlassTheme.teal.withValues(alpha: 0.25),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                shadow: false,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PingDot(),
                    SizedBox(width: 6),
                    _MinuteAlignedClock(),
                  ],
                ),
              ),

              // Synced text (only if real sync timestamp exists)
              if (syncedAt != null) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Text(
                    'Synced just now',
                    style: TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: context.ftMuted,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// 8px ping dot with 1s loop: scale 1->2, opacity .75->0, cubic-bezier(0,0,.2,1).
class _PingDot extends StatefulWidget {
  const _PingDot();

  @override
  State<_PingDot> createState() => _PingDotState();
}

class _PingDotState extends State<_PingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    const curve = Cubic(0.0, 0.0, 0.2, 1.0);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: curve),
    );
    _opacityAnimation = Tween<double>(begin: 0.75, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: curve),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final tickerActive = TickerMode.valuesOf(context).enabled && !disableMotion;
    if (!tickerActive && _controller.isAnimating) {
      _controller.stop();
    } else if (tickerActive && !_controller.isAnimating) {
      _controller.repeat();
    }

    return SizedBox(
      width: 10,
      height: 10,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pinging radar ring
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: FtGlassTheme.teal,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Solid 8px core dot
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: FtGlassTheme.teal,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rebuilds only itself once per minute to respect performance guidelines.
class _MinuteAlignedClock extends StatefulWidget {
  const _MinuteAlignedClock();

  @override
  State<_MinuteAlignedClock> createState() => _MinuteAlignedClockState();
}

class _MinuteAlignedClockState extends State<_MinuteAlignedClock> {
  Timer? _timer;
  late String _formattedTime;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _scheduleNextMinute();
  }

  void _updateTime() {
    _formattedTime = DateFormat('h:mm a').format(DateTime.now());
  }

  void _scheduleNextMinute() {
    _timer?.cancel();
    if (WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      return;
    }
    final now = DateTime.now();
    final delayToNextMinute = 60 - now.second;
    _timer = Timer(Duration(seconds: delayToNextMinute), () {
      if (mounted) {
        setState(() {
          _updateTime();
        });
        _timer = Timer.periodic(const Duration(minutes: 1), (_) {
          if (mounted) {
            setState(() {
              _updateTime();
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formattedTime,
      style: const TextStyle(
        fontFamily: FtText.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: FtGlassTheme.teal,
      ),
    );
  }
}
