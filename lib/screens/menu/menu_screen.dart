import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/core.dart';
import '../../data/local/hive/hive_manager.dart';
import '../../routes/app_pages.dart';
import 'menu_controller.dart' as menu;

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    final menu.MenuController controller = Get.put(menu.MenuController());
    final HiveManager hiveManager = Get.find(tag: (HiveManager).toString());

    final String userName =
        hiveManager.getString(HiveManager.fullNameKey).isNotEmpty
            ? hiveManager.getString(HiveManager.fullNameKey)
            : (hiveManager.getString(HiveManager.emailKey).isNotEmpty
                ? hiveManager.getString(HiveManager.emailKey)
                : AppStrings.guest.tr);

    final String? userImage =
        hiveManager.getString(HiveManager.profileKey).isNotEmpty
            ? hiveManager.getString(HiveManager.profileKey)
            : null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Profile Header Section
            Container(
              height: Get.height / 6.8,
              decoration: BoxDecoration(
                color: AppColors.kNeutral90Color,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(20.r),
                  bottomLeft: Radius.circular(20.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Container(
                      height: Get.height * 0.10,
                      width: Get.width * 0.20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          width: 1,
                          color: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10.r)),
                        image: userImage != null && userImage.isNotEmpty
                            ? DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(userImage),
                              )
                            : DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(AppImages.avatarImage),
                              ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: Get.width / 2,
                        child: Text(
                          userName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.myProfile);
                        },
                        child: Text(
                          AppStrings.viewProfile.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.kPrimaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Kids Safe Toggle
            _buildKidsSafeToggle(controller),
            // Menu List
            Expanded(
              child: _buildMenuList(controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKidsSafeToggle(menu.MenuController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppStrings.kidsSafe.tr,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          Obx(() => Transform.scale(
                scale: 1.0,
                child: Switch(
                  value: controller.isKidsSafeEnabled.value,
                  onChanged: controller.toggleKidsSafe,
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.kPrimaryColor,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMenuList(menu.MenuController controller) {
    return ListView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      children: [
        _buildMenuItem(
          icon: AppImages.preference,
          title: AppStrings.subscription.tr,
          onTap: () {
            Get.toNamed(AppRoutes.subscription);
          },
        ),
        _buildMenuItem(
          iconData: Icons.edit,
          title: AppStrings.updateProfile.tr,
          isIcon: true,
          onTap: () async {
            var value = await Get.toNamed(AppRoutes.editProfile);
            if (value == true) {
              setState(() {});
            }
          },
        ),
        _buildMenuItem(
          icon: AppImages.addAdition,
          title: AppStrings.addAudition.tr,
          onTap: () {
            Get.toNamed(AppRoutes.addAudition);
          },
        ),
        _buildMenuItem(
          icon: AppImages.watchlist,
          title: AppStrings.watchlist.tr,
          onTap: () {
            Get.toNamed(AppRoutes.watchlist);
          },
        ),
        // _buildMenuItem(
        //   iconData: Icons.favorite,
        //   title: AppStrings.favoriteList.tr,
        //   isIcon: true,
        //   onTap: () {
        //     Get.toNamed(AppRoutes.favoriteList);
        //   },
        // ),
        // _buildMenuItem(
        //   icon: AppImages.addAdition,
        //   title: AppStrings.auditionList.tr,
        //   onTap: () {
        //     Get.toNamed(AppRoutes.auditionList);
        //   },
        // ),
        _buildMenuItem(
          icon: AppImages.language,
          title: AppStrings.languages.tr,
          onTap: () {
            Get.toNamed(AppRoutes.languages);
          },
        ),
        _buildMenuItem(
          icon: AppImages.genres,
          title: AppStrings.genres.tr,
          onTap: () {
            Get.toNamed(AppRoutes.genres);
          },
        ),
        // _buildMenuItem(
        //   iconData: Icons.notifications,
        //   title: AppStrings.notifications.tr,
        //   isIcon: true,
        //   onTap: () {
        //     // Navigate to notifications screen
        //     // Get.toNamed(AppRoutes.notifications);
        //   },
        // ),
        // _buildMenuItem(
        //   icon: AppImages.accountSetting,
        //   title: AppStrings.accountSetting.tr,
        //   onTap: () {
        //     // Navigate to account setting screen
        //     // Get.toNamed(AppRoutes.accountSetting);
        //   },
        // ),
        _buildMenuItem(
          icon: AppImages.aboutUs,
          title: AppStrings.aboutUs.tr,
          onTap: () {
            Get.toNamed(AppRoutes.aboutUs);
          },
        ),
        _buildMenuItem(
          icon: AppImages.privacy,
          title: AppStrings.privacy.tr,
          onTap: () {
            // Navigate to privacy screen
            launchUrl(Uri.parse("https://www.google.com"));
          },
        ),
        _buildMenuItem(
          icon: AppImages.help,
          title: AppStrings.help.tr,
          onTap: () {
            // Navigate to help screen
            launchUrl(Uri.parse("https://www.google.com"));
          },
        ),
        _buildMenuItem(
          icon: AppImages.contactUs,
          title: AppStrings.contactUs.tr,
          onTap: () {
            Get.toNamed(AppRoutes.contactUs);
          },
        ),
        _buildMenuItem(
          icon: AppImages.backButton,
          title: AppStrings.logout.tr,
          onTap: controller.logout,
          showArrow: false,
        ),
        _buildMenuItem(
          icon: AppImages.backButton,
          title: AppStrings.deleteAccount.tr,
          onTap: () => DeleteConfirmationDialog.show(
              AppStrings.deleteAccount.tr,
              AppStrings.deleteAccountConfirmation.tr, onYes: () {
            launchUrl(Uri.parse("https://www.google.com"));
          }),
          showArrow: false,
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required String title,
    required VoidCallback onTap,
    String? icon,
    IconData? iconData,
    bool isIcon = false,
    bool showArrow = true,
  }) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.r),
                    border: Border.all(
                      color: Colors.white,
                      width: 0.5,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(7.w),
                    child: isIcon && iconData != null
                        ? Icon(
                            iconData,
                            color: AppColors.kPrimaryColor,
                            size: 20.sp,
                          )
                        : icon != null
                            ? Image.asset(
                                icon,
                                width: 20.w,
                                height: 20.h,
                              )
                            : SizedBox(),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            if (showArrow)
              Image.asset(
                AppImages.drop,
                width: 20.w,
                height: 20.h,
              ),
          ],
        ),
      ),
    );
  }
}
