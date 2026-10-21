import 'package:flutter/material.dart';

import '../../../../domain/entities/muscle_activation.dart';
import '../../../theme/ft_glass.dart';
import '../../../widgets/glass_surface.dart';
import 'activation_ring.dart';
import 'concentric_activation_chart.dart';
import 'details_section_header.dart';

/// Muscles Worked section of the Exercise Details screen.
///
/// Renders the recorded activation breakdown as an animated concentric chart
/// plus one stat card per muscle. The section is omitted entirely when no
/// muscle activations were recorded.
class MusclesWorkedSection extends StatelessWidget {
  const MusclesWorkedSection({
    super.key,
    required this.activations,
  });

  final List<MuscleActivation> activations;

  static const Color _teal = Color(0xFF2DD4BF);
  static const Color _amber = Color(0xFFFEB78B);

  @override
  Widget build(BuildContext context) {
    final primary = context.ftPrimary;
    final isDark = context.isDark;
    final trackColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE7DEFF);

    final colors = _resolveColors(primary);
    final bands = <ActivationBand>[];
    const radii = <double>[66, 52, 39];
    const strokes = <double>[9, 8, 7];

    for (var i = 0; i < activations.length; i++) {
      bands.add(
        ActivationBand(
          progress: activations[i].intensityPercentage / 100,
          color: colors[i],
          radius: radii[i % radii.length],
          strokeWidth: strokes[i % strokes.length],
        ),
      );
    }

    final peak = activations.reduce(
      (a, b) => a.intensityPercentage >= b.intensityPercentage ? a : b,
    );

    return GlassSurface(
      tier: FtGlassTier.glass1,
      radius: FtGlassTheme.radiusHero,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DetailsSectionHeader(
            icon: Icons.monitor_heart_rounded,
            title: 'Muscles Worked',
            subtitle: 'Targeted activation breakdown',
            countLabel:
                '${activations.length} ${activations.length == 1 ? 'group' : 'groups'}',
          ),
          const SizedBox(height: 16),

          // ── Concentric chart ─────────────────────────────────────────
          Center(
            child: ConcentricActivationChart(
              bands: bands,
              trackColor: trackColor,
              child: SizedBox(
                // Matches the inner diameter of the innermost band so the
                // centre readout can never spill over the rings.
                width: 72,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TOTAL PEAK',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: context.ftMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${peak.intensityPercentage}%',
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: FtText.fontFamily,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.6,
                          height: 1.1,
                          color: context.ftInk,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      peak.muscleName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: FtText.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ── Legend ───────────────────────────────────────────────────
          Wrap(
            spacing: 14,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (var i = 0; i < activations.length; i++)
                _LegendItem(
                  color: colors[i],
                  label: activations[i].muscleName,
                ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Per-muscle stat cards ─────────────────────────────────────
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < activations.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _MuscleStatCard(
                      activation: activations[i],
                      color: colors[i],
                      trackColor: trackColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Colours each muscle by its recorded role, falling back to the next free
  /// accent when two muscles share the same role.
  List<Color> _resolveColors(Color primary) {
    const palette = [_teal, _amber];
    final used = <Color>{};
    final result = <Color>[];

    for (final activation in activations) {
      final preferred = switch (activation.role) {
        MuscleRole.agonist => primary,
        MuscleRole.synergist => _teal,
        MuscleRole.stabilizer => _amber,
      };

      if (used.add(preferred)) {
        result.add(preferred);
        continue;
      }

      Color? fallback;
      for (final candidate in palette) {
        if (used.add(candidate)) {
          fallback = candidate;
          break;
        }
      }
      result.add(fallback ?? preferred);
    }

    return result;
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 110),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: context.ftInk,
            ),
          ),
        ),
      ],
    );
  }
}

class _MuscleStatCard extends StatelessWidget {
  const _MuscleStatCard({
    required this.activation,
    required this.color,
    required this.trackColor,
  });

  final MuscleActivation activation;
  final Color color;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    final ink = context.ftInk;
    final muted = context.ftMuted;
    final isDark = context.isDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedActivationRing(
            progress: activation.intensityPercentage / 100,
            color: color,
            trackColor: trackColor,
            strokeWidth: 6,
            size: 50,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${activation.intensityPercentage}%',
                maxLines: 1,
                style: TextStyle(
                  fontFamily: FtText.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: ink,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.20 : 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _roleLabel(activation.role),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: _roleTextColor(activation.role, isDark),
              ),
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              activation.muscleName,
              maxLines: 1,
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: muted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _roleLabel(MuscleRole role) {
    switch (role) {
      case MuscleRole.agonist:
        return 'Prime mover';
      case MuscleRole.synergist:
        return 'Synergist';
      case MuscleRole.stabilizer:
        return 'Stabilizer';
    }
  }

  static Color _roleTextColor(MuscleRole role, bool isDark) {
    switch (role) {
      case MuscleRole.agonist:
        return isDark ? Colors.white : const Color(0xFF4C1D95);
      case MuscleRole.synergist:
        return const Color(0xFF0F766E);
      case MuscleRole.stabilizer:
        return const Color(0xFF9A3412);
    }
  }
}
