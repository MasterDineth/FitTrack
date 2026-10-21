import 'package:flutter/material.dart';

import '../../../../domain/entities/execution_step.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import 'details_section_header.dart';

/// Execution Steps section of the Exercise Details screen.
///
/// Renders the recorded steps as a connected timeline. The section is omitted
/// entirely when no steps were recorded.
class ExecutionStepsSection extends StatelessWidget {
  const ExecutionStepsSection({
    super.key,
    required this.steps,
  });

  final List<ExecutionStep> steps;

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
            icon: Icons.format_list_numbered_rounded,
            title: 'Execution Steps',
            subtitle: 'Step-by-step movement cadence',
            countLabel: '${steps.length} ${steps.length == 1 ? 'step' : 'steps'}',
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < steps.length; i++)
            _StepTile(
              step: steps[i],
              isLast: i == steps.length - 1,
              accent: _accentFor(context, i),
            ),
        ],
      ),
    );
  }

  Color _accentFor(BuildContext context, int index) {
    const accents = <Color>[
      Color(0xFF2DD4BF),
      Color(0xFF14B8A6),
      Color(0xFFF59E0B),
    ];
    return accents[index % accents.length];
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.step,
    required this.isLast,
    required this.accent,
  });

  final ExecutionStep step;
  final bool isLast;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final ink = context.ftInk;
    final muted = context.ftMuted;
    final isDark = context.isDark;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Timeline gutter ───────────────────────────────────────────
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.32),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${step.stepNumber}',
                    style: const TextStyle(
                      fontFamily: FtText.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              accent.withValues(alpha: 0.55),
                              accent.withValues(alpha: 0.12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ── Step body ─────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Container(
                width: double.infinity,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (step.title.trim().isNotEmpty) ...[
                      Text(
                        step.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (step.instructions.trim().isNotEmpty)
                      Text(
                        step.instructions,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                          color: muted,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
