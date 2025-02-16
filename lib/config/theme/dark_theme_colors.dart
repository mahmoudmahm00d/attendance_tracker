import 'package:flutter/material.dart';

class DarkThemeColors {
  static const textColor = Color(0xFFeae9fc);
  static const backgroundColor = Color(0xFF121212);
  static const secondaryColor = Color(0xFFe97272);
  static const secondaryFgColor = Color(0xFF121212);
  static const primaryColor = Color(0xFFbe2727);
  static const primaryFgColor = Color(0xFFeae9fc);
  static const accentColor = Color(0xFFe9e2e2);
  static const accentFgColor = Color(0xFF121212);

  static const colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primaryColor,
    onPrimary: primaryFgColor,
    secondary: secondaryColor,
    onSecondary: secondaryFgColor,
    tertiary: accentColor,
    onTertiary: accentFgColor,
    surface: backgroundColor,
    onSurface: textColor,
    error: Color(0xffB3261E),
    onError: Color(0xff601410),
  );
}
