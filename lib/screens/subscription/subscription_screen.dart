// ignore_for_file: sized_box_for_whitespace, avoid_unnecessary_containers, prefer_const_constructors, file_names, prefer_is_empty, unnecessary_cast, avoid_print, use_build_context_synchronously, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/core.dart';
import '../../data/model/model.dart';
import 'subscription_controller.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SubscriptionController controller = Get.put(SubscriptionController());

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppStrings.subscription.tr,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.plans.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.kPrimaryColor,
            ),
          );
        }

        if (controller.plans.isEmpty) {
          return Center(
            child: Text(
              'No subscription plans available',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 16.h),
              // Current Subscription Card
              if (controller.hasActiveSubscription.value)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: _buildCurrentSubscriptionCard(controller),
                ),
              SizedBox(height: 16.h),
              // Available Plans
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    controller.hasActiveSubscription.value
                        ? 'Available Plans'
                        : 'Choose a Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // Subscription Plans
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: controller.plans.map((plan) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: _buildPlanCard(plan, controller),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final isCurrentPlanSelected = controller.selectedPlan.value != null &&
            controller.isCurrentPlan(controller.selectedPlan.value!);
        final hasActiveSubscription = controller.hasActiveSubscription.value;
        final selectedPlan = controller.selectedPlan.value;
        final isUpgrade = selectedPlan != null && controller.isUpgrade(selectedPlan);

        if (isCurrentPlanSelected) {
          return SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.all(16.w),
          child: CustomButton(
            text: hasActiveSubscription
                ? (isUpgrade
                    ? AppStrings.upgradeSubscription.tr
                    : AppStrings.purchaseSubscription.tr)
                : AppStrings.purchaseSubscription.tr,
            onPressed: controller.isLoading.value
                ? null
                : () {
                    if (hasActiveSubscription && isUpgrade) {
                      _showUpgradeConfirmation(controller);
                    } else {
                      controller.purchaseSubscription();
                    }
                  },
            backgroundColor: AppColors.kPrimaryColor,
            textColor: Colors.white,
            borderRadius: 8.r,
            elevation: 0,
            size: ButtonSize.medium,
            isLoading: controller.isLoading.value,
          ),
        );
      }),
    );
  }

  Widget _buildCurrentSubscriptionCard(SubscriptionController controller) {
    return Obx(() {
      if (!controller.hasActiveSubscription.value) {
        return SizedBox.shrink();
      }

      final currentPlan = controller.currentPlan.value;
      if (currentPlan == null) {
        return SizedBox.shrink();
      }

      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.kPrimaryColor.withValues(alpha: 0.8),
              AppColors.kPrimaryColor.withValues(alpha: 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.kPrimaryColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.currentSubscription.tr,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      currentPlan.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'ACTIVE',
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
            Row(
              children: [
                Expanded(
                  child: _buildDateInfo(
                    icon: Icons.calendar_today,
                    label: AppStrings.subscriptionStartedOn.tr,
                    date: controller.currentPlanStartDate.value,
                    controller: controller,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildDateInfo(
                    icon: Icons.event,
                    label: AppStrings.subscriptionExpiresOn.tr,
                    date: controller.currentPlanEndDate.value,
                    controller: controller,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: AppStrings.upgrade.tr,
                    onPressed: () {
                      // Scroll to plans or select next higher plan
                      if (controller.plans.isNotEmpty) {
                        final higherPlans = controller.plans
                            .where((p) => p.price > currentPlan.price)
                            .toList();
                        if (higherPlans.isNotEmpty) {
                          controller.selectPlan(higherPlans.first);
                        }
                      }
                    },
                    backgroundColor: Colors.white,
                    textColor: AppColors.kPrimaryColor,
                    borderRadius: 8.r,
                    elevation: 0,
                    size: ButtonSize.medium,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomButton(
                    text: AppStrings.cancel.tr,
                    onPressed: () => _showCancelConfirmation(controller),
                    backgroundColor: Colors.transparent,
                    textColor: Colors.white,
                    borderRadius: 8.r,
                    elevation: 0,
                    size: ButtonSize.medium,
                    disabledColor: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDateInfo({
    required IconData icon,
    required String label,
    required String date,
    required SubscriptionController controller,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.white.withValues(alpha: 0.8),
                size: 16.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            date.isNotEmpty
                ? controller.formatDate(date)
                : 'N/A',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showUpgradeConfirmation(SubscriptionController controller) {
    final selectedPlan = controller.selectedPlan.value;
    if (selectedPlan == null) return;

    DeleteConfirmationDialog.show(
      AppStrings.upgradeSubscription.tr,
      AppStrings.upgradeSubscriptionConfirmation.tr,
      onYes: () {
        controller.upgradeSubscription();
      },
    );
  }

  void _showCancelConfirmation(SubscriptionController controller) {
    DeleteConfirmationDialog.show(
      AppStrings.cancelSubscription.tr,
      AppStrings.cancelSubscriptionConfirmation.tr,
      onYes: () {
        controller.cancelSubscription();
      },
    );
  }

  Widget _buildPlanCard(
      SubscriptionPlanModel plan, SubscriptionController controller) {
    return Obx(() {
      final isSelected = controller.selectedPlan.value?.id == plan.id;
      final isCurrentPlan = controller.isCurrentPlan(plan);
      final opacity = isCurrentPlan ? 0.6 : 1.0;

      return InkWell(
        onTap: isCurrentPlan ? null : () => controller.selectPlan(plan),
        child: Opacity(
          opacity: opacity,
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.kNeutral90Color.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isCurrentPlan
                    ? Colors.green.withValues(alpha: 0.5)
                    : isSelected
                        ? AppColors.kPrimaryColor
                        : Colors.white.withValues(alpha: 0.1),
                width: isSelected || isCurrentPlan ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.kPrimaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          controller.getFormattedPrice(plan),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isCurrentPlan)
                          Container(
                            margin: EdgeInsets.only(top: 4.h),
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'CURRENT PLAN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else if (plan.isPopular)
                          Container(
                            margin: EdgeInsets.only(top: 4.h),
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColors.kPrimaryColor,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'POPULAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      color: isSelected
                          ? AppColors.kPrimaryColor
                          : Colors.white.withValues(alpha: 0.5),
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      controller.getDurationText(plan.duration),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  plan.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13.sp,
                    height: 1.4,
                  ),
                ),
                if (plan.features.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  ...plan.features.map((feature) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.kPrimaryColor,
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13.sp,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
                if (isCurrentPlan &&
                    controller.currentPlanEndDate.value.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.green,
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Expires on',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12.sp,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                controller.formatDate(
                                    controller.currentPlanEndDate.value),
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}
