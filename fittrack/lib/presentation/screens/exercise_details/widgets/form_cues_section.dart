import 'package:flutter/material.dart';

import '../../../../domain/entities/form_cue.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import 'details_section_header.dart';

/// Form Cues section of the Exercise Details screen.
///
/// Shows the recorded "do" and "don't" cues. The section is omitted entirely
/// when no cues were recorded.
class FormCuesSection extends StatelessWidget {
  const FormCuesSection({
    super.key,
    required this.cues,
  });

  final List<FormCue> cues;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      tier: FtGlassTier.glass1,
      radius: FtGlassTheme.radiusHero,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DetailsSectionHeader(
            icon: Icons.verified_rounded,
            title: 'Form Cues',
            subtitle: 'Mental anchors for peak tension',
            countLabel: '${cues.length} ${cues.length == 1 ? 'cue' : 'cues'}',
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < cues.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == cues.length - 1 ? 0 : 10),
              child: _CueTile(cue: cues[i]),
            ),
        ],
      ),
    );
  }
}

class _CueTile extends StatelessWidget {
  const _CueTile({required this.cue});

  final FormCue cue;

  static const Color _positive = Color(0xFF2DD4BF);
  static const Color _negative = Color(0xFFF43F5E);

  @override
  Widget build(BuildContext context) {
    final isPositive = cue.isPositive;
    final accent = isPositive ? _positive : _negative;
    final ink = context.ftInk;
    final muted = context.ftMuted;
    final isDark = context.isDark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.white.withValues(alpha: 0.90),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isDark ? 0.20 : 0.14),
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: Icon(
              isPositive
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              size: 19,
              color: accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      isPositive ? 'DO' : "DON'T",
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: muted.withValues(alpha: 0.20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  cue.description,
                  style: TextStyle(
                    fontFamily: FtText.fontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                    color: ink.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
