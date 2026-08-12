import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/analytics_summary.dart';
import '../../domain/repositories/analytics_repository.dart';

class FirebaseAnalyticsRepository implements AnalyticsRepository {
  final FirebaseFirestore _firestore;

  FirebaseAnalyticsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<AnalyticsSummary> getSummary(String userId) async {
    final docSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('analytics')
        .doc('summary')
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      return AnalyticsSummary(
        todayCompletion: (data['todayCompletion'] as num?)?.toDouble() ?? 0.0,
        weeklyCompletion: (data['weeklyCompletion'] as num?)?.toDouble() ?? 0.0,
        monthlyCompletion: (data['monthlyCompletion'] as num?)?.toDouble() ?? 0.0,
        yearlyCompletion: (data['yearlyCompletion'] as num?)?.toDouble() ?? 0.0,
        currentStreak: (data['currentStreak'] as num?)?.toInt() ?? 0,
        longestStreak: (data['longestStreak'] as num?)?.toInt() ?? 0,
        currentLevel: (data['currentLevel'] as num?)?.toInt() ?? 1,
        lifetimeXP: (data['lifetimeXP'] as num?)?.toInt() ?? 0,
        perfectDays: (data['perfectDays'] as num?)?.toInt() ?? 0,
        averageMood: (data['averageMood'] as num?)?.toDouble() ?? 0.0,
        averageDailyXP: (data['averageDailyXP'] as num?)?.toDouble() ?? 0.0,
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }
    return AnalyticsSummary.empty();
  }

  @override
  Future<List<double>> getWeeklyCompletionTrend(String userId) async {
    final now = DateTime.now();
    final weekStart = now.subtract(const Duration(days: 6));
    final weekTrend = List.filled(7, 0.0);

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('analytics_history')
          .where('date', isGreaterThanOrEqualTo: weekStart.toIso8601String().substring(0, 10))
          .orderBy('date')
          .get();

      final docs = querySnapshot.docs;

      for (int i = 0; i < 7; i++) {
        final dateString = now.subtract(Duration(days: 6 - i)).toIso8601String().substring(0, 10);
        final doc = docs.where((d) => d.id == dateString).firstOrNull;
        if (doc != null) {
          weekTrend[i] = (doc['completionRate'] as num?)?.toDouble() ?? 0.0;
        }
      }
    } catch (e) {
      debugPrint('Error fetching weekly trend: $e');
    }

    return weekTrend;
  }

  @override
  Future<Map<DateTime, int>> getHeatmapData(String userId, {int days = 30}) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days - 1));
    final result = <DateTime, int>{};

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('analytics_history')
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String().substring(0, 10))
          .orderBy('date')
          .get();

      for (final doc in querySnapshot.docs) {
        final rate = (doc['completionRate'] as num?)?.toDouble() ?? 0.0;
        // Map 0.0–1.0 completion rate to intensity 0–4
        final intensity = (rate * 4).round();
        // Parse the date string from doc id (yyyy-MM-dd)
        final parts = doc.id.split('-');
        if (parts.length == 3) {
          final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          result[date] = intensity;
        }
      }
    } catch (e) {
      debugPrint('Error fetching heatmap data: $e');
    }

    return result;
  }
}
