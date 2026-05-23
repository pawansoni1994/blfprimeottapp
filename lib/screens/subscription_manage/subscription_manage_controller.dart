import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/subscription_helper.dart';

class SubscriptionManageController extends GetxController {
  final SubscriptionHelper _subscriptionHelper = SubscriptionHelper();
  
  RxBool hasActiveSubscription = false.obs;
  Rx<EntitlementInfo?> currentEntitlement = Rx<EntitlementInfo?>(null);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadSubscriptionInfo();
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh subscription info when screen becomes visible
    loadSubscriptionInfo();
  }

  Future<void> loadSubscriptionInfo() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final hasActive = await _subscriptionHelper.hasActiveSubscription();
      hasActiveSubscription.value = hasActive;
      
      if (hasActive) {
        final entitlements = await _subscriptionHelper.getActiveEntitlements();
        if (entitlements.isNotEmpty) {
          // Get the first active entitlement
          currentEntitlement.value = entitlements.values.first;
        }
      } else {
        currentEntitlement.value = null;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load subscription info: $e';
      log('Error loading subscription info: $e', error: e, name: 'SubscriptionManageController');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      isLoading.value = true;
      final success = await _subscriptionHelper.restorePurchases();
      
      if (success) {
        Get.snackbar(
          'Success',
          'Purchases restored successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Refresh subscription info
        await loadSubscriptionInfo();
      } else {
        Get.snackbar(
          'Info',
          'No purchases to restore',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to restore purchases: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openCancelSubscription() async {
    try {
      // Get customer info to access management URL
      final customerInfo = await _subscriptionHelper.getCustomerInfo();
      
      if (customerInfo != null && customerInfo.managementURL != null) {
        // RevenueCat provides the platform-specific management URL
        final url = Uri.parse(customerInfo.managementURL!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          _showPlatformSpecificUrl();
        }
      } else {
        _showPlatformSpecificUrl();
      }
    } catch (e) {
      _showPlatformSpecificUrl();
    }
  }

  void _showPlatformSpecificUrl() {
    String url;
    if (Platform.isIOS) {
      // iOS App Store subscription management
      url = 'https://apps.apple.com/account/subscriptions';
    } else if (Platform.isAndroid) {
      // Android Play Store subscription management
      url = 'https://play.google.com/store/account/subscriptions';
    } else {
      Get.snackbar(
        'Info',
        'Please manage your subscription through your device settings',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    ).catchError((e) {
      Get.snackbar(
        'Error',
        'Could not open subscription management page. Please go to your device settings.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    });
  }
}
