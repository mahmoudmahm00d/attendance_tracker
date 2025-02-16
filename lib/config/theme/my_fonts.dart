import 'package:flutter/material.dart';

import '../../app/data/local/my_shared_pref.dart';
import '../translations/localization_service.dart';

class MyFonts {
  static TextStyle get getAppFontType =>
      LocalizationService.supportedLanguagesFontsFamilies[
          MySharedPref.getCurrentLocal().languageCode]!;

  static TextStyle get displayTextStyle => getAppFontType;
  static TextStyle get titleTextStyle => getAppFontType;
  static TextStyle get bodyTextStyle => getAppFontType;
  static TextStyle get buttonTextStyle => getAppFontType;
  static TextStyle get appBarTextStyle => getAppFontType;
  static TextStyle get chipTextStyle => getAppFontType;
}
