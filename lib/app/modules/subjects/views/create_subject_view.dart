import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:attendance_tracker/app/components/my_text_form_field.dart';
import 'package:attendance_tracker/app/modules/subjects/controllers/create_subject_controller.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CreateSubjectView extends GetView<CreateSubjectController> {
  const CreateSubjectView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsBold.caretLeft),
          onPressed: Get.back,
        ),
        title: (controller.isEdit)
            ? const Text('Edit Subject')
            : const Text('Create Subject'),
        centerTitle: true,
      ),
      body: GetBuilder<CreateSubjectController>(
        builder: (_) {
          return Padding(
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
                    hint: "Programming",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter subject name";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SearchAnchor(
                    isFullScreen: false,
                    builder: (context, searchController) {
                      if (controller.isEdit) {
                        searchController.text =
                            controller.subject!.group!.name.toString();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Group"),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: searchController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please select group";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
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
                            onTap: searchController.openView,
                          ),
                        ],
                      );
                    },
                    suggestionsBuilder: (context, searchController) async {
                      var groups = await controller.getGroups(
                        name: searchController.text,
                      );

                      return groups.map((group) {
                        return ListTile(
                          title: Text(group.name),
                          leading: const Icon(PhosphorIconsBold.users),
                          onTap: () {
                            controller.groupId = group.id;
                            searchController.closeView(group.name);
                          },
                        );
                      });
                    },
                  ),
                  const Spacer(),
                  Center(
                    child: SizedBox(
                      width: context.width - 32,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 36),
                        child: ElevatedButton(
                          onPressed: controller.isEdit
                              ? controller.edit
                              : controller.add,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              controller.isEdit
                                  ? 'Update Subject'
                                  : 'Create Subject',
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
