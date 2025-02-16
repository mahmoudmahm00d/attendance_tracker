import 'package:attendance_tracker/app/modules/attendance/controllers/qr_attendance_controller.dart';
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
                    borderColor: controller.result.value == "User not found"
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
                          Text("Session users count:",
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
                      // const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            "Show users",
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
                                      "No user added yet",
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
                                Text("Name:",
                                    style: context.textTheme.bodyMedium),
                                const Spacer(),
                                Obx(
                                  () => Text(
                                    controller.latestStudent.value?.name ?? "none",
                                    style: context.textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  "Father name:",
                                  style: context.textTheme.bodyMedium,
                                ),
                                const Spacer(),
                                Obx(
                                  () => Text(
                                    controller.latestStudent.value?.fatherName ??
                                        "none",
                                    style: context.textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              color: Colors.grey,
                            ),
                            Row(
                              children: [
                                Text(
                                  "Auto save",
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
                                    "User not found") {
                                  return const SizedBox.shrink();
                                }

                                if (controller.autoSave.value) {
                                  return const Text("Auto Saved Enabled");
                                }

                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      // width: 160,
                                      child: TextButton(
                                        onPressed: () {
                                          controller.result.value = "";
                                          controller.latestStudent.value = null;
                                        },
                                        child: const Text("Discard"),
                                      ),
                                    ),
                                    SizedBox(
                                      // width: 160,
                                      child: ElevatedButton(
                                        onPressed: controller.addAttendance,
                                        child: const Text("Ok"),
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
