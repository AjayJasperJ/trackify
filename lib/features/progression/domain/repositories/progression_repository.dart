import '../entities/progression_entity.dart';
import '../entities/xp_history_entity.dart';

abstract class ProgressionRepository {
  Future<ProgressionEntity?> getProgression(String uid);
  Future<void> updateProgression(String uid, ProgressionEntity progression);
  Future<void> addXPHistory(String uid, XPHistoryEntity history);
  Stream<ProgressionEntity?> watchProgression(String uid);
  Stream<List<XPHistoryEntity>> watchXPHistory(String uid, {int limit = 50});
  Future<int?> revertRecentTaskXP(String uid, String taskId, String date);
  Future<int> revertAllTaskXP(String uid, String taskId);
}
