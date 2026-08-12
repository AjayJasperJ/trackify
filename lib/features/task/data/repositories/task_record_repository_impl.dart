import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/daily_record_entity.dart';
import '../../domain/repositories/task_record_repository.dart';
import '../../../goals/domain/repositories/milestone_repository.dart';

import '../../domain/entities/reflection_entity.dart';

import '../../domain/entities/task_entity.dart';

class TaskRecordRepositoryImpl implements TaskRecordRepository {
  final FirebaseFirestore _firestore;
  final MilestoneRepository _milestoneRepository;

  TaskRecordRepositoryImpl(this._firestore, this._milestoneRepository);

  @override
  Stream<DailyRecordEntity?> getDailyRecord(String userId, String dateString) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('task_records')
        .doc(dateString)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return DailyRecordEntity.fromMap(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }

  @override
  Future<void> toggleTaskCompletion(String userId, String dateString, TaskEntity task, bool isCompleted, {ReflectionEntity? reflection, List<String> completedSubtaskIds = const []}) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('task_records')
        .doc(dateString);

    final publicActivityRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('public_activity')
        .doc(dateString);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final publicActivitySnapshot = await transaction.get(publicActivityRef);
      
      final taskCompletion = TaskCompletionEntity(
        taskId: task.taskId,
        completed: isCompleted,
        completedAt: isCompleted ? DateTime.now() : null,
        reflection: reflection,
        completedSubtaskIds: completedSubtaskIds,
      );

      // 1. Update task_records
      if (!snapshot.exists) {
        transaction.set(docRef, {
          'completedTasks': {task.taskId: (isCompleted || completedSubtaskIds.isNotEmpty) ? taskCompletion.toMap() : FieldValue.delete()}
        });
      } else {
        transaction.update(docRef, {
          'completedTasks.${task.taskId}': (isCompleted || completedSubtaskIds.isNotEmpty) ? taskCompletion.toMap() : FieldValue.delete()
        });
      }

      // 2. Update public_activity
      List<dynamic> publicTasks = [];
      if (publicActivitySnapshot.exists && publicActivitySnapshot.data() != null) {
        publicTasks = List.from(publicActivitySnapshot.data()!['completedTasks'] ?? []);
      }
      
      // Remove any existing entry for this task
      publicTasks.removeWhere((t) => t['taskId'] == task.taskId);

      // If fully completed or has completed subtasks, add to public activity
      if (isCompleted || completedSubtaskIds.isNotEmpty) {
        publicTasks.add({
          'taskId': task.taskId,
          'taskTitle': task.title,
          'completedAt': DateTime.now().toIso8601String(),
          'totalSubtasks': task.subtasks.length,
          'completedSubtasks': completedSubtaskIds.length,
          'subtasks': task.subtasks.map((s) => {
            'title': s.title,
            'isCompleted': completedSubtaskIds.contains(s.subtaskId),
          }).toList(),
          if (reflection != null) 'mood': reflection.level,
        });
      }

      if (publicTasks.isEmpty && publicActivitySnapshot.exists) {
        transaction.delete(publicActivityRef);
      } else {
        transaction.set(publicActivityRef, {
          'completedTasks': publicTasks
        }, SetOptions(merge: true));
      }
    });

    // 3. Feed milestone progress (if this task is linked to a milestone).
    // Runs after the record transaction: milestone contribution is derived
    // from task completion state, and milestone docs live under a different
    // collection path (no cross-collection transaction needed).
    final milestoneId = task.milestoneId;
    final goalId = task.goalId;
    if (milestoneId != null && goalId != null) {
      await _milestoneRepository.updateTaskContribution(
        userId, goalId, milestoneId, task.taskId, isCompleted ? 1 : 0,
      );
    }
  }

  @override
  Future<void> saveReflection(String userId, String dateString,
      String taskId, ReflectionEntity reflection) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('task_records')
        .doc(dateString);

    final publicActivityRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('public_activity')
        .doc(dateString);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      // If the record doesn't exist yet (task not completed that day) there
      // is nothing to attach a reflection to — no-op.
      if (!snapshot.exists || snapshot.data() == null) return;

      // Only the reflection part of the completion entry is updated.
      transaction.update(docRef, {
        'completedTasks.$taskId.reflection': reflection.toMap(),
      });

      // Keep the public activity mood in sync.
      final publicActivitySnapshot = await transaction.get(publicActivityRef);
      if (publicActivitySnapshot.exists &&
          publicActivitySnapshot.data() != null) {
        final publicTasks =
            List.from(publicActivitySnapshot.data()!['completedTasks'] ?? []);
        final idx = publicTasks.indexWhere((t) => t['taskId'] == taskId);
        if (idx != -1) {
          publicTasks[idx] = {
            ...publicTasks[idx] as Map,
            'mood': reflection.level,
          };
          transaction.set(
            publicActivityRef,
            {'completedTasks': publicTasks},
            SetOptions(merge: true),
          );
        }
      }
    });
  }
}
