import 'package:freezed_annotation/freezed_annotation.dart';
import 'achievement_enums.dart';

part 'achievement_entity.freezed.dart';
part 'achievement_entity.g.dart';

@freezed
abstract class AchievementEntity with _$AchievementEntity {
  const factory AchievementEntity({
    required String achievementId,
    required String title,
    required String description,
    required AchievementCategory category,
    required AchievementRarity rarity,
    @Default(0.0) double progress,
    required double target,
    @Default(false) bool completed,
    @Default(0) int rewardXP,
    String? badgeId,
    @Default(false) bool hidden,
    DateTime? completedAt,
    required DateTime createdAt,
  }) = _AchievementEntity;

  factory AchievementEntity.fromJson(Map<String, dynamic> json) =>
      _$AchievementEntityFromJson(json);
}
