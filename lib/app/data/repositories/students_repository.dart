import 'package:attendance_tracker/app/data/local/database_helper.dart';
import 'package:attendance_tracker/app/data/models/objects/query_result.dart';
import 'package:attendance_tracker/app/data/models/user.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class StudentsRepository {
  StudentsRepository();

  Future<Database> get database async {
    return await DatabaseHelper().database;
  }

  Future<int> getStudentsCount() async {
    var result = await (await database).rawQuery(
      """
      SELECT COUNT(id) as count
      FROM USERS
      WHERE deleted = 0
      """,
    );
    return result[0]["count"] as int? ?? 0;
  }

  getStudent(String userId) async {
    var queryResult = await (await database).query(
      "Users",
      where: "id = ? and deleted = 0",
      whereArgs: [userId],
    );

    return User.fromMap(queryResult.first);
  }

  Future<QueryList<User>> getStudents({
    String? groupId,
    String searchQuery = "",
    bool showDeleted = false,
    List<String>? groupIds,
    int page = 0,
    int pageSize = 20,
  }) async {
    var rawQuery = """
    SELECT {{cols}}
    FROM Users U
    LEFT JOIN Groups G ON U.primaryGroup = G.id
    WHERE U.deleted = ${showDeleted ? 1 : 0}
    """;

    if (groupIds != null && groupIds.isNotEmpty) {
      var groups = groupIds.map((id) => "'$id'").join(',');
      if (groups.length == 1) {
        rawQuery += """
        AND (primaryGroup in ($groupIds)
        OR U.id in (SELECT userId FROM GroupUsers WHERE groupId in ($groupIds)))
        """;
      } else {
        for (var gId in groupIds) {
          rawQuery += """
          AND (primaryGroup = '$gId'
          OR U.id in (SELECT userId FROM GroupUsers WHERE groupId = '$gId'))
          """;
        }
      }
    }

    if (groupId != null) {
      rawQuery += """
      AND primaryGroup = '$groupId' 
      OR U.id in (
        SELECT userId FROM GroupUsers WHERE groupId = '$groupId'
      )
      """;
    }

    if (searchQuery.isNotEmpty) {
      searchQuery = searchQuery.toLowerCase();

      rawQuery += """
      AND (U.name like ? OR fatherName like ?)
      """;
    }

    var countQueryResult = searchQuery.isNotEmpty
        ? await (await database).rawQuery(
            rawQuery.replaceFirst("{{cols}}", "COUNT(U.id) as count"),
            ['%$searchQuery%'],
          )
        : await (await database).rawQuery(
            rawQuery.replaceFirst("{{cols}}", "COUNT(U.id) as count"),
          );

    var rowsCount = countQueryResult[0]["count"] as int? ?? 0;

    rawQuery += """
    ORDER BY U.name, U.id
    LIMIT $pageSize
    OFFSET ${pageSize * page}
    """;

    var data = searchQuery.isNotEmpty
        ? await (await database).rawQuery(
            rawQuery.replaceFirst("{{cols}}", """
                U.id, U.name, U.fatherName, U.primaryGroup,
                G.name AS groupName, U.deleted, U.deletedAt
                """),
            ['%$searchQuery%'],
          )
        : await (await database).rawQuery(
            rawQuery.replaceFirst("{{cols}}", """
                U.id, U.name, U.fatherName, U.primaryGroup,
                G.name AS groupName, U.deleted, U.deletedAt
                """),
          );

    return QueryList(
      count: rowsCount,
      data: data.map(User.fromMap).toList(),
    );
  }

  Future<int> restoreDeletedStudent(User user) async {
    return await (await database).update(
      'Users',
      {
        "deleted": 0,
        "deletedAt": null,
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> softDeleteStudent(User user) async {
    return await (await database).update(
      'Users',
      {
        "deleted": 1,
        "deletedAt": DateFormat("yyyy-MM-dd").format(DateTime.now())
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteStudent(User user) async {
    var result = await (await database).delete(
      'GroupUsers',
      where: 'userId = ?',
      whereArgs: [user.id],
    );
    result = await (await database).delete(
      'Attendance',
      where: 'userId = ?',
      whereArgs: [user.id],
    );
    result = await (await database).delete(
      'Users',
      where: 'id = ?',
      whereArgs: [user.id],
    );

    return result;
  }

  Future<int> addStudent(
    User user,
    List<String> groupIds,
  ) async {
    var result = await (await database).insert(
      "Users",
      {
        "id": user.id,
        "name": user.name,
        "fatherName": user.fatherName,
        "primaryGroup": user.primaryGroup,
      },
    );

    if (result == 0) {
      return 0;
    }

    if (groupIds.isNotEmpty) {
      for (var groupId in groupIds) {
        await (await database).insert(
          "GroupUsers",
          {
            "groupId": groupId,
            "userId": user.id,
          },
        );
      }
    }

    return result;
  }

  Future<int> updateStudent(
    User user,
    List<String> groupIds,
  ) async {
    var result = await (await database).update(
      "Users",
      {
        "id": user.id,
        "name": user.name,
        "fatherName": user.fatherName,
        "primaryGroup": user.primaryGroup,
      },
      where: "id = ?",
      whereArgs: [user.id],
    );

    if (result == 0) {
      return 0;
    }

    if (groupIds.isNotEmpty) {
      for (var groupId in groupIds) {
        await (await database).insert(
          "GroupUsers",
          {
            "groupId": groupId,
            "userId": user.id,
          },
          conflictAlgorithm: ConflictAlgorithm.replace
        );
      }
    } else {
      await (await database).rawDelete("""
      DELETE FROM GroupUsers
      WHERE userId = '${user.id}' 
      """);
    }

    return result;
  }

  bulkUpdateGroups(
    List<User> users,
    String? primaryGroup,
    List<String> groupIds,
  ) async {
    if (users.isEmpty) return;
    var userIds = users.map((u) => "'${u.id}'").join(",");
    await (await database).update(
      "Users",
      {
        "primaryGroup": primaryGroup,
      },
      where: "id in ($userIds)",
    );

    await (await database).delete(
      "GroupUsers",
      where: "userId in ($userIds)",
    );

    for (var user in users) {
      for (var groupId in groupIds) {
        await (await database).insert(
          "GroupUsers",
          {
            "groupId": groupId,
            "userId": user.id,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }
}
