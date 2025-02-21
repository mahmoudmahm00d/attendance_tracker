import 'dart:io';
import 'package:attendance_tracker/app/data/models/attendance.dart';
import 'package:excel/excel.dart';
import 'package:attendance_tracker/app/data/models/user.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:ulid/ulid.dart';

Future<List<User>> getUsers(String filePath, String? primaryGroup) async {
  var file = File(filePath);

  if (!await file.exists()) {
    return [];
  }

  var excel = Excel.decodeBytes(await file.readAsBytes());
  var table = excel.tables.values.first;
  List<User> users = [];
  for (var i = 1; i < table.rows.length; i++) {
    try {
      var row = table.rows[i];
      var nameCell = row[0]?.value;
      if (nameCell == null ||
          nameCell is! TextCellValue ||
          nameCell.value.text.isBlank!) {
        continue;
      }
      String name = nameCell.value.text!;
      var fatherName = row.length == 2 ? row[1]?.value.toString() ?? "" : "";
      users.add(
        User(
          id: Ulid.new().toString(),
          name: name,
          fatherName: fatherName,
          primaryGroup: primaryGroup,
        ),
      );
    } on Exception {
      continue;
    }
  }

  return users;
}

List<int>? generateStudentsFile(List<User> users) {
  var excel = Excel.createExcel();
  Sheet sheet = excel['Students'];
  var defaultSheet = excel.getDefaultSheet();
  if (defaultSheet != null) {
    excel.delete(defaultSheet);
  }
  sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
      TextCellValue("Id");

  sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value =
      TextCellValue("Student");

  sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value =
      TextCellValue("Father");

  for (var i = 0; i < users.length; i++) {
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
        .value = TextCellValue(users[i].id);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
        .value = TextCellValue(users[i].name);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
        .value = TextCellValue(users[i].fatherName ?? "");
  }

  excel.setDefaultSheet("Students");
  sheet.setColumnAutoFit(0);
  sheet.setColumnAutoFit(1);
  sheet.setColumnAutoFit(2);

  return excel.save();
}

List<int>? generateAttendanceReport(
  String subjectName,
  int maxAttendanceCount,
  List<(String, int)> dates,
  List<UserAttendance> attendance,
) {
  var excel = Excel.createExcel();
  Sheet sheet = excel['Students'];
  var defaultSheet = excel.getDefaultSheet();
  if (defaultSheet != null) {
    excel.delete(defaultSheet);
  }

  sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
      TextCellValue("Subject");
  sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value =
      TextCellValue("Attendance Count");
  sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value =
      TextCellValue("Students Count");

  sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).value =
      TextCellValue(subjectName);
  sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1)).value =
      TextCellValue(maxAttendanceCount.toString());
  sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 1)).value =
      TextCellValue(attendance.length.toString());

  sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2)).value =
      TextCellValue("Lecture");
  sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2)).value =
      TextCellValue("At");
  sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 2)).value =
      TextCellValue("Attendance");

  for (var i = 0; i < dates.length; i++) {
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 3))
        .value = TextCellValue((i + 1).toString().padLeft(3, "0"));
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 3))
        .value = TextCellValue(dates[i].$1);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 3))
        .value = TextCellValue(dates[i].$2.toString());
  }

  sheet
      .cell(CellIndex.indexByColumnRow(
          columnIndex: 0, rowIndex: dates.length + 3))
      .value = TextCellValue("Student");
  sheet
      .cell(CellIndex.indexByColumnRow(
          columnIndex: 1, rowIndex: dates.length + 3))
      .value = TextCellValue("Father");
  sheet
      .cell(CellIndex.indexByColumnRow(
          columnIndex: 2, rowIndex: dates.length + 3))
      .value = TextCellValue("Attendance");

  for (var i = 0; i < attendance.length; i++) {
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: 0, rowIndex: i + dates.length + 4))
        .value = TextCellValue(attendance[i].name);
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: 1, rowIndex: i + dates.length + 4))
        .value = TextCellValue(attendance[i].fatherName ?? "");
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: 2, rowIndex: i + dates.length + 4))
        .value = TextCellValue(attendance[i].count.toString());
  }

  sheet.setColumnAutoFit(0);
  sheet.setColumnAutoFit(1);
  sheet.setColumnAutoFit(2);
  excel.setDefaultSheet("Students");
  return excel.save();
}
