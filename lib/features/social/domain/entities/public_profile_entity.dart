class PublicProfileEntity {
  final String displayName;
  final String? photoUrl;
  final String? bio;
  final int currentStreak;
  final int longestStreak;
  final double todayCompletion;
  final double weeklyCompletion;
  final double monthlyCompletion;
  final double overallCompletion;
  final int totalCompletedTasks;
  final DateTime updatedAt;

  int get level => (totalCompletedTasks ~/ 10) + 1;

  const PublicProfileEntity({
    required this.displayName,
    this.photoUrl,
    this.bio,
    required this.currentStreak,
    required this.longestStreak,
    required this.todayCompletion,
    required this.weeklyCompletion,
    required this.monthlyCompletion,
    required this.overallCompletion,
    required this.totalCompletedTasks,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'todayCompletion': todayCompletion,
      'weeklyCompletion': weeklyCompletion,
      'monthlyCompletion': monthlyCompletion,
      'overallCompletion': overallCompletion,
      'totalCompletedTasks': totalCompletedTasks,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PublicProfileEntity.fromMap(Map<String, dynamic> map) {
    return PublicProfileEntity(
      displayName: map['displayName'] ?? 'Unknown User',
      photoUrl: map['photoUrl'],
      bio: map['bio'],
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      todayCompletion: (map['todayCompletion'] ?? 0.0).toDouble(),
      weeklyCompletion: (map['weeklyCompletion'] ?? 0.0).toDouble(),
      monthlyCompletion: (map['monthlyCompletion'] ?? 0.0).toDouble(),
      overallCompletion: (map['overallCompletion'] ?? 0.0).toDouble(),
      totalCompletedTasks: map['totalCompletedTasks'] ?? 0,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now(),
    );
  }

  PublicProfileEntity copyWith({
    String? displayName,
    String? photoUrl,
    String? bio,
    int? currentStreak,
    int? longestStreak,
    double? todayCompletion,
    double? weeklyCompletion,
    double? monthlyCompletion,
    double? overallCompletion,
    int? totalCompletedTasks,
    DateTime? updatedAt,
  }) {
    return PublicProfileEntity(
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      todayCompletion: todayCompletion ?? this.todayCompletion,
      weeklyCompletion: weeklyCompletion ?? this.weeklyCompletion,
      monthlyCompletion: monthlyCompletion ?? this.monthlyCompletion,
      overallCompletion: overallCompletion ?? this.overallCompletion,
      totalCompletedTasks: totalCompletedTasks ?? this.totalCompletedTasks,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
