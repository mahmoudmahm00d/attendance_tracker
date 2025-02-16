import 'package:attendance_tracker/app/modules/attendance/controllers/user_attendance_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:attendance_tracker/app/components/my_widgets_animator.dart';
import 'package:attendance_tracker/app/routes/app_pages.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:attendance_tracker/app/components/no_data_found_widget.dart';

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
          return Text("${controller.user.name}'s Attendances");
        }),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(
          Routes.addAttendance,
          arguments: {
            "subject": controller.subject,
            "user": controller.user,
            "attendance": null,
          },
        ),
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
                  title: 'No Attendances found',
                  message: 'Try adding Attendance',
                  icon: PhosphorIconsFill.books,
                  buttonText: 'Add Attendance',
                  action: () => Get.toNamed(
                    Routes.addAttendance,
                    arguments: {
                      "subject": controller.subject,
                      "user": controller.user,
                      "attendance": null,
                    },
                  ),
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
                      DateFormat("yyyy-MM-dd")
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
                              child: const Text("No, keep"),
                            ),
                            confirm: ElevatedButton(
                              onPressed: () {
                                Get.back(result: true);
                              },
                              child: const Text("Yes, delete"),
                            ),
                            titleStyle: context.textTheme.titleLarge,
                            title: "Delete Attendance",
                            middleText:
                                "Are really want to delete ${DateFormat("yyyy-MM-dd").format(controller.attendance[index].at)}?",
                            barrierDismissible: false,
                          );

                          if (delete) controller.delete(index);
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          const PopupMenuItem(
                            value: 1,
                            child: Row(
                              children: [
                                Icon(PhosphorIconsBold.trash),
                                SizedBox(width: 8),
                                Text("Delete"),
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
