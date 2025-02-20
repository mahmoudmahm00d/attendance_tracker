import 'package:attendance_tracker/app/modules/students/controllers/students_controller.dart';
import 'package:attendance_tracker/app/services/database_execution_status.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ManageGroupsView extends GetView<StudentsController> {
  const ManageGroupsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Groups')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Text(
                "Important Notice",
                style: context.textTheme.bodyLarge!
                    .copyWith(color: context.theme.primaryColor),
              ),
              const Text(
                  "After save changes all student groups will be overwriten."),
              const SizedBox(height: 16),
              GetBuilder<StudentsController>(
                builder: (context) {
                  return SearchAnchor(
                    isFullScreen: false,
                    builder: (context, searchController) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Primary Group"),
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
                              suffix: controller.selectedManagedGroup == null
                                  ? null
                                  : InkWell(
                                      onTap: () {
                                        controller.selectedManagedGroup = null;
                                        controller.update();
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: Icon(PhosphorIconsBold.x),
                                      ),
                                    ),
                              hintText: 'Select Group',
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
                      return controller.groups.map(
                        (group) {
                          return ListTile(
                            title: Text(group.name),
                            leading: const Icon(PhosphorIconsBold.users),
                            onTap: () {
                              controller.selectedManagedGroup = group.id;
                              searchController.closeView(group.name);
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
                  return SearchAnchor(
                    isFullScreen: false,
                    builder: (context, searchController) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Show in Groups"),
                          const SizedBox(height: 4),
                          TextFormField(
                            onSaved: (_) {
                                searchController.closeView("");
                              },
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
                              hintText: 'Search for a group',
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
                              controller.selectedManagedGroups.contains(group);
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
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
                              var selected = controller.selectedManagedGroups
                                  .contains(group);
                              if (!selected) {
                                controller.selectedManagedGroups.add(group);
                              } else {
                                controller.selectedManagedGroups.remove(group);
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
                  if (controller.selectedManagedGroups.isNotEmpty) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.selectedManagedGroups.map(
                        (group) {
                          return FilterChip(
                            selected: true,
                            onDeleted: () {
                              controller.selectedManagedGroups.remove(group);
                              controller.update();
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
              Center(
                child: SizedBox(
                  width: context.width - 32,
                  child: ElevatedButton(
                    onPressed: controller.saveGroups,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: GetBuilder<StudentsController>(
                        builder: (_) {
                          return const Text("Save Changes");
                        },
                      ),
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
