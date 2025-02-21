import 'package:attendance_tracker/app/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:attendance_tracker/app/components/my_widgets_animator.dart';
import 'package:attendance_tracker/app/routes/app_pages.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:attendance_tracker/app/components/no_data_found_widget.dart';
import 'package:attendance_tracker/config/translations/strings_enum.dart';

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
              return Text("${controller.group!.name}${Strings.subjectsOf.tr}");
            }
            return Text(Strings.subjects.tr);
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
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: [
                            const Icon(PhosphorIconsBold.trash),
                            const SizedBox(width: 8),
                            Text(Strings.showNonDeleted.tr),
                          ],
                        ),
                      ),
                    ];
                  }

                  return [
                    PopupMenuItem(
                      value: 1,
                      child: Row(
                        children: [
                          const Icon(PhosphorIconsBold.trash),
                          const SizedBox(width: 8),
                          Text(Strings.showDeleted.tr),
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
                        ? Strings.noDeletedSubject.tr
                        : Strings.noSubjectsFound.tr,
                    message: controller.showDeleted
                        ? Strings.deletedSubjectToShow.tr
                        : Strings.tryAddingSubject.tr,
                    icon: PhosphorIconsFill.books,
                    buttonText: controller.showDeleted
                        ? Strings.showNonDeleted.tr
                        : Strings.createSubject.tr,
                    action: () => controller.showDeleted
                        ? controller.toggleShowDeleted()
                        : Get.toNamed(Routes.createSubject),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  return await controller.getSubjects(group: controller.group);
                },
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
                                          ? Strings.noKeepDeleted.tr
                                          : Strings.noKeep.tr,
                                    ),
                                  ),
                                  confirm: ElevatedButton(
                                    onPressed: () {
                                      Get.back(result: true);
                                    },
                                    child: Text(
                                      subject.deleted == 1
                                          ? Strings.yesRestore.tr
                                          : Strings.yesDelete.tr,
                                    ),
                                  ),
                                  titleStyle: context.textTheme.titleLarge,
                                  title: subject.deleted == 1
                                      ? Strings.restoreSubject.tr
                                      : Strings.deleteSubject.tr,
                                  middleText: Strings.confirmDeleteRestore.tr
                                      .replaceAll(
                                          '@action',
                                          subject.deleted == 1
                                              ? 'restore'
                                              : 'delete')
                                      .replaceAll('@name', subject.name),
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
                                    title: Strings.lackOfPermission.tr,
                                    message: Strings.addCameraPermission.tr,
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
                                    child: Text(Strings.noKeep.tr),
                                  ),
                                  confirm: ElevatedButton(
                                    onPressed: () {
                                      Get.back(result: true);
                                    },
                                    child: Text(Strings.yesDelete.tr),
                                  ),
                                  titleStyle: context.textTheme.titleLarge,
                                  title: Strings.deleteSubjectPermanently.tr,
                                  middleText: Strings
                                      .confirmDeleteSubjectPermanently.tr
                                      .replaceAll('@name', subject.name),
                                  barrierDismissible: false,
                                );

                                if (delete) controller.deleteSubject(subject);
                              }
                            },
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                  value: 1,
                                  child: Row(
                                    children: [
                                      const Icon(PhosphorIconsBold.pencil),
                                      const SizedBox(width: 8),
                                      Text(Strings.edit.tr),
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
                                            ? Strings.restore.tr
                                            : Strings.delete.tr,
                                      ),
                                    ],
                                  ),
                                ),
                                if (subject.deleted == 1)
                                  PopupMenuItem(
                                    value: 5,
                                    child: Row(
                                      children: [
                                        const Icon(PhosphorIconsBold.trash),
                                        const SizedBox(width: 8),
                                        Text(
                                          Strings.deleteSubjectPermanently.tr,
                                        ),
                                      ],
                                    ),
                                  ),
                                if (subject.deleted == 0)
                                  PopupMenuItem(
                                    value: 3,
                                    child: Row(
                                      children: [
                                        const Icon(PhosphorIconsBold.table),
                                        const SizedBox(width: 8),
                                        Text(Strings.attendance.tr),
                                      ],
                                    ),
                                  ),
                                if (subject.deleted == 0)
                                  PopupMenuItem(
                                    value: 4,
                                    child: Row(
                                      children: [
                                        const Icon(PhosphorIconsBold.qrCode),
                                        const SizedBox(width: 8),
                                        Text(Strings.takeAttendance.tr),
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
                              Strings.showingSubjects.tr
                                  .replaceAll(
                                    '@count',
                                    controller.subjects.length.toString(),
                                  )
                                  .replaceAll(
                                    '@total',
                                    controller.subjects.length.toString(),
                                  ),
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
