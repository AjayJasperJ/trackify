import '../entities/streak_entity.dart';

abstract class StreakRepository {
  Stream<StreakEntity?> getStreak(String userId);
  Future<void> updateStreak(String userId, StreakEntity streak);
}
