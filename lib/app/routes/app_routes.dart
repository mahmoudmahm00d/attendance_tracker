part of 'app_pages.dart';
// DO NOT EDIT. This is code generated via package:get_cli/get_cli.dart

abstract class Routes {
  Routes._();
  static const preferences = _Paths.preferences;
  static const landing = _Paths.landing;
  static const home = _Paths.home;
  static const groups = _Paths.groups;
  static const subjects = _Paths.subjects;
  static const students = _Paths.students;
  static const createSubject = _Paths.subjects + _Paths.createSubject;
  static const qrAttendance = _Paths.subjects + _Paths.qrAttendance;
  static const attendance = _Paths.subjects + _Paths.attendance;
  static const userAttendance = _Paths.subjects + _Paths.userAttendance;
  static const addAttendance = _Paths.subjects + _Paths.addAttendance;
  static const createGroup = _Paths.groups + _Paths.createGroup;
  static const createStudent = _Paths.students + _Paths.createStudent;
  static const importFromExcel = _Paths.students + _Paths.importFromExcel;
}

abstract class _Paths {
  _Paths._();
  static const preferences = '/preferences';
  static const landing = '/landing';
  static const home = '/home';
  static const groups = '/groups';
  static const subjects = '/subjects';
  static const students = '/students';
  static const importFromExcel = '/import-from-excel';
  static const attendance = '/attendance';
  static const userAttendance = '/user-attendance';
  static const addAttendance = '/add-attendance';
  static const qrAttendance = '/qr-attendance';
  static const createSubject = '/create-subject';
  static const createGroup = '/create-group';
  static const createStudent = '/create-student';
}
