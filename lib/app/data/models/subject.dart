import 'package:attendance_tracker/app/data/models/group.dart';

class Subject {
  final String id;
  final String name;
  final String groupId;
  final Group? group;
  final int deleted;
  final DateTime? deletedAt;

  Subject({
    required this.id,
    required this.name,
    required this.groupId,
    this.group,
    this.deleted = 0,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'groupId': groupId,
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      name: map['name'],
      groupId: map['groupId'],
      deleted: map['deleted'],
      deletedAt:
          map['deletedAt'] != null ? DateTime.parse(map["deletedAt"]) : null,
      group: map.containsKey("groupName")
          ? Group(id: map["groupId"], name: map["groupName"])
          : null,
    );
  }
}
