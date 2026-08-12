class ProgressionEntity {
  final int currentLevel;
  final int currentXP;
  final int requiredXP;
  final int lifetimeXP;
  final int todayXP;
  final int todayXPRemaining;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletedDate;
  final int perfectDays;
  final int weeklyBonuses;
  final int monthlyBonuses;
  final String rankName;
  final String nextRankName;
  final double focusScore;
  final DateTime updatedAt;

  const ProgressionEntity({
    this.currentLevel = 1,
    this.currentXP = 0,
    this.requiredXP = 100,
    this.lifetimeXP = 0,
    this.todayXP = 0,
    this.todayXPRemaining = 250,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate,
    this.perfectDays = 0,
    this.weeklyBonuses = 0,
    this.monthlyBonuses = 0,
    this.rankName = 'Novice',
    this.nextRankName = 'Apprentice',
    this.focusScore = 0.0,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'currentLevel': currentLevel,
      'currentXP': currentXP,
      'requiredXP': requiredXP,
      'lifetimeXP': lifetimeXP,
      'todayXP': todayXP,
      'todayXPRemaining': todayXPRemaining,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      if (lastCompletedDate != null) 'lastCompletedDate': lastCompletedDate!.toIso8601String(),
      'perfectDays': perfectDays,
      'weeklyBonuses': weeklyBonuses,
      'monthlyBonuses': monthlyBonuses,
      'rankName': rankName,
      'nextRankName': nextRankName,
      'focusScore': focusScore,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ProgressionEntity.fromMap(Map<String, dynamic> map) {
    return ProgressionEntity(
      currentLevel: map['currentLevel']?.toInt() ?? 1,
      currentXP: map['currentXP']?.toInt() ?? 0,
      requiredXP: map['requiredXP']?.toInt() ?? 100,
      lifetimeXP: map['lifetimeXP']?.toInt() ?? 0,
      todayXP: map['todayXP']?.toInt() ?? 0,
      todayXPRemaining: map['todayXPRemaining']?.toInt() ?? 250,
      currentStreak: map['currentStreak']?.toInt() ?? 0,
      longestStreak: map['longestStreak']?.toInt() ?? 0,
      lastCompletedDate: map['lastCompletedDate'] != null ? DateTime.parse(map['lastCompletedDate']) : null,
      perfectDays: map['perfectDays']?.toInt() ?? 0,
      weeklyBonuses: map['weeklyBonuses']?.toInt() ?? 0,
      monthlyBonuses: map['monthlyBonuses']?.toInt() ?? 0,
      rankName: map['rankName'] ?? 'Novice',
      nextRankName: map['nextRankName'] ?? 'Apprentice',
      focusScore: (map['focusScore'] ?? 0.0).toDouble(),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now(),
    );
  }

  ProgressionEntity copyWith({
    int? currentLevel,
    int? currentXP,
    int? requiredXP,
    int? lifetimeXP,
    int? todayXP,
    int? todayXPRemaining,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCompletedDate,
    int? perfectDays,
    int? weeklyBonuses,
    int? monthlyBonuses,
    String? rankName,
    String? nextRankName,
    double? focusScore,
    DateTime? updatedAt,
  }) {
    return ProgressionEntity(
      currentLevel: currentLevel ?? this.currentLevel,
      currentXP: currentXP ?? this.currentXP,
      requiredXP: requiredXP ?? this.requiredXP,
      lifetimeXP: lifetimeXP ?? this.lifetimeXP,
      todayXP: todayXP ?? this.todayXP,
      todayXPRemaining: todayXPRemaining ?? this.todayXPRemaining,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      perfectDays: perfectDays ?? this.perfectDays,
      weeklyBonuses: weeklyBonuses ?? this.weeklyBonuses,
      monthlyBonuses: monthlyBonuses ?? this.monthlyBonuses,
      rankName: rankName ?? this.rankName,
      nextRankName: nextRankName ?? this.nextRankName,
      focusScore: focusScore ?? this.focusScore,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
