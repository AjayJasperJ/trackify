import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/milestone_entity.dart';
import '../../domain/repositories/milestone_repository.dart';

class MilestoneRepositoryImpl implements MilestoneRepository {
  final FirebaseFirestore _firestore;

  MilestoneRepositoryImpl({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> addMilestone(String uid, MilestoneEntity milestone) async {
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(milestone.goalId)
        .collection('milestones')
        .doc();
    final data = milestone.toMap();
    data['milestoneId'] = docRef.id;
    await docRef.set(data);
  }

  @override
  Future<void> updateMilestone(String uid, MilestoneEntity milestone) async {
    // 1. Get the current milestone state from DB to check if deadline changed
    final currentMsSnap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(milestone.goalId)
        .collection('milestones')
        .doc(milestone.milestoneId)
        .get();
        
    DateTime? oldDeadline;
    bool becameCompleted = false;
    if (currentMsSnap.exists && currentMsSnap.data() != null) {
      final data = currentMsSnap.data()!;
      oldDeadline = data['deadline'] != null ? DateTime.parse(data['deadline']) : null;
      final oldCompleted = data['completed'] as bool? ?? false;
      if (milestone.completed && !oldCompleted) {
        becameCompleted = true;
      }
    }

    final batch = _firestore.batch();
    batch.update(
      _firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .doc(milestone.goalId)
          .collection('milestones')
          .doc(milestone.milestoneId),
      milestone.toMap(),
    );

    // If milestone became completed, archive all linked tasks
    if (becameCompleted && currentMsSnap.exists && currentMsSnap.data() != null) {
      final data = currentMsSnap.data()!;
      final linkedTasks = List<String>.from(data['linkedTasks'] ?? []);
      for (final taskId in linkedTasks) {
        batch.update(
          _firestore.collection('users').doc(uid).collection('tasks').doc(taskId),
          {'isArchived': true},
        );
      }
    }

    // If deadline changed, cascade update to tasks linked to this milestone
    if (milestone.deadline != oldDeadline) {
      final tasksSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .where('milestoneId', isEqualTo: milestone.milestoneId)
          .get();

      for (var doc in tasksSnapshot.docs) {
        final taskData = doc.data();
        DateTime? calcEffectiveEndDate = milestone.deadline;

        if (calcEffectiveEndDate == null) {
          // Fallback to goal's targetDate
          final goalSnap = await _firestore.collection('users').doc(uid).collection('goals').doc(milestone.goalId).get();
          if (goalSnap.exists && goalSnap.data() != null) {
            final goalData = goalSnap.data()!;
            calcEffectiveEndDate = goalData['targetDate'] != null ? DateTime.parse(goalData['targetDate']) : null;
          }
        }

        // Fallback to task's own endDate
        calcEffectiveEndDate ??= taskData['endDate'] != null ? DateTime.parse(taskData['endDate']) : null;

        batch.update(doc.reference, {
          'effectiveEndDate': calcEffectiveEndDate?.toIso8601String(),
        });
      }
    }

    await batch.commit();
  }

  @override
  Future<void> deleteMilestone(String uid, String goalId, String milestoneId) async {
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goalId)
        .collection('milestones')
        .doc(milestoneId);
        
    final batch = _firestore.batch();
    batch.delete(docRef);

    // Nullify milestoneId on associated tasks
    final tasksSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .where('milestoneId', isEqualTo: milestoneId)
        .get();
        
    for (var doc in tasksSnapshot.docs) {
      batch.update(doc.reference, {
        'milestoneId': null,
      });
    }

    await batch.commit();
  }

  @override
  Future<MilestoneEntity?> getMilestone(String uid, String goalId, String milestoneId) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goalId)
        .collection('milestones')
        .doc(milestoneId)
        .get();
    if (doc.exists && doc.data() != null) {
      return MilestoneEntity.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  @override
  Future<List<MilestoneEntity>> getMilestones(String uid, String goalId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goalId)
        .collection('milestones')
        .get();
    
    return snapshot.docs.map((doc) => MilestoneEntity.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Stream<List<MilestoneEntity>> watchMilestones(String uid, String goalId) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goalId)
        .collection('milestones')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => MilestoneEntity.fromMap(doc.data(), doc.id)).toList());
  }

  @override
  Stream<List<MilestoneEntity>> watchAllMilestones(String uid) {
    // Requires a collection group index on 'milestones' in Firestore
    return _firestore
        .collectionGroup('milestones')
        .where('createdAt', isNull: false) // dummy filter to force user data scoping, requires more complex setup in prod
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => MilestoneEntity.fromMap(doc.data(), doc.id)).toList());
  }

  @override
  Future<MilestoneEntity?> getMilestoneForTask(String uid, String taskId) async {
    try {
      final snapshot = await _firestore
          .collectionGroup('milestones')
          .where('linkedTasks', arrayContains: taskId)
          .get();
      if (snapshot.docs.isNotEmpty) {
        // Double check the milestone actually belongs to the user by verifying the path
        final doc = snapshot.docs.first;
        if (doc.reference.path.contains('users/$uid/')) {
          return MilestoneEntity.fromMap(doc.data(), doc.id);
        }
      }
    } catch (e) {
      // Collection group queries require an index, if missing, we may fail.
      // In a real app, you'd create the index.
    }
    return null;
  }

  @override
  Future<void> linkTaskToMilestone(
    String uid,
    String goalId,
    String milestoneId,
    String taskId, {
    int weight = 1,
  }) async {
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goalId)
        .collection('milestones')
        .doc(milestoneId);

    await docRef.update({
      'linkedTasks': FieldValue.arrayUnion([taskId]),
      'linkedTasksMeta.$taskId': {
        'taskId': taskId,
        'weight': weight,
        'contribution': 0,
      },
    });
  }
  
  @override
  Future<void> unlinkTaskFromMilestone(String uid, String goalId, String milestoneId, String taskId) async {
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goalId)
        .collection('milestones')
        .doc(milestoneId);
    
    await docRef.update({
      'linkedTasks': FieldValue.arrayRemove([taskId]),
      'linkedTasksMeta.$taskId': FieldValue.delete(),
    });
  }

  @override
  Future<void> updateTaskContribution(String uid, String goalId, String milestoneId, String taskId, int contribution) async {
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goalId)
        .collection('milestones')
        .doc(milestoneId);

    final goalRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goalId);

    // Read milestone references before transaction
    final milestonesSnap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goalId)
        .collection('milestones')
        .get();

    final milestoneRefs = milestonesSnap.docs.map((doc) => doc.reference).toList();

    await _firestore.runTransaction((transaction) async {
      final snap = await transaction.get(docRef);
      if (!snap.exists) return;
      final data = snap.data()!;

      final goalSnap = await transaction.get(goalRef);
      if (!goalSnap.exists) return;
      final goalData = goalSnap.data()!;

      // Fetch other milestone documents transactionally
      final List<DocumentSnapshot> milestoneSnaps = [];
      for (final ref in milestoneRefs) {
        if (ref.id == milestoneId) {
          milestoneSnaps.add(snap);
        } else {
          milestoneSnaps.add(await transaction.get(ref));
        }
      }

      // Read current meta; if this task isn't linked, ignore the update.
      final rawMeta = data['linkedTasksMeta'];
      final Map<String, dynamic> meta = {};
      if (rawMeta is Map) {
        rawMeta.forEach((k, v) {
          if (v is Map) meta[k as String] = Map<String, dynamic>.from(v);
        });
      }
      final entry = meta[taskId];
      if (entry == null) {
        // Task not linked to this milestone — nothing to contribute.
        return;
      }
      final weight = (entry['weight'] ?? 1) as int;

      // Store the contribution (weight when completed, 0 when unchecked).
      meta[taskId] = {
        'taskId': taskId,
        'weight': weight,
        'contribution': contribution > 0 ? weight : 0,
      };

      final linkedTasks = List<String>.from(data['linkedTasks'] ?? []);
      final currentValue = meta.values.fold<int>(
        0,
        (total, e) => total + (((e as Map)['contribution'] ?? 0) as int),
      );
      final doneCount = meta.values.where(
        (e) => (((e as Map)['contribution'] ?? 0) as int) > 0,
      ).length;

      final rule = data['completionRule'] as String?;
      double newProgress;
      bool newCompleted;
      if (rule == 'targetValue') {
        final target = (data['targetValue'] ?? 0) as int;
        newProgress = target == 0 ? 0.0 : (currentValue / target).clamp(0.0, 1.0);
        newCompleted = target > 0 && currentValue >= target;
      } else if (rule == 'manual') {
        // User-controlled; only reflect completion state for completed tasks.
        newProgress = data['progress'] as double? ?? 0.0;
        newCompleted = data['completed'] as bool? ?? false;
      } else {
        // allTasks (default)
        newProgress = linkedTasks.isEmpty ? 0.0 : doneCount / linkedTasks.length;
        newCompleted = linkedTasks.isNotEmpty && doneCount >= linkedTasks.length;
      }

      final wasCompleted = data['completed'] as bool? ?? false;
      if (newCompleted && !wasCompleted) {
        for (final taskId in linkedTasks) {
          final taskRef = _firestore.collection('users').doc(uid).collection('tasks').doc(taskId);
          transaction.update(taskRef, {'isArchived': true});
        }
      }

      transaction.update(docRef, {
        'linkedTasksMeta': meta,
        'currentValue': currentValue,
        'progress': newProgress,
        'completed': newCompleted,
        'completedAt': newCompleted ? DateTime.now().toIso8601String() : null,
      });

      // Calculate parent goal progress
      int completedMilestones = 0;
      for (final msSnap in milestoneSnaps) {
        if (!msSnap.exists) continue;
        final msData = msSnap.data() as Map<String, dynamic>? ?? {};
        final isCompleted = msSnap.id == milestoneId ? newCompleted : (msData['completed'] as bool? ?? false);
        if (isCompleted) {
          completedMilestones++;
        }
      }

      final double newGoalProgress = milestoneRefs.isEmpty ? 0.0 : completedMilestones / milestoneRefs.length;
      
      String newGoalStatus = goalData['status'] ?? 'notStarted';
      if (newGoalProgress == 1.0) {
        newGoalStatus = 'completed';
      } else if (newGoalProgress > 0.0) {
        if (newGoalStatus == 'notStarted') {
          newGoalStatus = 'active';
        }
      } else {
        if (newGoalStatus == 'completed' || newGoalStatus == 'active') {
          newGoalStatus = 'notStarted';
        }
      }

      transaction.update(goalRef, {
        'progress': newGoalProgress,
        'status': newGoalStatus,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    });
  }
  }
