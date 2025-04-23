import 'package:attendance_tracker/app/modules/attendance/controllers/attendance_controller.dart';
import 'package:attendance_tracker/app/services/database_execution_status.dart';
import 'package:attendance_tracker/config/translations/strings_enum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AttendanceFiltersView extends GetView<AttendanceController> {
  const AttendanceFiltersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Strings.filters.tr)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              GetBuilder<AttendanceController>(
                builder: (_) {
                  return SearchAnchor(
                    isFullScreen: false,
                    builder: (context, searchController) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(Strings.groups.tr),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: searchController,
                            validator: (value) {
                              return null;
                            },
                            decoration: InputDecoration(
                              prefixIcon: controller.loadingGroups.value ==
                                      DatabaseExecutionStatus.loading
                                  ? CupertinoActivityIndicator(
                                      color: Theme.of(context).primaryColor)
                                  : const Icon(
                                      PhosphorIconsBold.magnifyingGlass,
                                    ),
                              hintText: Strings.selectGroup.tr,
                            ),
                            onTap: () {
                              if (controller.loadingGroups.value ==
                                  DatabaseExecutionStatus.loading) {
                                return;
                              }
                              searchController.openView();
                            },
                          ),
                        ],
                      );
                    },
                    suggestionsBuilder: (context, searchController) async {
                      return controller.groups.where(
                        (group) {
                          return searchController.text.isEmpty ||
                              group.name.toLowerCase().contains(
                                    searchController.text.toLowerCase(),
                                  );
                        },
                      ).map(
                        (group) {
                          var selected =
                              controller.selectedGroups.contains(group);
                          return ListTile(
                            selectedTileColor:
                                Theme.of(context).primaryColor.withAlpha(30),
                            selected: selected,
                            title: Text(group.name),
                            trailing: selected
                                ? const Icon(
                                    PhosphorIconsBold.checkCircle,
                                  )
                                : null,
                            leading: const Icon(PhosphorIconsBold.users),
                            onTap: () {
                              var selected =
                                  controller.selectedGroups.contains(group);
                              if (!selected) {
                                controller.selectedGroups.add(group);
                              } else {
                                controller.selectedGroups.remove(group);
                              }
                              final previousText = searchController.text;
                              searchController.text = '\u200B$previousText';
                              searchController.text = previousText;
                              controller.update();
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              Obx(
                () {
                  if (controller.selectedGroups.isNotEmpty) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.selectedGroups.map(
                        (group) {
                          return FilterChip(
                            onDeleted: () {
                              controller.selectedGroups.remove(group);
                            },
                            onSelected: (s) {},
                            label: Text(group.name),
                          );
                        },
                      ).toList(),
                    );
                  }
                  return Text(Strings.noSelectedGroups.tr);
                },
              ),
              const SizedBox(height: 16),
              Obx(() {
                return Row(
                  children: [
                    Checkbox(
                      value: controller.nonZeroAttendance.value,
                      onChanged: (v) => controller.onNonZeroAttendance(v),
                    ),
                    const SizedBox(width: 8),
                    Text(Strings.nonZeroAttendance.tr)
                  ],
                );
              }),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(Strings.dates.tr),
                ],
              ),
              GetBuilder<AttendanceController>(
                builder: (_) {
                  if (controller.dates.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [Icon(PhosphorIconsBold.calendarSlash)],
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (var date in controller.dates)
                        Row(
                          children: [
                            Checkbox(
                              value: controller.selectedDates.contains(date),
                              onChanged: (v) {
                                if (controller.selectedDates.contains(date)) {
                                  controller.selectedDates.remove(date);
                                } else {
                                  controller.selectedDates.add(date);
                                }

                                controller.update();
                              },
                            ),
                            const SizedBox(width: 8),
                            Text(date)
                          ],
                        )
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              const Divider(),
              Obx(
                () {
                  return Row(
                    children: [
                      Checkbox(
                        value: controller.filterByCount.value,
                        onChanged: (v) {
                          controller.filterByCount.value = v!;
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(Strings.filterByCount.tr)
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Obx(
                () {
                  if (controller.filterByCount.isFalse) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    children: [
                      Text(
                        Strings.selectedCount.trParams(
                          {'count': controller.selectedAttendanceCount.value.toString()},
                        ),
                      ),
                      Slider(
                        label:
                            controller.selectedAttendanceCount.value.toString(),
                        min: 1,
                        max: controller.attendanceCount.toDouble(),
                        value: controller.selectedAttendanceCount.toDouble(),
                        inactiveColor:
                            context.theme.primaryColor.withAlpha(150),
                        onChanged: (count) {
                          controller.selectedAttendanceCount.value =
                              count.toInt();
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
              Center(
                child: SizedBox(
                  width: context.width - 32,
                  child: ElevatedButton(
                    onPressed: () => controller.applyFilters(goBack: true),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(Strings.applyFilters.tr),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (controller.filtering.value)
                Center(
                  child: SizedBox(
                    width: context.width - 32,
                    child: TextButton(
                      onPressed: () => controller.removeFilters(goBack: true),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(Strings.removeFilters.tr),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
