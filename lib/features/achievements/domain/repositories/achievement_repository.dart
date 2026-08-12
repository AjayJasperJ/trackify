import '../entities/achievement_entity.dart';
import '../entities/badge_entity.dart';

abstract class AchievementRepository {
  Stream<List<AchievementEntity>> watchUserAchievements(String uid);
  Stream<List<BadgeEntity>> watchUserBadges(String uid);
  Future<void> updateAchievementProgress(String uid, String achievementId, double progress);
  Future<AchievementEntity?> getAchievement(String uid, String achievementId);
  Future<void> saveAchievement(String uid, AchievementEntity achievement);
  Future<void> awardBadge(String uid, BadgeEntity badge);
  Future<void> setFeaturedBadges(String uid, List<String> badgeIds);
}
