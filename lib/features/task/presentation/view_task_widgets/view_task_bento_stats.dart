import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/schedule_entity.dart';

class ViewTaskBentoStats extends StatelessWidget {
  final TaskEntity task;
  final Color surfaceContainerLow;
  final Color secondary;
  final Color onSurface;
  final Color primary;
  final Color surfaceVariant;
  final Color onSurfaceVariant;

  const ViewTaskBentoStats({
    super.key,
    required this.task,
    required this.surfaceContainerLow,
    required this.secondary,
    required this.onSurface,
    required this.primary,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
  });

  Widget _buildDayBubble(String letter, bool isActive) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: isActive ? primary : surfaceVariant,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d');
    final timeFormat = DateFormat('h:mm a');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 18, color: secondary),
                      const SizedBox(width: 4),
                      Text(
                        'Due Date',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.effectiveEndDate != null
                        ? dateFormat.format(task.effectiveEndDate!)
                        : dateFormat.format(task.startDate),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Starts at ${timeFormat.format(task.startDate)}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sync, size: 18, color: secondary),
                      const SizedBox(width: 4),
                      Text(
                        'Repeat',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.schedule.type == ScheduleType.daily ? 'Daily' : (task.schedule.type == ScheduleType.weekday ? 'Weekly' : 'Once'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                    ),
                  ),
                  if (task.schedule.type == ScheduleType.weekday && task.schedule is WeekdayScheduleEntity) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildDayBubble('M', (task.schedule as WeekdayScheduleEntity).weekdays.contains(1)),
                        const SizedBox(width: 2),
                        _buildDayBubble('T', (task.schedule as WeekdayScheduleEntity).weekdays.contains(2)),
                        const SizedBox(width: 2),
                        _buildDayBubble('W', (task.schedule as WeekdayScheduleEntity).weekdays.contains(3)),
                        const SizedBox(width: 2),
                        _buildDayBubble('T', (task.schedule as WeekdayScheduleEntity).weekdays.contains(4)),
                        const SizedBox(width: 2),
                        _buildDayBubble('F', (task.schedule as WeekdayScheduleEntity).weekdays.contains(5)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
