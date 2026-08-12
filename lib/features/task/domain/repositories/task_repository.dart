import '../entities/task_entity.dart';

abstract class TaskRepository {
  Stream<List<TaskEntity>> getTasks(String userId);
  Future<TaskEntity?> getTask(String userId, String taskId);
  Future<void> addTask(String userId, TaskEntity task);
  Future<void> updateTask(String userId, TaskEntity task);
  Future<void> deleteTask(String userId, String taskId);

  /// Returns the total number of completed tasks (non-archived) for [userId].
  // Future<int> countCompletedTasks(String userId);
}
