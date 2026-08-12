class AnalyticsSummary {
  final double todayCompletion;
  final double weeklyCompletion;
  final double monthlyCompletion;
  final double yearlyCompletion;
  final int currentStreak;
  final int longestStreak;
  final int currentLevel;
  final int lifetimeXP;
  final int perfectDays;
  final double averageMood;
  final double averageDailyXP;
  final DateTime updatedAt;

  AnalyticsSummary({
    required this.todayCompletion,
    required this.weeklyCompletion,
    required this.monthlyCompletion,
    required this.yearlyCompletion,
    required this.currentStreak,
    required this.longestStreak,
    required this.currentLevel,
    required this.lifetimeXP,
    required this.perfectDays,
    required this.averageMood,
    required this.averageDailyXP,
    required this.updatedAt,
  });

  factory AnalyticsSummary.empty() => AnalyticsSummary(
        todayCompletion: 0.0,
        weeklyCompletion: 0.0,
        monthlyCompletion: 0.0,
        yearlyCompletion: 0.0,
        currentStreak: 0,
        longestStreak: 0,
        currentLevel: 1,
        lifetimeXP: 0,
        perfectDays: 0,
        averageMood: 0.0,
        averageDailyXP: 0.0,
        updatedAt: DateTime.now(),
      );
}
