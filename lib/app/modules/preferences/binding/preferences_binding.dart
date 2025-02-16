import 'package:attendance_tracker/app/modules/preferences/controllers/preferences_controller.dart';
import 'package:get/get.dart';

class PreferencesBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PreferencesController>(
      () => PreferencesController(),
    );
  }
}
