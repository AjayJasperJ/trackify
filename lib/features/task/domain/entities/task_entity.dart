import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../utils/model_parse.dart';
import 'schedule_entity.dart';
import 'subtask_entity.dart';
import 'task_size.dart';

enum TaskTrackingMode { none, timer, numeric }
enum TaskPriority { none, low, medium, high }

class TaskEntity {
  final String taskId;
  final String title;
  final String? description;
  final String? category;
  final ScheduleEntity schedule;
  final List<SubtaskEntity> subtasks;
  final TaskSize taskSize;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final String? goalId;
  final String? milestoneId;
  final TaskTrackingMode trackingMode;
  final int? expectedDurationMinutes;
  final String? startTimeOfDay;
  final String? endTimeOfDay;
  final TaskPriority priority;
  final double? numericTarget;
  final String? numericUnit;
  final DateTime? storedEffectiveEndDate;
  final bool isPrivate;

  /// The linked goal's target date / milestone's deadline — resolved by
  /// providers (task_state_providers) from the goals/milestones streams.
  /// Null when the task isn't linked, or the linked entity has no date.
  DateTime? linkedGoalTargetDate;
  DateTime? linkedMilestoneDeadline;
  bool linkedGoalCompleted = false;
  bool linkedMilestoneCompleted = false;

  TaskEntity({
    required this.taskId,
    required this.title,
    this.description,
    this.category,
    required this.schedule,
    this.subtasks = const [],
    this.taskSize = TaskSize.medium,
    required this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
    this.goalId,
    this.milestoneId,
    this.trackingMode = TaskTrackingMode.none,
    this.expectedDurationMinutes,
    this.startTimeOfDay,
    this.endTimeOfDay,
    this.priority = TaskPriority.none,
    this.numericTarget,
    this.numericUnit,
    this.storedEffectiveEndDate,
    this.isPrivate = false,
  });

  /// Effective expiry for a linked task:
  /// 1. Linked milestone's deadline wins over everything (most specific).
  /// 2. Otherwise the linked goal's targetDate.
  /// 3. Otherwise the task's own endDate.
  ///
  /// The linked dates are resolved by task_state_providers from the
  /// goals/milestones streams (fields are non-final so providers can enrich
  /// streamed tasks without rebuilding them).
  DateTime? get effectiveEndDate {
    if (linkedMilestoneDeadline != null) return linkedMilestoneDeadline;
    if (linkedGoalTargetDate != null) return linkedGoalTargetDate;
    return storedEffectiveEndDate ?? endDate;
  }

  /// A linked task expires when its goal or milestone is completed, or when
  /// its effective end date has passed.
  bool get isExpired {
    if (linkedGoalCompleted || linkedMilestoneCompleted) return true;
    final end = effectiveEndDate;
    if (end == null) return false;
    final today = DateTime.now();
    final endDay = DateTime(end.year, end.month, end.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    return todayDay.isAfter(endDay);
  }

  factory TaskEntity.fromMap(Map<String, dynamic> map, String id) {
    TaskTrackingMode parseTrackingMode(dynamic val) {
      final str = ModelParse.toStr(val);
      if (str == 'timer') return TaskTrackingMode.timer;
      if (str == 'numeric') return TaskTrackingMode.numeric;
      return TaskTrackingMode.none;
    }

    TaskPriority parsePriority(dynamic val) {
      final str = ModelParse.toStr(val);
      if (str == 'high') return TaskPriority.high;
      if (str == 'low') return TaskPriority.low;
      if (str == 'medium') return TaskPriority.medium;
      return TaskPriority.none;
    }

    return TaskEntity(
      taskId: id,
      title: ModelParse.toStr(map['title']),
      description: map['description'] != null
          ? ModelParse.toStr(map['description'])
          : null,
      category: map['category'] != null
          ? ModelParse.toStr(map['category'])
          : null,
      schedule:
          ModelParse.toModel<ScheduleEntity>(
            map['schedule'],
            ScheduleEntity.fromMap,
          ) ??
          ScheduleEntity.fromMap({'type': 'daily'}),
      subtasks: ModelParse.toModelList<SubtaskEntity>(
        map['subtasks'],
        SubtaskEntity.fromMap,
      ),
      taskSize: map['taskSize'] != null
          ? TaskSizeExtension.fromString(ModelParse.toStr(map['taskSize']))
          : TaskSize.medium,
      startDate: map['startDate'] is Timestamp
          ? (map['startDate'] as Timestamp).toDate()
          : ModelParse.toDate(map['startDate']),
      endDate: map['endDate'] != null
          ? (map['endDate'] is Timestamp
                ? (map['endDate'] as Timestamp).toDate()
                : ModelParse.toDateNull(map['endDate']))
          : null,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : ModelParse.toDate(map['createdAt']),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : ModelParse.toDate(map['updatedAt']),
      isArchived: ModelParse.toBool(map['isArchived']),
      goalId: map['goalId'] as String?,
      milestoneId: map['milestoneId'] as String?,
      trackingMode: parseTrackingMode(map['trackingMode']),
      expectedDurationMinutes: map['expectedDurationMinutes'] != null
          ? ModelParse.toInt(map['expectedDurationMinutes'])
          : null,
      startTimeOfDay: map['startTimeOfDay'] != null
          ? ModelParse.toStr(map['startTimeOfDay'])
          : null,
      endTimeOfDay: map['endTimeOfDay'] != null
          ? ModelParse.toStr(map['endTimeOfDay'])
          : null,
      priority: parsePriority(map['priority']),
      numericTarget: map['numericTarget'] != null ? ModelParse.toDouble(map['numericTarget']) : null,
      numericUnit: map['numericUnit'] != null ? ModelParse.toStr(map['numericUnit']) : null,
      storedEffectiveEndDate: map['effectiveEndDate'] != null
          ? (map['effectiveEndDate'] is Timestamp
                ? (map['effectiveEndDate'] as Timestamp).toDate()
                : ModelParse.toDateNull(map['effectiveEndDate']))
          : null,
      isPrivate: map['isPrivate'] != null ? ModelParse.toBool(map['isPrivate']) : false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'schedule': schedule.toMap(),
      'subtasks': subtasks.map((e) => e.toMap()).toList(),
      'taskSize': taskSize.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isArchived': isArchived,
      'goalId': goalId,
      'milestoneId': milestoneId,
      'trackingMode': trackingMode.name,
      'expectedDurationMinutes': expectedDurationMinutes,
      'startTimeOfDay': startTimeOfDay,
      'endTimeOfDay': endTimeOfDay,
      'priority': priority.name,
      'numericTarget': numericTarget,
      'numericUnit': numericUnit,
      'effectiveEndDate': storedEffectiveEndDate?.toIso8601String() ?? effectiveEndDate?.toIso8601String(),
      'isPrivate': isPrivate,
    };
  }

  TaskEntity copyWith({
    String? taskId,
    String? title,
    String? description,
    String? category,
    ScheduleEntity? schedule,
    List<SubtaskEntity>? subtasks,
    TaskSize? taskSize,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    String? goalId,
    String? milestoneId,
    TaskTrackingMode? trackingMode,
    int? expectedDurationMinutes,
    String? startTimeOfDay,
    String? endTimeOfDay,
    TaskPriority? priority,
    double? numericTarget,
    String? numericUnit,
    DateTime? storedEffectiveEndDate,
    bool? isPrivate,
  }) {
    return TaskEntity(
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      schedule: schedule ?? this.schedule,
      subtasks: subtasks ?? this.subtasks,
      taskSize: taskSize ?? this.taskSize,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      goalId: goalId ?? this.goalId,
      milestoneId: milestoneId ?? this.milestoneId,
      trackingMode: trackingMode ?? this.trackingMode,
      expectedDurationMinutes: expectedDurationMinutes ?? this.expectedDurationMinutes,
      startTimeOfDay: startTimeOfDay ?? this.startTimeOfDay,
      endTimeOfDay: endTimeOfDay ?? this.endTimeOfDay,
      priority: priority ?? this.priority,
      numericTarget: numericTarget ?? this.numericTarget,
      numericUnit: numericUnit ?? this.numericUnit,
      storedEffectiveEndDate: storedEffectiveEndDate ?? this.storedEffectiveEndDate,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }
}
