import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:attendance_tracker/app/components/custom_snackbar.dart';
import 'package:attendance_tracker/app/services/database_execution_status.dart';
import 'package:attendance_tracker/app/components/no_data_found_widget.dart';
import 'package:attendance_tracker/app/data/local/my_shared_pref.dart';
import 'package:attendance_tracker/app/routes/app_pages.dart';
import 'package:attendance_tracker/config/theme/dark_theme_colors.dart';
import 'package:attendance_tracker/config/theme/light_theme_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:attendance_tracker/config/translations/strings_enum.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Tracker"),
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 32,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 96,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Image.asset("assets/images/app_icon.png"),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "Attendance\nTracker",
                      style: context.textTheme.titleLarge!.copyWith(
                        color: context.theme.primaryColor,
                      ),
                    ),
                    // const Icon(PhosphorIconsFill.calendar, size: 48),
                  ],
                ),
              ),
              Container(
                color: Colors.grey.withAlpha(30),
                child: Column(
                  children: [
                    ListTile(
                      onTap: () => Get.toNamed(Routes.groups),
                      leading: const Icon(PhosphorIconsFill.users),
                      title: Text(Strings.groups.tr),
                    ),
                    ListTile(
                      onTap: () => Get.toNamed(Routes.subjects),
                      leading: const Icon(PhosphorIconsFill.book),
                      title: Text(Strings.subjects.tr),
                    ),
                    ListTile(
                      onTap: () => Get.toNamed(Routes.students),
                      leading: const Icon(PhosphorIconsFill.student),
                      title: Text(Strings.students.tr),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                color: Colors.grey.withAlpha(30),
                child: Column(
                  children: [
                    ListTile(
                      onTap: controller.exportDatabase,
                      leading: const Icon(PhosphorIconsFill.boxArrowUp),
                      title: Text(Strings.exportDatabase.tr),
                    ),
                    ListTile(
                      onTap: controller.importDatabase,
                      leading: const Icon(PhosphorIconsFill.boxArrowDown),
                      title: Text(Strings.importDatabase.tr),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                color: Colors.grey.withAlpha(30),
                child: Column(
                  children: [
                    ListTile(
                      onTap: () => Get.toNamed(Routes.preferences),
                      leading: const Icon(PhosphorIconsFill.gearFine),
                      title: Text(Strings.preferences.tr),
                    ),
                    ListTile(
                      onTap: () => Get.toNamed(Routes.landing),
                      leading: const Icon(PhosphorIconsFill.info),
                      title: Text(Strings.about.tr),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                color: Colors.grey.withAlpha(30),
                child: Column(
                  children: [
                    ListTile(
                      onTap: () {
                        launchUrl(Uri.parse(
                            "https://github.com/mahmoudmahm00d/attendance_tracker.git"));
                      },
                      leading: const Icon(PhosphorIconsFill.githubLogo),
                      title: Text(Strings.giveMeAStar.tr),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.getData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GetBuilder<HomeController>(
              builder: (_) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Strings.insights.tr,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Tile(
                          onTap: () => Get.toNamed(Routes.subjects),
                          height: 120,
                          width: context.width / 2 - 24,
                          icon: PhosphorIconsBold.books,
                          title: Strings.subjects.tr,
                          subTitle: controller.subjectsCount.toString(),
                        ),
                        const SizedBox(width: 16),
                        Tile(
                          onTap: () => Get.toNamed(Routes.groups),
                          height: 120,
                          width: context.width / 2 - 24,
                          icon: PhosphorIconsBold.users,
                          title: Strings.groups.tr,
                          subTitle: controller.groupsCount.toString(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Tile(
                      onTap: () => Get.toNamed(Routes.students),
                      height: 120,
                      width: context.width - 32,
                      title: Strings.students.tr,
                      subTitle: controller.usersCount.toString(),
                      icon: PhosphorIconsBold.student,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      Strings.quickActions.tr,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        ActionTile(
                          text: Strings.addGroup.tr,
                          icon: PhosphorIconsBold.users,
                          onTap: () => Get.toNamed(Routes.createGroup),
                        ),
                        ActionTile(
                          text: Strings.addSubject.tr,
                          icon: PhosphorIconsBold.book,
                          onTap: () => Get.toNamed(Routes.createSubject),
                        ),
                        ActionTile(
                          text: Strings.addStudent.tr,
                          icon: PhosphorIconsBold.student,
                          onTap: () => Get.toNamed(Routes.createStudent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      Strings.recentSubjects.tr,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (controller.databaseExecutionStatus ==
                        DatabaseExecutionStatus.loading)
                      Center(
                        child: CupertinoActivityIndicator(
                          radius: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    if (controller.databaseExecutionStatus !=
                            DatabaseExecutionStatus.loading &&
                        controller.latestSubject == null)
                      Align(
                        alignment: Alignment.topCenter,
                        child: NoDataFoundWidget(
                          title: Strings.noRecentSubject.tr,
                          message: Strings.useSubjectToAppear.tr,
                          action: () => Get.toNamed(Routes.subjects),
                          icon: PhosphorIconsFill.book,
                          buttonText: Strings.goToSubjects.tr,
                        ),
                      )
                    else if (controller.databaseExecutionStatus !=
                        DatabaseExecutionStatus.loading)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(controller.latestSubject!.name),
                        leading: const Icon(PhosphorIconsBold.users),
                        trailing: PopupMenuButton(
                          onSelected: (value) async {
                            if (value == 3) {
                              Get.toNamed(
                                Routes.attendance,
                                arguments: controller.latestSubject!,
                              );
                            }
                            if (value == 4) {
                              var status = await Permission.camera.request();
                              if (!status.isGranted) {
                                CustomSnackBar.showCustomErrorSnackBar(
                                  title: Strings.lackOfPermission.tr,
                                  message: Strings.addCameraPermission.tr,
                                );

                                return;
                              }

                              Get.toNamed(
                                Routes.qrAttendance,
                                arguments: controller.latestSubject!,
                              );
                            }
                          },
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                value: 3,
                                child: Row(
                                  children: [
                                    const Icon(PhosphorIconsBold.table),
                                    const SizedBox(width: 8),
                                    Text(Strings.attendance.tr),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 4,
                                child: Row(
                                  children: [
                                    const Icon(PhosphorIconsBold.qrCode),
                                    const SizedBox(width: 8),
                                    Text(Strings.takeAttendance.tr),
                                  ],
                                ),
                              ),
                            ];
                          },
                          icon: const Icon(PhosphorIconsBold.dotsThreeOutline),
                        ),
                      ),
                    const SizedBox(height: 60),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class Tile extends StatelessWidget {
  final String title;
  final String subTitle;
  final IconData icon;
  final double width;
  final double height;
  final Color? color;
  final Function()? onTap;

  const Tile({
    super.key,
    required this.title,
    required this.subTitle,
    required this.icon,
    required this.width,
    required this.height,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var theme = context.theme;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: color ?? theme.primaryColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 8),
            Icon(
              size: 40,
              icon,
              color: Colors.white,
            ),
            Text(
              title,
              style: theme.textTheme.titleMedium!.copyWith(color: Colors.white),
            ),
            Text(
              subTitle,
              style: theme.textTheme.titleLarge!.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class ActionTile extends StatelessWidget {
  final Function()? onTap;
  final String text;
  final IconData icon;
  const ActionTile({
    super.key,
    this.onTap,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    var isLightTheme = MySharedPref.getThemeIsLight();
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      onTap: onTap,
      child: Container(
        width: context.width / 3 - 22,
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLightTheme
              ? LightThemeColors.secondaryColor
              : DarkThemeColors.secondaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: context.theme.textTheme.titleSmall!
                      .copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
