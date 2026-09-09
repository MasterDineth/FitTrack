enum UnitSystem { metric, imperial }
enum BiologicalSex { male, female, other }

class BodyTelemetry {
  final String id;
  final String userId;
  final UnitSystem unitSystem;
  final BiologicalSex biologicalSex;
  final int age;
  final double weight;
  final double height;
  final DateTime recordedAt;

  BodyTelemetry({
    required this.id,
    required this.userId,
    required this.unitSystem,
    required this.biologicalSex,
    required this.age,
    required this.weight,
    required this.height,
    required this.recordedAt,
  });
}
