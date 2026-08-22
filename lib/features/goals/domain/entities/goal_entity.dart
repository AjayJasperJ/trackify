import 'goal_enums.dart';

class GoalEntity {
  final String goalId;
  final String title;
  final String description;
  final String category;
  final String icon;
  final GoalPriority priority;
  final GoalStatus status;
  final double progress;
  final double currentAmount;
  final double targetAmount;
  final String unit;
  final int earnedXP;
  final int targetXP;
  final DateTime startDate;
  final DateTime? targetDate;
  final DateTime? estimatedCompletion;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool archived;
  final bool isStrict;
  final List<String> linkedTasks;
  final int? durationDays;
  final bool isPrivate;

  const GoalEntity({
    required this.goalId,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    this.priority = GoalPriority.medium,
    this.status = GoalStatus.notStarted,
    this.progress = 0.0,
    this.currentAmount = 0.0,
    this.targetAmount = 0.0,
    this.unit = '',
    this.earnedXP = 0,
    this.targetXP = 0,
    required this.startDate,
    this.targetDate,
    this.estimatedCompletion,
    required this.createdAt,
    required this.updatedAt,
    this.archived = false,
    this.isStrict = false,
    this.linkedTasks = const [],
    this.durationDays,
    this.isPrivate = false,
  });

  /// Identity-independent equality (used for dropdown value matching,
  /// where stream instances differ from prefetched ones).
  bool isEqual(GoalEntity other) => goalId == other.goalId;

  GoalEntity copyWith({
    String? goalId,
    String? title,
    String? description,
    String? category,
    String? icon,
    GoalPriority? priority,
    GoalStatus? status,
    double? progress,
    double? currentAmount,
    double? targetAmount,
    String? unit,
    int? earnedXP,
    int? targetXP,
    DateTime? startDate,
    DateTime? targetDate,
    DateTime? estimatedCompletion,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? archived,
    bool? isStrict,
    List<String>? linkedTasks,
    int? durationDays,
    bool? isPrivate,
  }) {
    return GoalEntity(
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      currentAmount: currentAmount ?? this.currentAmount,
      targetAmount: targetAmount ?? this.targetAmount,
      unit: unit ?? this.unit,
      earnedXP: earnedXP ?? this.earnedXP,
      targetXP: targetXP ?? this.targetXP,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      estimatedCompletion: estimatedCompletion ?? this.estimatedCompletion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archived: archived ?? this.archived,
      isStrict: isStrict ?? this.isStrict,
      linkedTasks: linkedTasks ?? this.linkedTasks,
      durationDays: durationDays ?? this.durationDays,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'goalId': goalId,
      'title': title,
      'description': description,
      'category': category,
      'icon': icon,
      'priority': priority.name,
      'status': status.name,
      'progress': progress,
      'currentAmount': currentAmount,
      'targetAmount': targetAmount,
      'unit': unit,
      'earnedXP': earnedXP,
      'targetXP': targetXP,
      'startDate': startDate.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'estimatedCompletion': estimatedCompletion?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'archived': archived,
      'isStrict': isStrict,
      'linkedTasks': linkedTasks,
      'durationDays': durationDays,
      'isPrivate': isPrivate,
    };
  }

  factory GoalEntity.fromMap(Map<String, dynamic> map, String id) {
    return GoalEntity(
      goalId: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      icon: map['icon'] ?? '',
      priority: GoalPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => GoalPriority.medium,
      ),
      status: GoalStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => GoalStatus.notStarted,
      ),
      progress: (map['progress'] ?? 0.0).toDouble(),
      currentAmount: (map['currentAmount'] ?? 0.0).toDouble(),
      targetAmount: (map['targetAmount'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? '',
      earnedXP: map['earnedXP']?.toInt() ?? 0,
      targetXP: map['targetXP']?.toInt() ?? 0,
      startDate: DateTime.parse(map['startDate']),
      targetDate: map['targetDate'] != null ? DateTime.parse(map['targetDate']) : null,
      estimatedCompletion: map['estimatedCompletion'] != null ? DateTime.parse(map['estimatedCompletion']) : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      archived: map['archived'] ?? false,
      isStrict: map['isStrict'] ?? false,
      linkedTasks: List<String>.from(map['linkedTasks'] ?? []),
      durationDays: map['durationDays']?.toInt(),
      isPrivate: map['isPrivate'] ?? false,
    );
  }
}
