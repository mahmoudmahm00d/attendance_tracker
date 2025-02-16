import 'package:attendance_tracker/app/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:attendance_tracker/app/components/my_widgets_animator.dart';
import 'package:attendance_tracker/app/routes/app_pages.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:attendance_tracker/app/components/no_data_found_widget.dart';

import '../controllers/subjects_controller.dart';

class SubjectsView extends GetView<SubjectsController> {
  const SubjectsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsBold.caretLeft),
          onPressed: Get.back,
        ),
        title: GetBuilder<SubjectsController>(
          builder: (_) {
            if (controller.group != null) {
              return Text("${controller.group!.name}'s Subjects");
            }
            return const Text('Subjects');
          },
        ),
        centerTitle: true,
        actions: [
          GetBuilder<SubjectsController>(
            builder: (_) {
              return PopupMenuButton(
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Icon(PhosphorIconsBold.dotsThreeOutlineVertical),
                ),
                onSelected: (value) {
                  controller.toggleShowDeleted();
                },
                itemBuilder: (context) {
                  if (controller.showDeleted) {
                    return [
                      const PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: [
                            Icon(PhosphorIconsBold.trash),
                            SizedBox(width: 8),
                            Text("Show Non-Deleted"),
                          ],
                        ),
                      ),
                    ];
                  }

                  return [
                    const PopupMenuItem(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(PhosphorIconsBold.trash),
                          SizedBox(width: 8),
                          Text("Show Deleted"),
                        ],
                      ),
                    ),
                  ];
                },
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.createSubject),
        child: const Icon(PhosphorIconsBold.plus),
      ),
      body: GetBuilder<SubjectsController>(
        builder: (_) {
          return MyWidgetsAnimator(
            dbExecutionStatus: controller.status,
            errorWidget: () {
              return const SizedBox();
            },
            successWidget: () {
              if (controller.subjects.isEmpty) {
                return Center(
                  child: NoDataFoundWidget(
                    title: controller.showDeleted
                        ? 'No deleted subject found'
                        : 'No subjects found',
                    message: controller.showDeleted
                        ? 'Deleted subject to show here'
                        : 'Try adding subject',
                    icon: PhosphorIconsFill.books,
                    buttonText: controller.showDeleted
                        ? 'Show Non-Deleted'
                        : 'Create Subject',
                    action: () => controller.showDeleted
                        ? controller.toggleShowDeleted()
                        : Get.toNamed(Routes.createSubject),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () =>
                    controller.getSubjects(group: controller.group),
                child: SingleChildScrollView(
                  child: Column(
                    children: controller.subjects.map<Widget>(
                      (subject) {
                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          title: Text(subject.name),
                          subtitle: Text(subject.group!.name),
                          leading: const Icon(PhosphorIconsBold.book),
                          trailing: PopupMenuButton(
                            onSelected: (value) async {
                              if (value == 1) {
                                Get.toNamed(
                                  Routes.createSubject,
                                  arguments: subject,
                                );
                              }
                              if (value == 2) {
                                var delete = await Get.defaultDialog(
                                  cancel: TextButton(
                                    onPressed: () {
                                      Get.back(result: false);
                                    },
                                    child: Text(
                                      subject.deleted == 1
                                          ? "No keep deleted"
                                          : "No, keep",
                                    ),
                                  ),
                                  confirm: ElevatedButton(
                                    onPressed: () {
                                      Get.back(result: true);
                                    },
                                    child: Text(
                                      subject.deleted == 1
                                          ? "Yes, Restore"
                                          : "Yes, delete",
                                    ),
                                  ),
                                  titleStyle: context.textTheme.titleLarge,
                                  title: subject.deleted == 1
                                      ? "Restore Subject"
                                      : "Delete Subject?",
                                  middleText:
                                      "Are really want to ${subject.deleted == 1 ? "restore" : "delete"} ${subject.name}?",
                                  barrierDismissible: false,
                                );

                                if (delete) {
                                  controller.softDeleteSubject(subject);
                                }
                              }
                              if (value == 3) {
                                Get.toNamed(
                                  Routes.attendance,
                                  arguments: subject,
                                );
                              }
                              if (value == 4) {
                                var status = await Permission.camera.request();
                                if (!status.isGranted) {
                                  CustomSnackBar.showCustomErrorSnackBar(
                                    title: "Lack of permission",
                                    message: "Please add camera permission",
                                  );

                                  return;
                                }

                                Get.toNamed(
                                  Routes.qrAttendance,
                                  arguments: subject,
                                );
                              }
                              if (value == 5) {
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
                                  title: "Delete Subject Permenantly",
                                  middleText:
                                      "Are really want to delete ${subject.name}?",
                                  barrierDismissible: false,
                                );

                                if (delete) controller.deleteSubject(subject);
                              }
                            },
                            itemBuilder: (context) {
                              return [
                                const PopupMenuItem(
                                  value: 1,
                                  child: Row(
                                    children: [
                                      Icon(PhosphorIconsBold.pencil),
                                      SizedBox(width: 8),
                                      Text("Edit"),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 2,
                                  child: Row(
                                    children: [
                                      Icon(
                                        subject.deleted == 1
                                            ? PhosphorIconsBold
                                                .arrowCounterClockwise
                                            : PhosphorIconsBold.trash,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        subject.deleted == 1
                                            ? "Restore"
                                            : "Delete",
                                      ),
                                    ],
                                  ),
                                ),
                                if (subject.deleted == 1)
                                  const PopupMenuItem(
                                    value: 5,
                                    child: Row(
                                      children: [
                                        Icon(PhosphorIconsBold.trash),
                                        SizedBox(width: 8),
                                        Text("Delete Permenantly"),
                                      ],
                                    ),
                                  ),
                                if (subject.deleted == 0)
                                  const PopupMenuItem(
                                    value: 3,
                                    child: Row(
                                      children: [
                                        Icon(PhosphorIconsBold.table),
                                        SizedBox(width: 8),
                                        Text("Attendance"),
                                      ],
                                    ),
                                  ),
                                if (subject.deleted == 0)
                                  const PopupMenuItem(
                                    value: 4,
                                    child: Row(
                                      children: [
                                        Icon(PhosphorIconsBold.qrCode),
                                        SizedBox(width: 8),
                                        Text("Take Attendance"),
                                      ],
                                    ),
                                  ),
                              ];
                            },
                            icon:
                                const Icon(PhosphorIconsBold.dotsThreeOutline),
                          ),
                        );
                      },
                    ).toList()
                      ..add(
                        SizedBox(
                          height: 60,
                          child: Center(
                            child: Text(
                              "Showing ${controller.subjects.length} of ${controller.subjects.length} subjects",
                            ),
                          ),
                        ),
                      ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
