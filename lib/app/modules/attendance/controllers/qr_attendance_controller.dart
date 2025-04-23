import 'package:attendance_tracker/config/translations/strings_enum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:attendance_tracker/app/data/models/attendance.dart';
import 'package:attendance_tracker/app/data/models/subject.dart';
import 'package:attendance_tracker/app/data/models/user.dart';
import 'package:attendance_tracker/app/data/repositories/attendance_repository.dart';
import 'package:attendance_tracker/app/data/repositories/students_repository.dart';
import 'package:attendance_tracker/app/services/database_execution_status.dart';

class QrAttendanceController extends GetxController {
  Subject subject = Get.arguments;
  QRViewController? qrViewController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool isProcessing = false;
  Rx<DatabaseExecutionStatus> status =
      Rx<DatabaseExecutionStatus>(DatabaseExecutionStatus.success);
  RxBool isScanning = false.obs;
  RxString result = "".obs;
  Rx<User?> latestStudent = Rx<User?>(null);
  RxList<User> students = RxList<User>();
  RxBool autoSave = false.obs;
  bool showSessionUsers = false;

  final AttendanceRepository repository;
  final StudentsRepository studentsRepository;
  QrAttendanceController(this.repository, this.studentsRepository);

  void onQRViewCreated(QRViewController controller) {
    qrViewController = controller;
    qrViewController!.scannedDataStream.listen(
      (scanData) async {
        if (isProcessing) return;
        if (scanData.code == null) return;

        isProcessing = true;
        latestStudent.value =
            await studentsRepository.getStudent(scanData.code!);

        if (latestStudent.value == null) {
          result.value = Strings.userNotFound;
          return;
        }

        if (!students.contains(latestStudent.value)) {
          students.insert(0, latestStudent.value!);
          if (autoSave.value) {
            await addAttendance();
          }
        }
        isProcessing = false;
      },
    );
  }

  addAttendance() async {
    if (latestStudent.value == null && students.isEmpty) return;

    status.value = DatabaseExecutionStatus.loading;
    var today = DateFormat("yyyy-MM-dd").format(DateTime.now());
    var result = 0;
    if (autoSave.value) {
      result += await repository.addAttendance(
        Attendance(
          id: "${subject.id}:${latestStudent.value!.id}:$today",
          at: DateTime.now(),
          subjectId: subject.id,
          userId: latestStudent.value!.id,
        ),
      );
    } else {
      for (var student in students) {
        result += await repository.addAttendance(
          Attendance(
            id: "${subject.id}:${student.id}:$today",
            at: DateTime.now(),
            subjectId: subject.id,
            userId: student.id,
          ),
        );
      }
    }

    status.value = DatabaseExecutionStatus.success;
    if (result < students.length) {
      Get.snackbar(
        Strings.error.tr,
        Strings.countStudentsAddedSuccessfully
            .trParams({'count': result.toString()}),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 800),
      );
    } else {
      Get.snackbar(
        Strings.success.tr,
        autoSave.value
            ? Strings.usernameAddedSuccessfully
                .trParams({'name': latestStudent.value!.name})
            : Strings.countStudentsAddedSuccessfully
                .trParams({'count': students.length.toString()}),
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 800),
      );
    }
  }
}
