import 'package:attendance_tracker/app/data/repositories/groups_repository.dart';
import 'package:attendance_tracker/app/data/repositories/students_repository.dart';
import 'package:attendance_tracker/app/modules/students/controllers/import_from_excel_controller.dart';
import 'package:get/get.dart';

import '../controllers/create_student_controller.dart';
import '../controllers/students_controller.dart';

class StudentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentsController>(
      () => StudentsController(
        StudentsRepository(),
      ),
    );
    Get.lazyPut<CreateStudentController>(
      () => CreateStudentController(
        StudentsRepository(),
        GroupsRepository(),
      ),
    );
    Get.lazyPut<ImportFromExcelController>(
      () => ImportFromExcelController(StudentsRepository()),
    );
  }
}
