import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CustomSnackBar {
  static showCustomSnackBar({
    required String title,
    required String message,
    Duration? duration,
  }) {
    Get.snackbar(
      title,
      message,
      duration: duration ?? const Duration(seconds: 3),
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
      colorText: Colors.white,
      backgroundColor: Colors.green,
      isDismissible: true,
      icon: const Icon(
        PhosphorIconsRegular.checkCircle,
        color: Colors.white,
      ),
    );
  }

  static showCustomErrorSnackBar({
    required String title,
    required String message,
    Color? color,
    Duration? duration,
  }) {
    Get.snackbar(
      title,
      message,
      duration: duration ?? const Duration(seconds: 3),
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
      colorText: Colors.white,
      backgroundColor: color ?? Colors.redAccent,
      isDismissible: true,
      icon: const Icon(
        PhosphorIconsRegular.xCircle,
        color: Colors.white,
      ),
    );
  }

  static showCustomToast({
    String? title,
    required String message,
    Color? color,
    Duration? duration,
  }) {
    Get.rawSnackbar(
      title: title,
      duration: duration ?? const Duration(seconds: 3),
      snackStyle: SnackStyle.GROUNDED,
      backgroundColor: color ?? Colors.green,
      isDismissible: true,
      onTap: (snack) {
        Get.closeAllSnackbars();
      },
      overlayBlur: 0.8,
      message: message,
    );
  }

  static showCustomErrorToast({
    String? title,
    required String message,
    Color? color,
    Duration? duration,
  }) {
    Get.rawSnackbar(
      title: title,
      duration: duration ?? const Duration(seconds: 3),
      snackStyle: SnackStyle.GROUNDED,
      backgroundColor: color ?? Colors.redAccent,
      isDismissible: true,
      onTap: (snack) {
        Get.closeAllSnackbars();
      },
      overlayBlur: 0.8,
      message: message,
    );
  }
}
