import 'package:attendance_tracker/app/modules/students/controllers/import_from_excel_controller.dart';
import 'package:attendance_tracker/app/services/database_execution_status.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:attendance_tracker/config/translations/strings_enum.dart';

class ImportFromExcelView extends GetView<ImportFromExcelController> {
  const ImportFromExcelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsBold.caretLeft),
          onPressed: Get.back,
        ),
        title: Text(Strings.importFromExcel.tr),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                GetBuilder<ImportFromExcelController>(
                  builder: (context) {
                    return SearchAnchor(
                      isFullScreen: false,
                      builder: (context, searchController) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Strings.primaryGroup.tr),
                            const SizedBox(height: 4),
                            TextFormField(
                              controller: searchController,
                              validator: (value) {
                                return null;
                              },
                              decoration: InputDecoration(
                                prefixIcon: controller.loadingGroups ==
                                        DatabaseExecutionStatus.loading
                                    ? CupertinoActivityIndicator(
                                        color: Theme.of(context).primaryColor)
                                    : const Icon(
                                        PhosphorIconsBold.magnifyingGlass,
                                      ),
                                suffix: controller.groupId == null
                                    ? null
                                    : InkWell(
                                        onTap: () {
                                          controller.groupId = null;
                                          controller.update();
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(PhosphorIconsBold.x),
                                        ),
                                      ),
                                hintText: Strings.selectGroup.tr,
                              ),
                              onTap: () {
                                if (controller.loadingGroups ==
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
                                controller.groupId = group.id;
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
                GetBuilder<ImportFromExcelController>(
                  builder: (_) {
                    return SearchAnchor(
                      isFullScreen: false,
                      builder: (context, searchController) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Strings.showInGroups.tr),
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
                                prefixIcon: controller.loadingGroups ==
                                        DatabaseExecutionStatus.loading
                                    ? CupertinoActivityIndicator(
                                        color: Theme.of(context).primaryColor)
                                    : const Icon(
                                        PhosphorIconsBold.magnifyingGlass,
                                      ),
                                hintText: Strings.searchForGroup.tr,
                              ),
                              onTap: () {
                                if (controller.loadingGroups ==
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
                GetBuilder<ImportFromExcelController>(
                  builder: (_) {
                    if (controller.selectedGroups.isNotEmpty) {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.selectedGroups.map(
                          (group) {
                            return FilterChip(
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
                Center(
                  child: SizedBox(
                    width: context.width - 32,
                    child: ElevatedButton(
                      onPressed: controller.pickFile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            context.theme.primaryColor.withAlpha(120),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(Strings.pickFile.tr),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GetBuilder<ImportFromExcelController>(
                  builder: (_) {
                    if (controller.file != null) {
                      return Column(
                        children: [
                          Text(
                            Strings.fileSelected.tr.replaceAll(
                              "@name",
                              controller.file!.name,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
                Center(
                  child: SizedBox(
                    width: context.width - 32,
                    child: GetBuilder<ImportFromExcelController>(builder: (_) {
                      return IgnorePointer(
                        ignoring: controller.processing,
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller.import();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  controller.processing
                                      ? Strings.processing.tr
                                      : Strings.import.tr,
                                ),
                                if (controller.processing)
                                  const SizedBox(width: 8),
                                if (controller.processing)
                                  Center(
                                    child: CupertinoActivityIndicator(
                                      color: context.theme.primaryColor,
                                      radius: 16,
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Strings.importantNotice.tr,
                      style: context.textTheme.bodyLarge!
                          .copyWith(color: context.theme.primaryColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Strings.fileRequirements.tr,
                      style: context.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Strings.rowsIgnoreNotice.tr,
                      style: context.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Strings.fileExample.tr,
                      style: context.textTheme.titleSmall!.copyWith(
                        color: context.theme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DataTable(
                  border: TableBorder.all(),
                  columns: [
                    DataColumn(label: Text(Strings.name.tr)),
                    DataColumn(label: Text(Strings.fatherName.tr))
                  ],
                  rows: [
                    DataRow(
                      cells: [
                        DataCell(Text(Strings.exampleName.tr)),
                        DataCell(Text(Strings.exampleFatherName.tr)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
