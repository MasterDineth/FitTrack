import 'package:flutter/material.dart';

import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Floating bottom dock of the Exercise Details screen.
///
/// Replaces the previous "Add to workout" action with a single "Back to
/// workout" control that returns the user to the running session.
///
/// The action card floats directly over the scrolling content — there is no
/// colour scrim above it and no band below it.
class ExerciseDetailsDock extends StatelessWidget {
  const ExerciseDetailsDock({
    super.key,
    required this.onBackToWorkout,
  });

  final VoidCallback onBackToWorkout;

  @override
  Widget build(BuildContext context) {
    final primary = context.ftPrimary;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottomInset),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 361),
          child: GlassSurface(
            tier: FtGlassTier.glassFloating,
            radius: 24,
            // Live: the card floats over scrolling content.
            backdrop: GlassBackdrop.live,
            padding: const EdgeInsets.all(8),
            child: FtPressable(
              onTap: onBackToWorkout,
              pressedScale: 0.97,
              child: Semantics(
                button: true,
                label: 'Back to workout',
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        primary,
                        HSLColor.fromColor(primary)
                            .withLightness(
                              (HSLColor.fromColor(primary).lightness + 0.08)
                                  .clamp(0.0, 1.0),
                            )
                            .toColor(),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Back to workout',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: FtText.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
