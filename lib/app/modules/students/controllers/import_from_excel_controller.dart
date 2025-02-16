import 'package:attendance_tracker/app/components/custom_snackbar.dart';
import 'package:attendance_tracker/app/data/local/database_helper.dart';
import 'package:attendance_tracker/app/data/models/group.dart';
import 'package:attendance_tracker/app/data/models/user.dart';
import 'package:attendance_tracker/app/data/repositories/students_repository.dart';
import 'package:attendance_tracker/app/services/database_execution_status.dart';
import 'package:attendance_tracker/app/services/excel_service.dart' as excel;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class ImportFromExcelController extends GetxController {
  final StudentsRepository repository;
  ImportFromExcelController(this.repository);

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  DatabaseExecutionStatus loadingGroups = DatabaseExecutionStatus.loading;
  User? user = Get.arguments;
  bool get isEdit => user != null;
  late Database database;
  String? groupId;
  List<Group> groups = [];
  Set<Group> selectedGroups = <Group>{};
  PlatformFile? file;
  String? filePath;
  bool processing = false;

  Future<List<Group>> getGroups() async {
    return (await database.query("Groups", where: "deleted = 0"))
        .map(Group.fromMap)
        .toList();
  }

  pickFile() async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "Lack of permission",
        message: "Please add storage permission",
      );

      return;
    }

    var pickedFile = await FilePicker.platform.pickFiles(
      dialogTitle: "Select students excel file",
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ["xlsx"],
    );

    if (pickedFile == null) {
      return;
    }

    file = pickedFile.files[0];
    filePath = file?.path;
    update();
  }

  import() async {
    if (filePath == null) {
      Get.snackbar(
        "File is required",
        "Please select file first",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (processing) {
      return;
    }

    processing = true;
    var users = await excel.getUsers(filePath!, groupId);
    int usersAdded = 0;

    for (var user in users) {
      try {
        var result = await repository.addStudent(
          user,
          selectedGroups.map((group) => group.id).toList(),
        );
        if (result != 0) {
          usersAdded++;
        }
      } on Exception {
        continue;
      }
    }

    if (usersAdded == 0) {
      Get.snackbar(
        "No users added",
        "No users found",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      processing = false;
      return;
    }

    Get.back();
    Get.snackbar(
      "Users added successfully",
      "$usersAdded added successfully",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    processing = false;
  }

  Future<void> initialize() async {
    database = await DatabaseHelper().database;
    groups = await getGroups();
    loadingGroups = DatabaseExecutionStatus.success;
    update();
  }

  @override
  void onInit() {
    initialize();
    super.onInit();
  }
}
