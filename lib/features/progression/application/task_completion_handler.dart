import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../task/domain/entities/task_entity.dart';
import '../../progression/providers/progression_providers.dart';
import '../../achievements/providers/achievement_providers.dart';
import '../../achievements/presentation/widgets/achievement_unlock_dialog.dart';
import '../../task/providers/task_state_providers.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../social/providers/social_providers.dart';

Future<void> handleTaskCompletion({
  required WidgetRef ref,
  required String uid,
  required TaskEntity task,
  required bool isCompleted,
  required int completedSubtaskCount,
  required BuildContext context,
}) async {
  final publicProfileRepo = ref.read(publicProfileRepositoryProvider);

  if (!isCompleted) {
    final progressionService = ref.read(progressionServiceProvider);
    final dateString = ref.read(currentDateStringProvider);
    
    // Revert progression XP and level
    await progressionService.revertTaskCompletion(
      uid: uid,
      taskId: task.taskId,
      date: dateString,
    );

    // Update public profile stats
    final profile = await publicProfileRepo.getProfile(uid);
    final progression = await progressionService.repository.getProgression(uid);
    if (profile != null && progression != null) {
      await publicProfileRepo.updateProfile(uid, profile.copyWith(
        currentStreak: progression.currentStreak,
        totalCompletedTasks: max(0, profile.totalCompletedTasks - 1),
      ));
    }
    return;
  }

  final progressionService = ref.read(progressionServiceProvider);

  double? moodReflectionLevel;
  final todayRecord = ref.read(todayRecordStreamProvider).valueOrNull;
  if (todayRecord != null) {
    final completion = todayRecord.completedTasks[task.taskId];
    if (completion?.reflection != null) {
      final lvl = completion!.reflection!.level;
      if (lvl == 'Very Low') {
        moodReflectionLevel = 1.0;
      } else if (lvl == 'Low') {
        moodReflectionLevel = 2.0;
      } else if (lvl == 'Normal') {
        moodReflectionLevel = 3.0;
      } else if (lvl == 'Good') {
        moodReflectionLevel = 4.0;
      } else if (lvl == 'Excellent') {
        moodReflectionLevel = 5.0;
      }
    }
  }

  await progressionService.processTaskCompletion(
        uid: uid,
        task: task,
        completedSubtasks: completedSubtaskCount,
        moodReflectionLevel: moodReflectionLevel,
        isFirstTaskOfDay: false,
      );

  // Update public profile stats for completion
  final progression = await progressionService.repository.getProgression(uid);
  final profile = await publicProfileRepo.getProfile(uid);
  if (profile != null && progression != null) {
    await publicProfileRepo.updateProfile(uid, profile.copyWith(
      currentStreak: progression.currentStreak,
      longestStreak: progression.longestStreak,
      totalCompletedTasks: profile.totalCompletedTasks + 1,
    ));
  }

  int completedCount = 0;
  if (todayRecord != null) {
    completedCount = todayRecord.completedTasks.values
        .where((t) => t.completed)
        .length;
  }

  final newlyUnlocked = await ref
      .read(achievementServiceProvider)
      .checkTaskCompletion(completedCount);

  if (newlyUnlocked.isNotEmpty) {
    Future.delayed(const Duration(milliseconds: 600), () async {
      for (final achievement in newlyUnlocked) {
        if (!context.mounted) break;
        await AchievementUnlockDialog.show(context, achievement);
      }
    });
  }
}
