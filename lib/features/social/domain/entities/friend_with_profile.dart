import 'friend_entity.dart';
import 'public_profile_entity.dart';

class FriendWithProfile {
  final FriendEntity friend;
  final PublicProfileEntity? profile;

  const FriendWithProfile({
    required this.friend,
    this.profile,
  });

  String get uid => friend.friendUid;
  String get displayName => profile?.displayName ?? 'Trackify User';
  String? get photoUrl => profile?.photoUrl;
  int get level => profile?.level ?? 1;
  int get streak => profile?.currentStreak ?? 0;
  String get bio => profile?.bio ?? 'No bio set';
  bool get hasProfile => profile != null;
}