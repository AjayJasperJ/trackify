import '../entities/public_profile_entity.dart';

abstract class PublicProfileRepository {
  Future<PublicProfileEntity?> getProfile(String uid);
  Stream<PublicProfileEntity?> streamProfile(String uid);
  Future<void> updateProfile(String uid, PublicProfileEntity profile);
  Future<List<Map<String, dynamic>>> searchUsers(String query);
}
