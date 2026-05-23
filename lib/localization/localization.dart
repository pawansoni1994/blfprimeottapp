import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ar.dart';
import 'en.dart';
import 'hi.dart';

///  this class contains Localization Service make available app in multiple language.

List<Locale> supportedLocales = [
  Locale("en"),
  Locale("hi"),
  Locale("ar"),
];

List<String> languageNames = ["English", "हिंदी", "العربية"];

String getLanguageCodeFromName(String name){
  String code = 'en';
   switch(name) {
     case "English":
       return 'en';
     case "हिंदी":
       return "hi";
     case "العربية" :
       return "ar";
  }
  return code;
}

String getLanguageNameFromCode(String code){
  String name = 'English';
   switch(code) {
     case "en":
       return 'English';
     case "hi":
       return "हिंदी";
     case "ar" :
       return "العربية";
  }
  return name;
}

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': En.keys,
    'hi': Hi.keys,
    'ar': Ar.keys,
  };
}
