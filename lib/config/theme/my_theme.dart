import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/data/local/my_shared_pref.dart';
import 'dark_theme_colors.dart';
import 'light_theme_colors.dart';
import 'my_styles.dart';

class MyTheme {
  static getThemeData({required bool isLight}) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        surfaceTintColor: Colors.transparent,
      ),
      primaryColor: isLight
          ? LightThemeColors.primaryColor
          : DarkThemeColors.primaryColor,
      colorScheme:
          isLight ? LightThemeColors.colorScheme : DarkThemeColors.colorScheme,
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          elevation: WidgetStateProperty.all(0),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(vertical: 8, horizontal: 16)),
        ),
      ),
      elevatedButtonTheme:
          MyStyles.getElevatedButtonTheme(isLightTheme: isLight),
      textTheme: MyStyles.getTextTheme(isLightTheme: isLight),
      inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: isLight
              ? LightThemeColors.textColor.withAlpha(25)
              : DarkThemeColors.textColor.withAlpha(25),
          hintStyle: TextStyle(
            color: isLight
                ? LightThemeColors.textColor.withAlpha(160)
                : DarkThemeColors.textColor.withAlpha(160),
          ),
          floatingLabelStyle: TextStyle(
            color: isLight
                ? LightThemeColors.textColor.withAlpha(160)
                : DarkThemeColors.textColor.withAlpha(160),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          border: const OutlineInputBorder(borderSide: BorderSide.none)),
    );
  }

  static changeTheme() {
    bool isLightTheme = MySharedPref.getThemeIsLight();
    MySharedPref.setThemeIsLight(!isLightTheme);
    Get.changeThemeMode(!isLightTheme ? ThemeMode.light : ThemeMode.dark);
  }

  bool get getThemeIsLight => MySharedPref.getThemeIsLight();
}
