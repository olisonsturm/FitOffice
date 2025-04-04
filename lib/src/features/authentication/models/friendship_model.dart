
class FriendshipModel {
  final String id;
  final String friend1Id;
  final String friend2Id;
  final DateTime createdAt;
  final DateTime updatedAt;

  FriendshipModel({
    required this.id,
    required this.friend1Id,
    required this.friend2Id,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FriendshipModel.fromJson(Map<String, dynamic> json) {
    return FriendshipModel(
      id: json['id'] as String,
      friend1Id: json['user_id'] as String,
      friend2Id: json['friend_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'friend_1_id': friend1Id,
      'friend_2_id': friend2Id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}