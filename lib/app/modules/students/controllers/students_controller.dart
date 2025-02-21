import 'dart:io';

import 'package:attendance_tracker/app/components/custom_snackbar.dart';
import 'package:attendance_tracker/app/data/local/my_shared_pref.dart';
import 'package:attendance_tracker/app/data/repositories/students_repository.dart';
import 'package:attendance_tracker/app/services/pdf_service.dart';
import 'package:attendance_tracker/config/translations/strings_enum.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
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
  DatabaseExecutionStatus queryStatus = DatabaseExecutionStatus.success;
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
  bool get filtering => showDeleted || selectedGroups.isNotEmpty;
  bool showDeleted = false;
  Debouncer debouncer = Debouncer(delay: const Duration(milliseconds: 500));
  bool isProcessing = false;

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
    page = 0;
    users = [];
    getStudents();
  }

  removeFilters({bool goBack = false}) {
    if (goBack) {
      Get.back();
    }
    showDeleted = false;
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
    } else {
      queryStatus = DatabaseExecutionStatus.loading;
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
    } else {
      queryStatus = DatabaseExecutionStatus.success;
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
    queryStatus = DatabaseExecutionStatus.loading;
    update();
    var result = await repository.deleteStudent(user);
    if (result == 1) {
      getStudents(group: group, query: search.text);
    }
    queryStatus = DatabaseExecutionStatus.loading;
    update();
  }

  softDeleteStudent(User user) async {
    queryStatus = DatabaseExecutionStatus.loading;
    update();
    var result = user.deleted == 1
        ? await repository.restoreDeletedStudent(user)
        : await repository.softDeleteStudent(user);
    if (result == 1) {
      getStudents(group: group, query: search.text);
    }
    queryStatus = DatabaseExecutionStatus.success;
    update();
  }

  exportStudents() async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: Strings.lackOfPermission.tr,
        message: Strings.addStoragePermission.tr,
      );

      return;
    }

    isProcessing = true;
    var export = false;
    await Get.defaultDialog(
      titlePadding: const EdgeInsets.all(16),
      cancel: TextButton(
        onPressed: () {
          Get.back();
          update();
        },
        child: const Text("Cancel"),
      ),
      confirm: ElevatedButton(
        onPressed: () {
          export = true;
          Get.back();
          update();
        },
        child: const Text("Yes Export"),
      ),
      titleStyle: Get.context!.textTheme.titleLarge,
      title: Strings.exportingStudentsTitle.tr,
      middleText: Strings.exportingStudentsMessage.tr,
      barrierDismissible: false,
    );

    if (!export) {
      isProcessing = false;
      return;
    }

    var dir = await FilePicker.platform.getDirectoryPath();
    if (dir == null || dir.isEmpty) {
      isProcessing = false;
      return;
    }

    try {
      Get.dialog(
        PopScope(
          canPop: false,
          child: CupertinoActivityIndicator(
            radius: 16,
            color: Get.context?.theme.primaryColor,
          ),
        ),
        barrierColor: Get.context?.theme.scaffoldBackgroundColor,
        barrierDismissible: false,
      );
      var result = await repository.getStudents(
        groupId: group?.id,
        groupIds: selectedGroups.map((group) => group.id).toList(),
        pageSize: 0,
        page: 0,
      );
      var fileBytes = excel.generateStudentsFile(result.data);
      var path =
          "$dir/exported-students-${DateFormat("yyyy-MM-dd").format(DateTime.now())}.xlsx";
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes!);
      Get.back();
      CustomSnackBar.showCustomSnackBar(
        title: Strings.studentsExportedSuccessfully.tr,
        message: Strings.fileSavedAt.tr.replaceFirst('@path', path),
      );
      isProcessing = false;
    } on Exception {
      Get.back();
      CustomSnackBar.showCustomErrorSnackBar(
        title: Strings.failedToGenerateFile.tr,
        message: Strings.checkStoragePermission.tr,
      );
      isProcessing = false;
    }
  }

  generateQr() async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: Strings.lackOfPermission.tr,
        message: Strings.addStoragePermission.tr,
      );

      return;
    }

    isProcessing = true;
    var isArabic = false;
    await Get.defaultDialog(
      onWillPop: () async => false,
      titlePadding: const EdgeInsets.all(16),
      cancel: TextButton(
        onPressed: () {
          Get.back();
          update();
        },
        child: Text(Strings.noUseEnglish.tr),
      ),
      confirm: ElevatedButton(
        onPressed: () {
          isArabic = true;
          Get.back();
          update();
        },
        child: Text(Strings.yseUseArabic.tr),
      ),
      titleStyle: Get.context!.textTheme.titleLarge,
      title: Strings.exportStudentsWithAppliedFilters.tr,
      middleText: Strings.textDirectionToRTL.tr,
      barrierDismissible: false,
    );

    var dir = await FilePicker.platform.getDirectoryPath();
    if (dir == null || dir.isEmpty) {
      isProcessing = false;
      return;
    }

    // TODO: Handle QR the right way (selected)
    // TODO: Update the dialog message to be more clear
    try {
      Get.dialog(
        PopScope(
          canPop: false,
          child: CupertinoActivityIndicator(
            radius: 16,
            color: Get.context?.theme.primaryColor,
          ),
        ),
        barrierColor: Get.context?.theme.scaffoldBackgroundColor,
        barrierDismissible: false,
      );
      var result = await repository.getStudents(
        groupId: group?.id,
        groupIds: selectedGroups.map((group) => group.id).toList(),
        pageSize: 0,
        page: 0,
      );
      var pdf = await generatePDF(
        "Students QRs",
        result.data
            .map(
              (user) => PDFData(
                data: user.id,
                name: "${user.name}\n${user.fatherName}",
              ),
            )
            .toList(),
        size: BarcodeSize.small,
        isArabic: isArabic,
      );

      String filePath;
      if (group != null) {
        filePath =
            "$dir/QRs-${group!.name}-${DateFormat("yyyy-MM-dd-hh-mm-ss").format(DateTime.now())}.pdf";
      } else {
        filePath =
            "$dir/QRs-${DateFormat("yyyy-MM-dd-hh-mm-ss").format(DateTime.now())}.pdf";
      }
      File(join(filePath))
        ..createSync(recursive: true)
        ..writeAsBytesSync(pdf);
      Get.back();
      Get.snackbar(
        Strings.success.tr,
        Strings.fileSavedAt.tr.replaceFirst('@path', filePath),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      isProcessing = false;
    } on Exception {
      Get.back();
      Get.snackbar(
        Strings.error.tr,
        Strings.somethingWentWrong.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      isProcessing = false;
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
      title: Strings.studentsUpdatedSuccessfully.tr,
      message: Strings.countStudentsUpdated.tr.replaceFirst(
        '@count',
        selectedUsers.length.toString(),
      ),
    );
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
