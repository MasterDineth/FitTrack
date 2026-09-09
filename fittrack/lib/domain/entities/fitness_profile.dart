enum PrimaryFocus { hypertrophy, strength, fatLoss }
enum LiftingExperience { beginner, intermediate, advanced }
enum AvailableEquipment { fullGym, barbellDumbbells, homeBodyweight }

class FitnessProfile {
  final String id;
  final String userId;
  final PrimaryFocus primaryFocus;
  final LiftingExperience liftingExperience;
  final int weeklyFrequency;
  final AvailableEquipment availableEquipment;
  final DateTime updatedAt;

  FitnessProfile({
    required this.id,
    required this.userId,
    required this.primaryFocus,
    required this.liftingExperience,
    required this.weeklyFrequency,
    required this.availableEquipment,
    required this.updatedAt,
  });
}
