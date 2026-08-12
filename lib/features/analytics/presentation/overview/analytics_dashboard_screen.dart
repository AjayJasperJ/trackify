import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/analytics_providers.dart';
import '../widgets/rounded_line_chart.dart';
import '../widgets/statistic_card.dart';
import '../widgets/heatmap_calendar.dart';
import '../widgets/mood_analysis_card.dart';
import '../widgets/task_comparison_card.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(analyticsSummaryProvider);
    final trendAsync = ref.watch(weeklyTrendProvider);
    final heatmapAsync = ref.watch(heatmapDataProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Analytics'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: summaryAsync.when(
        data: (summary) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick overview stats
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    StatisticCard(
                      title: 'Today',
                      value: '${(summary.todayCompletion * 100).toInt()}%',
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.green,
                    ),
                    StatisticCard(
                      title: 'This Week',
                      value: '${(summary.weeklyCompletion * 100).toInt()}%',
                      icon: Icons.calendar_today,
                      iconColor: Colors.blue,
                    ),
                    StatisticCard(
                      title: 'Current Streak',
                      value: '${summary.currentStreak} Days',
                      icon: Icons.local_fire_department,
                      iconColor: Colors.orange,
                    ),
                    StatisticCard(
                      title: 'Avg Mood',
                      value: summary.averageMood.toStringAsFixed(1),
                      icon: Icons.mood,
                      iconColor: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Weekly trend chart
                trendAsync.when(
                  data: (dataPoints) => RoundedLineChart(
                    title: 'Weekly Productivity Trend',
                    dataPoints: dataPoints,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, _) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 24),

                // Heatmap — wired to real data
                heatmapAsync.when(
                  data: (data) => HeatMapCalendar(title: 'Activity Heatmap', data: data),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, _) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 24),

                MoodAnalysisCard(
                  averageMood: summary.averageMood,
                  trendText: 'Your mood is higher on days with a 100% completion rate.',
                ),

                const SizedBox(height: 24),

                TaskComparisonCard(completionRate: summary.todayCompletion),

                const SizedBox(height: 24),

                // Insights
                Text(
                  'Insights',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _insightCard(
                  context,
                  'You complete ${(summary.monthlyCompletion * 100).toInt()}% of your tasks on average. Keep it up!',
                  Icons.lightbulb_outline,
                ),
                const SizedBox(height: 12),
                _insightCard(
                  context,
                  'Longest streak: ${summary.longestStreak} days. Current: ${summary.currentStreak} days.',
                  Icons.trending_up,
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _insightCard(BuildContext context, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
