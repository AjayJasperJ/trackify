import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/firebase_friend_repository.dart';
import '../data/repositories/firebase_friend_request_repository.dart';
import '../data/repositories/firebase_public_profile_repository.dart';
import '../data/repositories/firebase_public_activity_repository.dart';
import '../domain/repositories/friend_repository.dart';
import '../domain/repositories/friend_request_repository.dart';
import '../domain/repositories/public_profile_repository.dart';
import '../domain/repositories/public_activity_repository.dart';
import '../domain/entities/friend_with_profile.dart';
import '../../authentication/providers/auth_provider.dart';

final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  return FirebaseFriendRepository();
});

final friendRequestRepositoryProvider = Provider<FriendRequestRepository>((ref) {
  return FirebaseFriendRequestRepository();
});

final publicProfileRepositoryProvider = Provider<PublicProfileRepository>((ref) {
  return FirebasePublicProfileRepository();
});

final publicActivityRepositoryProvider = Provider<PublicActivityRepository>((ref) {
  return FirebasePublicActivityRepository();
});

/// Aggregated stream: friends list + their public profiles in a single emission.
/// Prevents per-item stream flicker in FriendsScreen and TopStreaksSection.
final friendsWithProfilesStreamProvider = StreamProvider<List<FriendWithProfile>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  
  final friendsStream = ref.watch(friendRepositoryProvider).getFriends(user.uid);
  
  return friendsStream.asyncMap((friends) async {
    final profiles = await Future.wait(
      friends.map((f) => ref.read(publicProfileRepositoryProvider).getProfile(f.friendUid)),
    );
    return friends.asMap().entries.map((entry) {
      return FriendWithProfile(friend: entry.value, profile: profiles[entry.key]);
    }).toList();
  });
});
