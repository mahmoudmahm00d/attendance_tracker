import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:attendance_tracker/app/components/my_widgets_animator.dart';
import 'package:attendance_tracker/app/components/no_data_found_widget.dart';
import 'package:attendance_tracker/app/routes/app_pages.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:attendance_tracker/config/translations/strings_enum.dart';

import '../controllers/groups_controller.dart';

class GroupsView extends GetView<GroupsController> {
  const GroupsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsBold.caretLeft),
          onPressed: Get.back,
        ),
        title: Text(Strings.groups.tr),
        centerTitle: true,
        actions: [
          GetBuilder<GroupsController>(
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
        onPressed: () => Get.toNamed(Routes.createGroup),
        child: const Icon(PhosphorIconsBold.plus),
      ),
      body: GetBuilder<GroupsController>(
        builder: (_) {
          return MyWidgetsAnimator(
            dbExecutionStatus: controller.status,
            errorWidget: () {
              return const SizedBox();
            },
            successWidget: () {
              if (controller.groups.isEmpty) {
                return Center(
                  child: NoDataFoundWidget(
                    title: controller.showDeleted
                        ? Strings.noDeletedGroup.tr
                        : Strings.noGroupsFound.tr,
                    message: controller.showDeleted
                        ? Strings.deletedGroupToShow.tr
                        : Strings.tryAddingGroup.tr,
                    icon: PhosphorIconsFill.users,
                    buttonText: controller.showDeleted
                        ? Strings.showNonDeleted.tr
                        : Strings.createGroup.tr,
                    action: () => controller.showDeleted
                        ? controller.toggleShowDeleted()
                        : Get.toNamed(Routes.createGroup),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  return await controller.getGroups();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: controller.groups.map<Widget>(
                        (group) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(group.name),
                            leading: const Icon(PhosphorIconsBold.users),
                            trailing: PopupMenuButton(
                              onSelected: (value) async {
                                if (value == 1) {
                                  Get.toNamed(
                                    Routes.createGroup,
                                    arguments: group,
                                  );
                                }
                                if (value == 2) {
                                  var delete = await Get.defaultDialog(
                                    cancel: TextButton(
                                      onPressed: () {
                                        Get.back(result: false);
                                      },
                                      child: Text(
                                        group.deleted == 1
                                            ? Strings.noKeepDeleted.tr
                                            : Strings.noKeep.tr,
                                      ),
                                    ),
                                    confirm: ElevatedButton(
                                      onPressed: () {
                                        Get.back(result: true);
                                      },
                                      child: Text(
                                        group.deleted == 1
                                            ? Strings.yesRestore.tr
                                            : Strings.yesDelete.tr,
                                      ),
                                    ),
                                    titleStyle: context.textTheme.titleLarge,
                                    title: group.deleted == 1
                                        ? Strings.restoreGroup.tr
                                        : Strings.deleteGroup.tr,
                                    middleText: Strings.confirmDeleteRestore.tr
                                        .replaceAll(
                                            '@action',
                                            group.deleted == 1
                                                ? Strings.restore.tr
                                                : Strings.delete.tr)
                                        .replaceAll('@name', group.name),
                                    barrierDismissible: false,
                                  );

                                  if (delete) {
                                    controller.softDeleteGroup(group);
                                  }
                                }
                                if (value == 3) {
                                  Get.toNamed(
                                    Routes.subjects,
                                    arguments: group,
                                  );
                                }
                                if (value == 4) {
                                  Get.toNamed(
                                    Routes.students,
                                    arguments: group,
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
                                    title: Strings.deleteGroupPermanently.tr,
                                    middleText: Strings
                                        .confirmDeleteGroupPermanently.tr
                                        .replaceAll('@name', group.name),
                                    barrierDismissible: false,
                                  );

                                  if (delete) controller.deleteGroup(group);
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
                                          group.deleted == 1
                                              ? PhosphorIconsBold
                                                  .arrowCounterClockwise
                                              : PhosphorIconsBold.trash,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          group.deleted == 1
                                              ? Strings.restore.tr
                                              : Strings.delete.tr,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (group.deleted == 1)
                                    PopupMenuItem(
                                      value: 5,
                                      child: Row(
                                        children: [
                                          const Icon(PhosphorIconsBold.trash),
                                          const SizedBox(width: 8),
                                          Text(Strings.deletePermanently.tr),
                                        ],
                                      ),
                                    ),
                                  if (group.deleted == 0)
                                    PopupMenuItem(
                                      value: 3,
                                      child: Row(
                                        children: [
                                          const Icon(PhosphorIconsBold.books),
                                          const SizedBox(width: 8),
                                          Text(Strings.subjects.tr),
                                        ],
                                      ),
                                    ),
                                  if (group.deleted == 0)
                                    PopupMenuItem(
                                      value: 4,
                                      child: Row(
                                        children: [
                                          const Icon(PhosphorIconsBold.student),
                                          const SizedBox(width: 8),
                                          Text(Strings.students.tr),
                                        ],
                                      ),
                                    ),
                                ];
                              },
                              icon: const Icon(
                                  PhosphorIconsBold.dotsThreeOutline),
                            ),
                          );
                        },
                      ).toList()
                        ..add(
                          SizedBox(
                            height: 60,
                            child: Center(
                              child: Text(
                                Strings.showingGroups.tr
                                    .replaceAll('@count',
                                        controller.groups.length.toString())
                                    .replaceAll('@total',
                                        controller.groups.length.toString()),
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
