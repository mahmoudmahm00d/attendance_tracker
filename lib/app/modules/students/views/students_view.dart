import 'package:attendance_tracker/app/components/custom_snackbar.dart';
import 'package:attendance_tracker/app/components/my_text_form_field.dart';
import 'package:attendance_tracker/app/modules/students/views/manage_groups_view.dart';
import 'package:attendance_tracker/app/modules/students/views/students_filters_view.dart';
import 'package:attendance_tracker/app/services/database_execution_status.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:attendance_tracker/app/routes/app_pages.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:attendance_tracker/app/components/no_data_found_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../controllers/students_controller.dart';
import 'package:attendance_tracker/config/translations/strings_enum.dart';

class StudentsView extends GetView<StudentsController> {
  const StudentsView({super.key});
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!controller.selectionEnabled || controller.selectedUsers.isEmpty) {
          Get.back();
          return;
        }
        // Ask for confiramtion
        final bool shouldPop = await Get.defaultDialog(
          title: Strings.confirmExit.tr,
          middleText: Strings.confirmExitMessage.tr,
          cancel: TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: Text(Strings.no.tr),
          ),
          confirm: ElevatedButton(
            onPressed: () {
              Get.back(result: true);
            },
            child: Text(Strings.yes.tr),
          ),
          barrierDismissible: false,
        );
        if (shouldPop) {
          Get.back();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(PhosphorIconsBold.caretLeft),
            onPressed: () async {
              if (!controller.selectionEnabled ||
                  controller.selectedUsers.isEmpty) {
                Get.back();
                return;
              }
              // Ask for confiramtion
              final bool shouldPop = await Get.defaultDialog(
                title: Strings.confirmExit.tr,
                middleText: Strings.confirmExitMessage.tr,
                cancel: TextButton(
                  onPressed: () {
                    Get.back(result: false);
                  },
                  child: Text(Strings.no.tr),
                ),
                confirm: ElevatedButton(
                  onPressed: () {
                    Get.back(result: true);
                  },
                  child: Text(Strings.yes.tr),
                ),
                barrierDismissible: false,
              );
              if (shouldPop) {
                Get.back();
              }
            },
          ),
          title: GetBuilder<StudentsController>(
            builder: (_) {
              if (controller.selectionEnabled) {
                return Text(Strings.selected.tr.replaceAll(
                    '@count', controller.selectedUsers.length.toString()));
              }
              if (controller.group != null) {
                return Text(Strings.studentsOf.tr
                    .replaceAll('@name', controller.group!.name));
              }
              return Text(Strings.students.tr);
            },
          ),
          centerTitle: true,
          actions: [
            PopupMenuButton(
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Icon(PhosphorIconsBold.dotsThreeOutlineVertical),
              ),
              onSelected: (value) async {
                if (value == "ImportFromExcel") {
                  Get.toNamed(Routes.importFromExcel);
                  return;
                }
                if (value == "ExportQrs") {
                  await controller.generateQr();
                  return;
                }
                if (value == "ExportExcel") {
                  await controller.exportStudents();
                  return;
                }
                if (value == "ToggleSelection") {
                  controller.selectionEnabled = !controller.selectionEnabled;
                  controller.selectedUsers.clear();
                  controller.update();
                }
              },
              itemBuilder: (context) {
                return [
                  if (!controller.selectionEnabled)
                    PopupMenuItem(
                      value: "ImportFromExcel",
                      child: Row(
                        children: [
                          const Icon(PhosphorIconsBold.fileXls),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(Strings.importFromExcel.tr),
                        ],
                      ),
                    ),
                  if (!controller.selectionEnabled)
                    PopupMenuItem(
                      value: "ExportExcel",
                      child: Row(
                        children: [
                          const Icon(PhosphorIconsBold.fileXls),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(Strings.exportToExcel.tr),
                        ],
                      ),
                    ),
                  if (!controller.selectionEnabled)
                    PopupMenuItem(
                      value: "ExportQrs",
                      child: Row(
                        children: [
                          const Icon(PhosphorIconsBold.qrCode),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(Strings.exportQrs.tr),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: "ToggleSelection",
                    child: Row(
                      children: [
                        Icon(
                          controller.selectionEnabled
                              ? PhosphorIconsBold.selectionSlash
                              : PhosphorIconsBold.selection,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          controller.selectionEnabled
                              ? Strings.removeSelection.tr
                              : Strings.selectStudents.tr,
                        ),
                      ],
                    ),
                  ),
                ];
              },
            )
          ],
        ),
        floatingActionButton: GetBuilder<StudentsController>(
          builder: (_) {
            if (controller.selectionEnabled) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.theme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PopupMenuButton(
                  child: const Icon(
                    PhosphorIconsBold.dotsThreeOutlineVertical,
                    color: Colors.white,
                  ),
                  onSelected: (value) {
                    if (value == "AddToGroup") {
                      return;
                    }
                    if (value == "SelectAll") {
                      controller.selectAll();
                      return;
                    }
                    if (value == "UnSelectAll") {
                      controller.unSelectAll();
                      return;
                    }
                    if (value == "ManageGroups") {
                      if (controller.selectedUsers.isEmpty) {
                        CustomSnackBar.showCustomErrorSnackBar(
                          title: Strings.noUserSelected.tr,
                          message: Strings.mustSelectOneUser.tr,
                        );
                        return;
                      }
                      controller.getGroups();
                      Get.to(const ManageGroupsView());
                      return;
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        value: "ManageGroups",
                        child: Row(
                          children: [
                            const Icon(PhosphorIconsBold.userCircleDashed),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(Strings.manageGroups.tr),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: controller.users.length ==
                                controller.selectedUsers.length
                            ? "UnSelectAll"
                            : "SelectAll",
                        child: Row(
                          children: [
                            Icon(
                              controller.users.length ==
                                      controller.selectedUsers.length
                                  ? PhosphorIconsBold.selectionSlash
                                  : PhosphorIconsBold.selectionAll,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              controller.users.length ==
                                      controller.selectedUsers.length
                                  ? Strings.unselectAll.tr
                                  : Strings.selectAll.tr,
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              );
            }

            return FloatingActionButton(
              onPressed: () {
                if (controller.search.text.isNotEmpty &&
                    controller.queryStudentsCount == 0) {
                  Get.toNamed(
                    Routes.createStudent,
                    parameters: {"suggestedName": controller.search.text},
                  );
                  return;
                }
                Get.toNamed(Routes.createStudent);
              },
              child: const Icon(PhosphorIconsBold.plus),
            );
          },
        ),
        body: GetBuilder<StudentsController>(
          builder: (_) {
            if (controller.users.isEmpty && controller.studentsCount == 0) {
              return Center(
                child: NoDataFoundWidget(
                  title: Strings.noStudentsFound.tr,
                  message: Strings.tryAddingStudent.tr,
                  icon: PhosphorIconsFill.student,
                  buttonText: Strings.addStudent.tr,
                  action: () => Get.toNamed(Routes.createStudent),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                return await controller.refreshData();
              },
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: context.theme.scaffoldBackgroundColor,
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(20, 0, 0, 0),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 96,
                                child: MyTextFormField(
                                  controller: controller.search,
                                  hint: Strings.typeToSearch.tr,
                                  suffixIcon: PhosphorIconsBold.magnifyingGlass,
                                  onChanged: controller.onSearchChanged,
                                ),
                              ),
                              SizedBox(
                                width: 56,
                                height: 56,
                                child: controller.filtering
                                    ? ElevatedButton(
                                        onPressed: () {
                                          controller.getGroups();
                                          Get.to(const StudentsFiltersView());
                                        },
                                        child: Icon(
                                          PhosphorIconsBold.funnel,
                                          size: 24,
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                        ),
                                      )
                                    : IconButton(
                                        onPressed: () {
                                          controller.getGroups();
                                          Get.to(const StudentsFiltersView());
                                        },
                                        icon: const Icon(
                                          PhosphorIconsBold.funnel,
                                          size: 24,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        if (controller.selectedGroups.isNotEmpty)
                          Column(
                            children: [
                              Wrap(
                                spacing: 4,
                                children: controller.selectedGroups.map(
                                  (group) {
                                    return FilterChip(
                                      selected: true,
                                      onDeleted: () {
                                        controller.selectedGroups.remove(group);
                                        controller.applyFilters(goBack: false);
                                      },
                                      onSelected: (_) {},
                                      label: Text(
                                        group.name,
                                        style: context.textTheme.bodySmall,
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: (controller.queryStatus ==
                              DatabaseExecutionStatus.loading)
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: CupertinoActivityIndicator(
                                  radius: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                ...controller.users.map<Widget>(
                                  (user) {
                                    return ListTile(
                                      onTap: !controller.selectionEnabled
                                          ? null
                                          : () {
                                              if (controller.selectedUsers
                                                  .contains(user)) {
                                                controller.selectedUsers
                                                    .remove(user);
                                              } else {
                                                controller.selectedUsers
                                                    .add(user);
                                              }
                                              controller.update();
                                            },
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16),
                                      title: Text(user.name),
                                      subtitle: user.fatherName != null &&
                                              user.fatherName!.isNotEmpty
                                          ? Text(user.fatherName ?? "")
                                          : null,
                                      leading:
                                          const Icon(PhosphorIconsBold.user),
                                      trailing: controller.selectionEnabled
                                          ? Checkbox(
                                              value: controller.selectedUsers
                                                  .contains(user),
                                              onChanged: (value) {
                                                if (controller.selectedUsers
                                                    .contains(user)) {
                                                  controller.selectedUsers
                                                      .remove(user);
                                                } else {
                                                  controller.selectedUsers
                                                      .add(user);
                                                }
                                                controller.update();
                                              },
                                            )
                                          : PopupMenuButton(
                                              onSelected: (value) async {
                                                if (value == 1) {
                                                  Get.toNamed(
                                                    Routes.createStudent,
                                                    arguments: user,
                                                  );
                                                }
                                                if (value == 2) {
                                                  var delete =
                                                      await Get.defaultDialog(
                                                    cancel: TextButton(
                                                      onPressed: () {
                                                        Get.back(result: false);
                                                      },
                                                      child: Text(
                                                        user.deleted == 1
                                                            ? Strings
                                                                .noKeepDeleted
                                                                .tr
                                                            : Strings.noKeep.tr,
                                                      ),
                                                    ),
                                                    confirm: ElevatedButton(
                                                      onPressed: () {
                                                        Get.back(result: true);
                                                      },
                                                      child: Text(
                                                        user.deleted == 1
                                                            ? Strings
                                                                .yesRestore.tr
                                                            : Strings
                                                                .yesDelete.tr,
                                                      ),
                                                    ),
                                                    titleStyle: context
                                                        .textTheme.titleLarge,
                                                    title: user.deleted == 1
                                                        ? Strings
                                                            .restoreStudent.tr
                                                        : Strings
                                                            .deleteStudent.tr,
                                                    middleText: user.deleted ==
                                                            0
                                                        ? Strings
                                                            .areYouSureDelete.tr
                                                            .replaceAll("@name",
                                                                user.name)
                                                        : Strings
                                                            .areYouSureRestore
                                                            .tr
                                                            .replaceAll("@name",
                                                                user.name),
                                                    barrierDismissible: false,
                                                  );

                                                  if (delete) {
                                                    controller
                                                        .softDeleteStudent(
                                                            user);
                                                  }
                                                }
                                                if (value == 3) {
                                                  Get.defaultDialog(
                                                    title: user.name,
                                                    content: Container(
                                                      width: 240,
                                                      height: 240,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16),
                                                      child: QrImageView(
                                                          data: user.id),
                                                    ),
                                                  );
                                                }
                                                if (value == 4) {
                                                  var delete =
                                                      await Get.defaultDialog(
                                                    cancel: TextButton(
                                                      onPressed: () {
                                                        Get.back(result: false);
                                                      },
                                                      child: Text(
                                                          Strings.noKeep.tr),
                                                    ),
                                                    confirm: ElevatedButton(
                                                      onPressed: () {
                                                        Get.back(result: true);
                                                      },
                                                      child: Text(
                                                          Strings.yesDelete.tr),
                                                    ),
                                                    titleStyle: context
                                                        .textTheme.titleLarge,
                                                    title: Strings
                                                        .deleteStudentPermanently
                                                        .tr,
                                                    middleText: Strings
                                                        .confirmDeleteStudentPermanently
                                                        .tr
                                                        .replaceAll(
                                                            "@name", user.name),
                                                    barrierDismissible: false,
                                                  );

                                                  if (delete) {
                                                    controller
                                                        .deleteStudent(user);
                                                  }
                                                }
                                              },
                                              itemBuilder: (context) {
                                                return [
                                                  PopupMenuItem(
                                                    value: 1,
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                            PhosphorIconsBold
                                                                .pencil),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(Strings.edit.tr),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 2,
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          user.deleted == 1
                                                              ? PhosphorIconsBold
                                                                  .arrowCounterClockwise
                                                              : PhosphorIconsBold
                                                                  .trash,
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(
                                                          user.deleted == 1
                                                              ? Strings
                                                                  .restore.tr
                                                              : Strings
                                                                  .delete.tr,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 3,
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                          PhosphorIconsBold
                                                              .qrCode,
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(Strings.qr.tr),
                                                      ],
                                                    ),
                                                  ),
                                                  if (controller.showDeleted)
                                                    PopupMenuItem(
                                                      value: 4,
                                                      child: Row(
                                                        children: [
                                                          const Icon(
                                                            PhosphorIconsBold
                                                                .trash,
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          Text(
                                                            Strings
                                                                .deletePermanently
                                                                .tr,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ];
                                              },
                                              icon: const Icon(PhosphorIconsBold
                                                  .dotsThreeOutline),
                                            ),
                                    );
                                  },
                                ),
                                SizedBox(
                                  height: 120,
                                  child: Center(
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 16),
                                        GetBuilder<StudentsController>(
                                          builder: (_) {
                                            if (controller.queryStudentsCount ==
                                                controller.studentsCount) {
                                              return Text(
                                                Strings.showing.tr
                                                    .replaceAll(
                                                      "@count",
                                                      controller.users.length
                                                          .toString(),
                                                    )
                                                    .replaceAll(
                                                      "@total",
                                                      controller.studentsCount
                                                          .toString(),
                                                    ),
                                              );
                                            } else {
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    Strings.showing.tr
                                                        .replaceAll(
                                                          "@count",
                                                          controller
                                                              .users.length
                                                              .toString(),
                                                        )
                                                        .replaceAll(
                                                          "@total",
                                                          controller
                                                              .queryStudentsCount
                                                              .toString(),
                                                        ),
                                                  ),
                                                  Text(
                                                    Strings.filteredFrom.tr
                                                        .replaceAll(
                                                      "@total",
                                                      controller.studentsCount
                                                          .toString(),
                                                    ),
                                                    style: context
                                                        .textTheme.bodySmall,
                                                  ),
                                                ],
                                              );
                                            }
                                          },
                                        ),
                                        GetBuilder<StudentsController>(
                                          builder: (_) {
                                            if (!controller.hasMoreData) {
                                              return Text(
                                                Strings.noMoreData.tr,
                                                style:
                                                    context.textTheme.bodySmall,
                                              );
                                            }
                                            if (controller
                                                    .loadingMoreDataStatus ==
                                                DatabaseExecutionStatus
                                                    .loading) {
                                              return Center(
                                                child:
                                                    CupertinoActivityIndicator(
                                                  radius: 16,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              );
                                            }

                                            if (controller.hasMoreData) {
                                              return TextButton(
                                                onPressed: controller.loadMore,
                                                child:
                                                    Text(Strings.loadMore.tr),
                                              );
                                            }

                                            return const SizedBox.shrink();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
