import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../core/core.dart';
import 'subscription_manage_controller.dart';

class SubscriptionManageScreen extends StatelessWidget {
  SubscriptionManageScreen({super.key});
  final SubscriptionManageController controller = Get.put(SubscriptionManageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Subscription',
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
                    onPressed: () => controller.loadSubscriptionInfo(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            SizedBox(height: 20.h),
            
            // Subscription Status Card
            Obx(() => _buildStatusCard(controller.hasActiveSubscription.value)),
            
            SizedBox(height: 24.h),
            
            // Current Subscription Details
            if (controller.hasActiveSubscription.value)
              Obx(() => _buildSubscriptionDetails(controller.currentEntitlement.value)),
            
            SizedBox(height: 24.h),
            
            // Actions
            if (controller.hasActiveSubscription.value) ...[
              _buildActionButton(
                icon: Icons.cancel_outlined,
                title: 'Cancel Subscription',
                subtitle: 'Manage or cancel your subscription',
                onTap: () => controller.openCancelSubscription(),
                color: Colors.red,
              ),
              SizedBox(height: 12.h),
            ],
            
            _buildActionButton(
              icon: Icons.refresh,
              title: 'Restore Purchases',
              subtitle: 'Restore your previous purchases',
              onTap: () => controller.restorePurchases(),
              color: AppColors.pinkButton,
            ),
            
            SizedBox(height: 12.h),
            
            _buildActionButton(
              icon: Icons.shopping_cart,
              title: 'View Plans',
              subtitle: 'Browse available subscription plans',
              onTap: () => Get.toNamed('/subscription-purchase'),
              color: AppColors.pinkButton,
            ),
            
            SizedBox(height: 24.h),
            
            // Terms and Info
            Text(
              "Subscriptions are managed through your device's app store. To cancel, go to your device settings.",
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

  Widget _buildStatusCard(bool hasActive) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: hasActive ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: hasActive ? Colors.green : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: hasActive ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasActive ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasActive ? 'Active Subscription' : 'No Active Subscription',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  hasActive
                      ? 'You have an active premium subscription'
                      : 'Subscribe to unlock premium features',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionDetails(EntitlementInfo? entitlement) {
    if (entitlement == null) return SizedBox.shrink();
    
    final productId = entitlement.productIdentifier;
    final expiresDate = entitlement.expirationDate;
    final isActive = entitlement.isActive;
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Plan',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          _buildDetailRow('Plan', _getPlanName(productId)),
          SizedBox(height: 8.h),
          _buildDetailRow(
            'Status',
            isActive ? 'Active' : 'Expired',
            valueColor: isActive ? Colors.green : Colors.red,
          ),
          if (expiresDate != null) ...[
            SizedBox(height: 8.h),
            _buildDetailRow(
              'Expires',
              _formatDate(DateTime.tryParse(expiresDate.toString()) ?? DateTime.now()),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  String _getPlanName(String productId) {
    final id = productId.toLowerCase();
    if (id.contains('weekly')) return 'Weekly Plan';
    if (id.contains('monthly')) return 'Monthly Plan';
    if (id.contains('yearly')) return 'Yearly Plan';
    return productId;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
