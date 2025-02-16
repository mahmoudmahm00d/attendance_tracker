import 'package:get/get.dart';
import 'package:attendance_tracker/app/data/models/attendance.dart';
import 'package:attendance_tracker/app/data/models/user.dart';
import 'package:attendance_tracker/app/data/repositories/attendance_repository.dart';
import 'package:attendance_tracker/app/data/models/subject.dart';
import 'package:attendance_tracker/app/services/database_execution_status.dart';

class UserAttendanceController extends GetxController {
  Subject subject = Get.arguments["subject"];
  User user = Get.arguments["user"];
  DatabaseExecutionStatus status = DatabaseExecutionStatus.loading;
  List<Attendance> attendance = [];

  final AttendanceRepository repository;
  UserAttendanceController(this.repository);

  getAttendance() async {
    status = DatabaseExecutionStatus.loading;
    update();
    attendance = await repository.getUserAttendance(user.id, subject.id);
    status = DatabaseExecutionStatus.success;
    update();
  }

  delete(int index) async {
    await repository.deleteAttendance(attendance[index].id);
    getAttendance();
  }

  @override
  void onInit() async {
    await getAttendance();
    super.onInit();
  }
}
