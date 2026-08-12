// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BadgeEntity _$BadgeEntityFromJson(Map<String, dynamic> json) => _BadgeEntity(
  badgeId: json['badgeId'] as String,
  title: json['title'] as String,
  icon: json['icon'] as String,
  rarity: $enumDecode(_$AchievementRarityEnumMap, json['rarity']),
  featured: json['featured'] as bool? ?? false,
  earnedAt: DateTime.parse(json['earnedAt'] as String),
);

Map<String, dynamic> _$BadgeEntityToJson(_BadgeEntity instance) =>
    <String, dynamic>{
      'badgeId': instance.badgeId,
      'title': instance.title,
      'icon': instance.icon,
      'rarity': _$AchievementRarityEnumMap[instance.rarity]!,
      'featured': instance.featured,
      'earnedAt': instance.earnedAt.toIso8601String(),
    };

const _$AchievementRarityEnumMap = {
  AchievementRarity.common: 'common',
  AchievementRarity.rare: 'rare',
  AchievementRarity.epic: 'epic',
  AchievementRarity.legendary: 'legendary',
  AchievementRarity.mythic: 'mythic',
};
