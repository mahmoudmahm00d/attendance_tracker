import 'package:attendance_tracker/app/modules/attendance/controllers/add_attendance_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:attendance_tracker/config/translations/strings_enum.dart';

class AddAttendanceView extends GetView<AddAttendanceController> {
  const AddAttendanceView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsBold.caretLeft),
          onPressed: Get.back,
        ),
        title: Text(Strings.addAttendance.tr),
        centerTitle: true,
      ),
      body: GetBuilder<AddAttendanceController>(
        builder: (_) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(Strings.date.tr),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: context.width,
                          child: ElevatedButton(
                            onPressed: () async {
                              controller.date = await showDatePicker(
                                context: context,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                                initialDate: DateTime.now(),
                              );
                              controller.update();
                            },
                            child: controller.date == null
                                ? Text(Strings.selectDate.tr)
                                : Text(
                                    DateFormat("yyyy-MM-dd")
                                        .format(controller.date!),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: context.width - 32,
                  margin: const EdgeInsets.only(bottom: 36),
                  child: ElevatedButton(
                    onPressed: controller.add,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(Strings.addAttendance.tr),
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
