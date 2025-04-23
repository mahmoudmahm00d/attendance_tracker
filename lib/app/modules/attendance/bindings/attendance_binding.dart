import 'package:get/get.dart';
import 'package:attendance_tracker/app/data/repositories/attendance_repository.dart';
import 'package:attendance_tracker/app/data/repositories/groups_repository.dart';
import 'package:attendance_tracker/app/data/repositories/students_repository.dart';
import 'package:attendance_tracker/app/data/repositories/subjects_repository.dart';
import 'package:attendance_tracker/app/modules/attendance/controllers/qr_attendance_controller.dart';
import 'package:attendance_tracker/app/modules/attendance/controllers/attendance_controller.dart';
import 'package:attendance_tracker/app/modules/attendance/controllers/user_attendance_controller.dart';

class AttendanceBinding extends Bindings {
  @override
  void dependencies() async {
    Get.lazyPut<AttendanceController>(
      () => AttendanceController(
        AttendanceRepository(),
        SubjectsRepository(),
        GroupsRepository(),
      ),
    );

    Get.lazyPut<UserAttendanceController>(
      () => UserAttendanceController(AttendanceRepository()),
    );

    Get.lazyPut<QrAttendanceController>(
      () => QrAttendanceController(
        AttendanceRepository(),
        StudentsRepository(),
      ),
    );
  }
}
