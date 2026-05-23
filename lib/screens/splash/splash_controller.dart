import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/local/hive/hive_manager.dart';
import '../../main.dart';
import '../../routes/app_pages.dart';

class SplashController extends GetxController {
  final HiveManager hiveManager = Get.find(tag: (HiveManager).toString());

  @override
  void onInit() {
    super.onInit();
    _loadLocale();
    _navigateToNextScreen();
  }

  void _loadLocale() {
    final String savedLocale =
        hiveManager.getString(HiveManager.localeKey, defaultValue: 'en');
    selectedLocale.value = Locale(savedLocale);
    Get.updateLocale(Locale(savedLocale));
  }

  void _navigateToNextScreen() {
    Future.delayed(
      Duration(seconds: 2),
      () {
        // if(hiveManager.getBool(HiveManager.onboardingDoneKey)){
        if (hiveManager.getString(HiveManager.tokenKey).isEmpty) {
          Get.offNamed(AppRoutes.login);
        } else {
          Get.offNamed(AppRoutes.home);
        }
        // } else {
        //   Get.offNamed(AppRoutes.onboarding);
        // }
      },
    );
  }
}
