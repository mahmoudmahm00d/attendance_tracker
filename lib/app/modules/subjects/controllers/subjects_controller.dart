import 'package:get/get.dart';
import 'package:attendance_tracker/app/data/repositories/subjects_repository.dart';
import 'package:attendance_tracker/app/data/models/group.dart';
import 'package:attendance_tracker/app/data/models/subject.dart';
import 'package:attendance_tracker/app/services/database_execution_status.dart';

class SubjectsController extends GetxController {
  Group? group = Get.arguments;
  DatabaseExecutionStatus status = DatabaseExecutionStatus.loading;
  List<Subject> subjects = [];
  bool showDeleted = false;

  final SubjectsRepository repository;
  SubjectsController(this.repository);

  getSubjects({Group? group}) async {
    status = DatabaseExecutionStatus.loading;
    subjects = await repository.getSubjects(
      groupId: group?.id,
      showDeleted: showDeleted,
    );
    status = DatabaseExecutionStatus.success;
    update();
  }

  toggleShowDeleted() {
    showDeleted = !showDeleted;
    getSubjects(group: group);
    update();
  }

  softDeleteSubject(Subject subject) async {
    status = DatabaseExecutionStatus.loading;
    update();
    var result = subject.deleted == 1
        ? await repository.restoreDeletedSubject(subject)
        : await repository.softDeleteSubject(subject);
    if (result == 1) {
      getSubjects(group: group);
    }
  }

  deleteSubject(Subject subject) async {
    status = DatabaseExecutionStatus.loading;
    update();
    var result = await repository.deleteSubject(subject);
    if (result == 1) {
      getSubjects(group: group);
    }
  }

  @override
  void onInit() {
    initialize();
    super.onInit();
  }

  Future<void> initialize() async {
    await getSubjects(group: group);
  }
}
