import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/entities/goal_enums.dart';
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
    // 1. Get the current goal state from DB to check if targetDate changed or status changed
    final currentGoalSnap = await _firestore.collection('users').doc(uid).collection('goals').doc(goal.goalId).get();
    DateTime? oldTargetDate;
    bool becameCompleted = false;
    if (currentGoalSnap.exists && currentGoalSnap.data() != null) {
      final data = currentGoalSnap.data()!;
      oldTargetDate = data['targetDate'] != null ? DateTime.parse(data['targetDate']) : null;
      final oldStatus = data['status'] as String?;
      if (goal.status == GoalStatus.completed && oldStatus != 'completed') {
        becameCompleted = true;
      }
    }

    final batch = _firestore.batch();
    batch.update(
      _firestore.collection('users').doc(uid).collection('goals').doc(goal.goalId),
      goal.toMap(),
    );

    // If targetDate changed or status became completed, cascade update to tasks
    final targetDateChanged = goal.targetDate != oldTargetDate;
    if (targetDateChanged || becameCompleted) {
      final tasksSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .where('goalId', isEqualTo: goal.goalId)
          .get();

      for (var doc in tasksSnapshot.docs) {
        final taskData = doc.data();
        final updates = <String, dynamic>{};

        if (becameCompleted) {
          updates['isArchived'] = true;
        }

        if (targetDateChanged) {
          final milestoneId = taskData['milestoneId'] as String?;
          DateTime? calcEffectiveEndDate = goal.targetDate;

          if (milestoneId != null) {
            // Fetch the milestone to see if it has a deadline
            final msSnap = await _firestore
                .collection('users')
                .doc(uid)
                .collection('goals')
                .doc(goal.goalId)
                .collection('milestones')
                .doc(milestoneId)
                .get();
            if (msSnap.exists && msSnap.data() != null) {
              final msData = msSnap.data()!;
              final msDeadline = msData['deadline'] != null ? DateTime.parse(msData['deadline']) : null;
              if (msDeadline != null) {
                calcEffectiveEndDate = msDeadline;
              }
            }
          }

          // If no milestone deadline overrides it, fall back to the goal's targetDate or the task's own endDate
          calcEffectiveEndDate ??= taskData['endDate'] != null ? DateTime.parse(taskData['endDate']) : null;

          updates['effectiveEndDate'] = calcEffectiveEndDate?.toIso8601String();
        }

        if (updates.isNotEmpty) {
          batch.update(doc.reference, updates);
        }
      }
    }

    await batch.commit();
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
