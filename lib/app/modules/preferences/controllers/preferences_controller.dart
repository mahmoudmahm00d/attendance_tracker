import 'package:attendance_tracker/app/data/local/my_shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PreferencesController extends GetxController {
  TextEditingController pageSizeController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onReady() {
    var pageSize = MySharedPref.getPageSize();
    pageSizeController.text = pageSize.toString();
    super.onReady();
  }
}
