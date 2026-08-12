import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final FirebaseFirestore _firestore;

  TaskRepositoryImpl(this._firestore);

  @override
  Stream<List<TaskEntity>> getTasks(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .where('isArchived', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TaskEntity.fromMap(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<TaskEntity?> getTask(String userId, String taskId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .get();
    if (doc.exists && doc.data() != null) {
      return TaskEntity.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  @override
  Future<void> addTask(String userId, TaskEntity task) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(task.taskId)
        .set(task.toMap());
  }

  @override
  Future<void> updateTask(String userId, TaskEntity task) async {
    // merge:true instead of update() so null fields (goalId/milestoneId when
    // unlinked) are actually written. Firestore update() silently drops nulls.
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(task.taskId)
        .set(task.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteTask(String userId, String taskId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .update({'isArchived': true});
  }
}
