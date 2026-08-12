enum GoalStatus {
  notStarted,
  active,
  onTrack,
  atRisk,
  completed,
  failed,
  archived
}

enum GoalPriority {
  low,
  medium,
  high,
  critical
}

extension GoalStatusExtension on GoalStatus {
  String get name {
    switch (this) {
      case GoalStatus.notStarted:
        return 'Not Started';
      case GoalStatus.active:
        return 'Active';
      case GoalStatus.onTrack:
        return 'On Track';
      case GoalStatus.atRisk:
        return 'At Risk';
      case GoalStatus.completed:
        return 'Completed';
      case GoalStatus.failed:
        return 'Failed';
      case GoalStatus.archived:
        return 'Archived';
    }
  }
}
