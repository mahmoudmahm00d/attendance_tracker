import 'package:attendance_tracker/app/data/repositories/groups_repository.dart';
import 'package:get/get.dart';
import 'package:attendance_tracker/app/data/models/group.dart';
import 'package:attendance_tracker/app/services/database_execution_status.dart';

class GroupsController extends GetxController {
  List<Group> groups = [];
  // Filters
  bool showDeleted = false;
  DatabaseExecutionStatus status = DatabaseExecutionStatus.loading;
  
  final GroupsRepository repository;
  GroupsController(this.repository);

  getGroups() async {
    status = DatabaseExecutionStatus.loading;
    update();
    try {
      groups = await repository.getGroups(showDeleted: showDeleted);
      status = DatabaseExecutionStatus.success;
      update();
    } on Exception {
      status = DatabaseExecutionStatus.error;
    }
  }

  toggleShowDeleted() {
    showDeleted = !showDeleted;
    getGroups();
    update();
  }

  softDeleteGroup(Group group) async {
    status = DatabaseExecutionStatus.loading;
    update();
    var result = group.deleted == 1
        ? await repository.restoreDeletedGroup(group)
        : await repository.softDeleteGroup(group);
    if (result == 1) {
      getGroups();
    }
  }

  deleteGroup(Group group) async {
    status = DatabaseExecutionStatus.loading;
    var result = await repository.deleteGroup(group);
    if (result == 1) {
      getGroups();
    }
  }

  @override
  void onInit() {
    initialize();
    super.onInit();
  }

  Future<void> initialize() async {
    await getGroups();
  }
}
