import 'dart:math';
import '../entities/progression_entity.dart';
import '../entities/xp_history_entity.dart';
import '../repositories/progression_repository.dart';
import 'package:trackify/features/task/domain/entities/task_size.dart';

class ProgressionService {
  final ProgressionRepository repository;

  ProgressionService({required this.repository});

  int getBaseXP(TaskSize size) {
    switch (size) {
      case TaskSize.tiny:
        return 5;
      case TaskSize.small:
        return 10;
      case TaskSize.medium:
        return 20;
      case TaskSize.large:
        return 40;
      case TaskSize.huge:
        return 75;
    }
  }

  double getStreakMultiplier(int streak) {
    if (streak >= 365) return 0.50;
    if (streak >= 100) return 0.30;
    if (streak >= 60) return 0.20;
    if (streak >= 30) return 0.15;
    if (streak >= 14) return 0.10;
    if (streak >= 7) return 0.05;
    return 0.0;
  }

  double getLevelBonus(int level) {
    if (level >= 100) return 0.20;
    if (level >= 50) return 0.10;
    if (level >= 40) return 0.08;
    if (level >= 30) return 0.06;
    if (level >= 20) return 0.04;
    if (level >= 10) return 0.02;
    return 0.0;
  }

  int getRequiredXP(int level) {
    return (100 * pow(1.15, level - 1)).round();
  }

  Future<int> processTaskCompletion({
    required String uid,
    required String taskId,
    required TaskSize size,
    required int completedSubtasks,
    bool isFirstTaskOfDay = false,
  }) async {
    ProgressionEntity progression = await repository.getProgression(uid) ?? 
        ProgressionEntity(updatedAt: DateTime.now());

    // Reset daily stats if it's a new day
    final now = DateTime.now();
    bool isNewDay = progression.lastCompletedDate == null || 
        now.difference(progression.lastCompletedDate!).inDays > 0 ||
        now.day != progression.lastCompletedDate!.day;

    if (isNewDay) {
      progression = progression.copyWith(
        todayXP: 0,
        todayXPRemaining: 250,
      );
    }

    double totalGeneratedXP = 0;

    // 1. Base XP
    int baseXP = getBaseXP(size);
    totalGeneratedXP += baseXP;

    // 2. Subtask XP (max 15 per task)
    int subtaskXP = min(completedSubtasks * 3, 15);
    totalGeneratedXP += subtaskXP;

    // 3. Apply Streak Multiplier
    double streakMultiplier = getStreakMultiplier(progression.currentStreak);
    totalGeneratedXP += totalGeneratedXP * streakMultiplier;

    // 4. Apply Level Bonus
    double levelBonus = getLevelBonus(progression.currentLevel);
    totalGeneratedXP += totalGeneratedXP * levelBonus;

    // Calculate subtotal before flat bonuses

    // 5. First Task Bonus
    int firstTaskBonus = 0;
    if (isNewDay || isFirstTaskOfDay) {
      firstTaskBonus = 20;
      totalGeneratedXP += firstTaskBonus;
    }

    int rawXP = totalGeneratedXP.round();

    // Apply Daily XP Cap logic
    int actualAwardedXP = 0;
    int currentTodayXP = progression.todayXP;

    for (int i = 0; i < rawXP; i++) {
      int testXP = currentTodayXP + 1;
      if (testXP <= 250) {
        actualAwardedXP += 1;
        currentTodayXP += 1;
      } else if (testXP <= 350) {
        // 25% efficiency (award 1 XP for every 4 raw XP)
        if (i % 4 == 0) {
          actualAwardedXP += 1;
          currentTodayXP += 1;
        }
      } else {
        // 0 XP after 350
        break;
      }
    }

    if (actualAwardedXP == 0) {
      // Nothing to do if cap exceeded entirely and no XP awarded
      // Still need to update last completed date
      await repository.updateProgression(uid, progression.copyWith(
        lastCompletedDate: now,
        updatedAt: now,
      ));
      return actualAwardedXP;
    }

    // Check Level Up
    int newLevelXP = progression.currentXP + actualAwardedXP;
    int newLevel = progression.currentLevel;
    int requiredXPForNextLevel = progression.requiredXP;

    while (newLevelXP >= requiredXPForNextLevel) {
      newLevelXP -= requiredXPForNextLevel;
      newLevel += 1;
      requiredXPForNextLevel = getRequiredXP(newLevel);
    }

    final updatedProgression = progression.copyWith(
      currentLevel: newLevel,
      currentXP: newLevelXP,
      requiredXP: requiredXPForNextLevel,
      lifetimeXP: progression.lifetimeXP + actualAwardedXP,
      todayXP: currentTodayXP,
      todayXPRemaining: max(0, 250 - currentTodayXP),
      lastCompletedDate: now,
      updatedAt: now,
    );

    await repository.updateProgression(uid, updatedProgression);

    // Save history
    final history = XPHistoryEntity(
      historyId: '', // Set by repo
      date: "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
      taskId: taskId,
      source: 'task_completion',
      baseXP: baseXP,
      bonusXP: actualAwardedXP - baseXP, // Approximate representation
      totalXP: actualAwardedXP,
      reason: 'Task Completion',
      createdAt: now,
    );

    await repository.addXPHistory(uid, history);
    
    return actualAwardedXP;
  }

  Future<int> revertTaskCompletion({
    required String uid,
    required String taskId,
    required String date,
  }) async {
    final xpToRevert = await repository.revertRecentTaskXP(uid, taskId, date);
    if (xpToRevert == null || xpToRevert <= 0) return 0;

    ProgressionEntity? progression = await repository.getProgression(uid);
    if (progression == null) return 0;

    int newLevelXP = progression.currentXP - xpToRevert;
    int newLevel = progression.currentLevel;
    
    while (newLevelXP < 0 && newLevel > 1) {
      newLevel -= 1;
      newLevelXP += getRequiredXP(newLevel);
    }
    
    if (newLevelXP < 0) {
      newLevelXP = 0; // Just in case
    }

    final updatedProgression = progression.copyWith(
      currentLevel: newLevel,
      currentXP: newLevelXP,
      requiredXP: getRequiredXP(newLevel),
      lifetimeXP: max(0, progression.lifetimeXP - xpToRevert),
      todayXP: max(0, progression.todayXP - xpToRevert),
      todayXPRemaining: min(250, progression.todayXPRemaining + xpToRevert),
      updatedAt: DateTime.now(),
    );

    await repository.updateProgression(uid, updatedProgression);
    return xpToRevert;
  }

  Future<int> awardCustomXP(
      String uid, String reason, int amount, String date) async {
    ProgressionEntity progression = await repository.getProgression(uid) ??
        ProgressionEntity(updatedAt: DateTime.now());

    final now = DateTime.now();

    int newLevelXP = progression.currentXP + amount;
    int newLevel = progression.currentLevel;
    int requiredXPForNextLevel = progression.requiredXP;

    while (newLevelXP >= requiredXPForNextLevel) {
      newLevelXP -= requiredXPForNextLevel;
      newLevel += 1;
      requiredXPForNextLevel = getRequiredXP(newLevel);
    }

    final updatedProgression = progression.copyWith(
      currentLevel: newLevel,
      currentXP: newLevelXP,
      requiredXP: requiredXPForNextLevel,
      lifetimeXP: progression.lifetimeXP + amount,
      // We don't add goal/milestone XP to todayXP to avoid capping task XP.
      updatedAt: now,
    );

    await repository.updateProgression(uid, updatedProgression);

    // Save history
    final history = XPHistoryEntity(
      historyId: '', // Set by repo
      date: date,
      taskId: 'custom_reward',
      source: 'custom_reward',
      baseXP: amount,
      bonusXP: 0,
      totalXP: amount,
      reason: reason,
      createdAt: now,
    );

    await repository.addXPHistory(uid, history);
    return amount;
  }

  // Future feature: process streaks, perfect day, weekly bonus etc.
}
