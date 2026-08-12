import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/friend_entity.dart';
import '../../domain/repositories/friend_repository.dart';

class FirebaseFriendRepository implements FriendRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<FriendEntity>> getFriends(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('friends')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => FriendEntity.fromMap(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> removeFriend(String uid, String friendUid) async {
    final batch = _firestore.batch();
    
    final userFriendRef = _firestore.collection('users').doc(uid).collection('friends').doc(friendUid);
    final friendUserRef = _firestore.collection('users').doc(friendUid).collection('friends').doc(uid);
    
    batch.delete(userFriendRef);
    batch.delete(friendUserRef);
    
    await batch.commit();
  }
}
