import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackify/features/dashboard/providers/dashboard_providers.dart';
import 'package:trackify/features/task/domain/entities/task_entity.dart';
import 'package:trackify/features/progression/providers/progression_providers.dart';

/// Handles task deletion with proper XP reversion.
/// When a task is deleted, all XP earned from completing it must be reverted.
Future<void> handleTaskDeletion({
  required WidgetRef ref,
  required String uid,
  required TaskEntity task,
  required BuildContext context,
}) async {
  // First, revert all XP earned from this task
  final progressionService = ref.read(progressionServiceProvider);
  final revertedXP = await progressionService.revertTaskDeletionXP(
    uid: uid,
    taskId: task.taskId,
  );

  // Then delete the task (archive it)
  await ref.read(taskRepositoryProvider).deleteTask(uid, task.taskId);

  if (!context.mounted) return;

  if (revertedXP > 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task deleted. \$revertedXP XP reverted.')),
    );
  } else {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Task deleted successfully')));
  }
}
