import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/achievement_entity.dart';
import '../../domain/entities/badge_entity.dart';
import '../../domain/repositories/achievement_repository.dart';

class AchievementRepositoryImpl implements AchievementRepository {
  final FirebaseFirestore _firestore;

  AchievementRepositoryImpl(this._firestore);

  @override
  Stream<List<AchievementEntity>> watchUserAchievements(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('achievements')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AchievementEntity.fromJson(doc.data()))
            .toList());
  }

  @override
  Stream<List<BadgeEntity>> watchUserBadges(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('badges')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BadgeEntity.fromJson(doc.data()))
            .toList());
  }

  @override
  Future<void> updateAchievementProgress(String uid, String achievementId, double progress) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('achievements')
        .doc(achievementId)
        .update({'progress': progress});
  }

  @override
  Future<AchievementEntity?> getAchievement(String uid, String achievementId) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('achievements')
        .doc(achievementId)
        .get();
    
    if (doc.exists && doc.data() != null) {
      return AchievementEntity.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Future<void> saveAchievement(String uid, AchievementEntity achievement) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('achievements')
        .doc(achievement.achievementId)
        .set(achievement.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> awardBadge(String uid, BadgeEntity badge) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('badges')
        .doc(badge.badgeId)
        .set(badge.toJson());
  }

  @override
  Future<void> setFeaturedBadges(String uid, List<String> badgeIds) async {
    final batch = _firestore.batch();
    final badgesRef = _firestore.collection('users').doc(uid).collection('badges');

    final snapshot = await badgesRef.get();
    for (var doc in snapshot.docs) {
      if (badgeIds.contains(doc.id)) {
        batch.update(doc.reference, {'featured': true});
      } else {
        batch.update(doc.reference, {'featured': false});
      }
    }
    
    await batch.commit();
  }
}
