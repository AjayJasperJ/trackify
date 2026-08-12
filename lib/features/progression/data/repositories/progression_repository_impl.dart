import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/progression_entity.dart';
import '../../domain/entities/xp_history_entity.dart';
import '../../domain/repositories/progression_repository.dart';

class ProgressionRepositoryImpl implements ProgressionRepository {
  final FirebaseFirestore _firestore;

  ProgressionRepositoryImpl({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<ProgressionEntity?> getProgression(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).collection('progression').doc('current').get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return ProgressionEntity.fromMap(doc.data()!);
  }

  @override
  Future<void> updateProgression(String uid, ProgressionEntity progression) async {
    await _firestore.collection('users').doc(uid).collection('progression').doc('current').set(progression.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> addXPHistory(String uid, XPHistoryEntity history) async {
    final docRef = _firestore.collection('users').doc(uid).collection('xp_history').doc();
    final data = history.toMap();
    data['historyId'] = docRef.id;
    await docRef.set(data);
  }

  @override
  Stream<ProgressionEntity?> watchProgression(String uid) {
    return _firestore.collection('users').doc(uid).collection('progression').doc('current').snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return ProgressionEntity.fromMap(doc.data()!);
    });
  }

  @override
  Stream<List<XPHistoryEntity>> watchXPHistory(String uid, {int limit = 50}) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('xp_history')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => XPHistoryEntity.fromMap(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<int?> revertRecentTaskXP(String uid, String taskId, String date) async {
    try {
      final query = await _firestore
          .collection('users')
          .doc(uid)
          .collection('xp_history')
          .where('taskId', isEqualTo: taskId)
          .where('date', isEqualTo: date)
          .get();

      if (query.docs.isEmpty) {
        return null;
      }

      // Sort in memory to avoid needing a composite index in Firestore
      final docs = query.docs.toList();
      docs.sort((a, b) {
        final dataA = a.data() as Map<String, dynamic>? ?? {};
        final dataB = b.data() as Map<String, dynamic>? ?? {};
        
        final String timeA = dataA['createdAt']?.toString() ?? '';
        final String timeB = dataB['createdAt']?.toString() ?? '';
        
        return timeB.compareTo(timeA); // Descending
      });

      final doc = docs.first;
      final data = doc.data() as Map<String, dynamic>? ?? {};
      
      final dynamic xpRaw = data['totalXP'];
      int xp = 0;
      if (xpRaw is int) {
        xp = xpRaw;
      } else if (xpRaw is double) {
        xp = xpRaw.toInt();
      } else if (xpRaw is String) {
        xp = int.tryParse(xpRaw) ?? 0;
      }
      
      await doc.reference.delete();
      return xp;
    } catch (e) {
      // ignore: avoid_print
      print('Error reverting XP: $e');
      return null;
    }
  }
}
