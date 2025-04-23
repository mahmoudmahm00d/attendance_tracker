import 'package:attendance_tracker/app/components/custom_snackbar.dart';
import 'package:attendance_tracker/config/translations/strings_enum.dart';
import 'package:get/get.dart';
import 'package:attendance_tracker/app/data/models/attendance.dart';
import 'package:attendance_tracker/app/data/models/user.dart';
import 'package:attendance_tracker/app/data/repositories/attendance_repository.dart';
import 'package:attendance_tracker/app/data/models/subject.dart';
import 'package:attendance_tracker/app/services/database_execution_status.dart';
import 'package:intl/intl.dart';

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

  Future<int> add(DateTime date) async {
    var at = DateFormat("yyyy-MM-dd").format(date);
    var result = await repository.addAttendance(
      Attendance(
        id: "${subject.id}:${user.id}:$at",
        userId: user.id,
        subjectId: subject.id,
        at: date,
      ),
    );

    if (result != 0) {
      getAttendance();
    } else {
      CustomSnackBar.showCustomErrorSnackBar(
        title: Strings.error.tr,
        message: Strings.noStudentFound.tr,
      );
    }

    return result;
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
