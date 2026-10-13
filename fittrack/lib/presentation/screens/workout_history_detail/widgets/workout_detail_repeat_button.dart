import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/ft_glass.dart';
import '../../dashboard/widgets/ft_pressable.dart';

/// Floating Repeat Workout button pinned to bottom of Workout History Details screen.
class WorkoutDetailRepeatButton extends StatelessWidget {
  final String scheduleId;

  const WorkoutDetailRepeatButton({
    super.key,
    required this.scheduleId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.0),
            Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.85),
            Theme.of(context).scaffoldBackgroundColor,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: SafeArea(
        top: false,
        child: FtPressable(
          onTap: () {
            HapticFeedback.mediumImpact();
            final targetId = scheduleId.isNotEmpty ? scheduleId : 'sch1';
            context.push('/workouts/active/$targetId');
          },
          pressedScale: 0.97,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.ftPrimary,
                  context.ftPrimaryLight,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(FtGlassTheme.radiusPill),
              boxShadow: [
                BoxShadow(
                  color: context.ftPrimary.withValues(alpha: 0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.replay_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Repeat workout',
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
