/// How a milestone decides it is complete.
enum MilestoneCompletionRule {
  /// All linked tasks must be completed.
  allTasks,

  /// currentValue must reach targetValue (tasks contribute weighted amounts).
  targetValue,

  /// User manually marks it complete.
  manual,

  /// Time-based tracking (e.g., track for X days).
  duration,
}

extension MilestoneCompletionRuleX on MilestoneCompletionRule {
  String get key => name; // 'allTasks' | 'targetValue' | 'manual' | 'duration'

  static MilestoneCompletionRule fromString(String? value) {
    return MilestoneCompletionRule.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MilestoneCompletionRule.allTasks,
    );
  }
}

/// Lightweight metadata stored per linked task inside a milestone.
/// Keeps Firestore `linkedTasks` as a plain `List<String>` for arrayContains
/// queries, while this map lets tasks contribute different weights.
class LinkedTaskEntry {
  final String taskId;

  /// Max XP/points this task can contribute to the milestone.
  final int weight;

  /// Actual contribution (populated when task is completed).
  final int contribution;

  const LinkedTaskEntry({
    required this.taskId,
    this.weight = 1,
    this.contribution = 0,
  });

  LinkedTaskEntry copyWith({String? taskId, int? weight, int? contribution}) =>
      LinkedTaskEntry(
        taskId: taskId ?? this.taskId,
        weight: weight ?? this.weight,
        contribution: contribution ?? this.contribution,
      );

  Map<String, dynamic> toMap() => {
        'taskId': taskId,
        'weight': weight,
        'contribution': contribution,
      };

  factory LinkedTaskEntry.fromMap(Map<String, dynamic> map) => LinkedTaskEntry(
        taskId: map['taskId'] as String,
        weight: (map['weight'] ?? 1) as int,
        contribution: (map['contribution'] ?? 0) as int,
      );

  @override
  String toString() => 'LinkedTaskEntry($taskId, w=$weight, c=$contribution)';
}

class MilestoneEntity {
  final String milestoneId;
  final String goalId;
  final String title;
  final String description;
  final double progress;
  final bool completed;

  /// Plain task-ID list — kept for Firestore `arrayContains` queries.
  List<String> get linkedTasks => linkedTasksMeta.keys.toList();

  /// Weighted metadata per task — keyed by taskId.
  final Map<String, LinkedTaskEntry> linkedTasksMeta;

  /// How this milestone decides it is complete.
  final MilestoneCompletionRule completionRule;

  final int? targetValue;
  final int currentValue;
  final DateTime? deadline;
  final DateTime? completedAt;
  final DateTime createdAt;

  const MilestoneEntity({
    required this.milestoneId,
    required this.goalId,
    required this.title,
    required this.description,
    this.progress = 0.0,
    this.completed = false,
    this.linkedTasksMeta = const {},
    this.completionRule = MilestoneCompletionRule.allTasks,
    this.targetValue,
    this.currentValue = 0,
    this.deadline,
    this.completedAt,
    required this.createdAt,
  });

  // ── Derived helpers ────────────────────────────────────────────────────────

  int get totalWeight =>
      linkedTasksMeta.values.fold(0, (s, e) => s + e.weight);

  int get totalContribution =>
      linkedTasksMeta.values.fold(0, (s, e) => s + e.contribution);

  /// Recomputes progress from meta (0.0–1.0).
  double get computedProgress {
    switch (completionRule) {
      case MilestoneCompletionRule.allTasks:
        if (linkedTasks.isEmpty) return 0.0;
        final done =
            linkedTasksMeta.values.where((e) => e.contribution > 0).length;
        return done / linkedTasks.length;
      case MilestoneCompletionRule.targetValue:
        if (targetValue == null || targetValue == 0) return 0.0;
        return (currentValue / targetValue!).clamp(0.0, 1.0);
      case MilestoneCompletionRule.duration:
        if (targetValue == null || targetValue == 0) return 0.0;
        final daysPassed = DateTime.now().difference(createdAt).inDays;
        return (daysPassed / targetValue!).clamp(0.0, 1.0);
      case MilestoneCompletionRule.manual:
        return progress;
    }
  }

  /// Identity-independent equality (used for dropdown value matching,
  /// where stream instances differ from prefetched ones).
  bool isEqual(MilestoneEntity other) => milestoneId == other.milestoneId;

  // ── copyWith ───────────────────────────────────────────────────────────────

  MilestoneEntity copyWith({
    String? milestoneId,
    String? goalId,
    String? title,
    String? description,
    double? progress,
    bool? completed,
    Map<String, LinkedTaskEntry>? linkedTasksMeta,
    MilestoneCompletionRule? completionRule,
    int? targetValue,
    int? currentValue,
    DateTime? deadline,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return MilestoneEntity(
      milestoneId: milestoneId ?? this.milestoneId,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      description: description ?? this.description,
      progress: progress ?? this.progress,
      completed: completed ?? this.completed,
      linkedTasksMeta: linkedTasksMeta ?? this.linkedTasksMeta,
      completionRule: completionRule ?? this.completionRule,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      deadline: deadline ?? this.deadline,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ── Serialization ──────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      'milestoneId': milestoneId,
      'goalId': goalId,
      'title': title,
      'description': description,
      'progress': progress,
      'completed': completed,
      'linkedTasks': linkedTasks,
      'linkedTasksMeta':
          linkedTasksMeta.map((k, v) => MapEntry(k, v.toMap())),
      'completionRule': completionRule.key,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'deadline': deadline?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MilestoneEntity.fromMap(Map<String, dynamic> map, String id) {
    // Parse weighted meta map
    final rawMeta = map['linkedTasksMeta'];
    final Map<String, LinkedTaskEntry> meta = {};
    if (rawMeta is Map) {
      rawMeta.forEach((k, v) {
        if (v is Map) {
          meta[k as String] = LinkedTaskEntry.fromMap(
            Map<String, dynamic>.from(v),
          );
        }
      });
    }

    // Back-fill meta from plain linkedTasks if meta is missing
    final rawTasks = List<String>.from(map['linkedTasks'] ?? []);
    for (final taskId in rawTasks) {
      meta.putIfAbsent(taskId, () => LinkedTaskEntry(taskId: taskId));
    }

    return MilestoneEntity(
      milestoneId: id,
      goalId: map['goalId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      progress: (map['progress'] ?? 0.0).toDouble(),
      completed: map['completed'] ?? false,
      linkedTasksMeta: meta,
      completionRule:
          MilestoneCompletionRuleX.fromString(map['completionRule'] as String?),
      targetValue: map['targetValue']?.toInt(),
      currentValue: map['currentValue']?.toInt() ?? 0,
      deadline:
          map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
