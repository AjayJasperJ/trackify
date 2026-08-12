import '../../../../utils/model_parse.dart';

class SubtaskEntity {
  final String subtaskId;
  final String title;
  final String? description;
  final int order;
  final bool isCompleted;

  const SubtaskEntity({
    required this.subtaskId,
    required this.title,
    this.description,
    required this.order,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'subtaskId': subtaskId,
      'title': title,
      'description': description,
      'order': order,
      'isCompleted': isCompleted,
    };
  }

  factory SubtaskEntity.fromMap(Map<String, dynamic> map) {
    return SubtaskEntity(
      subtaskId: ModelParse.toStr(map['subtaskId']),
      title: ModelParse.toStr(map['title']),
      description: map['description'] != null
          ? ModelParse.toStr(map['description'])
          : null,
      order: ModelParse.toInt(map['order']),
      isCompleted: ModelParse.toBool(map['isCompleted']),
    );
  }

  SubtaskEntity copyWith({
    String? subtaskId,
    String? title,
    String? description,
    int? order,
    bool? isCompleted,
  }) {
    return SubtaskEntity(
      subtaskId: subtaskId ?? this.subtaskId,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
