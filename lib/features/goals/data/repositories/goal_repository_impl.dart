import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/goal_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  final FirebaseFirestore _firestore;

  GoalRepositoryImpl({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> addGoal(String uid, GoalEntity goal) async {
    final docRef = _firestore.collection('users').doc(uid).collection('goals').doc();
    final data = goal.toMap();
    data['goalId'] = docRef.id;
    await docRef.set(data);
  }

  @override
  Future<void> updateGoal(String uid, GoalEntity goal) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goal.goalId)
        .update(goal.toMap());
  }

  @override
  Future<void> deleteGoal(String uid, String goalId) async {
    final goalRef = _firestore.collection('users').doc(uid).collection('goals').doc(goalId);
    final milestonesSnapshot = await goalRef.collection('milestones').get();
    
    final batch = _firestore.batch();
    for (var doc in milestonesSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(goalRef);

    // Nullify goalId and milestoneId on associated tasks
    final tasksSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .where('goalId', isEqualTo: goalId)
        .get();
        
    for (var doc in tasksSnapshot.docs) {
      batch.update(doc.reference, {
        'goalId': null,
        'milestoneId': null,
      });
    }

    await batch.commit();
  }

  @override
  Future<GoalEntity?> getGoal(String uid, String goalId) async {
    final doc = await _firestore.collection('users').doc(uid).collection('goals').doc(goalId).get();
    if (doc.exists && doc.data() != null) {
      return GoalEntity.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  @override
  Stream<List<GoalEntity>> watchGoals(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => GoalEntity.fromMap(doc.data(), doc.id)).toList());
  }
}
