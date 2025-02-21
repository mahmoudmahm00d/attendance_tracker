import 'package:attendance_tracker/app/modules/attendance/controllers/qr_attendance_controller.dart';
import 'package:attendance_tracker/config/translations/strings_enum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QrAttendanceView extends GetView<QrAttendanceController> {
  const QrAttendanceView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsBold.caretLeft),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(controller.subject.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Obx(
              () => Icon(
                controller.isScanning.value
                    ? PhosphorIconsBold.lightning
                    : PhosphorIconsBold.lightningSlash,
              ),
            ),
            onPressed: () async {
              await controller.qrViewController?.toggleFlash();
              controller.isScanning.toggle();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Obx(
              () {
                return QRView(
                  key: controller.qrKey,
                  onQRViewCreated: controller.onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: controller.result.value == Strings.userNotFound
                        ? Colors.red
                        : Colors.green,
                    borderRadius: 8,
                    borderLength: 32,
                    borderWidth: 8,
                    cutOutSize: 240,
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          DateFormat('yyyy-MM-dd').format(DateTime.now()),
                          style: context.textTheme.titleSmall,
                        ),
                      ),
                      Row(
                        children: [
                          Text(Strings.sessionUsersCount.tr,
                              style: context.textTheme.bodyMedium),
                          const Spacer(),
                          Obx(
                            () => Text(
                              controller.students.length.toString(),
                              style: context.textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            Strings.showUsers.tr,
                            style: context.textTheme.bodyMedium,
                          ),
                          const Spacer(),
                          GetBuilder<QrAttendanceController>(
                            builder: (_) => Switch(
                              value: controller.showSessionUsers,
                              onChanged: (showSessionUsers) {
                                controller.showSessionUsers = showSessionUsers;
                                controller.update();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                  Expanded(
                    child: GetBuilder<QrAttendanceController>(
                      builder: (_) {
                        if (controller.showSessionUsers) {
                          return SingleChildScrollView(
                            child: Obx(
                              () {
                                if (controller.students.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Text(
                                      Strings.noUserAddedYet.tr,
                                      style: context.textTheme.titleSmall,
                                    ),
                                  );
                                }

                                return Column(
                                  children: controller.students.map(
                                    (user) {
                                      return ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        title: Text(user.name),
                                        subtitle: user.fatherName != null &&
                                                user.fatherName!.isNotEmpty
                                            ? Text(user.fatherName!)
                                            : null,
                                        leading:
                                            const Icon(PhosphorIconsBold.user),
                                        trailing: IconButton(
                                          onPressed: () =>
                                              controller.students.remove(user),
                                          icon: Icon(
                                            PhosphorIconsBold.minusCircle,
                                            color: context.theme.primaryColor,
                                          ),
                                        ),
                                      );
                                    },
                                  ).toList(),
                                );
                              },
                            ),
                          );
                        }

                        return Column(
                          children: [
                            Row(
                              children: [
                                Text(Strings.name.tr,
                                    style: context.textTheme.bodyMedium),
                                const Spacer(),
                                Obx(
                                  () => Text(
                                    controller.latestStudent.value?.name ??
                                        Strings.none.tr,
                                    style: context.textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  Strings.fatherName.tr,
                                  style: context.textTheme.bodyMedium,
                                ),
                                const Spacer(),
                                Obx(
                                  () => Text(
                                    controller
                                            .latestStudent.value?.fatherName ??
                                        Strings.none.tr,
                                    style: context.textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.grey),
                            Row(
                              children: [
                                Text(
                                  Strings.autoSave.tr,
                                  style: context.textTheme.bodyMedium,
                                ),
                                const Spacer(),
                                Obx(
                                  () => Switch(
                                    value: controller.autoSave.value,
                                    onChanged: (autoSave) =>
                                        controller.autoSave.value = autoSave,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Obx(
                              () {
                                if (controller.result.value ==
                                    Strings.userNotFound) {
                                  return const SizedBox.shrink();
                                }

                                if (controller.autoSave.value) {
                                  return Text(Strings.autoSaveEnabled.tr);
                                }

                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      child: TextButton(
                                        onPressed: () {
                                          controller.result.value = "";
                                          controller.latestStudent.value = null;
                                        },
                                        child: Text(Strings.discard.tr),
                                      ),
                                    ),
                                    SizedBox(
                                      child: ElevatedButton(
                                        onPressed: controller.addAttendance,
                                        child: Text(Strings.addAttendance.tr),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 32),
                          ],
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
