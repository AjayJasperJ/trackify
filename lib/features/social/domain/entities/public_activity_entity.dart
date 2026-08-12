class PublicCompletedTask {
  final String taskId;
  final String taskTitle;
  final DateTime completedAt;
  final int totalSubtasks;
  final int completedSubtasks;
  final List<Map<String, dynamic>> subtasks;
  final String? mood;

  const PublicCompletedTask({
    required this.taskId,
    required this.taskTitle,
    required this.completedAt,
    this.totalSubtasks = 0,
    this.completedSubtasks = 0,
    this.subtasks = const [],
    this.mood,
  });

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'taskTitle': taskTitle,
      'completedAt': completedAt.toIso8601String(),
      'totalSubtasks': totalSubtasks,
      'completedSubtasks': completedSubtasks,
      'subtasks': subtasks,
      if (mood != null) 'mood': mood,
    };
  }

  factory PublicCompletedTask.fromMap(Map<String, dynamic> map) {
    return PublicCompletedTask(
      taskId: map['taskId'] ?? '',
      taskTitle: map['taskTitle'] ?? '',
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : DateTime.now(),
      totalSubtasks: map['totalSubtasks'] ?? 0,
      completedSubtasks: map['completedSubtasks'] ?? 0,
      subtasks: List<Map<String, dynamic>>.from(map['subtasks'] ?? []),
      mood: map['mood'],
    );
  }
}

class PublicActivityEntity {
  final String date; // yyyy-MM-dd
  final List<PublicCompletedTask> completedTasks;

  const PublicActivityEntity({
    required this.date,
    required this.completedTasks,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'completedTasks': completedTasks.map((t) => t.toMap()).toList(),
    };
  }

  factory PublicActivityEntity.fromMap(Map<String, dynamic> map, String id) {
    return PublicActivityEntity(
      date: id,
      completedTasks: (map['completedTasks'] as List?)
              ?.map((e) => PublicCompletedTask.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }
}
