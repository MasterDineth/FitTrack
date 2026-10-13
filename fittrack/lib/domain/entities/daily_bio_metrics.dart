/// Represents the daily bio-metric telemetry (Movement, Strain, Recovery).
class DailyBioMetrics {
  final int movementSteps;
  final int movementGoal;
  final double movementPercent; // 0.0 - 1.0+
  final String movementTag;

  final double strainValue;
  final double strainGoal;
  final String strainTag;

  final int recoveryPercent;
  final String recoveryTime;
  final String recoveryTag;

  final DateTime? syncedAt;
  final bool isOptimal;

  const DailyBioMetrics({
    required this.movementSteps,
    required this.movementGoal,
    required this.movementPercent,
    required this.movementTag,
    required this.strainValue,
    required this.strainGoal,
    required this.strainTag,
    required this.recoveryPercent,
    required this.recoveryTime,
    required this.recoveryTag,
    this.syncedAt,
    this.isOptimal = false,
  });

  /// Ratio of strain value to strain goal (capped to 1.0 for ring fill).
  double get strainPercent => strainGoal > 0 ? (strainValue / strainGoal).clamp(0.0, 1.0) : 0.0;
  double get recoveryFraction => (recoveryPercent / 100.0).clamp(0.0, 1.0);
}
