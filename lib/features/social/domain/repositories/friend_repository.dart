import '../entities/friend_entity.dart';

abstract class FriendRepository {
  Stream<List<FriendEntity>> getFriends(String uid);
  Future<void> removeFriend(String uid, String friendUid);
}
