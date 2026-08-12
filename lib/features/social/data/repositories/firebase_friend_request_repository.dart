import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/friend_request_entity.dart';
import '../../domain/repositories/friend_request_repository.dart';

class FirebaseFriendRequestRepository implements FriendRequestRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<FriendRequestEntity>> getPendingRequestsForUser(String uid) {
    return _firestore
        .collection('friend_requests')
        .where('receiverUid', isEqualTo: uid)
        .where('status', isEqualTo: FriendRequestStatus.pending.name)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => FriendRequestEntity.fromMap(doc.data(), doc.id)).toList();
    });
  }

  @override
  Stream<List<FriendRequestEntity>> getSentRequestsByUser(String uid) {
    return _firestore
        .collection('friend_requests')
        .where('senderUid', isEqualTo: uid)
        .where('status', isEqualTo: FriendRequestStatus.pending.name)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => FriendRequestEntity.fromMap(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> sendRequest(String senderUid, String receiverUid) async {
    final docRef = _firestore.collection('friend_requests').doc();
    final now = DateTime.now();
    
    final request = FriendRequestEntity(
      requestId: docRef.id,
      senderUid: senderUid,
      receiverUid: receiverUid,
      status: FriendRequestStatus.pending,
      sentAt: now,
      updatedAt: now,
    );
    
    await docRef.set(request.toMap());
  }

  @override
  Future<void> respondToRequest(String requestId, String currentUid, String otherUid, FriendRequestStatus status) async {
    final docRef = _firestore.collection('friend_requests').doc(requestId);
    final now = DateTime.now();
    
    final batch = _firestore.batch();
    
    batch.update(docRef, {
      'status': status.name,
      'updatedAt': now.toIso8601String(),
    });
    
    if (status == FriendRequestStatus.accepted) {
      final userFriendRef = _firestore.collection('users').doc(currentUid).collection('friends').doc(otherUid);
      final otherFriendRef = _firestore.collection('users').doc(otherUid).collection('friends').doc(currentUid);
      
      batch.set(userFriendRef, {
        'friendUid': otherUid,
        'since': now.toIso8601String(),
        'favorite': false,
      });
      
      batch.set(otherFriendRef, {
        'friendUid': currentUid,
        'since': now.toIso8601String(),
        'favorite': false,
      });
    }
    
    await batch.commit();
  }
}
