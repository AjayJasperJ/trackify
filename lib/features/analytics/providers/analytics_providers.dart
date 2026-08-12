import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../authentication/providers/auth_controller.dart';
import '../data/repositories/firebase_analytics_repository.dart';
import '../domain/models/analytics_summary.dart';
import '../domain/repositories/analytics_repository.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return FirebaseAnalyticsRepository();
});

final analyticsSummaryProvider = FutureProvider.autoDispose<AnalyticsSummary>((
  ref,
) async {
  final user = ref.watch(authControllerProvider.notifier).currentUser;
  if (user == null) return AnalyticsSummary.empty();
  return ref.watch(analyticsRepositoryProvider).getSummary(user.uid);
});

final weeklyTrendProvider = FutureProvider.autoDispose<List<double>>((
  ref,
) async {
  final user = ref.watch(authControllerProvider.notifier).currentUser;
  if (user == null) return List.filled(7, 0.0);
  return ref
      .watch(analyticsRepositoryProvider)
      .getWeeklyCompletionTrend(user.uid);
});

final heatmapDataProvider = FutureProvider.autoDispose<Map<DateTime, int>>((
  ref,
) async {
  final user = ref.watch(authControllerProvider.notifier).currentUser;
  if (user == null) return {};
  return ref.watch(analyticsRepositoryProvider).getHeatmapData(user.uid);
});
