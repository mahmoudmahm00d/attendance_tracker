import 'package:attendance_tracker/app/data/local/database_helper.dart';
import 'package:attendance_tracker/app/data/models/attendance.dart';
import 'package:attendance_tracker/app/data/models/objects/query_result.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class AttendanceRepository {
  Future<Database> get database async => DatabaseHelper().database;
  AttendanceRepository();

  Future<int> getMaxAttendanceCount(String subjectId) async {
    var result = await (await database).rawQuery(
      """
      SELECT
      MAX(count) as count
      FROM
      (
        SELECT
          COUNT(a.userId) as count
        FROM
          Attendance a
        WHERE
          a.subjectId = ?
        GROUP BY
          a.userId
      )
      """,
      [subjectId],
    );
    return result[0]["count"] as int? ?? 0;
  }

  Future<int> getAttendanceCount(String groupId) async {
    var result = await (await database).rawQuery("""
    SELECT
      COUNT(u.id) count
    FROM 
      Users u
    WHERE
    (
      u.primaryGroup = '$groupId'
      OR u.id in (
      SELECT
        gu.userId
      FROM
        GroupUsers gu
      WHERE
        gu.groupId = '$groupId')
    )
    """);

    return result[0]["count"] as int? ?? 0;
  }

  Future<QueryList<UserAttendance>> getAttendance(
    String subjectId,
    String groupId, {
    String searchQuery = "",
    List<String>? groupIds,
    List<String>? selectedDates,
    bool nonZeroAttendance = false,
    bool orderByCount = true,
    int pageSize = 20,
    int page = 0,
  }) async {
    var rawQuery = """
    SELECT
      {{cols}}
    FROM 
      Users u
    """;

    var aleadyHasWhere = false;
    if (groupIds != null && groupIds.isNotEmpty) {
      var groups = groupIds.map((id) => "'$id'").join(',');
      if (groups.length == 1) {
        rawQuery += """
        WHERE (primaryGroup in ($groupIds)
        OR U.id in (SELECT userId FROM GroupUsers WHERE groupId in ($groupIds)))
        """;
        aleadyHasWhere = true;
      } else {
        for (var gId in groupIds) {
          rawQuery += """
          ${aleadyHasWhere ? "AND" : "WHERE"} (primaryGroup = '$gId'
          OR U.id in (SELECT userId FROM GroupUsers WHERE groupId = '$gId'))
          """;
          aleadyHasWhere = true;
        }
      }
    } else {
      rawQuery += """
      WHERE
      (
        u.primaryGroup = '$groupId'
        OR u.id in (
        SELECT
          gu.userId
        FROM
          GroupUsers gu
        WHERE
          gu.groupId = '$groupId')
      )
      """;
      aleadyHasWhere = true;
    }

    if (searchQuery.isNotEmpty) {
      searchQuery = searchQuery.toLowerCase();

      rawQuery += """
      ${aleadyHasWhere ? "AND" : "WHERE"} (U.name like ? OR fatherName like ?)
      """;
    }

    var datesCondition = selectedDates != null && selectedDates.isNotEmpty
        ? selectedDates.map((date) => "AND a.at = '$date'").join("\n")
        : "";

    if (nonZeroAttendance) {
      rawQuery += """
          ${aleadyHasWhere ? "AND" : "WHERE"} count <> 0
          """;
    }

    var countQueryResult = searchQuery.isNotEmpty
        ? await (await database).rawQuery(
            rawQuery.replaceFirst("{{cols}}", """
            COUNT(u.id) as counts,
            (
              SELECT
                COUNT(userId)
              FROM
                Attendance a
              WHERE
                u.id = a.userId
              AND
                a.subjectId = '$subjectId'
              $datesCondition
            ) as count
            """),
            ['%$searchQuery%'],
          )
        : await (await database).rawQuery(
            rawQuery.replaceFirst(
              "{{cols}}",
              """
            COUNT(u.id) as counts,
            (
              SELECT
                COUNT(userId)
              FROM
                Attendance a
              WHERE
                u.id = a.userId
              AND
                a.subjectId = '$subjectId'
              $datesCondition
            ) as count
            """,
            ),
          );

    var rowsCount = countQueryResult[0]["counts"] as int? ?? 0;

    rawQuery += """
    ORDER BY ${orderByCount ? "count DESC," : ""} name ASC, u.id
    """;
    if (0 < pageSize) {
      rawQuery += """
      LIMIT $pageSize
      OFFSET ${pageSize * page}
      """;
    }

    rawQuery = rawQuery.replaceFirst(
      "{{cols}}",
      """
      u.*,
      (
        SELECT
          COUNT(userId)
        FROM
          Attendance a
        WHERE
          u.id = a.userId
        AND
          a.subjectId = '$subjectId'
        $datesCondition
      ) as count
    """,
    );

    var data = searchQuery.isNotEmpty
        ? await (await database).rawQuery(
            rawQuery,
            ['%$searchQuery%'],
          )
        : await (await database).rawQuery(rawQuery);

    return QueryList(
      count: rowsCount,
      data: data.map(UserAttendance.fromMap).toList(),
    );
  }

  Future<QueryList<DetailedUserAttendance>> getDetailedAttendance(
    String subjectId,
    String groupId, {
    String searchQuery = "",
    List<String>? groupIds,
    int pageSize = 20,
    int page = 0,
  }) async {
    var rawQuery = """
    SELECT
      {{cols}}
    FROM Attendance a 
    INNER JOIN Users u ON u.id = a.userId
    """;

    var aleadyHasWhere = false;
    if (groupIds != null && groupIds.isNotEmpty) {
      var groups = groupIds.map((id) => "'$id'").join(',');
      if (groups.length == 1) {
        rawQuery += """
        WHERE (primaryGroup in ($groupIds)
        OR U.id in (SELECT userId FROM GroupUsers WHERE groupId in ($groupIds)))
        """;
        aleadyHasWhere = true;
      } else {
        for (var gId in groupIds) {
          rawQuery += """
          ${aleadyHasWhere ? "AND" : "WHERE"} (primaryGroup = '$gId'
          OR U.id in (SELECT userId FROM GroupUsers WHERE groupId = '$gId'))
          """;
          aleadyHasWhere = true;
        }
      }
    } else {
      rawQuery += """
      WHERE
      (
        u.primaryGroup = '$groupId'
        OR u.id in (
        SELECT
          gu.userId
        FROM
          GroupUsers gu
        WHERE
          gu.groupId = '$groupId')
      )
      """;
      aleadyHasWhere = true;
    }

    if (searchQuery.isNotEmpty) {
      searchQuery = searchQuery.toLowerCase();

      rawQuery += """
      ${aleadyHasWhere ? "AND" : "WHERE"} (U.name like ? OR fatherName like ?)
      """;
    }

    var countQueryResult = searchQuery.isNotEmpty
        ? await (await database).rawQuery(
            rawQuery.replaceFirst("{{cols}}", """
            COUNT(u.id) as counts,
            (
              SELECT
                COUNT(userId)
              FROM
                Attendance a
              WHERE
                u.id = a.userId
              AND
                a.subjectId = '$subjectId'
            ) as count
            """),
            ['%$searchQuery%'],
          )
        : await (await database).rawQuery(
            rawQuery.replaceFirst(
              "{{cols}}",
              """
            COUNT(u.id) as counts,
            (
              SELECT
                COUNT(userId)
              FROM
                Attendance a
              WHERE
                u.id = a.userId
              AND
                a.subjectId = '$subjectId'
            ) as count
            """,
            ),
          );

    var rowsCount = countQueryResult[0]["counts"] as int? ?? 0;

    rawQuery += """
    ORDER BY u.name, u.id
    """;
    if (0 < pageSize) {
      rawQuery += """
      LIMIT $pageSize
      OFFSET ${pageSize * page}
      """;
    }

    rawQuery = rawQuery.replaceFirst(
      "{{cols}}",
      """
      u.*,
      a.at
    """,
    );

    var data = searchQuery.isNotEmpty
        ? await (await database).rawQuery(
            rawQuery,
            ['%$searchQuery%'],
          )
        : await (await database).rawQuery(rawQuery);

    List<DetailedUserAttendance> attendance = [];
    for (var i = 0; i < data.length; i++) {
      var detailedUserAttendance = DetailedUserAttendance(
        id: data[i]['id'] as String,
        attendance: {data[i]["at"] as String: true},
        name: data[i]["name"] as String,
        fatherName: data[i]["fatherName"] as String,
        primaryGroup: data[i]["primaryGroup"] as String,
      );
      if (attendance.contains(detailedUserAttendance)) {
        attendance[attendance.indexOf(detailedUserAttendance)]
            .attendance[data[i]["at"] as String] = true;
      } else {
        attendance.add(detailedUserAttendance);
      }
    }
    return QueryList(
      count: rowsCount,
      data: attendance,
    );
  }

  Future<List<Attendance>> getUserAttendance(
    String userId,
    String subjectId,
  ) async {
    List<Map<String, Object?>> data = await (await database).query(
      "Attendance",
      where: "subjectId = ? and userId = ?",
      whereArgs: [subjectId, userId],
    );
    return data.map(Attendance.fromMap).toList();
  }

  Future<int> restoreDeletedAttendance(Attendance attendance) async {
    return await (await database).update(
      'Attendance',
      {
        "deleted": 0,
        "deletedAt": null,
      },
      where: 'id = ?',
      whereArgs: [attendance.id],
    );
  }

  Future<int> softDeleteAttendance(Attendance attendance) async {
    return await (await database).update(
      'Attendance',
      {
        "deleted": 1,
        "deletedAt": DateFormat("yyyy-MM-dd").format(DateTime.now())
      },
      where: 'id = ?',
      whereArgs: [attendance.id],
    );
  }

  Future<int> deleteAttendance(String attendanceId) async {
    var result = await (await database).delete(
      'Attendance',
      where: 'id = ?',
      whereArgs: [attendanceId],
    );

    return result;
  }

  Future<int> addAttendance(Attendance attendance) async {
    var result = await (await database).insert(
      "Attendance",
      attendance.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (result == 0) {
      return 0;
    }

    return result;
  }

  Future<int> updateAttendance(Attendance attendance) async {
    var result = await (await database).update(
      "Attendance",
      attendance.toMap(),
      where: "id = ?",
      whereArgs: [attendance.id],
    );

    if (result == 0) {
      return 0;
    }

    return result;
  }
}
