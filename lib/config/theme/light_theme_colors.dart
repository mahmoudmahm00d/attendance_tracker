import 'package:flutter/material.dart';

class LightThemeColors {
  static const textColor = Color(0xFF040316);
  static const backgroundColor = Color(0xFFEEEEEE);
  static const primaryColor = Color(0xFF8E1616);
  static const primaryFgColor = Color(0xFFEEEEEE);
  static const secondaryColor = Color.fromARGB(130, 216, 64, 64);
  static const secondaryFgColor = Color(0xFF040316);
  static const accentColor = Color(0xFF1D1616);
  static const accentFgColor = Color(0xFFEEEEEE);

  static const colorScheme = ColorScheme(
    brightness: Brightness.light,
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
