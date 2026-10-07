import '../entities/daily_bio_metrics.dart';

abstract interface class IBioMetricsRepository {
  Future<DailyBioMetrics?> getTodayBioMetrics();
}
