import '../entities/daily_record_entity.dart';
import '../entities/reflection_entity.dart';
import '../entities/task_entity.dart';

abstract class TaskRecordRepository {
  Stream<DailyRecordEntity?> getDailyRecord(String userId, String dateString);
  Future<List<DailyRecordEntity>> getRecordsForDateRange(String userId, String startDateString, String endDateString);
  Future<void> toggleTaskCompletion(String userId, String dateString, TaskEntity task, bool isCompleted, {ReflectionEntity? reflection, List<String> completedSubtaskIds = const []});
  /// Persists mood + note for a completed task on the given day without
  /// touching the completion state.
  Future<void> saveReflection(String userId, String dateString, String taskId, ReflectionEntity reflection);
}
