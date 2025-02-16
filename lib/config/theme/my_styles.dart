import 'package:flutter/material.dart';

import 'dark_theme_colors.dart';
import 'light_theme_colors.dart';
import 'my_fonts.dart';

class MyStyles {
  static IconThemeData getIconTheme({required bool isLightTheme}) =>
      IconThemeData(
        color: isLightTheme
            ? LightThemeColors.primaryFgColor
            : DarkThemeColors.primaryFgColor,
      );

  static TextTheme getTextTheme({required bool isLightTheme}) => TextTheme(
        labelLarge: MyFonts.buttonTextStyle.copyWith(),
        bodyLarge: (MyFonts.bodyTextStyle).copyWith(
          fontWeight: FontWeight.bold,
        ),
        titleMedium: MyFonts.titleTextStyle.copyWith(
          fontWeight: FontWeight.bold,
        ),
        titleLarge: MyFonts.titleTextStyle.copyWith(
          fontWeight: FontWeight.bold,
        ),
        titleSmall: MyFonts.titleTextStyle.copyWith(
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: (MyFonts.bodyTextStyle).copyWith(),
        displayLarge: (MyFonts.displayTextStyle).copyWith(
          fontWeight: FontWeight.bold,
        ),
        bodySmall: MyFonts.titleTextStyle,
        displayMedium: (MyFonts.displayTextStyle).copyWith(
          fontWeight: FontWeight.bold,
        ),
        displaySmall: (MyFonts.displayTextStyle).copyWith(
          fontWeight: FontWeight.bold,
        ),
      );

  // elevated button text style
  static WidgetStateProperty<TextStyle?>? getElevatedButtonTextStyle(
      bool isLightTheme,
      {bool isBold = true,
      double? fontSize}) {
    return WidgetStateProperty.resolveWith<TextStyle>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return MyFonts.buttonTextStyle.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isLightTheme
                ? LightThemeColors.primaryFgColor
                : DarkThemeColors.primaryFgColor,
          );
        } else if (states.contains(WidgetState.disabled)) {
          return MyFonts.buttonTextStyle.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isLightTheme
                ? LightThemeColors.primaryFgColor.withValues(alpha: 60)
                : DarkThemeColors.primaryFgColor.withValues(alpha: 60),
          );
        }
        return MyFonts.buttonTextStyle.copyWith(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: isLightTheme
              ? LightThemeColors.primaryFgColor
              : DarkThemeColors.primaryFgColor,
        ); // Use the component's default.
      },
    );
  }

  //elevated button theme data
  static ElevatedButtonThemeData getElevatedButtonTheme(
          {required bool isLightTheme}) =>
      ElevatedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          elevation: WidgetStateProperty.all(0),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(vertical: 8, horizontal: 16)),
          textStyle: getElevatedButtonTextStyle(isLightTheme),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.pressed)) {
              return isLightTheme
                  ? LightThemeColors.primaryFgColor
                  : DarkThemeColors.primaryFgColor;
            } else if (states.contains(WidgetState.disabled)) {
              return isLightTheme
                  ? LightThemeColors.primaryFgColor.withValues(alpha: 60)
                  : DarkThemeColors.primaryFgColor.withValues(alpha: 60);
            }
            return isLightTheme
                ? LightThemeColors.primaryFgColor
                : DarkThemeColors.primaryFgColor;
          }),
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return isLightTheme
                    ? LightThemeColors.primaryColor.withValues(alpha: 60)
                    : DarkThemeColors.primaryColor.withValues(alpha: 60);
              } else if (states.contains(WidgetState.disabled)) {
                return isLightTheme
                    ? LightThemeColors.primaryColor.withValues(alpha: 90)
                    : DarkThemeColors.primaryColor.withValues(alpha: 90);
              } else if (states.contains(WidgetState.hovered)) {
                return isLightTheme
                    ? LightThemeColors.primaryColor.withValues(alpha: 30)
                    : DarkThemeColors.primaryColor.withValues(alpha: 30);
              }
              return isLightTheme
                  ? LightThemeColors.primaryColor
                  : DarkThemeColors
                      .primaryColor; // Use the component's default.
            },
          ),
        ),
      );
}
