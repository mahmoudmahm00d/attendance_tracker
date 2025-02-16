import 'package:attendance_tracker/app/modules/landing/controllers/landing_controller.dart';
import 'package:attendance_tracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                  Text(
                    "Welcom to Attendance Tracker",
                    style: context.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Basic attendnace app to track your students",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: controller.nextPage,
                        child: const Text("Next"),
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
                    "Easy Import",
                    style: context.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Import your students easily using excel file with just name and father name",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: controller.previousPage,
                        child: const Text("Previous"),
                      ),
                      ElevatedButton(
                        onPressed: controller.nextPage,
                        child: const Text("Next"),
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
                    "QR codes Generator",
                    style: context.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Export a PDF contains your students ids in QR code format with just one click",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: controller.previousPage,
                        child: const Text("Previous"),
                      ),
                      ElevatedButton(
                        onPressed: controller.nextPage,
                        child: const Text("Next"),
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
                    "QR attendance",
                    style: context.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Add attendances by scanning student's QR code with auto save to easy add multiple attendances with ease",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: controller.previousPage,
                        child: const Text("Previous"),
                      ),
                      ElevatedButton(
                        onPressed: controller.nextPage,
                        child: const Text("Next"),
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
                    "Export your data",
                    style: context.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Easily export your data to an excel format, or just export the whole database!",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: controller.previousPage,
                        child: const Text("Previous"),
                      ),
                      ElevatedButton(
                        onPressed: controller.nextPage,
                        child: const Text("Next"),
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
                    "And more and more to explore",
                    style: context.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "* Linear group management",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "* Soft delete",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "* Generate attendance report",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "* Bulk operation",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "* Data insights",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "and more...",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Let's get started",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: controller.previousPage,
                        child: const Text("Previous"),
                      ),
                      ElevatedButton(
                        onPressed: () => Get.offNamed(Routes.home),
                        child: const Text("Done"),
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
