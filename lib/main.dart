import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'bindings/initial_binding.dart';
import 'core/values/theme_data.dart';
import 'data/local/hive/hive_manager.dart';
import 'localization/localization.dart';
import 'routes/app_pages.dart';

import 'core/utils/subscription_helper.dart';

import 'core/utils/notification_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_ad/flutter_native_ad.dart';
import 'core/utils/ad_config.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

ValueNotifier<Locale> selectedLocale = ValueNotifier(Locale('en'));
ValueNotifier<bool> isDarkTheme = ValueNotifier(true);

Future<void> initAppTrackingTransparency() async {
  try {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await Future.delayed(const Duration(milliseconds: 200));
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  } catch (e) {
    print('Error initializing AppTrackingTransparency: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initAppTrackingTransparency();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AdConfig.init();
  try {
    await FlutterNativeAd.init();
  } catch (e) {}

  NotificationService().initialize();

  await SubscriptionHelper().initialize();

  await Hive.initFlutter();
  await Hive.openBox(HiveManager.appName);

  // Load saved locale from Hive
  final HiveManager hiveManager = HiveManagerImpl();
  final String savedLocale =
      hiveManager.getString(HiveManager.localeKey, defaultValue: 'en');
  selectedLocale.value = Locale(savedLocale);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Force rebuild or reinit logic if necessary
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_, child) {
        return ValueListenableBuilder(
          valueListenable: selectedLocale,
          builder: (context, value, child) {
            return ValueListenableBuilder(
                valueListenable: isDarkTheme,
                builder: (context, themeValue, child) {
                  return GetMaterialApp(
                    title: 'BLF Prime',
                    initialRoute: AppRoutes.splash,
                    initialBinding: InitialBinding(),
                    getPages: AppPages.routes,
                    localizationsDelegates: [
                      GlobalCupertinoLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      // LocalizationService.delegate(),
                    ],
                    builder: EasyLoading.init(
                      builder: (context, child) {
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            textScaler: const TextScaler.linear(1.0),
                          ),
                          child: child!,
                        );
                      },
                    ),
                    locale: value,
                    supportedLocales: supportedLocales,
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeValue ? ThemeMode.dark : ThemeMode.light,
                    debugShowCheckedModeBanner: false,
                    translations: AppTranslations(),
                  );
                });
          },
        );
      },
    );
  }
}
