import 'package:attendance_tracker/app/data/local/my_shared_pref.dart';
import 'package:attendance_tracker/app/modules/preferences/controllers/preferences_controller.dart';
import 'package:attendance_tracker/config/theme/my_theme.dart';
import 'package:attendance_tracker/config/translations/localization_service.dart';
import 'package:attendance_tracker/config/translations/strings_enum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PreferencesView extends GetView<PreferencesController> {
  const PreferencesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsBold.caretLeft),
          onPressed: Get.back,
        ),
        title: Text(Strings.preferences.tr),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              GetBuilder<PreferencesController>(
                builder: (_) {
                  var themeIsLight = MySharedPref.getThemeIsLight();
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: themeIsLight
                        ? const Icon(PhosphorIconsFill.sun)
                        : const Icon(PhosphorIconsFill.moon),
                    title: Text(
                        "${Strings.changeTo.tr} ${themeIsLight ? Strings.dark.tr : Strings.light.tr}"),
                    trailing: Switch(
                      value: themeIsLight,
                      onChanged: (_) {
                        MyTheme.changeTheme();
                        controller.update();
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              GetBuilder<PreferencesController>(
                builder: (_) {
                  var isItEnglish = LocalizationService.isItEnglish();
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(PhosphorIconsFill.translate),
                    title: Text(Strings.currentLanguage.tr),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        LocalizationService.updateLanguage(value);
                        controller.update();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          !isItEnglish ? Strings.arabic.tr : Strings.english.tr,
                          style: context.textTheme.bodyLarge,
                        ),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: "ar",
                          child: Text(Strings.arabic.tr),
                        ),
                        PopupMenuItem(
                          value: "en",
                          child: Text(Strings.english.tr),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Form(
                key: controller.formKey,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 0,
                  ),
                  leading: const Icon(PhosphorIconsBold.listBullets),
                  title: Text(Strings.defaultPageSize.tr),
                  trailing: SizedBox(
                    height: 90,
                    width: 96,
                    child: TextFormField(
                      controller: controller.pageSizeController,
                      keyboardType: TextInputType.number,
                      validator: (str) => !GetUtils.isNum(str ?? "")
                          ? Strings.numberValidation.tr
                          : null,
                      onChanged: (_) {
                        if (!controller.formKey.currentState!.validate()) {
                          return;
                        }

                        MySharedPref.setPageSize(
                          int.parse(controller.pageSizeController.text),
                        );
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
