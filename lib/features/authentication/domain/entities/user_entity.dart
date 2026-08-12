class UserEntity {
  final String uid;
  final String displayName;
  final String email;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.uid,
    required this.displayName,
    required this.email,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserEntity.fromMap(Map<String, dynamic> map, String id) {
    return UserEntity(
      uid: id,
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now(),
    );
  }

  UserEntity copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
