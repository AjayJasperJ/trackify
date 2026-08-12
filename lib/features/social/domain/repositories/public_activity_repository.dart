import '../entities/public_activity_entity.dart';

abstract class PublicActivityRepository {
  Stream<PublicActivityEntity?> streamActivityForDate(String uid, String date);
  Future<List<PublicActivityEntity>> getRecentActivities(String uid, int limit);
  Future<void> recordTaskCompletion(String uid, String date, PublicCompletedTask task);
  Stream<List<PublicActivityEntity>> streamRecentActivities(String uid, int limit);
}
