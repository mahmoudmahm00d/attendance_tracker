import 'package:attendance_tracker/app/modules/landing/controllers/landing_controller.dart';
import 'package:attendance_tracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:attendance_tracker/config/translations/strings_enum.dart';

class LandingView extends GetView<LandingController> {
  const LandingView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
          child: GetBuilder<LandingController>(
            builder: (_) {
              return Row(
                children: [
                  for (int i = 0; i < 6; i++)
                    InkWell(
                      borderRadius: BorderRadius.circular(1000),
                      onTap: () {
                        controller.goTo(i);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: i <= controller.currentPage
                              ? context.theme.primaryColor
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(1000),
                        ),
                      ),
                    ),
                ],
              );
            },
          )),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller.pageViewController,
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 160),
                  Container(
                    width: 240,
                    height: 240,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Image.asset("assets/images/app_icon.png"),
                  ),
                  const SizedBox(height: 160),
                  // First page texts
                  Text(
                    Strings.welcomeTitle.tr,
                    style: context.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Strings.welcomeDescription.tr,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: controller.nextPage,
                        child: Text(Strings.next.tr),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 160),
                  Container(
                    width: 240,
                    height: 240,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: SvgPicture.asset(
                      "assets/images/Documents2.svg",
                    ),
                  ),
                  const SizedBox(height: 140),
                  Text(
                    Strings.easyImportTitle.tr,
                    style: context.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Strings.easyImportDescription.tr,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: controller.previousPage,
                        child: Text(Strings.previous.tr),
                      ),
                      ElevatedButton(
                        onPressed: controller.nextPage,
                        child: Text(Strings.next.tr),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 160),
                  Container(
                    width: 240,
                    height: 240,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: SvgPicture.asset("assets/images/QRCode.svg"),
                  ),
                  const SizedBox(height: 140),
                  Text(
                    Strings.qrGeneratorTitle.tr,
                    style: context.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Strings.qrGeneratorDescription.tr,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: controller.previousPage,
                        child: Text(Strings.previous.tr),
                      ),
                      ElevatedButton(
                        onPressed: controller.nextPage,
                        child: Text(Strings.next.tr),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 160),
                  Container(
                    width: 240,
                    height: 240,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: SvgPicture.asset("assets/images/QRCode.svg"),
                  ),
                  const SizedBox(height: 120),
                  Text(
                    Strings.qrAttendanceTitle.tr,
                    style: context.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Strings.qrAttendanceDescription.tr,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: controller.previousPage,
                        child: Text(Strings.previous.tr),
                      ),
                      ElevatedButton(
                        onPressed: controller.nextPage,
                        child: Text(Strings.next.tr),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 160),
                  Container(
                    width: 240,
                    height: 240,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: SvgPicture.asset("assets/images/DataCloud2.svg"),
                  ),
                  const SizedBox(height: 140),
                  Text(
                    Strings.exportDataTitle.tr,
                    style: context.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Strings.exportDataDescription.tr,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: controller.previousPage,
                        child: Text(Strings.previous.tr),
                      ),
                      ElevatedButton(
                        onPressed: controller.nextPage,
                        child: Text(Strings.next.tr),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 160),
                  Container(
                    width: 240,
                    height: 240,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: SvgPicture.asset("assets/images/Checklist2.svg"),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    Strings.moreToExploreTitle.tr,
                    style: context.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Strings.linearGroupManagement.tr,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Strings.softDelete.tr,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Strings.generateReport.tr,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Strings.bulkOperation.tr,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Strings.dataInsights.tr,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Strings.andMore.tr,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Strings.letsGetStarted.tr,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: controller.previousPage,
                        child: Text(Strings.previous.tr),
                      ),
                      ElevatedButton(
                        onPressed: () => Get.offNamed(Routes.home),
                        child: Text(Strings.done.tr),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
