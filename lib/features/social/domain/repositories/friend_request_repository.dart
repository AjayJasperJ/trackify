import '../entities/friend_request_entity.dart';

abstract class FriendRequestRepository {
  Stream<List<FriendRequestEntity>> getPendingRequestsForUser(String uid);
  Stream<List<FriendRequestEntity>> getSentRequestsByUser(String uid);
  Future<void> sendRequest(String senderUid, String receiverUid);
  Future<void> respondToRequest(String requestId, String currentUid, String otherUid, FriendRequestStatus status);
}
