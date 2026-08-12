class FriendEntity {
  final String friendUid;
  final DateTime since;
  final bool favorite;
  final DateTime? lastInteraction;

  const FriendEntity({
    required this.friendUid,
    required this.since,
    this.favorite = false,
    this.lastInteraction,
  });

  Map<String, dynamic> toMap() {
    return {
      'friendUid': friendUid,
      'since': since.toIso8601String(),
      'favorite': favorite,
      'lastInteraction': lastInteraction?.toIso8601String(),
    };
  }

  factory FriendEntity.fromMap(Map<String, dynamic> map, String id) {
    return FriendEntity(
      friendUid: id,
      since: map['since'] != null ? DateTime.parse(map['since']) : DateTime.now(),
      favorite: map['favorite'] ?? false,
      lastInteraction: map['lastInteraction'] != null ? DateTime.parse(map['lastInteraction']) : null,
    );
  }

  FriendEntity copyWith({
    String? friendUid,
    DateTime? since,
    bool? favorite,
    DateTime? lastInteraction,
  }) {
    return FriendEntity(
      friendUid: friendUid ?? this.friendUid,
      since: since ?? this.since,
      favorite: favorite ?? this.favorite,
      lastInteraction: lastInteraction ?? this.lastInteraction,
    );
  }
}
