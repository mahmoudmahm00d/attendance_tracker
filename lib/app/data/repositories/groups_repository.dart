import 'package:attendance_tracker/app/data/local/database_helper.dart';
import 'package:attendance_tracker/app/data/models/group.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class GroupsRepository {
  Future<Database> get database => DatabaseHelper().database;
  GroupsRepository();

  Future<int> getGroupsCount() async {
    var result = await (await database).rawQuery(
      """
      SELECT COUNT(id) as count
      FROM Groups
      WHERE deleted = 0
      """,
    );
    return result[0]["count"] as int;
  }

  Future<List<Group>> getGroups({
    String query = "",
    bool showDeleted = false,
  }) async {
    var queryResult = query.isEmpty
        ? await (await database).query(
            'Groups',
            where: 'deleted = ${showDeleted ? 1 : 0}',
          )
        : await (await database).query('Groups',
            where: 'deleted = ${showDeleted ? 1 : 0} AND name = ?',
            whereArgs: ['%$query%']);
    return queryResult.map(Group.fromMap).toList();
  }

  Future<Set<Group>> getUserGroups(String userId) async {
    var queryResult = await (await database).rawQuery(
      '''
      SELECT * FROM Groups
      WHERE id in 
      (
        SELECT groupId FROM GroupUsers
        WHERE userId = ?
      )
      ''',
      [userId],
    );

    return queryResult.map(Group.fromMap).toSet();
  }

  Future<int> restoreDeletedGroup(Group group) async {
    return await (await database).update(
      'Groups',
      {
        "deleted": 0,
        "deletedAt": null,
      },
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }

  Future<int> softDeleteGroup(Group group) async {
    return await (await database).update(
      'Groups',
      {
        "deleted": 1,
        "deletedAt": DateFormat("yyyy-MM-dd").format(DateTime.now())
      },
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }

  Future<int> deleteGroup(Group group) async {
    var result = await (await database).delete(
      'Subjects',
      where: 'groupId = ?',
      whereArgs: [group.id],
    );
    result = await (await database).delete(
      'GroupUsers',
      where: 'groupId = ?',
      whereArgs: [group.id],
    );
    result = await (await database).update(
      'Users',
      {"primaryGroup": null},
      where: 'primaryGroup = ?',
      whereArgs: [group.id],
    );
    result = await (await database).delete(
      'Groups',
      where: 'id = ?',
      whereArgs: [group.id],
    );

    return result;
  }

  Future<int> addGroup(Group group) async {
    var result = await (await database).insert(
      "Groups",
      {
        "id": group.id,
        "name": group.name,
      },
    );

    if (result == 0) {
      return 0;
    }

    return result;
  }

  Future<int> updateGroup(Group group) async {
    var result = await (await database).update(
      "Groups",
      {
        "id": group.id,
        "name": group.name,
      },
      where: "id = ?",
      whereArgs: [group.id],
    );

    if (result == 0) {
      return 0;
    }

    return result;
  }
}
