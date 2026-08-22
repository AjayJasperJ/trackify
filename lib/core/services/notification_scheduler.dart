import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_notification_service.dart';
import '../../features/task/domain/entities/task_entity.dart';
import '../../features/task/providers/task_state_providers.dart';

final incompleteTasksProvider = Provider<List<TaskEntity>>((ref) {
  final tasksAsync = ref.watch(todayTasksProvider);
  final recordAsync = ref.watch(todayRecordStreamProvider);

  final tasks = tasksAsync.value ?? [];
  final record = recordAsync.value;
  final completedTaskIds = record?.completedTasks.keys.toSet() ?? {};

  return tasks.where((task) => !completedTaskIds.contains(task.taskId)).toList();
});

final notificationSchedulerProvider = Provider.autoDispose<void>((ref) {
  final service = LocalNotificationService.instance;
  
  // Initialize notification service
  service.initialize();

  // Watch incomplete tasks
  final incompleteTasks = ref.watch(incompleteTasksProvider);

  // Set up a periodic timer to check every 1 minute
  final timer = Timer.periodic(const Duration(seconds: 30), (timer) {
    final now = DateTime.now();

    // 1. Check for tasks ending in 10 minutes
    for (final task in incompleteTasks) {
      if (task.endTimeOfDay != null) {
        final parts = task.endTimeOfDay!.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]);
          final minute = int.tryParse(parts[1]);
          if (hour != null && minute != null) {
            final taskEndTime = DateTime(now.year, now.month, now.day, hour, minute);
            final difference = taskEndTime.difference(now).inMinutes;

            // If the task ends in exactly 10 minutes (between 9 and 10 minutes from now)
            if (difference == 10 || (difference >= 9 && difference < 11)) {
              service.notifyTaskEndingSoon(task.title);
            }
          }
        }
      }
    }

    // 2. Periodically send a random task reminder for active tasks (e.g. 10% chance every 30 seconds)
    // To satisfy "auto notifies users random notification"
    final randomValue = DateTime.now().millisecond % 10;
    if (randomValue == 0 && incompleteTasks.isNotEmpty) {
      service.triggerRandomNotification(incompleteTasks);
    }
  });

  ref.onDispose(() {
    timer.cancel();
  });
});
