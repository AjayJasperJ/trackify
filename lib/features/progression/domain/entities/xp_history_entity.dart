class XPHistoryEntity {
  final String historyId;
  final String date;
  final String? taskId;
  final String source;
  final int baseXP;
  final int bonusXP;
  final int totalXP;
  final String reason;
  final DateTime createdAt;

  const XPHistoryEntity({
    required this.historyId,
    required this.date,
    this.taskId,
    required this.source,
    this.baseXP = 0,
    this.bonusXP = 0,
    required this.totalXP,
    required this.reason,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'historyId': historyId,
      'date': date,
      if (taskId != null) 'taskId': taskId,
      'source': source,
      'baseXP': baseXP,
      'bonusXP': bonusXP,
      'totalXP': totalXP,
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory XPHistoryEntity.fromMap(Map<String, dynamic> map, String id) {
    return XPHistoryEntity(
      historyId: id,
      date: map['date'] ?? '',
      taskId: map['taskId'],
      source: map['source'] ?? '',
      baseXP: map['baseXP']?.toInt() ?? 0,
      bonusXP: map['bonusXP']?.toInt() ?? 0,
      totalXP: map['totalXP']?.toInt() ?? 0,
      reason: map['reason'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }
}
