import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ulid/ulid.dart';
import 'package:attendance_tracker/app/data/repositories/groups_repository.dart';
import 'package:attendance_tracker/app/data/repositories/subjects_repository.dart';
import 'package:attendance_tracker/app/data/models/group.dart';
import 'package:attendance_tracker/app/data/models/subject.dart';
import 'package:attendance_tracker/app/modules/subjects/controllers/subjects_controller.dart';

class CreateSubjectController extends GetxController {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Subject? subject = Get.arguments;
  bool get isEdit => subject != null;

  SearchController searchController = SearchController();
  TextEditingController nameController = TextEditingController();
  String? groupId;

  final SubjectsRepository repository;
  final GroupsRepository groupsRepository;

  CreateSubjectController(this.repository, this.groupsRepository);

  void add() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    var result = await repository.addSubject(
      Subject(
        id: Ulid.new().toString(),
        name: nameController.text,
        groupId: groupId!,
      ),
    );

    if (result != 0) {
      Get.back();
      Get.find<SubjectsController>().getSubjects();
    }
  }

  void edit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    var result = await repository.updateSubject(
      Subject(
        id: subject!.id,
        name: nameController.text,
        groupId: groupId!,
      ),
    );

    if (result != 0) {
      Get.back();
      Get.find<SubjectsController>().getSubjects();
    }
  }

  Future<List<Group>> getGroups({String? name}) async {
    if (name != null && name.removeAllWhitespace.isEmpty) {
      return await groupsRepository.getGroups(query: name.removeAllWhitespace);
    }
    return await groupsRepository.getGroups();
  }

  @override
  void onInit() {
    initialize();
    searchController.text = subject?.group?.name.toString() ?? "";
    super.onInit();
  }

  Future<void> initialize() async {
    if (isEdit) {
      nameController.text = subject!.name;
      groupId = subject!.groupId;
    }
  }
}
