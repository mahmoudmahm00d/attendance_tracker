import 'package:attendance_tracker/app/data/local/database_helper.dart';
import 'package:attendance_tracker/app/data/models/subject.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class SubjectsRepository {
  Future<Database> get database async => DatabaseHelper().database;
  SubjectsRepository();

  Future<int> getSubjectsCount() async {
    var result = await (await database).rawQuery(
      """
      SELECT COUNT(id) as count
      FROM Subjects
      WHERE deleted = 0
      """,
    );
    return result[0]["count"] as int;
  }

  Future<List<Subject>> getSubjects(
      {String? groupId, bool showDeleted = false}) async {
    var queryResult = await (await database).rawQuery(
      """
      SELECT s.id, s.name, s.groupId, g.name AS groupName, s.deleted, s.deletedAt
      FROM Subjects AS s, Groups AS g
      WHERE s.groupId = g.id
      AND s.deleted = ${showDeleted ? 1 : 0}
      ${groupId != null ? "AND groupId = ?" : ""};
      """,
      groupId != null ? [groupId] : null,
    );
    return queryResult.map(Subject.fromMap).toList();
  }

  Future<Set<String>> getSubjectAttendanceDates(String subjectId) async {
    var queryResult = await (await database).rawQuery(
      "SELECT DISTINCT at FROM Attendance WHERE subjectId = '$subjectId'",
    );

    return queryResult.map((date) => date["at"].toString()).toSet();
  }

  Future<int> addSubject(Subject subject) async {
    var result = await (await database).insert(
      "Subjects",
      {
        "id": subject.id,
        "name": subject.name,
        "groupId": subject.groupId
      },
    );

    if (result == 0) {
      return 0;
    }

    return result;
  }

  Future<int> updateSubject(Subject subject) async {
    var result = await (await database).update(
      "Subjects",
      {
        "id": subject.id,
        "name": subject.name,
      },
      where: "id = ?",
      whereArgs: [subject.id],
    );

    if (result == 0) {
      return 0;
    }

    return result;
  }

  Future<int> restoreDeletedSubject(Subject subject) async {
    return await (await database).update(
      'Subjects',
      {
        "deleted": 0,
        "deletedAt": null,
      },
      where: 'id = ?',
      whereArgs: [subject.id],
    );
  }

  Future<int> softDeleteSubject(Subject subject) async {
    return await (await database).update(
      'Subjects',
      {
        "deleted": 1,
        "deletedAt": DateFormat("yyyy-MM-dd").format(DateTime.now())
      },
      where: 'id = ?',
      whereArgs: [subject.id],
    );
  }

  Future<int> deleteSubject(Subject subject) async {
    var result = await (await database).delete(
      'Attendance',
      where: 'subjectId = ?',
      whereArgs: [subject.id],
    );
    result = await (await database).delete(
      'Subjects',
      where: 'id = ?',
      whereArgs: [subject.id],
    );

    return result;
  }
}
