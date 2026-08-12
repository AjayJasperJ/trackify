import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'social_providers.dart';
import '../domain/entities/friend_entity.dart';
import '../domain/entities/friend_request_entity.dart';
import '../../authentication/providers/auth_provider.dart';

final userFriendsProvider = StreamProvider<List<FriendEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(friendRepositoryProvider).getFriends(user.uid);
});

final pendingRequestsProvider = StreamProvider<List<FriendRequestEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(friendRequestRepositoryProvider).getPendingRequestsForUser(user.uid);
});

final sentRequestsProvider = StreamProvider<List<FriendRequestEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(friendRequestRepositoryProvider).getSentRequestsByUser(user.uid);
});
