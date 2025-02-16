import 'package:get/get.dart';
import 'package:attendance_tracker/app/data/repositories/groups_repository.dart';
import 'package:attendance_tracker/app/data/repositories/subjects_repository.dart';
import 'package:attendance_tracker/app/modules/subjects/controllers/create_subject_controller.dart';

import '../controllers/subjects_controller.dart';

class SubjectsBinding extends Bindings {
  @override
  void dependencies() async {
    Get.lazyPut<SubjectsController>(
      () => SubjectsController(SubjectsRepository()),
    );
    Get.lazyPut<CreateSubjectController>(
      () => CreateSubjectController(
        SubjectsRepository(),
        GroupsRepository(),
      ),
    );
  }
}
