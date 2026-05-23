// ignore_for_file: sized_box_for_whitespace, avoid_unnecessary_containers, prefer_const_constructors, file_names, prefer_is_empty, unnecessary_cast, avoid_print, use_build_context_synchronously, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/core.dart';
import '../../routes/app_pages.dart';
import 'my_profile_controller.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MyProfileController controller = Get.put(MyProfileController());

    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.myProfile.tr,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.profile.value == null) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.kPrimaryColor,
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20.h),
              _buildProfileImage(controller),
              SizedBox(height: 16.h),
              _buildProfileInfo(controller),
              SizedBox(height: 24.h),
              _buildSubscriptionDetails(controller),
              SizedBox(height: 24.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileImage(MyProfileController controller) {
    final userImage = controller.getUserImage();

    return Center(
      child: Container(
        width: Get.width * 0.4,
        height: Get.height * 0.2,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 1, color: Colors.transparent),
          shape: BoxShape.circle,
          image: userImage != null && userImage.isNotEmpty
              ? DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(userImage),
                )
              : DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(AppImages.splash),
                ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(MyProfileController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.kNeutral90Color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.getUserName(),
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.h),
            _buildInfoRow(
              icon: Icons.email_outlined,
              label: AppStrings.email.tr,
              value: controller.profile.value?.email ?? 'N/A',
            ),
            SizedBox(height: 12.h),
            _buildInfoRow(
              icon: Icons.phone_outlined,
              label: AppStrings.phoneNumber.tr,
              value: controller.getUserPhone(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.kPrimaryColor,
          size: 20.sp,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: valueColor ?? Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionDetails(MyProfileController controller) {
    return Obx(() {
      final hasSubscription = controller.subscriptionId.value != "No Subscription" &&
          controller.subscriptionId.value.isNotEmpty;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: hasSubscription
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.kPrimaryColor.withValues(alpha: 0.8),
                      AppColors.kPrimaryColor.withValues(alpha: 0.6),
                    ],
                  )
                : null,
            color: hasSubscription
                ? null
                : AppColors.kNeutral90Color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: hasSubscription
                  ? AppColors.kPrimaryColor.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.subscription.tr,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (hasSubscription)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        controller.profile.value?.plan?.status?.toUpperCase() ?? 'ACTIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 20.h),
              if (hasSubscription) ...[
                _buildSubscriptionInfoRow(
                  icon: Icons.card_membership,
                  label: AppStrings.subscription.tr,
                  value: controller.subscriptionId.value,
                ),
                SizedBox(height: 16.h),
                if (controller.paymentAmount.value != "00")
                  _buildSubscriptionInfoRow(
                    icon: Icons.payments,
                    label: 'Amount',
                    value: '${controller.profile.value?.plan?.currency ?? 'INR'} ${controller.paymentAmount.value}',
                  ),
                if (controller.paymentAmount.value != "00") SizedBox(height: 16.h),
                if (controller.startDate.value != "00" && controller.startDate.value.isNotEmpty)
                  _buildSubscriptionInfoRow(
                    icon: Icons.calendar_today,
                    label: AppStrings.subscriptionStartedOn.tr,
                    value: controller.formatDate(controller.startDate.value),
                  ),
                if (controller.startDate.value != "00" && controller.startDate.value.isNotEmpty)
                  SizedBox(height: 16.h),
                if (controller.endDate.value != "00" && controller.endDate.value.isNotEmpty)
                  _buildSubscriptionInfoRow(
                    icon: Icons.event,
                    label: AppStrings.subscriptionExpiresOn.tr,
                    value: controller.formatDate(controller.endDate.value),
                  ),
                SizedBox(height: 24.h),
                _buildUpgradeButton(),
                SizedBox(height: 12.h),
                InkWell(
                  onTap: () => _showCancelSubscriptionDialog(controller),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cancel_outlined,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          AppStrings.cancelSubscription.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.card_membership_outlined,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 48.sp,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        AppStrings.noActiveSubscription.tr,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Subscribe to unlock premium features',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                CustomButton(
                  text: 'View Plans',
                  onPressed: () async {
                    var result = await Get.toNamed(AppRoutes.subscription);
                    if (result == true) {
                      controller.getProfile();
                    }
                  },
                  backgroundColor: AppColors.kPrimaryColor,
                  textColor: Colors.white,
                  borderRadius: 8.r,
                  elevation: 0,
                  size: ButtonSize.medium,
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSubscriptionInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.8),
          size: 20.sp,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradeButton() {
    return CustomButton(
      text: AppStrings.upgradeYourPlan.tr,
      onPressed: () async {
        var result = await Get.toNamed(AppRoutes.subscription);
        if (result == true) {
          Get.find<MyProfileController>().getProfile();
        }
      },
      backgroundColor: Colors.white,
      textColor: AppColors.kPrimaryColor,
      borderRadius: 8.r,
      elevation: 0,
      size: ButtonSize.medium,
    );
  }

  void _showCancelSubscriptionDialog(MyProfileController controller) {
    DeleteConfirmationDialog.show(
      AppStrings.cancelSubscription.tr,
      AppStrings.cancelSubscriptionConfirmation.tr,
      onYes: () {
        controller.cancelSubscription();
      },
    );
  }
}
