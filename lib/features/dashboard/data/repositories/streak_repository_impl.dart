import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../task/domain/entities/streak_entity.dart';
import '../../../task/domain/repositories/streak_repository.dart';

class StreakRepositoryImpl implements StreakRepository {
  final FirebaseFirestore _firestore;

  StreakRepositoryImpl(this._firestore);

  @override
  Stream<StreakEntity?> getStreak(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('streak')
        .doc('current')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return StreakEntity.fromMap(snapshot.data()!);
      }
      return null;
    });
  }

  @override
  Future<void> updateStreak(String userId, StreakEntity streak) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('streak')
        .doc('current')
        .set(streak.toMap(), SetOptions(merge: true));
  }
}
