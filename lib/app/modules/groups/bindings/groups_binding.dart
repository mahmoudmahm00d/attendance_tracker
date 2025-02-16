import 'package:get/get.dart';
import 'package:attendance_tracker/app/modules/groups/controllers/create_group_controller.dart';
import 'package:attendance_tracker/app/data/repositories/groups_repository.dart';

import '../controllers/groups_controller.dart';

class GroupsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GroupsController>(
      () => GroupsController(GroupsRepository()),
    );
    Get.lazyPut<CreateGroupController>(
      () => CreateGroupController(GroupsRepository()),
    );
  }
}
