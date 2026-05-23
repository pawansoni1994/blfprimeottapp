import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../core/core.dart';
import '../../core/controllers/user_subscription_controller.dart';
import '../../core/utils/subscription_helper.dart';
import '../../data/model/model.dart';
import '../../network/error_handlers.dart';

class SubscriptionController extends GetxController {
  final SubscriptionHelper _subscriptionHelper = SubscriptionHelper();
  
  // Store RevenueCat packages
  final RxList<Package> _revenueCatPackages = <Package>[].obs;
  final RxMap<String, Package> _packageMap = <String, Package>{}.obs;

  final Rx<SubscriptionPlanModel?> selectedPlan =
      Rx<SubscriptionPlanModel?>(null);
  final RxBool isLoading = false.obs;
  final RxList<SubscriptionPlanModel> plans = <SubscriptionPlanModel>[].obs;

  // Current subscription info
  final RxString currentPlanId = ''.obs;
  final RxString currentPlanEndDate = ''.obs;
  final RxString currentPlanName = ''.obs;
  final RxString currentPlanStartDate = ''.obs;
  final RxBool hasActiveSubscription = false.obs;
  final Rx<SubscriptionPlanModel?> currentPlan = Rx<SubscriptionPlanModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadSubscriptionData();
  }

  Future<void> _loadSubscriptionData() async {
    try {
      isLoading.value = true;

      // Load subscription plans from RevenueCat
      await _loadSubscriptionPlans();

      // Load current subscription status from RevenueCat
      await _loadCurrentSubscription();
    } catch (e) {
      logger.e(e);
      Utils.showToast('Failed to load subscription data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadCurrentSubscription() async {
    try {
      final subscriptionInfo = await _subscriptionHelper.getCurrentSubscriptionInfo();
      
      if (subscriptionInfo != null && subscriptionInfo['isActive'] == true) {
        currentPlanId.value = subscriptionInfo['productId'] ?? '';
        currentPlanName.value = 'Active Subscription';
        currentPlanEndDate.value = subscriptionInfo['expirationDate'] ?? '';
        currentPlanStartDate.value = subscriptionInfo['purchaseDate'] ?? '';
        hasActiveSubscription.value = true;
        
        // Find and set current plan model from plans list
        if (currentPlanId.value.isNotEmpty) {
          final planModel = plans.firstWhereOrNull(
            (p) => p.id == currentPlanId.value,
          );
          currentPlan.value = planModel;
        }
      } else {
        currentPlanId.value = '';
        currentPlanEndDate.value = '';
        currentPlanStartDate.value = '';
        currentPlanName.value = '';
        hasActiveSubscription.value = false;
        currentPlan.value = null;
      }
    } catch (e) {
      logger.e(e);
      hasActiveSubscription.value = false;
    }
  }

  Future<void> _loadSubscriptionPlans() async {
    try {
      // Get packages from RevenueCat
      final packages = await _subscriptionHelper.getAvailableOfferings();
      _revenueCatPackages.value = packages;
      
      // Create a map for quick lookup
      _packageMap.clear();
      for (var package in packages) {
        _packageMap[package.storeProduct.identifier] = package;
      }

      // Convert packages to SubscriptionPlanModel
      final subscriptionPlans = await _subscriptionHelper.getSubscriptionPlans();
      
      // Sort by order field
      subscriptionPlans.sort((a, b) => a.order.compareTo(b.order));

      plans.value = subscriptionPlans;

      // Update current plan model if subscription exists
      if (currentPlanId.value.isNotEmpty) {
        final planModel = plans.firstWhereOrNull(
          (plan) => plan.id == currentPlanId.value,
        );
        currentPlan.value = planModel;
      }

      // Select first available plan by default (skip current plan if exists)
      if (plans.isNotEmpty) {
        final availablePlan = plans.firstWhere(
          (plan) => plan.id != currentPlanId.value,
          orElse: () => plans[0],
        );
        selectedPlan.value = availablePlan;
      }
    } catch (e) {
      logger.e(e);
      Utils.showToast('Failed to load subscription plans');
    }
  }

  void selectPlan(SubscriptionPlanModel plan) {
    // Don't allow selecting the current plan
    if (plan.id == currentPlanId.value) {
      Utils.showToast('You are already subscribed to this plan');
      return;
    }
    selectedPlan.value = plan;
  }

  bool isCurrentPlan(SubscriptionPlanModel plan) {
    return plan.id == currentPlanId.value;
  }

  String formatDate(String dateStr) {
    try {
      if (dateStr.isEmpty) return '';
      final dateTime = DateTime.parse(dateStr);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return "${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}";
    } catch (e) {
      return dateStr;
    }
  }

  String getDurationText(int months) {
    if (months == 1) {
      return '1 Month';
    } else if (months == 3) {
      return '3 Months';
    } else if (months == 12) {
      return '12 Months';
    }
    return '$months Months';
  }

  String getFormattedPrice(SubscriptionPlanModel plan) {
    return '${plan.currency} ${plan.priceString}';
  }

  Future<void> purchaseSubscription() async {
    if (selectedPlan.value == null) {
      Utils.showToast('Please select a subscription plan');
      return;
    }

    // Prevent purchasing current plan
    if (selectedPlan.value!.id == currentPlanId.value) {
      Utils.showToast('You are already subscribed to this plan');
      return;
    }

    try {
      isLoading.value = true;

      // Find the RevenueCat package for this plan
      final package = _packageMap[selectedPlan.value!.id];
      if (package == null) {
        Utils.showToast('Subscription plan not found');
        return;
      }

      // Purchase through RevenueCat
      final success = await _subscriptionHelper.purchasePackage(package);

      if (success) {
        // Reload subscription data
        await _loadCurrentSubscription();
        await _loadSubscriptionPlans();
        
        // Refresh shared subscription status
        if (Get.isRegistered<UserSubscriptionController>()) {
          await Get.find<UserSubscriptionController>().refreshSubscriptionStatus();
        }
        
        Get.back(result: true);
        Utils.showToast('Subscription purchased successfully!');
      } else {
        final errorMsg = _subscriptionHelper.errorMessage.value;
        if (errorMsg.isNotEmpty && !errorMsg.contains('cancelled')) {
          Utils.showToast(errorMsg);
        }
      }
    } catch (e) {
      logger.e(e);
      Utils.showToast('Failed to purchase subscription');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> upgradeSubscription() async {
    if (selectedPlan.value == null) {
      Utils.showToast('Please select a subscription plan');
      return;
    }

    // Check if user has active subscription
    if (!hasActiveSubscription.value) {
      // If no subscription, use purchase instead
      await purchaseSubscription();
      return;
    }

    // Prevent upgrading to current plan
    if (selectedPlan.value!.id == currentPlanId.value) {
      Utils.showToast('You are already subscribed to this plan');
      return;
    }

    // Check if selected plan is actually an upgrade (higher price)
    final currentPlanModel = currentPlan.value;
    if (currentPlanModel != null) {
      if (selectedPlan.value!.price <= currentPlanModel.price) {
        Utils.showToast('Please select a higher plan to upgrade');
        return;
      }
    }

    try {
      isLoading.value = true;

      // Find the RevenueCat package for this plan
      final package = _packageMap[selectedPlan.value!.id];
      if (package == null) {
        Utils.showToast('Subscription plan not found');
        return;
      }

      // Purchase through RevenueCat (RevenueCat handles upgrades automatically)
      final success = await _subscriptionHelper.purchasePackage(package);

      if (success) {
        // Reload subscription data
        await _loadCurrentSubscription();
        await _loadSubscriptionPlans();
        
        // Refresh shared subscription status
        if (Get.isRegistered<UserSubscriptionController>()) {
          await Get.find<UserSubscriptionController>().refreshSubscriptionStatus();
        }
        
        Get.back(result: true);
        Utils.showToast('Subscription upgraded successfully!');
      } else {
        final errorMsg = _subscriptionHelper.errorMessage.value;
        if (errorMsg.isNotEmpty && !errorMsg.contains('cancelled')) {
          Utils.showToast(errorMsg);
        }
      }
    } catch (e) {
      logger.e(e);
      Utils.showToast('Failed to upgrade subscription');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelSubscription() async {
    if (!hasActiveSubscription.value) {
      Utils.showToast('No active subscription to cancel');
      return;
    }

    try {
      isLoading.value = true;

      // Get customer info to access management URL
      final customerInfo = await _subscriptionHelper.getCustomerInfo();
      
      if (customerInfo != null && customerInfo.managementURL != null) {
        // Open subscription management URL
        // Note: You'll need to use url_launcher to open this URL
        // For now, we'll show instructions
        Utils.showToast(
          'Please cancel your subscription through your device settings:\n'
          'iOS: Settings > Apple ID > Subscriptions\n'
          'Android: Google Play Store > Subscriptions',
        );
        
        // Refresh subscription status after showing instructions
        await _loadCurrentSubscription();
        
        // Refresh shared subscription status
        if (Get.isRegistered<UserSubscriptionController>()) {
          await Get.find<UserSubscriptionController>().refreshSubscriptionStatus();
        }
      } else {
        Utils.showToast('Unable to access subscription management');
      }
    } catch (e) {
      logger.e(e);
      Utils.showToast('Failed to cancel subscription');
    } finally {
      isLoading.value = false;
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    try {
      isLoading.value = true;
      final success = await _subscriptionHelper.restorePurchases();
      
      if (success) {
        await _loadCurrentSubscription();
        await _loadSubscriptionPlans();
        
        // Refresh shared subscription status
        if (Get.isRegistered<UserSubscriptionController>()) {
          await Get.find<UserSubscriptionController>().refreshSubscriptionStatus();
        }
        
        Utils.showToast('Purchases restored successfully!');
      } else {
        Utils.showToast('No purchases to restore');
      }
    } catch (e) {
      logger.e(e);
      Utils.showToast('Failed to restore purchases');
    } finally {
      isLoading.value = false;
    }
  }

  bool isUpgrade(SubscriptionPlanModel plan) {
    if (!hasActiveSubscription.value || currentPlan.value == null) {
      return false;
    }
    return plan.price > currentPlan.value!.price;
  }

  bool isDowngrade(SubscriptionPlanModel plan) {
    if (!hasActiveSubscription.value || currentPlan.value == null) {
      return false;
    }
    return plan.price < currentPlan.value!.price;
  }
}
