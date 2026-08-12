// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AchievementEntity _$AchievementEntityFromJson(Map<String, dynamic> json) =>
    _AchievementEntity(
      achievementId: json['achievementId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: $enumDecode(_$AchievementCategoryEnumMap, json['category']),
      rarity: $enumDecode(_$AchievementRarityEnumMap, json['rarity']),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      target: (json['target'] as num).toDouble(),
      completed: json['completed'] as bool? ?? false,
      rewardXP: (json['rewardXP'] as num?)?.toInt() ?? 0,
      badgeId: json['badgeId'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AchievementEntityToJson(_AchievementEntity instance) =>
    <String, dynamic>{
      'achievementId': instance.achievementId,
      'title': instance.title,
      'description': instance.description,
      'category': _$AchievementCategoryEnumMap[instance.category]!,
      'rarity': _$AchievementRarityEnumMap[instance.rarity]!,
      'progress': instance.progress,
      'target': instance.target,
      'completed': instance.completed,
      'rewardXP': instance.rewardXP,
      'badgeId': instance.badgeId,
      'hidden': instance.hidden,
      'completedAt': instance.completedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$AchievementCategoryEnumMap = {
  AchievementCategory.consistency: 'consistency',
  AchievementCategory.productivity: 'productivity',
  AchievementCategory.goals: 'goals',
  AchievementCategory.tasks: 'tasks',
  AchievementCategory.streaks: 'streaks',
  AchievementCategory.xp: 'xp',
  AchievementCategory.levels: 'levels',
  AchievementCategory.social: 'social',
  AchievementCategory.milestones: 'milestones',
  AchievementCategory.hidden: 'hidden',
  AchievementCategory.legendary: 'legendary',
  AchievementCategory.seasonal: 'seasonal',
};

const _$AchievementRarityEnumMap = {
  AchievementRarity.common: 'common',
  AchievementRarity.rare: 'rare',
  AchievementRarity.epic: 'epic',
  AchievementRarity.legendary: 'legendary',
  AchievementRarity.mythic: 'mythic',
};
