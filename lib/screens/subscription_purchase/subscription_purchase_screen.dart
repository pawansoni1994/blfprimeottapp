import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../core/core.dart';
import 'subscription_purchase_controller.dart';

class SubscriptionPurchaseScreen extends StatelessWidget {
  SubscriptionPurchaseScreen({super.key});
  final SubscriptionPurchaseController controller = Get.put(SubscriptionPurchaseController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Subscription Plans',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.sp, color: Colors.red),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => controller.loadOfferings(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.packages.isEmpty) {
          return Center(
            child: Text(
              'No subscription plans available',
              style: TextStyle(fontSize: 16.sp),
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            SizedBox(height: 20.h),
            // Header
            Text(
              'Choose Your Plan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Unlock all premium features',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 32.h),
            
            // Subscription Plans
            ...controller.packages.map((package) {
              return _buildSubscriptionCard(
                package,
                controller.selectedPackage.value?.identifier == package.identifier,
                () => controller.selectPackage(package),
              );
            }).toList(),
            
            SizedBox(height: 24.h),
            
            // Features List
            _buildFeaturesList(),
            
            SizedBox(height: 24.h),
            
            // Purchase Button
            Obx(() => ElevatedButton(
              onPressed: controller.selectedPackage.value != null && !controller.isPurchasing.value
                  ? () => controller.purchaseSelectedPackage()
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pinkButton,
                fixedSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: controller.isPurchasing.value
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Subscribe Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            )),
            
            SizedBox(height: 16.h),
            
            // Restore Purchases
            TextButton(
              onPressed: () => controller.restorePurchases(),
              child: Text(
                'Restore Purchases',
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Terms and Privacy
            Text(
              'By subscribing, you agree to our Terms of Service and Privacy Policy. Subscription will auto-renew unless cancelled.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSubscriptionCard(
    Package package,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final price = package.storeProduct.priceString;
    final period = _getPeriodFromPackage(package);
    final title = _getTitleFromPackage(package);
    
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppColors.pinkButton : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16.r),
        color: isSelected ? AppColors.pinkButton.withOpacity(0.1) : Colors.white,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Radio button
              Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.pinkButton : Colors.grey[400]!,
                    width: 2,
                  ),
                  color: isSelected ? AppColors.pinkButton : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(Icons.check, size: 16.sp, color: Colors.white)
                    : null,
              ),
              SizedBox(width: 16.w),
              
              // Plan details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      period,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Price
              Text(
                price,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.pinkButton,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium Features:',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          _buildFeatureItem('Lorem ipsum dolor sit amet'),
          _buildFeatureItem('Consectetur adipiscing elit'),
          _buildFeatureItem('Sed do eiusmod tempor incididunt'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: AppColors.pinkButton, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(fontSize: 14.sp),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getPeriodFromPackage(Package package) {
    final identifier = package.identifier.toLowerCase();
    if (identifier.contains('weekly')) return 'Per Week';
    if (identifier.contains('monthly')) return 'Per Month';
    if (identifier.contains('yearly')) return 'Per Year';
    return 'Subscription';
  }

  String _getTitleFromPackage(Package package) {
    final identifier = package.identifier.toLowerCase();
    if (identifier.contains('weekly')) return 'Weekly Plan';
    if (identifier.contains('monthly')) return 'Monthly Plan';
    if (identifier.contains('yearly')) return 'Yearly Plan';
    return package.storeProduct.title;
  }
}
