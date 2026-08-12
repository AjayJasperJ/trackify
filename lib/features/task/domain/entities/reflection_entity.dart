import '../../../../utils/model_parse.dart';

class ReflectionEntity {
  final String level;
  final String? note;

  const ReflectionEntity({required this.level, this.note});

  Map<String, dynamic> toMap() {
    return {'level': level, 'note': note};
  }

  factory ReflectionEntity.fromMap(Map<String, dynamic> map) {
    final levelParsed = ModelParse.toStr(map['level']);
    return ReflectionEntity(
      level: levelParsed.isNotEmpty ? levelParsed : 'Normal',
      note: map['note'] != null ? ModelParse.toStr(map['note']) : null,
    );
  }
}
