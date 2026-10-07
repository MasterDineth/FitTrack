import '../../core/constants/ft_constants.dart';
import '../../domain/entities/daily_bio_metrics.dart';
import '../../domain/repositories/i_bio_metrics_repository.dart';

class BioMetricsRepositoryImpl implements IBioMetricsRepository {
  final bool useSampleData;

  const BioMetricsRepositoryImpl({this.useSampleData = kUseTemplateSampleData});

  @override
  Future<DailyBioMetrics?> getTodayBioMetrics() async {
    if (!useSampleData) {
      // In release mode without connected health service, return null for empty state
      return null;
    }

    return DailyBioMetrics(
      movementSteps: 6420,
      movementGoal: 8500,
      movementPercent: 0.75,
      movementTag: '+4% yday',
      strainValue: 12.4,
      strainGoal: 14.5,
      strainTag: 'Mod-High',
      recoveryPercent: 92,
      recoveryTime: '7h 48m',
      recoveryTag: 'Prime Day',
      syncedAt: DateTime.now().subtract(const Duration(minutes: 2)),
      isOptimal: true,
    );
  }
}
