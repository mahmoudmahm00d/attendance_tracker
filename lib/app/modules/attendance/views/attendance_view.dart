import 'package:attendance_tracker/app/components/custom_snackbar.dart';
import 'package:attendance_tracker/app/components/my_text_form_field.dart';
import 'package:attendance_tracker/app/data/models/user.dart';
import 'package:attendance_tracker/app/modules/attendance/views/attendance_filters_view.dart';
import 'package:attendance_tracker/app/services/database_execution_status.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:attendance_tracker/app/routes/app_pages.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:attendance_tracker/app/components/no_data_found_widget.dart';

import '../controllers/attendance_controller.dart';

class AttendancesView extends GetView<AttendanceController> {
  const AttendancesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsBold.caretLeft),
          onPressed: Get.back,
        ),
        title: GetBuilder<AttendanceController>(builder: (_) {
          if (controller.subject != null) {
            return Text("${controller.subject!.name}'s Attendances");
          }
          return const Text('Attendances');
        }),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              controller.showSearch.value = !controller.showSearch.value;
              var oldText = controller.search.text;
              if (!controller.showSearch.value) {
                controller.search.clear();
              }
              if (oldText.isNotEmpty) {
                await controller.onSearchChanged("");
              }
            },
            icon: Obx(
              () => controller.showSearch.value
                  ? const Icon(PhosphorIconsBold.x)
                  : const Icon(PhosphorIconsBold.magnifyingGlass),
            ),
          ),
          PopupMenuButton(
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(PhosphorIconsBold.dotsThreeOutlineVertical),
            ),
            onSelected: (value) async {
              if (value == "ExportExcel") {
                await controller.generateExcel();
                return;
              }
              if (value == "ToggleSelection") {
                controller.selectionEnabled = !controller.selectionEnabled;
                controller.selectedAttendance.clear();
                controller.update();
              }
            },
            itemBuilder: (context) {
              return [
                if (controller.selectionEnabled)
                  const PopupMenuItem(
                    value: "ExportExcel",
                    child: Row(
                      children: [
                        Icon(PhosphorIconsBold.fileXls),
                        SizedBox(
                          width: 4,
                        ),
                        Text("Generate Report"),
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
                            ? "Remove Selection"
                            : "Select Students",
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      floatingActionButton: GetBuilder<AttendanceController>(
        builder: (_) {
          if (!controller.selectionEnabled) {
            return FloatingActionButton(
              onPressed: () {
                controller.getGroups();
                controller.getDates();
                Get.to(
                  () => const AttendanceFiltersView(),
                  arguments: controller.subject,
                );
              },
              child: const Icon(
                PhosphorIconsBold.funnel,
                size: 24,
              ),
            );
          }

          return SizedBox(
            height: 120,
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  child: FloatingActionButton(
                    onPressed: () async {
                      if (controller.selectedAttendance.isEmpty) {
                        CustomSnackBar.showCustomErrorSnackBar(
                          title: "No user selected",
                          message: "You must select at least one users",
                        );
                        return;
                      }

                      var date = await showDatePicker(
                        context: Get.context!,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                        helpText:
                            'Select your date to add to ${controller.selectedAttendance.length} students', // Custom title
                        cancelText: 'Cancel', // Custom cancel button text
                        confirmText: 'Select', // Custom confirm button text
                        errorFormatText: 'Invalid date', // Custom error message
                        errorInvalidText: 'Date out of range',
                      );
                      if (date != null) {
                        await controller.addAttendances(date);
                      }
                    },
                    child: const Icon(
                      PhosphorIconsBold.plus,
                      size: 24,
                    ),
                  ),
                ),
                FloatingActionButton(
                  onPressed: () {
                    controller.getGroups();
                    controller.getDates();
                    Get.to(
                      () => const AttendanceFiltersView(),
                      arguments: controller.subject,
                    );
                  },
                  child: const Icon(
                    PhosphorIconsBold.funnel,
                    size: 24,
                  ),
                )
              ],
            ),
          );
        },
      ),
      body: GetBuilder<AttendanceController>(
        builder: (_) {
          if (controller.status == DatabaseExecutionStatus.loading) {
            return Center(
              child: CupertinoActivityIndicator(
                radius: 16,
                color: Theme.of(context).primaryColor,
              ),
            );
          }

          if (!controller.showSearch.value &&
              controller.search.text.isEmpty &&
              controller.attendance.isEmpty) {
            return Center(
              child: NoDataFoundWidget(
                title: 'No Attendances found',
                message: 'Try adding Attendance',
                icon: PhosphorIconsFill.books,
                buttonText: 'Create Attendance',
                action: () {}, //=> Get.toNamed(Routes.createAttendance),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              await controller.refreshData();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Obx(() {
                  return Container(
                    width: context.width,
                    decoration: BoxDecoration(
                      color: context.theme.scaffoldBackgroundColor,
                      boxShadow: controller.showSearch.value
                          ? const [
                              BoxShadow(
                                color: Color.fromARGB(20, 0, 0, 0),
                                blurRadius: 10,
                              )
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Obx(
                          () => AnimatedSlide(
                            offset: controller.showSearch.value
                                ? const Offset(0, 0)
                                : const Offset(0, -160),
                            duration: const Duration(milliseconds: 300),
                            child: controller.showSearch.value
                                ? Column(
                                    children: [
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: context.width - 32,
                                        child: MyTextFormField(
                                          controller: controller.search,
                                          hint: "Type to serach",
                                          suffixIcon:
                                              PhosphorIconsBold.magnifyingGlass,
                                          onChanged: controller.onSearchChanged,
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                          ),
                        ),
                        Obx(
                          () {
                            if (controller.selectedGroups.isNotEmpty) {
                              return Column(
                                children: [
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 4,
                                    children: controller.selectedGroups.map(
                                      (group) {
                                        return FilterChip(
                                          selected: true,
                                          onDeleted: () {
                                            controller.selectedGroups
                                                .remove(group);
                                            controller.applyFilters(
                                                goBack: false);
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
                              );
                            }
                            return Container();
                          },
                        ),
                        Obx(
                          () => controller.selectedGroups.isNotEmpty ||
                                  controller.showSearch.value
                              ? const SizedBox(height: 16)
                              : Container(),
                        ),
                      ],
                    ),
                  );
                }),
                Expanded(
                  child: controller.searching == DatabaseExecutionStatus.loading
                      ? Center(
                          child: CupertinoActivityIndicator(
                            radius: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                      : SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                ...controller.attendance.map<Widget>(
                                  (attendance) {
                                    return ListTile(
                                      contentPadding: const EdgeInsets.all(0),
                                      title: Text(attendance.name),
                                      subtitle: Row(
                                        children: [
                                          Text(
                                            "${attendance.count}",
                                            style: context.textTheme.bodyLarge!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w600),
                                          ),
                                          const Text("/"),
                                          Text(
                                            "${controller.attendanceCount}",
                                          ),
                                        ],
                                      ),
                                      leading:
                                          const Icon(PhosphorIconsBold.student),
                                      trailing: controller.selectionEnabled
                                          ? Checkbox(
                                              value: controller
                                                  .selectedAttendance
                                                  .contains(attendance),
                                              onChanged: (value) {
                                                if (controller
                                                    .selectedAttendance
                                                    .contains(attendance)) {
                                                  controller.selectedAttendance
                                                      .remove(attendance);
                                                } else {
                                                  controller.selectedAttendance
                                                      .add(attendance);
                                                }
                                                controller.update();
                                              },
                                            )
                                          : PopupMenuButton(
                                              onSelected: (value) async {
                                                if (value == 1) {
                                                  Get.toNamed(
                                                    Routes.userAttendance,
                                                    arguments: {
                                                      "subject":
                                                          controller.subject!,
                                                      "user": User(
                                                        id: attendance.id,
                                                        name: attendance.name,
                                                        fatherName: attendance
                                                            .fatherName,
                                                        primaryGroup: attendance
                                                            .primaryGroup,
                                                      ),
                                                    },
                                                  );
                                                }

                                                if (value == 2) {
                                                  var date =
                                                      await showDatePicker(
                                                    context: Get.context!,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime(2000),
                                                    lastDate: DateTime.now(),
                                                    helpText:
                                                        'Select your date', // Custom title
                                                    cancelText:
                                                        'Cancel', // Custom cancel button text
                                                    confirmText:
                                                        'Select', // Custom confirm button text
                                                    errorFormatText:
                                                        'Invalid date', // Custom error message
                                                    errorInvalidText:
                                                        'Date out of range',
                                                  );

                                                  if (date != null) {
                                                    await controller
                                                        .addAttendance(
                                                            attendance, date);
                                                  }
                                                }
                                              },
                                              itemBuilder: (context) {
                                                return [
                                                  const PopupMenuItem(
                                                    value: 1,
                                                    child: Row(
                                                      children: [
                                                        Icon(PhosphorIconsBold
                                                            .table),
                                                        SizedBox(width: 8),
                                                        Text("Attendance"),
                                                      ],
                                                    ),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 2,
                                                    child: Row(
                                                      children: [
                                                        Icon(PhosphorIconsBold
                                                            .calendarBlank),
                                                        SizedBox(width: 8),
                                                        Text("Add Attendance"),
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
                                        GetBuilder<AttendanceController>(
                                          builder: (_) {
                                            if (controller.queryCount ==
                                                controller.studentsCount) {
                                              return Text(
                                                  "Showing ${controller.attendance.length} of ${controller.studentsCount} students");
                                            } else {
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Showing ${controller.attendance.length} of ${controller.queryCount} students",
                                                  ),
                                                  Text(
                                                    "Filtered from ${controller.studentsCount}",
                                                    style: context
                                                        .textTheme.bodySmall,
                                                  ),
                                                ],
                                              );
                                            }
                                          },
                                        ),
                                        GetBuilder<AttendanceController>(
                                          builder: (_) {
                                            if (!controller.hasMoreData) {
                                              return Text(
                                                "No More Data",
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
                                                child: const Text("Load More"),
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
