import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/public_activity_entity.dart';
import '../../domain/repositories/public_activity_repository.dart';

class FirebasePublicActivityRepository implements PublicActivityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<PublicActivityEntity?> streamActivityForDate(String uid, String date) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('public_activity')
        .doc(date)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return PublicActivityEntity.fromMap(doc.data()!, doc.id);
    });
  }

  @override
  Future<List<PublicActivityEntity>> getRecentActivities(String uid, int limit) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('public_activity')
        .get();
        
    final activities = snapshot.docs.map((doc) => PublicActivityEntity.fromMap(doc.data(), doc.id)).toList();
    activities.sort((a, b) => b.date.compareTo(a.date));
    if (activities.length > limit) {
      return activities.sublist(0, limit);
    }
    return activities;
  }

  @override
  Future<void> recordTaskCompletion(String uid, String date, PublicCompletedTask task) async {
    final docRef = _firestore.collection('users').doc(uid).collection('public_activity').doc(date);
    
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (doc.exists && doc.data() != null) {
        final current = PublicActivityEntity.fromMap(doc.data()!, doc.id);
        final exists = current.completedTasks.any((t) => t.taskId == task.taskId);
        
        if (!exists) {
          transaction.update(docRef, {
            'completedTasks': FieldValue.arrayUnion([task.toMap()])
          });
        }
      } else {
        transaction.set(docRef, {
          'completedTasks': [task.toMap()]
        });
      }
    });
  }
  @override
  Stream<List<PublicActivityEntity>> streamRecentActivities(String uid, int limit) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('public_activity')
        .snapshots()
        .map((snapshot) {
      final activities = snapshot.docs.map((doc) => PublicActivityEntity.fromMap(doc.data(), doc.id)).toList();
      activities.sort((a, b) => b.date.compareTo(a.date));
      if (activities.length > limit) {
        return activities.sublist(0, limit);
      }
      return activities;
    });
  }
}
