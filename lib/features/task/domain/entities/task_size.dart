enum TaskSize { tiny, small, medium, large, huge }

extension TaskSizeExtension on TaskSize {
  String get name {
    switch (this) {
      case TaskSize.tiny:
        return 'tiny';
      case TaskSize.small:
        return 'small';
      case TaskSize.medium:
        return 'medium';
      case TaskSize.large:
        return 'large';
      case TaskSize.huge:
        return 'huge';
    }
  }

  static TaskSize fromString(String name) {
    switch (name.toLowerCase()) {
      case 'tiny':
        return TaskSize.tiny;
      case 'small':
        return TaskSize.small;
      case 'medium':
        return TaskSize.medium;
      case 'large':
        return TaskSize.large;
      case 'huge':
        return TaskSize.huge;
      default:
        return TaskSize.medium; // default
    }
  }
}
