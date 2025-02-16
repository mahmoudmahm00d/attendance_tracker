import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ulid/ulid.dart';
import 'package:attendance_tracker/app/data/repositories/groups_repository.dart';
import 'package:attendance_tracker/app/data/models/group.dart';
import 'package:attendance_tracker/app/modules/groups/controllers/groups_controller.dart';

class CreateGroupController extends GetxController {
  Group? group = Get.arguments;
  bool get isEdit => group != null;
  TextEditingController nameController = TextEditingController();

  final GroupsRepository repository;
  CreateGroupController(this.repository);

  void add() async {
    var result = await repository.addGroup(
      Group(
        id: Ulid.new().toString(),
        name: nameController.text,
      ),
    );

    if (result != 0) {
      Get.back();
      Get.find<GroupsController>().getGroups();
    }
  }

  void edit() async {
    var result = await repository.updateGroup(
      Group(
        id: group!.id,
        name: nameController.text,
      ),
    );

    if (result != 0) {
      Get.back();
      Get.find<GroupsController>().getGroups();
    }
  }

  @override
  void onInit() async {
    if (isEdit) {
      nameController.text = group!.name;
    }
    super.onInit();
  }
}
