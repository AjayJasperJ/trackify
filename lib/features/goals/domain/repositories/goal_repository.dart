import '../entities/goal_entity.dart';

abstract class GoalRepository {
  Future<void> addGoal(String uid, GoalEntity goal);
  Future<void> updateGoal(String uid, GoalEntity goal);
  Future<void> deleteGoal(String uid, String goalId);
  Future<GoalEntity?> getGoal(String uid, String goalId);
  Stream<List<GoalEntity>> watchGoals(String uid);
}
