// ignore_for_file: prefer_initializing_formals
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackify/features/achievements/domain/entities/achievement_entity.dart';
import '../domain/entities/badge_entity.dart';
import '../../authentication/providers/auth_provider.dart';
import '../domain/repositories/achievement_repository.dart';
import '../domain/entities/achievement_enums.dart';
import '../../progression/domain/repositories/progression_repository.dart';
import '../../progression/providers/progression_providers.dart';
import '../providers/achievement_providers.dart';

class AchievementService {
  final AchievementRepository _achievementRepository;
  // ignore: unused_field
  final ProgressionRepository _progressionRepository;
  final String _uid;

  AchievementService({
    required AchievementRepository achievementRepository,
    required ProgressionRepository progressionRepository,
    required String uid,
  })  : _achievementRepository = achievementRepository,
        _progressionRepository = progressionRepository,
        _uid = uid;

  Future<List<AchievementEntity>> checkTaskCompletion(int totalTasksCompleted) async {
    final unlocked = <AchievementEntity>[];
    
    // Basic task achievements
    final a1 = await _evaluateAchievement(
      id: 'first_task',
      title: 'First Task',
      description: 'Complete 1 Task',
      category: AchievementCategory.tasks,
      rarity: AchievementRarity.common,
      currentProgress: totalTasksCompleted.toDouble(),
      target: 1,
      rewardXP: 50,
    );
    if (a1 != null) unlocked.add(a1);

    final a2 = await _evaluateAchievement(
      id: 'task_master',
      title: 'Task Master',
      description: 'Complete 100 Tasks',
      category: AchievementCategory.tasks,
      rarity: AchievementRarity.rare,
      currentProgress: totalTasksCompleted.toDouble(),
      target: 100,
      rewardXP: 500,
      badgeId: 'badge_task_master',
    );
    if (a2 != null) unlocked.add(a2);

    return unlocked;
  }

  Future<List<AchievementEntity>> checkGoalCompletion(int totalGoalsCompleted) async {
    final unlocked = <AchievementEntity>[];
    final a1 = await _evaluateAchievement(
      id: 'goal_beginner',
      title: 'Goal Beginner',
      description: 'Complete First Goal',
      category: AchievementCategory.goals,
      rarity: AchievementRarity.common,
      currentProgress: totalGoalsCompleted.toDouble(),
      target: 1,
      rewardXP: 100,
    );
    if (a1 != null) unlocked.add(a1);
    
    return unlocked;
  }

  Future<List<AchievementEntity>> checkStreakUpdate(int currentStreak) async {
    final unlocked = <AchievementEntity>[];
    final a1 = await _evaluateAchievement(
      id: 'first_week_streak',
      title: '🔥 First Week',
      description: '7 Day Streak',
      category: AchievementCategory.streaks,
      rarity: AchievementRarity.rare,
      currentProgress: currentStreak.toDouble(),
      target: 7,
      rewardXP: 300,
      badgeId: 'badge_first_week',
    );
    if (a1 != null) unlocked.add(a1);
    
    return unlocked;
  }

  Future<List<AchievementEntity>> checkLevelUp(int newLevel) async {
    final unlocked = <AchievementEntity>[];
    final a1 = await _evaluateAchievement(
      id: 'reach_level_10',
      title: 'Reach Level 10',
      description: 'Reach Level 10',
      category: AchievementCategory.levels,
      rarity: AchievementRarity.epic,
      currentProgress: newLevel.toDouble(),
      target: 10,
      rewardXP: 1000,
      badgeId: 'badge_level_10',
    );
    if (a1 != null) unlocked.add(a1);
    
    return unlocked;
  }

  Future<AchievementEntity?> _evaluateAchievement({
    required String id,
    required String title,
    required String description,
    required AchievementCategory category,
    required AchievementRarity rarity,
    required double currentProgress,
    required double target,
    required int rewardXP,
    String? badgeId,
  }) async {
    final existingAchievement = await _achievementRepository.getAchievement(_uid, id);
    
    if (existingAchievement != null && existingAchievement.completed) {
      return null;
    }

    final progressToSet = currentProgress > target ? target : currentProgress;
    final isNewlyCompleted = progressToSet >= target;
    
    final updatedAchievement = AchievementEntity(
      achievementId: id,
      title: title,
      description: description,
      category: category,
      rarity: rarity,
      progress: progressToSet,
      target: target,
      completed: isNewlyCompleted,
      rewardXP: rewardXP,
      badgeId: badgeId,
      completedAt: isNewlyCompleted ? DateTime.now() : null,
      createdAt: existingAchievement?.createdAt ?? DateTime.now(),
    );

    await _achievementRepository.saveAchievement(_uid, updatedAchievement);
    
    // We should also award the badge and XP here if it's newly completed.
    if (isNewlyCompleted) {
      if (badgeId != null) {
        await _achievementRepository.awardBadge(_uid, BadgeEntity(
          badgeId: badgeId,
          title: title,
          icon: '',
          rarity: rarity,
          earnedAt: DateTime.now(),
        ));
      }
      return updatedAchievement;
    }
    return null;
  }
}

final achievementServiceProvider = Provider<AchievementService?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;

  return AchievementService(
    achievementRepository: ref.watch(achievementRepositoryProvider),
    progressionRepository: ref.watch(progressionRepositoryProvider),
    uid: user.uid,
  );
});
