import '../../../../utils/model_parse.dart';

enum ScheduleType { daily, monthly, weekday, oneTime, yearly, interval }

abstract class ScheduleEntity {
  final ScheduleType type;

  const ScheduleEntity({required this.type});

  Map<String, dynamic> toMap();

  factory ScheduleEntity.fromMap(Map<String, dynamic> map) {
    final typeString = ModelParse.toStr(map['type']);
    final type = ScheduleType.values.firstWhere(
      (e) => e.name == typeString,
      orElse: () => ScheduleType.oneTime,
    );

    switch (type) {
      case ScheduleType.daily:
        return DailyScheduleEntity();
      case ScheduleType.monthly:
        return MonthlyScheduleEntity(
          days: ModelParse.toIntList(map['days']),
        );
      case ScheduleType.weekday:
        return WeekdayScheduleEntity(
          weekdays: ModelParse.toIntList(map['weekdays']),
        );
      case ScheduleType.yearly:
        return YearlyScheduleEntity(
          dates: ModelParse.toStrList(map['dates']),
        );
      case ScheduleType.interval:
        return IntervalScheduleEntity(
          intervalDays: map['intervalDays'] != null ? ModelParse.toInt(map['intervalDays']) : 1,
        );
      case ScheduleType.oneTime:
        return OneTimeScheduleEntity();
    }
  }
}

class DailyScheduleEntity extends ScheduleEntity {
  const DailyScheduleEntity() : super(type: ScheduleType.daily);

  @override
  Map<String, dynamic> toMap() => {
        'type': type.name,
      };
}

class MonthlyScheduleEntity extends ScheduleEntity {
  final List<int> days; // 1 to 31

  const MonthlyScheduleEntity({required this.days})
      : super(type: ScheduleType.monthly);

  @override
  Map<String, dynamic> toMap() => {
        'type': type.name,
        'days': days,
      };
}

class WeekdayScheduleEntity extends ScheduleEntity {
  final List<int> weekdays; // 1 (Monday) to 7 (Sunday)

  const WeekdayScheduleEntity({required this.weekdays})
      : super(type: ScheduleType.weekday);

  @override
  Map<String, dynamic> toMap() => {
        'type': type.name,
        'weekdays': weekdays,
      };
}

class YearlyScheduleEntity extends ScheduleEntity {
  final List<String> dates; // "MM-DD" format

  const YearlyScheduleEntity({required this.dates})
      : super(type: ScheduleType.yearly);

  @override
  Map<String, dynamic> toMap() => {
        'type': type.name,
        'dates': dates,
      };
}

class IntervalScheduleEntity extends ScheduleEntity {
  final int intervalDays;

  const IntervalScheduleEntity({required this.intervalDays})
      : super(type: ScheduleType.interval);

  @override
  Map<String, dynamic> toMap() => {
        'type': type.name,
        'intervalDays': intervalDays,
      };
}

class OneTimeScheduleEntity extends ScheduleEntity {
  const OneTimeScheduleEntity() : super(type: ScheduleType.oneTime);

  @override
  Map<String, dynamic> toMap() => {
        'type': type.name,
      };
}
