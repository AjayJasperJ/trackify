import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../utils/model_parse.dart';
import 'reflection_entity.dart';

class TaskCompletionEntity {
  final String taskId;
  final bool completed;
  final DateTime? completedAt;
  final ReflectionEntity? reflection;
  final List<String> completedSubtaskIds;

  const TaskCompletionEntity({
    required this.taskId,
    required this.completed,
    this.completedAt,
    this.reflection,
    this.completedSubtaskIds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'completed': completed,
      'completedAt': completedAt?.toIso8601String(),
      'reflection': reflection?.toMap(),
      'completedSubtaskIds': completedSubtaskIds,
    };
  }

  factory TaskCompletionEntity.fromMap(Map<String, dynamic> map) {
    return TaskCompletionEntity(
      taskId: ModelParse.toStr(map['taskId']),
      completed: ModelParse.toBool(map['completed']),
      completedAt: map['completedAt'] is Timestamp
          ? (map['completedAt'] as Timestamp).toDate()
          : ModelParse.toDateNull(map['completedAt']),
      reflection: ModelParse.toModel<ReflectionEntity>(
        map['reflection'],
        ReflectionEntity.fromMap,
      ),
      completedSubtaskIds: ModelParse.toStrList(map['completedSubtaskIds']),
    );
  }

  TaskCompletionEntity copyWith({
    String? taskId,
    bool? completed,
    DateTime? completedAt,
    ReflectionEntity? reflection,
    List<String>? completedSubtaskIds,
  }) {
    return TaskCompletionEntity(
      taskId: taskId ?? this.taskId,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      reflection: reflection ?? this.reflection,
      completedSubtaskIds: completedSubtaskIds ?? this.completedSubtaskIds,
    );
  }
}

class DailyRecordEntity {
  final String dateString; // Format: yyyy-MM-dd
  // Map of taskId to TaskCompletionEntity
  final Map<String, TaskCompletionEntity> completedTasks;

  const DailyRecordEntity({
    required this.dateString,
    required this.completedTasks,
  });

  factory DailyRecordEntity.fromMap(Map<String, dynamic> map, String id) {
    final completionsMap = map['completedTasks'] as Map<String, dynamic>? ?? {};
    final completedTasks = <String, TaskCompletionEntity>{};

    completionsMap.forEach((key, value) {
      if (value is bool) {
        // Migration from old format where it was just a bool
        completedTasks[key] = TaskCompletionEntity(
          taskId: key,
          completed: value,
        );
      } else if (value is Map<String, dynamic>) {
        completedTasks[key] = TaskCompletionEntity.fromMap(value);
      }
    });

    return DailyRecordEntity(dateString: id, completedTasks: completedTasks);
  }

  Map<String, dynamic> toMap() {
    return {
      'completedTasks': completedTasks.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
    };
  }
}
