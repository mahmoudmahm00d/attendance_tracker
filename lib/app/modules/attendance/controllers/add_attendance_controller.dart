import 'package:attendance_tracker/config/translations/strings_enum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ulid/ulid.dart';

import 'package:attendance_tracker/app/components/custom_snackbar.dart';
import 'package:attendance_tracker/app/data/models/attendance.dart';
import 'package:attendance_tracker/app/data/models/user.dart';
import 'package:attendance_tracker/app/data/repositories/attendance_repository.dart';
import 'package:attendance_tracker/app/modules/attendance/controllers/user_attendance_controller.dart';
import 'package:attendance_tracker/app/data/models/subject.dart';

class AddAttendanceController extends GetxController {
  final AttendanceRepository repository;
  AddAttendanceController(this.repository);

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  User? user = Get.arguments["user"];
  Subject? subject = Get.arguments["subject"];
  Attendance? attendance = Get.arguments["attendance"];

  TextEditingController nameController = TextEditingController();

  DateTime? date;

  void add() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (date == null) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: Strings.dateIsRequired.tr,
        message: Strings.selectDateToAddAttendance.tr,
      );
    }

    var result = await repository.addAttendance(
      Attendance(
        id: Ulid.new().toString(),
        userId: user!.id,
        subjectId: subject!.id,
        at: date!,
      ),
    );

    if (result != 0) {
      Get.back();
      Get.find<UserAttendanceController>().getAttendance();
    }
  }
}
