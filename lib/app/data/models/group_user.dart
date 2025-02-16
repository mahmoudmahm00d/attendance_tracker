class GroupUser {
  final String groupId;
  final String userId;

  GroupUser({
    required this.groupId,
    required this.userId,
  });

  // Convert a GroupUser object into a Map
  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'userId': userId,
    };
  }

  // Extract a GroupUser object from a Map
  factory GroupUser.fromMap(Map<String, dynamic> map) {
    return GroupUser(
      groupId: map['groupId'],
      userId: map['userId'],
    );
  }
}
