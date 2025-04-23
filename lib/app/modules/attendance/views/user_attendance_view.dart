import 'package:attendance_tracker/app/modules/attendance/controllers/user_attendance_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:attendance_tracker/app/components/my_widgets_animator.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:attendance_tracker/app/components/no_data_found_widget.dart';
import 'package:attendance_tracker/config/translations/strings_enum.dart';

class UserAttendancesView extends GetView<UserAttendanceController> {
  const UserAttendancesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsBold.caretLeft),
          onPressed: Get.back,
        ),
        title: GetBuilder<UserAttendanceController>(builder: (_) {
          return Text(
            Strings.userAttendances.tr
                .replaceAll('@name', controller.user.name),
          );
        }),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var date = await showDatePicker(
            context: Get.context!,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
            helpText: Strings.selectDate.tr,
            cancelText: Strings.cancel.tr, // Custom cancel button text
            confirmText: Strings.select.tr, // Custom confirm button text
            errorFormatText: Strings.invalidDate.tr, // Custom error message
            errorInvalidText: Strings.dateOutOfRange.tr,
          );

          if (date != null) {
            await controller.add(date);
          }
        },
        child: const Icon(PhosphorIconsBold.plus),
      ),
      body: GetBuilder<UserAttendanceController>(builder: (_) {
        return MyWidgetsAnimator(
          dbExecutionStatus: controller.status,
          errorWidget: () {
            return const SizedBox();
          },
          successWidget: () {
            if (controller.attendance.isEmpty) {
              return Center(
                child: NoDataFoundWidget(
                  title: Strings.noAttendancesFound.tr,
                  message: Strings.tryAddingAttendance.tr,
                  icon: PhosphorIconsFill.calendarBlank,
                  buttonText: Strings.addAttendance.tr,
                  action: () async {
                    var date = await showDatePicker(
                      context: Get.context!,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      helpText: Strings.selectDate.tr,
                      cancelText:
                          Strings.cancel.tr, // Custom cancel button text
                      confirmText:
                          Strings.select.tr, // Custom confirm button text
                      errorFormatText:
                          Strings.invalidDate.tr, // Custom error message
                      errorInvalidText: Strings.dateOutOfRange.tr,
                    );

                    if (date != null) {
                      await controller.add(date);
                    }
                  },
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {},
              child: ListView.builder(
                itemCount: controller.attendance.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: Text(
                      DateFormat("yyyy-MM-dd, EEEE")
                          .format(controller.attendance[index].at),
                    ),
                    leading: const Icon(PhosphorIconsBold.calendarCheck),
                    trailing: PopupMenuButton(
                      onSelected: (value) async {
                        if (value == 1) {
                          var delete = await Get.defaultDialog(
                            cancel: TextButton(
                              onPressed: () {
                                Get.back(result: false);
                              },
                              child: Text(Strings.noKeep.tr),
                            ),
                            confirm: ElevatedButton(
                              onPressed: () {
                                Get.back(result: true);
                              },
                              child: Text(Strings.yesDelete.tr),
                            ),
                            titleStyle: context.textTheme.titleLarge,
                            title: Strings.deleteAttendance.tr,
                            middleText:
                                Strings.deleteAttendanceConfirm.tr.replaceAll(
                              '@date',
                              DateFormat("yyyy-MM-dd")
                                  .format(controller.attendance[index].at),
                            ),
                            barrierDismissible: false,
                          );

                          if (delete) controller.delete(index);
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            value: 1,
                            child: Row(
                              children: [
                                const Icon(PhosphorIconsBold.trash),
                                const SizedBox(width: 8),
                                Text(Strings.delete.tr),
                              ],
                            ),
                          ),
                        ];
                      },
                      icon: const Icon(PhosphorIconsBold.dotsThreeOutline),
                    ),
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }
}
