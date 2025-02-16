import 'package:attendance_tracker/app/modules/attendance/controllers/attendance_controller.dart';
import 'package:attendance_tracker/app/services/database_execution_status.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AttendanceFiltersView extends GetView<AttendanceController> {
  const AttendanceFiltersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filters')),
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
                          const Text("Groups"),
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
                              hintText: 'Search for a group',
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
                  return const Text("No selected groups");
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
                    const Text("Non Zero")
                  ],
                );
              }),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Dates"),
              ),
              GetBuilder<AttendanceController>(
                builder: (_) {
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
                                }
                                else {
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
              Center(
                child: SizedBox(
                  width: context.width - 32,
                  child: ElevatedButton(
                    onPressed: () => controller.applyFilters(goBack: true),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("Apply Filters"),
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
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text("Remove Filters"),
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
