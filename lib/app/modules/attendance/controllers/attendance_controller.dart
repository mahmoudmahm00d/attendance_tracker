import 'dart:io';
import 'package:attendance_tracker/config/translations/strings_enum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import 'package:attendance_tracker/app/components/custom_snackbar.dart';
import 'package:attendance_tracker/app/data/local/my_shared_pref.dart';
import 'package:attendance_tracker/app/data/models/attendance.dart';
import 'package:attendance_tracker/app/data/models/group.dart';
import 'package:attendance_tracker/app/data/repositories/attendance_repository.dart';
import 'package:attendance_tracker/app/data/repositories/groups_repository.dart';
import 'package:attendance_tracker/app/data/repositories/subjects_repository.dart';
import 'package:attendance_tracker/app/data/models/subject.dart';
import 'package:attendance_tracker/app/services/database_execution_status.dart';
import 'package:attendance_tracker/app/services/excel_service.dart' as excel;
import 'package:permission_handler/permission_handler.dart';

class AttendanceController extends GetxController {
  int page = 0;
  final int length = MySharedPref.getPageSize();

  int studentsCount = 0;
  int attendanceCount = 0;
  int queryCount = 0;

  Subject? subject;
  DatabaseExecutionStatus status = DatabaseExecutionStatus.loading;
  List<UserAttendance> attendance = [];

  // Pagination
  bool get hasMoreData => (queryCount - attendance.length) > 0;
  DatabaseExecutionStatus loadingMoreDataStatus =
      DatabaseExecutionStatus.success;

  // Selection
  var selectionEnabled = false;
  Set<UserAttendance> selectedAttendance = {};

  // Filtering
  Rx<DatabaseExecutionStatus> loadingGroups =
      Rx(DatabaseExecutionStatus.loading);
  Rx<DatabaseExecutionStatus> loadingDates =
      Rx(DatabaseExecutionStatus.loading);
  var filtering = false.obs;
  List<Group> groups = [];
  RxSet<Group> selectedGroups = RxSet<Group>();
  Set<String> dates = <String>{};
  Set<String> selectedDates = <String>{};
  var nonZeroAttendance = false.obs;
  var selectedAttendanceCount = 0.obs;
  RxBool filterByCount = false.obs;

  // Searching
  DatabaseExecutionStatus searching = DatabaseExecutionStatus.success;
  TextEditingController search = TextEditingController();
  var showSearch = false.obs;
  var debouncer = Debouncer(delay: const Duration(milliseconds: 500));

  final AttendanceRepository repository;
  final SubjectsRepository subjectsRepository;
  final GroupsRepository groupssRepository;

  AttendanceController(
    this.repository,
    this.subjectsRepository,
    this.groupssRepository,
  );

  onSearchChanged(String? value) async {
    page = 0;
    attendance = [];
    debouncer.call(
      () async {
        await getAttendance(
          subject: subject,
          searchQuery: search.text.trim(),
        );
      },
    );
  }

  onNonZeroAttendance(bool? value) {
    nonZeroAttendance.value = value as bool;
  }

  // Filters View Preperation
  getGroups() async {
    loadingGroups.value = DatabaseExecutionStatus.loading;
    update();
    groups = await groupssRepository.getGroups();
    loadingGroups.value = DatabaseExecutionStatus.success;
    update();
  }

  getDates() async {
    loadingDates.value = DatabaseExecutionStatus.loading;
    update();
    dates = (await subjectsRepository.getSubjectAttendanceDates(subject!.id))
        .map((item) => item.$1)
        .toSet();
    loadingDates.value = DatabaseExecutionStatus.success;
    update();
  }

  applyFilters({bool goBack = false}) {
    if (goBack) {
      Get.back();
    }
    filtering.value = true;
    page = 0;
    attendance = [];
    getAttendance(subject: subject);
  }

  removeFilters({bool goBack = false}) {
    if (goBack) {
      Get.back();
    }
    filtering.value = false;
    selectedGroups.clear();
    page = 0;
    attendance = [];
    getAttendance(subject: subject);
  }

  refreshData() {
    page = 0;
    attendance = [];
    getAttendance(subject: subject);
  }

  loadMore() async {
    page++;
    await getAttendance(
      subject: subject,
      searchQuery: search.text,
      loadingMoreData: true,
    );
  }

  getAttendance({
    Subject? subject,
    String searchQuery = "",
    bool loadingMoreData = false,
  }) async {
    if (loadingMoreData) {
      loadingMoreDataStatus = DatabaseExecutionStatus.loading;
    } else if (showSearch.value) {
      searching = DatabaseExecutionStatus.loading;
    } else {
      status = DatabaseExecutionStatus.loading;
    }
    update();

    attendanceCount = await repository.getMaxAttendanceCount(subject!.id);
    studentsCount = await repository.getAttendanceCount(subject.groupId);
    var groupIds = selectedGroups.map((group) => group.id).toList();
    var result = await repository.getAttendance(
      subject.id,
      subject.groupId,
      groupIds: groupIds,
      nonZeroAttendance: nonZeroAttendance.value,
      selectedDates: selectedDates.toList(),
      searchQuery: searchQuery,
      count: filterByCount.value ? selectedAttendanceCount.value : -1,
      page: page,
      pageSize: length,
    );

    queryCount = result.count;

    if (loadingMoreData) {
      attendance.addAll(result.data);
    } else {
      attendance = result.data;
    }

    if (loadingMoreData) {
      loadingMoreDataStatus = DatabaseExecutionStatus.success;
    } else if (showSearch.value) {
      searching = DatabaseExecutionStatus.success;
    } else {
      status = DatabaseExecutionStatus.success;
    }
    update();
  }

  // Quick Add
  addAttendance(UserAttendance user, DateTime date) async {
    var at = DateFormat("yyyy-MM-dd").format(date);
    var result = await repository.addAttendance(
      Attendance(
        id: "${subject!.id}:${user.id}:$at",
        userId: user.id,
        subjectId: subject!.id,
        at: date,
      ),
    );

    if (result != 0) {
      CustomSnackBar.showCustomSnackBar(
        title: Strings.attendanceAddedSuccessfully.tr,
        message: Strings.addedAttendanceAt.tr
            .replaceFirst("@date", DateFormat("yyyy-MM-dd").format(date))
            .replaceFirst("@name", user.name),
      );
      getAttendance(
        searchQuery: search.text,
        subject: subject,
      );

      return;
    }

    CustomSnackBar.showCustomErrorSnackBar(
      title: Strings.error.tr,
      message: Strings.noStudentFound.tr,
    );
  }

  // Bulk Add
  addAttendances(DateTime date) async {
    String at = DateFormat("yyyy-MM-dd").format(date);
    for (var student in selectedAttendance) {
      await repository.addAttendance(
        Attendance(
          id: "${subject!.id}:${student.id}:$at",
          userId: student.id,
          subjectId: subject!.id,
          at: date,
        ),
      );
    }

    CustomSnackBar.showCustomSnackBar(
      title: Strings.attendanceAddedSuccessfully.tr,
      message: Strings.attendancesAddedSuccessfully.tr
          .replaceFirst("@date", at)
          .replaceFirst("@count", selectedAttendance.length.toString()),
    );
    getAttendance(
      searchQuery: search.text,
      subject: subject,
    );
  }

  deleteAttendance(int index) async {
    await repository.deleteAttendance(attendance[index].id);
    getAttendance(subject: subject);
  }

  generateExcel() async {
    var storageStatus = await Permission.storage.request();
    var status = await Permission.manageExternalStorage.request();
    if (!status.isGranted && !storageStatus.isGranted) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: Strings.lackOfPermission.tr,
        message: Strings.addStoragePermission.tr,
      );

      return;
    }

    bool detailed = false;
    await Get.defaultDialog(
      onWillPop: () async => false,
      titlePadding: const EdgeInsets.all(16),
      cancel: TextButton(
        onPressed: () {
          Get.back();
          update();
        },
        child: Text(Strings.noExportNormalExcel.tr),
      ),
      confirm: ElevatedButton(
        onPressed: () {
          detailed = true;
          Get.back();
          update();
        },
        child: Text(Strings.yesExportDetailed.tr),
      ),
      titleStyle: Get.context!.textTheme.titleLarge,
      title: Strings.exportDetailedExcelFileTitle.tr,
      middleText: Strings.exportDetailedExcelFileMiddleText.tr,
      barrierDismissible: false,
    );

    var dir = await FilePicker.platform.getDirectoryPath();
    if (dir == null || dir.isEmpty) {
      return;
    }

    var result = await repository.getAttendance(
      subject!.id,
      subject!.groupId,
      orderByCount: false,
      pageSize: 0,
    );

    var dates = await subjectsRepository.getSubjectAttendanceDates(subject!.id);

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
    List<int>? fileBytes;
    if (!detailed) {
      fileBytes = excel.generateAttendanceReport(
          subject!.name, attendanceCount, dates.toList(), result.data);
    } else {
      var query = await repository.getDetailedAttendance(
        subject!.id,
        subject!.groupId,
        pageSize: 0,
      );
      fileBytes = excel.generateDetailedAttendanceReport(
          subject!.name, attendanceCount, dates.toList(), query.data);
    }

    try {
      var now = DateTime.now();
      var path = join(
        dir,
        "${subject!.name}-attendance-students-${DateFormat("yyyy-MM-dd-hh-mm-ss").format(now)}.xlsx",
      );
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes!);

      Get.back();
      CustomSnackBar.showCustomSnackBar(
          title: Strings.attendanceReportGeneratedSuccessfully.tr,
          message: Strings.fileSavedAt.tr.replaceFirst("@path", path));
    } on Exception {
      Get.back();
      CustomSnackBar.showCustomErrorSnackBar(
        title: Strings.failedToGenerateFile.tr,
        message: Strings.checkStoragePermission.tr,
      );
    }
  }

  Future<void> initialize() async {
    await getAttendance(subject: subject);
    selectedAttendanceCount.value = attendanceCount;
  }

  @override
  void onInit() {
    subject = Get.arguments;
    initialize();
    super.onInit();
  }
}
