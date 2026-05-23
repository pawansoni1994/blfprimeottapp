import 'package:get/get.dart';
import '../home/home_controller.dart';

class MainController extends GetxController {
  // Current selected tab index
  final RxInt currentIndex = 0.obs;

  // Method to change tab
  void changeTab(int index) {
    if (index != currentIndex.value) {
      currentIndex.value = index;
      
      // Refresh continue watching when switching to home tab (index 0)
      if (index == 0) {
        _refreshContinueWatching();
      }
    }
  }

  void _refreshContinueWatching() {
    try {
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        homeController.fetchContinueWatching();
      }
    } catch (e) {
      // HomeController might not be initialized yet
    }
  }
}

