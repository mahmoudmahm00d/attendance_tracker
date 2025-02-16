import 'package:attendance_tracker/app/data/local/my_shared_pref.dart';
import 'package:attendance_tracker/app/modules/preferences/controllers/preferences_controller.dart';
import 'package:attendance_tracker/config/theme/my_theme.dart';
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
        title: const Text("Preferences"),
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
                    title: Text("Change to ${themeIsLight ? "Dark" : "Light"}"),
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
              Form(
                key: controller.formKey,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    // vertical: 16,
                  ),
                  leading: const Icon(PhosphorIconsBold.listBullets),
                  title: const Text("Default Page Size"),
                  trailing: SizedBox(
                    height: 90,
                    width: 96,
                    child: TextFormField(
                      controller: controller.pageSizeController,
                      keyboardType: TextInputType.number,
                      validator: (str) =>
                          !GetUtils.isNum(str ?? "") ? "1..N" : null,
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
