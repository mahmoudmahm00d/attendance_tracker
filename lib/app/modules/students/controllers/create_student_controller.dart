import 'package:attendance_tracker/app/data/models/user.dart';
import 'package:attendance_tracker/app/data/repositories/groups_repository.dart';
import 'package:attendance_tracker/app/data/repositories/students_repository.dart';
import 'package:attendance_tracker/app/modules/students/controllers/students_controller.dart';
import 'package:attendance_tracker/app/services/database_execution_status.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:attendance_tracker/app/data/local/database_helper.dart';
import 'package:attendance_tracker/app/data/models/group.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ulid/ulid.dart';

class CreateStudentController extends GetxController {
  final StudentsRepository repository;
  final GroupsRepository groupsRepository;
  CreateStudentController(this.repository, this.groupsRepository);

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  DatabaseExecutionStatus loadingGroups = DatabaseExecutionStatus.loading;
  DatabaseExecutionStatus loadingUserGroups = DatabaseExecutionStatus.loading;
  User? user = Get.arguments;
  bool get isEdit => user != null;
  late Database database;
  TextEditingController nameController =
      TextEditingController(text: Get.parameters["suggestedName"]);
  TextEditingController fatherController = TextEditingController();
  String? groupId;
  List<Group> groups = [];
  Set<Group> selectedGroups = <Group>{};
  String? suggestedName = Get.parameters["suggestedName"];

  void add() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    var id = Ulid.new().toString();
    var user = User(
      id: id,
      name: nameController.text,
      fatherName: fatherController.text,
      primaryGroup: groupId,
    );

    var result = await repository.addStudent(
      user,
      selectedGroups.map((group) => group.id).toList(),
    );

    if (result != 0) {
      Get.back();
      Get.find<StudentsController>().getStudents();
    }
  }

  void edit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    var user = User(
      id: this.user!.id,
      name: nameController.text,
      fatherName: fatherController.text,
      primaryGroup: groupId,
    );

    var result = await repository.updateStudent(
      user,
      selectedGroups.map((group) => group.id).toList(),
    );

    if (result != 0) {
      Get.back();
      Get.find<StudentsController>().getStudents();
    }
  }

  Future<List<Group>> getGroups({String? name}) async {
    if (name != null && name.removeAllWhitespace.isEmpty) {
      return await groupsRepository.getGroups(query: name.removeAllWhitespace);
    }
    return await groupsRepository.getGroups();
  }

  Future<Set<Group>> getStudentGroups() async {
    return await groupsRepository.getUserGroups(user!.id);
  }

  @override
  void onInit() {
    initialize();
    super.onInit();
  }

  Future<void> initialize() async {
    database = await DatabaseHelper().database;
    groups = await getGroups();
    loadingGroups = DatabaseExecutionStatus.success;
    update();
    if (isEdit) {
      nameController.text = user!.name;
      fatherController.text = user!.fatherName ?? "";
      selectedGroups = await getStudentGroups();
      loadingUserGroups = DatabaseExecutionStatus.success;
      update();
    }
  }
}
