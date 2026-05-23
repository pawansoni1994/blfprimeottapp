import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/core.dart';
import 'main_controller.dart';
import '../home/home_tab_screen.dart';
import '../coming_soon/coming_soon_screen.dart';
import '../menu/menu_screen.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final MainController controller = Get.put(MainController());

  // List of tab screens
  final List<Widget> _screens = [
    HomeTabScreen(),
    ComingSoonScreen(),
    MenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: _screens,
          )),
      bottomNavigationBar: Obx(() => Container(
            decoration: BoxDecoration(
              color: AppColors.darkBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: controller.currentIndex.value,
              onTap: controller.changeTab,
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.darkBackground,
              selectedItemColor: AppColors.kPrimaryColor,
              unselectedItemColor: Colors.white.withValues(alpha: 0.6),
              selectedLabelStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: Center(
                      child: Image.asset(
                    AppImages.homeGrey,
                    width: 20,
                    height: 20,
                  )),
                  activeIcon: Center(
                      child: Image.asset(
                    AppImages.homeWhite,
                    width: 20,
                    height: 20,
                  )),
                  label: AppStrings.home.tr,
                ),
                BottomNavigationBarItem(
                  icon: Center(
                      child: Image.asset(
                    AppImages.comingSoonGrey,
                    width: 20,
                    height: 20,
                  )),
                  activeIcon: Center(
                      child: Image.asset(
                    AppImages.comingSoonWhite,
                    width: 20,
                    height: 20,
                  )),
                  label: AppStrings.comingSoon.tr,
                ),
                BottomNavigationBarItem(
                  icon: Center(
                      child: Image.asset(
                    AppImages.menuGrey,
                    width: 20,
                    height: 20,
                  )),
                  activeIcon: Center(
                      child: Image.asset(
                    AppImages.menuWhite,
                    width: 20,
                    height: 20,
                  )),
                  label: AppStrings.menu.tr,
                ),
              ],
            ),
          )),
    );
  }
}
