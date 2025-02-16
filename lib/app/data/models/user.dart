import 'package:attendance_tracker/app/data/models/group.dart';
import 'package:ulid/ulid.dart';

class User {
  final String id;
  final String name;
  final String? fatherName;
  final String? primaryGroup;
  final Group? group;
  final int deleted;
  final DateTime? deletedAt;

  User({
    required this.id,
    required this.name,
    this.fatherName,
    this.primaryGroup,
    this.group,
    this.deleted = 0,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'fatherName': fatherName,
      'primaryGroup': primaryGroup,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      deleted: map['deleted'],
      deletedAt:
          map['deletedAt'] != null ? DateTime.parse(map["deletedAt"]) : null,
      fatherName: map['fatherName'],
      primaryGroup: map['primaryGroup'],
      group: map.containsKey("groupName") && map["groupName"] != null
          ? Group(id: map["primaryGroup"], name: map["groupName"])
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }

  @override
  int get hashCode => Ulid.parse(id).toMillis() * 31 + name.hashCode;
}
