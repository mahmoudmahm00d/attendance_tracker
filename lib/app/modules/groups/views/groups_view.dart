import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:attendance_tracker/app/components/my_widgets_animator.dart';
import 'package:attendance_tracker/app/components/no_data_found_widget.dart';
import 'package:attendance_tracker/app/routes/app_pages.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
          title: const Text('Groups'),
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
          ]),
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
                        ? 'No deleted group found'
                        : 'No groups found',
                    message: controller.showDeleted
                        ? 'Deleted group to show here'
                        : 'Try adding group',
                    icon: PhosphorIconsFill.users,
                    buttonText: controller.showDeleted
                        ? 'Show Non-Deleted'
                        : 'Create Group',
                    action: () => controller.showDeleted
                        ? controller.toggleShowDeleted()
                        : Get.toNamed(Routes.createGroup),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () => controller.getGroups(),
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
                                            ? "No keep deleted"
                                            : "No, keep",
                                      ),
                                    ),
                                    confirm: ElevatedButton(
                                      onPressed: () {
                                        Get.back(result: true);
                                      },
                                      child: Text(
                                        group.deleted == 1
                                            ? "Yes, Restore"
                                            : "Yes, delete",
                                      ),
                                    ),
                                    titleStyle: context.textTheme.titleLarge,
                                    title: group.deleted == 1
                                        ? "Restore Group"
                                        : "Delete Group?",
                                    middleText:
                                        "Are really want to ${group.deleted == 1 ? "restore" : "delete"} ${group.name}?",
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
                                      child: const Text("No, keep"),
                                    ),
                                    confirm: ElevatedButton(
                                      onPressed: () {
                                        Get.back(result: true);
                                      },
                                      child: const Text("Yes, delete"),
                                    ),
                                    titleStyle: context.textTheme.titleLarge,
                                    title: "Delete Group Permenantly",
                                    middleText:
                                        "Are really want to delete ${group.name}?",
                                    barrierDismissible: false,
                                  );

                                  if (delete) controller.deleteGroup(group);
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
                                          group.deleted == 1
                                              ? PhosphorIconsBold
                                                  .arrowCounterClockwise
                                              : PhosphorIconsBold.trash,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          group.deleted == 1
                                              ? "Restore"
                                              : "Delete",
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (group.deleted == 1)
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
                                  if (group.deleted == 0)
                                    const PopupMenuItem(
                                      value: 3,
                                      child: Row(
                                        children: [
                                          Icon(PhosphorIconsBold.books),
                                          SizedBox(width: 8),
                                          Text("Subjects"),
                                        ],
                                      ),
                                    ),
                                  if (group.deleted == 0)
                                    const PopupMenuItem(
                                      value: 4,
                                      child: Row(
                                        children: [
                                          Icon(PhosphorIconsBold.student),
                                          SizedBox(width: 8),
                                          Text("Students"),
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
                                "Showing ${controller.groups.length} of ${controller.groups.length} groups",
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
