import 'package:attendance_tracker/app/components/custom_snackbar.dart';
import 'package:attendance_tracker/app/components/global_operation_widget.dart';
import 'package:attendance_tracker/app/data/local/database_helper.dart';
import 'package:attendance_tracker/app/data/models/subject.dart';
import 'package:attendance_tracker/app/services/database_execution_status.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class HomeController extends GetxController {
  late Database database;
  DatabaseExecutionStatus databaseExecutionStatus =
      DatabaseExecutionStatus.loading;
  int usersCount = 0;
  int groupsCount = 0;
  int subjectsCount = 0;
  Subject? latestSubject;

  getData() async {
    databaseExecutionStatus = DatabaseExecutionStatus.loading;
    usersCount = (await database.rawQuery("""
    SELECT COUNT(*) AS count FROM Users WHERE deleted = 0;
    """))[0]["count"] as int;
    subjectsCount = (await database.rawQuery("""
    SELECT COUNT(*) AS count FROM Subjects WHERE deleted = 0;
    """))[0]["count"] as int;
    groupsCount = (await database.rawQuery("""
    SELECT COUNT(*) AS count FROM Groups WHERE deleted = 0;
    """))[0]["count"] as int;

    var data = await database.rawQuery("""
    SELECT S.* FROM Attendance AS A
    JOIN Subjects AS S
    ON S.id = A.subjectId
    WHERE deleted = 0
    ORDER BY at DESC
    LIMIT 1
    """);
    if (data.isNotEmpty) {
      latestSubject = Subject.fromMap(data[0]);
    }
    databaseExecutionStatus = DatabaseExecutionStatus.success;
    update();
  }

  exportDatabase() async {
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
      CustomSnackBar.showCustomErrorSnackBar(
        title: "Aborted",
        message: "Directory is required",
      );
      return;
    }

    Get.offAll(
      GlobalOperationWidget(
        image: 'assets/images/Loading.svg',
        title: "Exporting Database",
        subTitle:
            "Exporting your database. Do not close the application unitl we done ",
        operation: () async {
          return await export(dir);
        },
      ),
    );
  }

  importDatabase() async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "Lack of permission",
        message: "Please add storage permission",
      );

      return;
    }

    var result = await FilePicker.platform.pickFiles(
      dialogTitle: "Select database file",
      allowMultiple: false,
      type: FileType.any,
    );
    var file = result?.files[0];
    if (file == null || (file.path?.isEmpty ?? false)) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "Aborted",
        message: "File is required",
      );
      return;
    }

    if (!file.path!.endsWith(".db")) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "Aborted",
        message: "Invalid db file",
      );
      return;
    }

    Get.offAll(
      GlobalOperationWidget(
        image: 'assets/images/Loading.svg',
        title: "Importing Database",
        subTitle:
            "Importing your database. Do not close the application unitl we done ",
        operation: () async {
          return await import(file.path!);
        },
      ),
    );
  }

  Future<String?> export(String dir) async {
    var result = await DatabaseHelper().exportDatabase(dir);
    return result != null ? "Exported to $result" : null;
  }

  Future<String?> import(String path) async {
    return (await DatabaseHelper().importDatabase(path))
        ? "Imported Succesfaully"
        : null;
  }

  initialize() async {
    database = await DatabaseHelper().database;
    await getData();
  }

  @override
  onInit() {
    initialize();
    super.onInit();
  }
}
