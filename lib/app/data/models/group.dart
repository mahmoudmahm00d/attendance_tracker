import 'package:ulid/ulid.dart';

class Group {
  final String id;
  final String name;
  final int deleted;
  final DateTime? deletedAt;

  Group({
    required this.id,
    required this.name,
    this.deleted = 0,
    this.deletedAt,
  });

  // Convert a Group object into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  // Extract a Group object from a Map
  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      name: map['name'],
      deleted: map['deleted'],
      deletedAt:
          map['deletedAt'] != null ? DateTime.parse(map["deletedAt"]) : null,
    );
  }

  @override
  int get hashCode => Ulid.parse(id).toMillis() * 31;

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }
}
