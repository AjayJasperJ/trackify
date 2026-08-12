import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trackify/features/task/domain/entities/task_entity.dart';
import 'package:trackify/features/task/domain/entities/schedule_entity.dart';

import 'all_tasks_utils.dart';
import 'all_tasks_interactive_list_task_item.dart';

/// Lists every task that isn't shown in the Today section, so the user can
/// tap to view or long-press to edit/delete regardless of schedule type.
class AllTasksOtherSection extends StatelessWidget {
  final List<TaskEntity> tasks;
  final dynamic dailyRecord;
  final WidgetRef ref;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color surfaceContainerHighest;
  final Color surfaceContainerLow;
  final Color surfaceContainerLowest;
  final Color secondaryContainer;
  final Color outline;
  final Color outlineVariant;
  final Color primary;

  const AllTasksOtherSection({
    super.key,
    required this.tasks,
    required this.dailyRecord,
    required this.ref,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.surfaceContainerHighest,
    required this.surfaceContainerLow,
    required this.surfaceContainerLowest,
    required this.secondaryContainer,
    required this.outline,
    required this.outlineVariant,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Other Schedules",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "${tasks.length}",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...tasks.map((task) {
          final timeText = task.schedule.type == ScheduleType.oneTime
              ? formatTime(task.startDate)
              : "Anytime";
          // Linked tasks show their link as the pill (most specific first):
          // milestone → "MILESTONE", goal → "GOAL". Otherwise the category
          // or schedule type.
          final tag = task.milestoneId != null && task.goalId != null
              ? 'MILESTONE'
              : task.goalId != null
                  ? 'GOAL'
                  : task.category?.toUpperCase() ??
                        task.schedule.type.name.toUpperCase();
          final colors = getTagColors(
            tag,
            primary: primary,
            secondaryContainer: secondaryContainer,
          );
          final isCompleted =
              dailyRecord != null &&
                  dailyRecord.completedTasks[task.taskId]?.completed == true;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: AllTasksInteractiveListTaskItem(
              task: task,
              ref: ref,
              title: task.title,
              timeText: '$timeText • ${scheduleLabel(task.schedule.type)}',
              tag: tag,
              tagColor: colors.$1,
              tagTextColor: colors.$2,
              initialCompleted: isCompleted,
              showCheckbox: false,
              iconData: task.schedule.type == ScheduleType.oneTime
                  ? Icons.schedule
                  : Icons.calendar_today,
              surfaceContainerLowest: surfaceContainerLowest,
              surfaceContainerLow: surfaceContainerLow,
              outline: outline,
              primary: primary,
              onSurface: onSurface,
              onSurfaceVariant: onSurfaceVariant,
            ),
          );
        }),
      ],
    );
  }
}
