import 'package:attendance_tracker/app/data/models/user.dart';
import 'package:intl/intl.dart';
import 'package:ulid/ulid.dart';

class Attendance {
  final String id;
  final String subjectId;
  final String userId;
  final DateTime at;

  Attendance({
    required this.id,
    required this.subjectId,
    required this.userId,
    required this.at,
  });

  // Convert an Attendance object into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'userId': userId,
      'at': DateFormat("yyyy-MM-dd").format(at), // Store DateTime as a string
    };
  }

  // Extract an Attendance object from a Map
  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      subjectId: map['subjectId'],
      userId: map['userId'],
      at: DateTime.parse(map['at']), // Parse string back to DateTime
    );
  }
}

class UserAttendance {
  final String id;
  final String name;
  final String? fatherName;
  final String? primaryGroup;
  final int count;

  UserAttendance({
    required this.name,
    required this.primaryGroup,
    required this.id,
    required this.count,
    this.fatherName,
  });

  // Extract an Attendance object from a Map
  factory UserAttendance.fromMap(Map<String, dynamic> map) {
    return UserAttendance(
      id: map['id'],
      count: map['count'],
      name: map["name"],
      fatherName: map["fatherName"],
      primaryGroup: map["primaryGroup"],
    );
  }
}

class DetailedUserAttendance {
  final String id;
  final String name;
  final String? fatherName;
  final String? primaryGroup;
  final Map<String, bool> attendance;

  DetailedUserAttendance({
    required this.name,
    required this.primaryGroup,
    required this.id,
    required this.attendance,
    this.fatherName,
  });

  @override
  bool operator ==(Object other) {
    return id == (other as DetailedUserAttendance).id;
  }

  @override
  int get hashCode => Ulid.parse(id).hashCode;
}

class SubjectAttendance {
  final String id;
  final User? user;
  final DateTime? at;

  SubjectAttendance({
    required this.id,
    required this.user,
    required this.at,
  });

  // Extract an Attendance object from a Map
  factory SubjectAttendance.fromMap(Map<String, dynamic> map) {
    return SubjectAttendance(
      id: map['id'],
      user: map.containsKey("userId")
          ? User(
              id: map["userId"],
              name: map["userName"],
              fatherName: map["fatherName"],
            )
          : null,
      at: map["at"] != null
          ? DateTime.parse(map['at'])
          : null, // Parse string back to DateTime
    );
  }
}
