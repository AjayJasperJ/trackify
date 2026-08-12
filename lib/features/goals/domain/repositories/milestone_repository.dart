import '../entities/milestone_entity.dart';

abstract class MilestoneRepository {
  Future<void> addMilestone(String uid, MilestoneEntity milestone);
  Future<void> updateMilestone(String uid, MilestoneEntity milestone);
  Future<void> deleteMilestone(String uid, String goalId, String milestoneId);
  Future<MilestoneEntity?> getMilestone(String uid, String goalId, String milestoneId);
  Future<List<MilestoneEntity>> getMilestones(String uid, String goalId);
  Stream<List<MilestoneEntity>> watchMilestones(String uid, String goalId);
  Stream<List<MilestoneEntity>> watchAllMilestones(String uid);
  Future<MilestoneEntity?> getMilestoneForTask(String uid, String taskId);
  Future<void> linkTaskToMilestone(String uid, String goalId, String milestoneId, String taskId, {int weight = 1});
  Future<void> unlinkTaskFromMilestone(String uid, String goalId, String milestoneId, String taskId);

  /// Feeds task completion state back into the milestone's weighted meta so
  /// [MilestoneEntity.computedProgress] reflects real task completion.
  /// `contribution` is the value to store for this task (0 when unchecked,
  /// its stored weight when completed).
  Future<void> updateTaskContribution(String uid, String goalId, String milestoneId, String taskId, int contribution);
}
