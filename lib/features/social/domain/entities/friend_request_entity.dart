enum FriendRequestStatus { pending, accepted, rejected, cancelled }

class FriendRequestEntity {
  final String requestId;
  final String senderUid;
  final String receiverUid;
  final FriendRequestStatus status;
  final DateTime sentAt;
  final DateTime updatedAt;

  const FriendRequestEntity({
    required this.requestId,
    required this.senderUid,
    required this.receiverUid,
    required this.status,
    required this.sentAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'status': status.name,
      'sentAt': sentAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FriendRequestEntity.fromMap(Map<String, dynamic> map, String id) {
    return FriendRequestEntity(
      requestId: id,
      senderUid: map['senderUid'] ?? '',
      receiverUid: map['receiverUid'] ?? '',
      status: FriendRequestStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => FriendRequestStatus.pending,
      ),
      sentAt: map['sentAt'] != null ? DateTime.parse(map['sentAt']) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now(),
    );
  }

  FriendRequestEntity copyWith({
    String? requestId,
    String? senderUid,
    String? receiverUid,
    FriendRequestStatus? status,
    DateTime? sentAt,
    DateTime? updatedAt,
  }) {
    return FriendRequestEntity(
      requestId: requestId ?? this.requestId,
      senderUid: senderUid ?? this.senderUid,
      receiverUid: receiverUid ?? this.receiverUid,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
