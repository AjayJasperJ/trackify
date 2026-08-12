import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../utils/model_parse.dart';

class StreakEntity {
  final int currentStreak;
  final int longestStreak;
  final String? lastCompletedDate; // Format: yyyy-MM-dd
  final int totalCompletedDays;
  final DateTime updatedAt;

  StreakEntity({
    required this.currentStreak,
    required this.longestStreak,
    this.lastCompletedDate,
    required this.totalCompletedDays,
    required this.updatedAt,
  });

  factory StreakEntity.fromMap(Map<String, dynamic> map) {
    return StreakEntity(
      currentStreak: ModelParse.toInt(map['currentStreak']),
      longestStreak: ModelParse.toInt(map['longestStreak']),
      lastCompletedDate: map['lastCompletedDate'] != null
          ? ModelParse.toStr(map['lastCompletedDate'])
          : null,
      totalCompletedDays: ModelParse.toInt(map['totalCompletedDays']),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : (ModelParse.toDateNull(map['updatedAt']) ?? DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastCompletedDate': lastCompletedDate,
      'totalCompletedDays': totalCompletedDays,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
