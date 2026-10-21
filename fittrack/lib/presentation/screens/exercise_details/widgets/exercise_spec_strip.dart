import 'package:flutter/material.dart';

import '../../../../domain/entities/exercise.dart';
import '../../../../domain/entities/muscle_activation.dart';
import '../../../theme/ft_glass.dart';

/// Quick-spec strip under the hero media.
///
/// Every tile is backed by a recorded value; tiles without data are dropped
/// instead of being rendered empty.
class ExerciseSpecStrip extends StatelessWidget {
  const ExerciseSpecStrip({
    super.key,
    required this.exercise,
    required this.primaryActivation,
  });

  final Exercise exercise;
  final MuscleActivation? primaryActivation;

  @override
  Widget build(BuildContext context) {
    final specs = <_Spec>[];

    final activation = primaryActivation;
    if (activation != null) {
      specs.add(
        _Spec(
          label: 'Primary target',
          value: '${activation.muscleName} ${activation.intensityPercentage}%',
          valueColor: context.ftPrimary,
        ),
      );
    }

    specs.add(
      _Spec(
        label: 'Equipment',
        value: _equipmentLabel(exercise.equipment),
        valueColor: context.ftInk,
      ),
    );

    specs.add(
      _Spec(
        label: 'Movement',
        value: _movementLabel(exercise.movementClassification),
        valueColor: const Color(0xFF0F766E),
      ),
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < specs.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _SpecTile(spec: specs[i])),
          ],
        ],
      ),
    );
  }

  static String _equipmentLabel(Equipment equipment) {
    switch (equipment) {
      case Equipment.barbell:
        return 'Barbell';
      case Equipment.dumbbell:
        return 'Dumbbell';
      case Equipment.cable:
        return 'Cable';
      case Equipment.machine:
        return 'Machine';
      case Equipment.bodyweight:
        return 'Bodyweight';
      case Equipment.other:
        return 'Other';
    }
  }

  static String _movementLabel(MovementClassification classification) {
    switch (classification) {
      case MovementClassification.compound:
        return 'Compound';
      case MovementClassification.isolation:
        return 'Isolation';
      case MovementClassification.calisthenics:
        return 'Calisthenics';
      case MovementClassification.mobility:
        return 'Mobility';
      case MovementClassification.other:
        return 'Other';
    }
  }
}

class _Spec {
  const _Spec({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;
}

class _SpecTile extends StatelessWidget {
  const _SpecTile({required this.spec});

  final _Spec spec;

  @override
  Widget build(BuildContext context) {
    final muted = context.ftMuted;
    final isDark = context.isDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.white.withValues(alpha: 0.85),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            spec.label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: FtText.fontFamily,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: muted,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              spec.value,
              maxLines: 1,
              style: TextStyle(
                fontFamily: FtText.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: spec.valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
