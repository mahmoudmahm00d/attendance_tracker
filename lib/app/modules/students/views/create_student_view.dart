import 'package:attendance_tracker/app/services/database_execution_status.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:attendance_tracker/app/components/my_text_form_field.dart';
import 'package:attendance_tracker/app/modules/students/controllers/create_student_controller.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CreateStudentView extends GetView<CreateStudentController> {
  const CreateStudentView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsBold.caretLeft),
          onPressed: Get.back,
        ),
        title: (controller.isEdit)
            ? const Text('Edit Student')
            : const Text('Create Student'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                MyTextFormField(
                  controller: controller.nameController,
                  heading: "Name",
                  hint: "Mahmoud Mahmoud",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter student name";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                MyTextFormField(
                  controller: controller.fatherController,
                  heading: "Father Name",
                  hint: "Darwish",
                ),
                const SizedBox(height: 16),
                GetBuilder<CreateStudentController>(
                  builder: (context) {
                    return SearchAnchor(
                      isFullScreen: false,
                      searchController: controller.searchController,
                      builder: (context, searchController) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Primary Group"),
                            const SizedBox(height: 4),
                            TextFormField(
                              controller: searchController,
                              validator: (value) {
                                return null;
                              },
                              decoration: InputDecoration(
                                prefixIcon: controller.loadingGroups ==
                                        DatabaseExecutionStatus.loading
                                    ? CupertinoActivityIndicator(
                                        color: Theme.of(context).primaryColor)
                                    : const Icon(
                                        PhosphorIconsBold.magnifyingGlass,
                                      ),
                                suffix: controller.groupId == null
                                    ? null
                                    : InkWell(
                                        onTap: () {
                                          controller.groupId = null;
                                          controller.update();
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(PhosphorIconsBold.x),
                                        ),
                                      ),
                                hintText: 'Select Group',
                              ),
                              onTap: () {
                                if (controller.loadingGroups ==
                                    DatabaseExecutionStatus.loading) {
                                  return;
                                }
                                searchController.openView();
                              },
                            ),
                          ],
                        );
                      },
                      suggestionsBuilder: (context, searchController) async {
                        return controller.groups.map(
                          (group) {
                            return ListTile(
                              title: Text(group.name),
                              leading: const Icon(PhosphorIconsBold.users),
                              onTap: () {
                                controller.groupId = group.id;
                                searchController.closeView(group.name);
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                GetBuilder<CreateStudentController>(
                  builder: (_) {
                    return SearchAnchor(
                      isFullScreen: false,
                      builder: (context, searchController) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Show in Groups"),
                            const SizedBox(height: 4),
                            TextFormField(
                              onSaved: (_) {
                                searchController.closeView("");
                              },
                              controller: searchController,
                              validator: (value) {
                                return null;
                              },
                              decoration: InputDecoration(
                                prefixIcon: controller.loadingGroups ==
                                        DatabaseExecutionStatus.loading
                                    ? CupertinoActivityIndicator(
                                        color: Theme.of(context).primaryColor)
                                    : const Icon(
                                        PhosphorIconsBold.magnifyingGlass,
                                      ),
                                hintText: 'Search for a group',
                              ),
                              onTap: () {
                                if (controller.loadingGroups ==
                                    DatabaseExecutionStatus.loading) {
                                  return;
                                }
                                searchController.openView();
                              },
                            ),
                          ],
                        );
                      },
                      suggestionsBuilder: (context, searchController) async {
                        return controller.groups.where(
                          (group) {
                            return searchController.text.isEmpty ||
                                group.name.toLowerCase().contains(
                                      searchController.text.toLowerCase(),
                                    );
                          },
                        ).map(
                          (group) {
                            var selected =
                                controller.selectedGroups.contains(group);
                            return ListTile(
                              selectedTileColor:
                                  Theme.of(context).primaryColor.withAlpha(30),
                              selected: selected,
                              title: Text(group.name),
                              trailing: selected
                                  ? const Icon(
                                      PhosphorIconsBold.checkCircle,
                                    )
                                  : null,
                              leading: const Icon(PhosphorIconsBold.users),
                              onTap: () {
                                var selected =
                                    controller.selectedGroups.contains(group);
                                if (!selected) {
                                  controller.selectedGroups.add(group);
                                } else {
                                  controller.selectedGroups.remove(group);
                                }
                                final previousText = searchController.text;
                                searchController.text = '\u200B$previousText';
                                searchController.text = previousText;
                                controller.update();
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                GetBuilder<CreateStudentController>(
                  builder: (_) {
                    if (controller.isEdit &&
                        controller.loadingUserGroups ==
                            DatabaseExecutionStatus.loading) {
                      return Center(
                        child: CupertinoActivityIndicator(
                          color: Theme.of(context).primaryColor,
                        ),
                      );
                    }
                    if (controller.selectedGroups.isNotEmpty) {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.selectedGroups.map(
                          (group) {
                            return FilterChip(
                              onDeleted: () {
                                controller.selectedGroups.remove(group);
                                controller.update();
                              },
                              onSelected: (s) {},
                              label: Text(group.name),
                            );
                          },
                        ).toList(),
                      );
                    }
                    return const Text("No selected groups");
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: context.width - 32,
                    margin: const EdgeInsets.only(bottom: 36),
                    child: ElevatedButton(
                      onPressed:
                          controller.isEdit ? controller.edit : controller.add,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          controller.isEdit
                              ? 'Update Student'
                              : 'Create Student',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
