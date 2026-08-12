import '../models/analytics_summary.dart';

abstract class AnalyticsRepository {
  Future<AnalyticsSummary> getSummary(String userId);
  Future<List<double>> getWeeklyCompletionTrend(String userId);
  /// Returns a map of date → completion intensity (0–4) for the last [days] days.
  Future<Map<DateTime, int>> getHeatmapData(String userId, {int days = 30});
}
