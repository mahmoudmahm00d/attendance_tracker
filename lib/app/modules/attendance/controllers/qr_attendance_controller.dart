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
  RxSet<User> students = RxSet<User>();
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
          result.value = "User not found";
          return;
        }

        if (!students.contains(latestStudent.value)) {
          students.add(latestStudent.value!);
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
    if (autoSave.value) {
      await repository.addAttendance(Attendance(
        id: "${subject.id}:${latestStudent.value!.id}:$today",
        at: DateTime.now(),
        subjectId: subject.id,
        userId: latestStudent.value!.id,
      ));
    } else {
      for (var student in students) {
        await repository.addAttendance(Attendance(
          id: "${subject.id}:${student.id}:$today",
          at: DateTime.now(),
          subjectId: subject.id,
          userId: student.id,
        ));
      }
    }

    status.value = DatabaseExecutionStatus.success;
    Get.snackbar(
      "Success",
      autoSave.value
          ? "${latestStudent.value!.name} added successfully"
          : "${students.length} students added successfully",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(milliseconds: 800),
    );

    latestStudent.value = null;
  }
}
