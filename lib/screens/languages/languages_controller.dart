import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/core.dart';
import '../../data/local/hive/hive_manager.dart';
import '../../localization/localization.dart';
import '../../main.dart';

class LanguagesController extends GetxController {
  final HiveManager hiveManager = Get.find(tag: (HiveManager).toString());
  
  final RxString selectedLanguageCode = 'en'.obs;
  final RxList<LanguageModel> languages = <LanguageModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
    _initializeLanguages();
  }

  void _loadSavedLanguage() {
    final String savedLocale = hiveManager.getString(HiveManager.localeKey, defaultValue: 'en');
    selectedLanguageCode.value = savedLocale;
  }

  void _initializeLanguages() {
    languages.value = [
      LanguageModel(
        code: 'en',
        name: 'English',
        nativeName: 'English',
        flag: '🇬🇧',
      ),
      LanguageModel(
        code: 'hi',
        name: 'Hindi',
        nativeName: 'हिंदी',
        flag: '🇮🇳',
      ),
      LanguageModel(
        code: 'ar',
        name: 'Arabic',
        nativeName: 'العربية',
        flag: '🇸🇦',
      ),
    ];
  }

  void selectLanguage(String languageCode) {
    if (selectedLanguageCode.value == languageCode) return;

    selectedLanguageCode.value = languageCode;
    _saveLanguage(languageCode);
    _updateAppLocale(languageCode);
  }

  void _saveLanguage(String languageCode) {
    hiveManager.setString(HiveManager.localeKey, languageCode);
  }

  void _updateAppLocale(String languageCode) {
    selectedLocale.value = Locale(languageCode);
    Get.updateLocale(Locale(languageCode));
    Utils.showToast('Language changed to ${getLanguageNameFromCode(languageCode)}');
  }

  LanguageModel? getSelectedLanguage() {
    return languages.firstWhereOrNull(
      (lang) => lang.code == selectedLanguageCode.value,
    );
  }
}

class LanguageModel {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

