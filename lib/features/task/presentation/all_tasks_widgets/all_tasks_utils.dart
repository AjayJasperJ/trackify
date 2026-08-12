import 'package:flutter/material.dart';
import 'package:trackify/features/task/domain/entities/schedule_entity.dart';

String formatTime(DateTime time) {
  final hour = time.hour == 0
      ? 12
      : (time.hour > 12 ? time.hour - 12 : time.hour);
  final period = time.hour >= 12 ? "PM" : "AM";
  final minute = time.minute.toString().padLeft(2, '0');
  return "$hour:$minute $period";
}

/// Human-friendly schedule label, e.g. "Daily", "Weekly", "Monthly".
String scheduleLabel(ScheduleType type) {
  switch (type) {
    case ScheduleType.daily:
      return 'Daily';
    case ScheduleType.weekday:
      return 'Weekly';
    case ScheduleType.monthly:
      return 'Monthly';
    case ScheduleType.yearly:
      return 'Yearly';
    case ScheduleType.interval:
      return 'Interval';
    case ScheduleType.oneTime:
      return 'One-time';
  }
}

(Color, Color) getTagColors(
  String tag, {
  required Color primary,
  required Color secondaryContainer,
}) {
  switch (tag.toUpperCase()) {
    case 'WORK':
    case 'PERSONAL':
      return (secondaryContainer, const Color(0xFF626262));
    case 'DESIGN':
    case 'GROWTH':
      return (primary.withValues(alpha: 0.1), primary);
    case 'GOAL':
      return (primary.withValues(alpha: 0.12), primary);
    case 'MILESTONE':
      return (
        const Color(0xFF43A047).withValues(alpha: 0.12),
        const Color(0xFF2E7D32),
      );
    default:
      return (secondaryContainer, const Color(0xFF626262));
  }
}
