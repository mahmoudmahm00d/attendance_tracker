import 'dart:io';

import 'package:attendance_tracker/app/components/custom_snackbar.dart';
import 'package:attendance_tracker/app/data/local/my_shared_pref.dart';
import 'package:attendance_tracker/app/data/repositories/students_repository.dart';
import 'package:attendance_tracker/app/services/pdf_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:attendance_tracker/app/data/local/database_helper.dart';
import 'package:attendance_tracker/app/data/models/group.dart';
import 'package:attendance_tracker/app/data/models/user.dart';
import 'package:attendance_tracker/app/services/database_execution_status.dart';
import 'package:attendance_tracker/app/services/excel_service.dart' as excel;
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class StudentsController extends GetxController {
  final StudentsRepository repository;
  StudentsController(this.repository);

  int page = 0;
  final int length = MySharedPref.getPageSize();
  int studentsCount = 0;
  int queryStudentsCount = 0;
  bool get hasMoreData => (queryStudentsCount - users.length) > 0;
  Group? group = Get.arguments;
  late Database database;
  DatabaseExecutionStatus defaultQueryStatus = DatabaseExecutionStatus.loading;
  DatabaseExecutionStatus searchQueryStatus = DatabaseExecutionStatus.success;
  DatabaseExecutionStatus loadingGroupsQueryStatus =
      DatabaseExecutionStatus.loading;
  DatabaseExecutionStatus loadingMoreDataStatus =
      DatabaseExecutionStatus.success;
  DatabaseExecutionStatus managingGroups = DatabaseExecutionStatus.success;
  TextEditingController search = TextEditingController();
  bool selectionEnabled = false;
  List<User> users = [];
  Set<User> selectedUsers = {};
  List<Group> groups = [];
  Set<Group> selectedGroups = <Group>{};
  String? selectedManagedGroup;
  Set<Group> selectedManagedGroups = <Group>{};
  bool filtering = false;
  bool showDeleted = false;
  Debouncer debouncer = Debouncer(delay: const Duration(milliseconds: 300));

  Future getGroups() async {
    loadingGroupsQueryStatus = DatabaseExecutionStatus.loading;
    update();
    groups = (await database.query("Groups", where: 'deleted = 0'))
        .map(Group.fromMap)
        .toList();
    loadingGroupsQueryStatus = DatabaseExecutionStatus.success;
    update();
  }

  onShowDeleted(showDeleted) {
    this.showDeleted = showDeleted;
    update();
  }

  applyFilters({bool goBack = false}) {
    if (goBack) {
      Get.back();
    }
    filtering = true;
    page = 0;
    users = [];
    getStudents();
  }

  removeFilters({bool goBack = false}) {
    if (goBack) {
      Get.back();
    }
    filtering = false;
    selectedGroups.clear();
    page = 0;
    users = [];
    getStudents();
  }

  selectAll() {
    selectedUsers.addAll(users);
    update();
  }

  unSelectAll() {
    selectedUsers.clear();
    update();
  }

  refreshData() {
    page = 0;
    users = [];
    getStudents(group: group, query: search.text);
  }

  Future getStudents({
    Group? group,
    String query = "",
    bool loadingMoreData = false,
  }) async {
    if (loadingMoreData) {
      loadingMoreDataStatus = DatabaseExecutionStatus.loading;
    } else if (query.isNotEmpty) {
      searchQueryStatus = DatabaseExecutionStatus.loading;
    } else {
      defaultQueryStatus = DatabaseExecutionStatus.loading;
    }
    update();

    studentsCount = await repository.getStudentsCount();

    var result = await repository.getStudents(
      groupId: group?.id,
      groupIds: selectedGroups.map((group) => group.id).toList(),
      searchQuery: query,
      showDeleted: showDeleted,
      pageSize: length,
      page: page,
    );
    queryStudentsCount = result.count;
    if (!loadingMoreData) {
      users = result.data;
    } else {
      users.addAll(result.data);
    }
    if (loadingMoreData) {
      loadingMoreDataStatus = DatabaseExecutionStatus.success;
    } else if (query.isNotEmpty) {
      searchQueryStatus = DatabaseExecutionStatus.success;
    } else {
      defaultQueryStatus = DatabaseExecutionStatus.success;
    }
    update();
  }

  loadMore() async {
    page++;
    await getStudents(
      group: group,
      query: search.text,
      loadingMoreData: true,
    );
  }

  onSearchChanged(String? value) async {
    debouncer.call(
      () async {
        page = 0;
        users = [];
        await getStudents(
          group: group,
          query: search.text,
        );
      },
    );
  }

  deleteStudent(User user) async {
    defaultQueryStatus = DatabaseExecutionStatus.loading;
    update();
    var result = await repository.deleteStudent(user);
    if (result == 1) {
      getStudents(group: group, query: search.text);
    }
    defaultQueryStatus = DatabaseExecutionStatus.loading;
    update();
  }

  softDeleteStudent(User user) async {
    defaultQueryStatus = DatabaseExecutionStatus.loading;
    update();
    var result = user.deleted == 1
        ? await repository.restoreDeletedStudent(user)
        : await repository.softDeleteStudent(user);
    if (result == 1) {
      getStudents(group: group, query: search.text);
    }
    defaultQueryStatus = DatabaseExecutionStatus.success;
    update();
  }

  exportStudents() async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "Lack of permission",
        message: "Please add storage permission",
      );

      return;
    }

    var dir = await FilePicker.platform.getDirectoryPath();
    if (dir == null || dir.isEmpty) {
      return;
    }

    try {
      var fileBytes = excel.generateStudentsFile(users);
      var path =
          "$dir/exported-students-${DateFormat("yyyy-MM-dd").format(DateTime.now())}.xlsx";
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes!);
      CustomSnackBar.showCustomSnackBar(
        title: "Students data exported successfully",
        message: "Report saved at $path",
      );
    } on Exception {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "Failed to export students",
        message: "Please check storage permission",
      );
    }
  }

  generateQr() async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "Lack of permission",
        message: "Please add storage permission",
      );

      return;
    }

    var isArabic = false;
    await Get.defaultDialog(
      cancel: TextButton(
        onPressed: () {
          Get.back();
          update();
        },
        child: const Text("no"),
      ),
      confirm: TextButton(
        onPressed: () {
          isArabic = true;
          Get.back();
          update();
        },
        child: const Text("Yes use Arabic"),
      ),
      titleStyle: Get.context!.textTheme.titleLarge,
      title: "Use Arabic font?",
      middleText: "This will make the directionality rtl",
      barrierDismissible: false,
    );

    var pdf = await generatePDF(
        "Students QRs",
        users
            .map(
              (user) => PDFData(
                data: user.id,
                name: "${user.name}\n${user.fatherName}",
              ),
            )
            .toList(),
        size: BarcodeSize.small,
        isArabic: isArabic);

    var dir = await FilePicker.platform.getDirectoryPath();
    if (dir == null || dir.isEmpty) {
      return;
    }
    try {
      String filePath;
      var now = DateTime.now();
      if (group != null) {
        filePath =
            "$dir/QRs-${group!.name}-${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}-${now.second}.pdf";
      } else {
        filePath = "$dir/QRs.pdf";
      }
      File(join(filePath))
        ..createSync(recursive: true)
        ..writeAsBytesSync(pdf);
      Get.snackbar(
        'Success',
        'Saved Successfully at "$dir/QRs.pdf"',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on Exception {
      Get.snackbar(
        "Error",
        "Something went wrong",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  saveGroups() async {
    if (selectedUsers.isEmpty) return;
    managingGroups = DatabaseExecutionStatus.loading;
    update();
    await repository.bulkUpdateGroups(
      selectedUsers.toList(),
      selectedManagedGroup,
      selectedManagedGroups.map((group) => group.id).toList(),
    );

    managingGroups = DatabaseExecutionStatus.success;

    Get.back();
    CustomSnackBar.showCustomSnackBar(
        title: "Students updated successfully",
        message: "${selectedUsers.length} has been updated");
    selectionEnabled = false;
    selectedManagedGroup = null;
    selectedManagedGroups.clear();
    selectedUsers.clear();
    update();
    getStudents();
  }

  @override
  void onInit() {
    initialize();
    super.onInit();
  }

  Future<void> initialize() async {
    database = await DatabaseHelper().database;
    await getStudents(group: group);
  }
}
