import 'package:attendance_tracker/app/modules/attendance/bindings/attendance_binding.dart';
import 'package:attendance_tracker/app/modules/attendance/views/attendance_view.dart';
import 'package:attendance_tracker/app/modules/attendance/views/qr_attendance.dart';
import 'package:attendance_tracker/app/modules/attendance/views/user_attendance_view.dart';
import 'package:attendance_tracker/app/modules/landing/binding/landing_binding.dart';
import 'package:attendance_tracker/app/modules/landing/views/landing_view.dart';
import 'package:attendance_tracker/app/modules/preferences/binding/preferences_binding.dart';
import 'package:attendance_tracker/app/modules/preferences/views/preferences_view.dart';
import 'package:attendance_tracker/app/modules/students/views/import_from_excel_view.dart';
import 'package:get/get.dart';
import 'package:attendance_tracker/app/modules/groups/views/create_group_view.dart';
import 'package:attendance_tracker/app/modules/students/bindings/studnets_binding.dart';
import 'package:attendance_tracker/app/modules/students/views/create_student_view.dart';
import 'package:attendance_tracker/app/modules/students/views/students_view.dart';
import 'package:attendance_tracker/app/modules/subjects/views/create_subject_view.dart';

import '../modules/groups/bindings/groups_binding.dart';
import '../modules/groups/views/groups_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/subjects/bindings/subjects_binding.dart';
import '../modules/subjects/views/subjects_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.home;

  static final routes = [
    GetPage(
      name: _Paths.preferences,
      page: () => const PreferencesView(),
      binding: PreferencesBinding(),
    ),
    GetPage(
      name: _Paths.landing,
      page: () => const LandingView(),
      binding: LandingBinding(),
    ),
    GetPage(
      name: _Paths.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.groups,
      page: () => const GroupsView(),
      binding: GroupsBinding(),
      children: [
        GetPage(
          name: _Paths.createGroup,
          page: () => const CreateGroupView(),
          binding: GroupsBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.subjects,
      page: () => const SubjectsView(),
      binding: SubjectsBinding(),
      children: [
        GetPage(
          name: _Paths.createSubject,
          page: () => const CreateSubjectView(),
          binding: SubjectsBinding(),
        ),
        GetPage(
          name: _Paths.attendance,
          page: () => const AttendancesView(),
          binding: AttendanceBinding(),
        ),
        GetPage(
          name: _Paths.userAttendance,
          page: () => const UserAttendancesView(),
          binding: AttendanceBinding(),
        ),
        GetPage(
          name: _Paths.qrAttendance,
          page: () => const QrAttendanceView(),
          binding: AttendanceBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.students,
      page: () => const StudentsView(),
      binding: StudentsBinding(),
      children: [
        GetPage(
          name: _Paths.createStudent,
          page: () => const CreateStudentView(),
          binding: StudentsBinding(),
        ),
        GetPage(
          name: _Paths.importFromExcel,
          page: () => const ImportFromExcelView(),
          binding: StudentsBinding(),
        ),
      ],
    ),
  ];
}
