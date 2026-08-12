import 'package:freezed_annotation/freezed_annotation.dart';
import 'achievement_enums.dart';

part 'badge_entity.freezed.dart';
part 'badge_entity.g.dart';

@freezed
abstract class BadgeEntity with _$BadgeEntity {
  const factory BadgeEntity({
    required String badgeId,
    required String title,
    required String icon,
    required AchievementRarity rarity,
    @Default(false) bool featured,
    required DateTime earnedAt,
  }) = _BadgeEntity;

  factory BadgeEntity.fromJson(Map<String, dynamic> json) =>
      _$BadgeEntityFromJson(json);
}
