import 'package:flutter/material.dart';

import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';

/// Session Notes Card for Workout History Details screen.
class WorkoutDetailNotesCard extends StatelessWidget {
  final String? notes;

  const WorkoutDetailNotesCard({
    super.key,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    final noteText = (notes != null && notes!.trim().isNotEmpty)
        ? notes!.trim()
        : 'Felt great — hit a new bench PR today!';

    return GlassSurface(
      tier: FtGlassTier.glass1,
      radius: FtGlassTheme.radiusCards,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote_rounded,
                size: 18,
                color: context.ftPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                'SESSION NOTES',
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: context.ftMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              '"$noteText"',
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                height: 20 / 14,
                color: context.ftInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
