import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/data/local/my_shared_pref.dart';
import 'app/routes/app_pages.dart';
import 'config/theme/my_theme.dart';
import 'config/translations/localization_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MySharedPref.init();
  bool firstOpen = MySharedPref.getIsFirstOpen();
  MySharedPref.setIsFirstOpen(false);

  runApp(
    GetMaterialApp(
      title: "Attendance Tracker",
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(),
      ),
      useInheritedMediaQuery: true,
      debugShowCheckedModeBanner: false,
      builder: (context, widget) {
        bool themeIsLight = MySharedPref.getThemeIsLight();
        return Theme(
          data: MyTheme.getThemeData(isLight: themeIsLight),
          child: MediaQuery(
            data: MediaQuery.of(context),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: widget!,
            ),
          ),
        );
      },
      defaultTransition: Transition.cupertino,
      initialRoute: firstOpen ? Routes.landing : AppPages.initial,
      getPages: AppPages.routes,
      locale: MySharedPref.getCurrentLocal(),
      translations: LocalizationService.getInstance(),
    ),
  );
}
