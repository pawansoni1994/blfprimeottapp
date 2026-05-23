import 'package:get/get.dart';
import '../../core/core.dart';
import '../../data/local/hive/hive_manager.dart';
import '../../routes/app_pages.dart';
import '../../network/network.dart';
import '../home/home_controller.dart';
import '../view_all/view_all_controller.dart';

class MenuController extends GetxController {
  final HiveManager hiveManager = Get.find(tag: (HiveManager).toString());
  
  // Kids Safe toggle state
  final RxBool isKidsSafeEnabled = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadKidsSafeStatus();
  }
  
  void _loadKidsSafeStatus() {
    // Load kids safe status from Hive storage
    isKidsSafeEnabled.value = hiveManager.getBool(HiveManager.isForKidsKey, defaultValue: false);
  }
  
  void toggleKidsSafe(bool value) {
    isKidsSafeEnabled.value = value;
    // Save to Hive storage
    hiveManager.setBool(HiveManager.isForKidsKey, value);
    // Notify other controllers that the value changed
    // This will trigger API calls to refresh with new filter
    try {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().refreshMovies();
      }
    } catch (e) {
      // HomeController might not be initialized
    }
    
    try {
      if (Get.isRegistered<ViewAllController>()) {
        Get.find<ViewAllController>().refreshMovies();
      }
    } catch (e) {
      // ViewAllController might not be initialized
    }
  }
  
  void logout() {
    DeleteConfirmationDialog.show(
      AppStrings.logout.tr,
      AppStrings.logoutConfirmation.tr,
      onYes: () async {
        try {
          // Clear all user data
          hiveManager.clear();
          
          // Navigate to login
          Get.offAllNamed(AppRoutes.login);
        } catch (e) {
          logger.e(e);
        }
      },
    );
  }
}

