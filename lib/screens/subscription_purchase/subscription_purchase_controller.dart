import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../core/utils/subscription_helper.dart';

class SubscriptionPurchaseController extends GetxController {
  final SubscriptionHelper _subscriptionHelper = SubscriptionHelper();
  
  RxList<Package> packages = <Package>[].obs;
  Rx<Package?> selectedPackage = Rx<Package?>(null);
  RxBool isLoading = false.obs;
  RxBool isPurchasing = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadOfferings();
  }

  Future<void> loadOfferings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final offerings = await _subscriptionHelper.getAvailableOfferings();
      packages.value = offerings;
      
      // Auto-select the first package (usually monthly)
      if (packages.isNotEmpty && selectedPackage.value == null) {
        // Prefer monthly, then yearly, then weekly
        final monthly = packages.firstWhereOrNull((p) => 
          p.identifier.toLowerCase().contains('monthly'));
        final yearly = packages.firstWhereOrNull((p) => 
          p.identifier.toLowerCase().contains('yearly'));
        final weekly = packages.firstWhereOrNull((p) => 
          p.identifier.toLowerCase().contains('weekly'));
        
        selectedPackage.value = monthly ?? yearly ?? weekly ?? packages.first;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load subscription plans: $e';
      log('Error loading offerings: $e', error: e, name: 'SubscriptionPurchaseController');
    } finally {
      isLoading.value = false;
    }
  }

  void selectPackage(Package package) {
    selectedPackage.value = package;
  }

  Future<void> purchaseSelectedPackage() async {
    if (selectedPackage.value == null) {
      Get.snackbar(
        'Error',
        'Please select a subscription plan',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isPurchasing.value = true;
      errorMessage.value = '';
      
      final success = await _subscriptionHelper.purchasePackage(selectedPackage.value!);
      
      if (success) {
        Get.snackbar(
          'Success',
          'Subscription purchased successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Navigate to subscription management or home
        Future.delayed(Duration(seconds: 1), () {
          Get.offNamedUntil('/subscription-manage', (route) => false);
        });
      } else {
        if (_subscriptionHelper.errorMessage.value.isNotEmpty) {
          Get.snackbar(
            'Purchase Failed',
            _subscriptionHelper.errorMessage.value,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Purchase failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isPurchasing.value = false;
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
        Future.delayed(Duration(seconds: 1), () {
          Get.offNamedUntil('/subscription-manage', (route) => false);
        });
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
}
