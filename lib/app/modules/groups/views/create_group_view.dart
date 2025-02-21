import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:attendance_tracker/app/components/my_text_form_field.dart';
import 'package:attendance_tracker/app/modules/groups/controllers/create_group_controller.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:attendance_tracker/config/translations/strings_enum.dart';

class CreateGroupView extends GetView<CreateGroupController> {
  const CreateGroupView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsBold.caretLeft),
          onPressed: Get.back,
        ),
        title: Text(
          controller.isEdit ? Strings.editGroup.tr : Strings.createGroup.tr,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            MyTextFormField(
              controller: controller.nameController,
              heading: Strings.groupName.tr,
              hint: Strings.groupNameHint.tr,
            ),
            const Spacer(),
            Center(
              child: SizedBox(
                width: context.width - 32,
                child: ElevatedButton(
                  onPressed:
                      controller.isEdit ? controller.edit : controller.add,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      controller.isEdit
                          ? Strings.updateGroup.tr
                          : Strings.createGroup.tr,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}
