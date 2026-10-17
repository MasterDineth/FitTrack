import 'package:flutter/material.dart';

import '../../../theme/ft_glass.dart';
import '../../../widgets/header/ft_dynamic_header.dart';
import '../../../widgets/header/ft_header_avatar.dart';

/// Top header for Dashboard featuring FitTrack brand lockup and universal
/// in-header dynamic island notifications morphing.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return FtDynamicHeader(
      leftChild: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              'assets/images/dashboard/brand_mark.webp',
              width: 32,
              height: 32,
              cacheWidth: 64,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'FitTrack',
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.55,
              color: context.ftInk,
            ),
          ),
        ],
      ),
      trailing: const FtHeaderAvatar(),
    );
  }
}
