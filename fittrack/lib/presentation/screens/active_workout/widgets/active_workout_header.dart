import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fittrack/domain/entities/schedule.dart';
import '../../../providers/active_workout_provider.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Top session header for Active Workout matching Stitch Screen `7e785328b1f24951adf11ae52e15b460`.
///
/// Features:
/// - Minimize button (40x40 circle glass2)
/// - Center: Routine title and isolated elapsed stopwatch timer (watches only elapsedSeconds via `.select`)
/// - Settings / options button (40x40 circle glass2)
class ActiveWorkoutHeader extends StatelessWidget {
  const ActiveWorkoutHeader({
    super.key,
    required this.schedule,
    required this.onMinimize,
    required this.onSettings,
  });

  final Schedule schedule;
  final VoidCallback onMinimize;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final title = schedule.name.isNotEmpty
        ? schedule.name
        : 'Push–Pull–Legs Split';

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Minimize Button
          FtPressable(
            onTap: onMinimize,
            pressedScale: 0.90,
            child: GlassSurface(
              tier: FtGlassTier.glass2,
              radius: 20,
              width: 40,
              height: 40,
              shadow: false,
              alignment: Alignment.center,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 24,
                color: context.ftInk,
              ),
            ),
          ),

          // Center: Title & Isolated Elapsed Stopwatch Timer
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: context.ftInk,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 1),
                const _IsolatedElapsedTimer(),
              ],
            ),
          ),

          // Workout Settings Button
          FtPressable(
            onTap: onSettings,
            pressedScale: 0.90,
            child: GlassSurface(
              tier: FtGlassTier.glass2,
              radius: 20,
              width: 40,
              height: 40,
              shadow: false,
              alignment: Alignment.center,
              child: Icon(
                Icons.settings_outlined,
                size: 20,
                color: context.ftInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Isolated Timer widget watching only `elapsedSeconds` via `.select` so the header/screen
/// doesn't re-render on every second tick per AGENTS.md rule.
class _IsolatedElapsedTimer extends ConsumerWidget {
  const _IsolatedElapsedTimer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elapsedSeconds = ref.watch(
      activeWorkoutProvider.select((s) => s.elapsedSeconds),
    );
    final m = elapsedSeconds ~/ 60;
    final s = elapsedSeconds % 60;
    final formatted =
        '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    return Text(
      formatted,
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: context.ftMuted,
        letterSpacing: 0.2,
      ),
    );
  }
}
