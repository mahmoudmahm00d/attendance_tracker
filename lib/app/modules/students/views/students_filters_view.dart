import 'package:attendance_tracker/app/modules/students/controllers/students_controller.dart';
import 'package:attendance_tracker/app/services/database_execution_status.dart';
import 'package:attendance_tracker/config/translations/strings_enum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class StudentsFiltersView extends GetView<StudentsController> {
  const StudentsFiltersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Strings.filters.tr)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              GetBuilder<StudentsController>(
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
                              prefixIcon: controller.loadingGroupsQueryStatus ==
                                      DatabaseExecutionStatus.loading
                                  ? CupertinoActivityIndicator(
                                      color: Theme.of(context).primaryColor)
                                  : const Icon(
                                      PhosphorIconsBold.magnifyingGlass,
                                    ),
                              hintText: Strings.searchForGroup.tr,
                            ),
                            onTap: () {
                              if (controller.loadingGroupsQueryStatus ==
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
              GetBuilder<StudentsController>(
                builder: (_) {
                  if (controller.selectedGroups.isNotEmpty) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.selectedGroups.map(
                        (group) {
                          return FilterChip(
                            selected: true,
                            onDeleted: () {
                              controller.selectedGroups.remove(group);
                              controller.update();
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
              GetBuilder<StudentsController>(
                builder: (_) {
                  return Row(
                    children: [
                      Checkbox(
                        value: controller.showDeleted,
                        onChanged: (showDeleted) =>
                            controller.onShowDeleted(showDeleted),
                      ),
                      const SizedBox(width: 8),
                      Text(Strings.showDeleted.tr)
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
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(Strings.applyFilters.tr),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: context.width - 32,
                  child: GetBuilder<StudentsController>(
                    builder: (_) {
                      return TextButton(
                        onPressed: () => controller.removeFilters(goBack: true),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(Strings.removeFilters.tr),
                        ),
                      );
                    },
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
