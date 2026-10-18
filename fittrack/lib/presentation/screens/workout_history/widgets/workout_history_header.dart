import 'package:flutter/material.dart';

import '../../../theme/ft_glass.dart';
import '../../../widgets/header/ft_dynamic_header.dart';
import '../../../widgets/header/ft_header_avatar.dart';

/// Top header for Workout History matching the Dashboard navigation bar & actions,
/// featuring universal in-header dynamic island notifications morphing.
class WorkoutHistoryHeader extends StatelessWidget {
  const WorkoutHistoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FtDynamicHeader(
        padding: EdgeInsets.zero,
        leftChild: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'History',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 26,
                height: 32 / 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.65,
                color: context.ftInk,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Track your past sessions & milestones',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.ftMuted,
              ),
            ),
          ],
        ),
        trailing: const FtHeaderAvatar(),
      ),
    );
  }
}
