import 'dart:developer';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:get/get.dart';
import '../../data/model/subscription_model.dart';
import '../controllers/user_subscription_controller.dart';

/// RevenueCat Subscription Helper
///
/// This helper provides all subscription-related functionality including:
/// - Initializing RevenueCat
/// - Getting available products and offerings
/// - Purchasing subscriptions
/// - Cancelling subscriptions
/// - Restoring purchases
/// - Checking subscription status
class SubscriptionHelper {
  static final SubscriptionHelper _instance = SubscriptionHelper._internal();
  factory SubscriptionHelper() => _instance;
  SubscriptionHelper._internal();

  // RevenueCat API Key - Replace with your actual API key
  // Get it from: https://app.revenuecat.com -> Your Project -> API Keys
  static const String _revenueCatApiKey = 'appl_qZLgFKOitawncMXqcSfYSMItOTY';

  bool _isInitialized = false;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  /// Initialize RevenueCat SDK
  ///
  /// Call this in your main.dart or app initialization
  Future<void> initialize() async {
    if (_isInitialized) {
      log('RevenueCat already initialized');
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      await Purchases.setLogLevel(
          LogLevel.debug); // Set to LogLevel.info for production

      // Initialize RevenueCat
      PurchasesConfiguration configuration =
          PurchasesConfiguration(_revenueCatApiKey);
      await Purchases.configure(configuration);

      // Set user identifier if needed (optional)
      // await Purchases.logIn('user_id_here');

      _isInitialized = true;
      log('RevenueCat initialized successfully');
    } catch (e) {
      errorMessage.value = 'Failed to initialize RevenueCat: $e';
      log('Error initializing RevenueCat: $e', error: e);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get all available offerings (product packages)
  ///
  /// Returns a list of available subscription offerings from RevenueCat
  Future<List<Package>> getAvailableOfferings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (!_isInitialized) {
        await initialize();
      }

      Offerings offerings = await Purchases.getOfferings();

      if (offerings.current != null) {
        return offerings.current!.availablePackages;
      }

      return [];
    } catch (e) {
      errorMessage.value = 'Failed to get offerings: $e';
      log('Error getting offerings: $e', error: e);
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Get product IDs for all available packages
  ///
  /// Returns a list of product identifiers
  Future<List<String>> getProductIds() async {
    try {
      final packages = await getAvailableOfferings();
      return packages
          .map((package) => package.storeProduct.identifier)
          .toList();
    } catch (e) {
      errorMessage.value = 'Failed to get product IDs: $e';
      log('Error getting product IDs: $e', error: e);
      return [];
    }
  }

  /// Get specific product by ID
  ///
  /// [productId] - The product identifier from App Store Connect / Google Play Console
  Future<StoreProduct?> getProduct(String productId) async {
    try {
      final packages = await getAvailableOfferings();

      for (var package in packages) {
        if (package.storeProduct.identifier == productId) {
          return package.storeProduct;
        }
      }

      return null;
    } catch (e) {
      errorMessage.value = 'Failed to get product: $e';
      log('Error getting product: $e', error: e);
      return null;
    }
  }

  /// Purchase a subscription product
  ///
  /// [productId] - The product identifier to purchase
  /// Returns true if purchase was successful, false otherwise
  Future<bool> purchaseProduct(String productId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (!_isInitialized) {
        await initialize();
      }

      // Find the package containing this product
      final packages = await getAvailableOfferings();
      Package? selectedPackage;

      for (var package in packages) {
        if (package.storeProduct.identifier == productId) {
          selectedPackage = package;
          break;
        }
      }

      if (selectedPackage == null) {
        errorMessage.value = 'Product not found: $productId';
        log('Product not found: $productId');
        return false;
      }

      // Make the purchase
      CustomerInfo customerInfo =
          await Purchases.purchasePackage(selectedPackage);

      // Check if user has active entitlement
      if (customerInfo.entitlements.active.isNotEmpty) {
        log('Purchase successful! Active entitlements: ${customerInfo.entitlements.active.keys}');
        return true;
      } else {
        errorMessage.value =
            'Purchase completed but no active entitlement found';
        log('Purchase completed but no active entitlement found');
        return false;
      }
    } on PurchasesError catch (e) {
      if (e.code == PurchasesErrorCode.purchaseCancelledError) {
        errorMessage.value = 'Purchase was cancelled';
        log('User cancelled the purchase');
      } else {
        errorMessage.value = 'Purchase failed: ${e.message}';
        log('Purchase error: ${e.message}', error: e);
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Purchase failed: $e';
      log('Error purchasing product: $e', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Purchase a subscription by package
  ///
  /// [package] - The RevenueCat package to purchase
  /// Returns true if purchase was successful, false otherwise
  Future<bool> purchasePackage(Package package) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (!_isInitialized) {
        await initialize();
      }

      CustomerInfo customerInfo = await Purchases.purchasePackage(package);

      if (customerInfo.entitlements.active.isNotEmpty) {
        log('Purchase successful! Active entitlements: ${customerInfo.entitlements.active.keys}');
        return true;
      } else {
        errorMessage.value =
            'Purchase completed but no active entitlement found';
        return false;
      }
    } on PurchasesError catch (e) {
      if (e.code == PurchasesErrorCode.purchaseCancelledError) {
        errorMessage.value = 'Purchase was cancelled';
      } else {
        errorMessage.value = 'Purchase failed: ${e.message}';
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Purchase failed: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Cancel a subscription
  ///
  /// Note: This method doesn't directly cancel the subscription.
  /// Subscriptions are managed through the App Store / Google Play.
  /// This method provides information about how to cancel.
  ///
  /// [productId] - The product identifier to cancel
  Future<void> cancelSubscription(String productId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get customer info to check subscription status
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();

      // Note: RevenueCat doesn't provide a direct cancel method
      // Users need to cancel through App Store / Google Play
      // You can show them instructions or redirect to the appropriate store

      log('To cancel subscription:');
      log('iOS: Settings -> Apple ID -> Subscriptions');
      log('Android: Google Play Store -> Subscriptions');

      // You can also check if subscription is active
      final hasActiveSubscription = customerInfo.entitlements.active.isNotEmpty;
      if (!hasActiveSubscription) {
        errorMessage.value = 'No active subscription found';
      }
    } catch (e) {
      errorMessage.value = 'Failed to get subscription info: $e';
      log('Error getting subscription info: $e', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Restore previous purchases
  ///
  /// Restores any previously purchased subscriptions for the user
  /// Returns true if any purchases were restored, false otherwise
  Future<bool> restorePurchases() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (!_isInitialized) {
        await initialize();
      }

      CustomerInfo customerInfo = await Purchases.restorePurchases();

      if (customerInfo.entitlements.active.isNotEmpty) {
        log('Purchases restored! Active entitlements: ${customerInfo.entitlements.active.keys}');
        return true;
      } else {
        errorMessage.value = 'No purchases to restore';
        log('No active entitlements found');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to restore purchases: $e';
      log('Error restoring purchases: $e', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if user has an active subscription
  ///
  /// [entitlementId] - Optional entitlement identifier to check for specific entitlement
  /// Returns true if user has active subscription, false otherwise
  Future<bool> hasActiveSubscription({String? entitlementId}) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      CustomerInfo customerInfo = await Purchases.getCustomerInfo();

      if (entitlementId != null) {
        return customerInfo.entitlements.active[entitlementId] != null;
      }

      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      log('Error checking subscription status: $e', error: e);
      return false;
    }
  }

  /// Check if user has premium access (synchronous version)
  ///
  /// This is a cached version that uses the reactive hasSubscription from UserSubscriptionController
  /// For real-time checks, use hasActiveSubscription() instead
  /// Returns true if user has active subscription, false otherwise
  bool get hasPremiumAccess {
    try {
      if (Get.isRegistered<UserSubscriptionController>()) {
        return Get.find<UserSubscriptionController>().hasSubscription.value;
      }
      return false;
    } catch (e) {
      log('Error checking premium access: $e', error: e);
      return false;
    }
  }

  /// Get current customer info
  ///
  /// Returns CustomerInfo object with all subscription details
  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo;
    } catch (e) {
      errorMessage.value = 'Failed to get customer info: $e';
      log('Error getting customer info: $e', error: e);
      return null;
    }
  }

  /// Get active entitlements
  ///
  /// Returns a map of active entitlements
  Future<Map<String, EntitlementInfo>> getActiveEntitlements() async {
    try {
      final customerInfo = await getCustomerInfo();
      if (customerInfo != null) {
        return customerInfo.entitlements.active;
      }
      return {};
    } catch (e) {
      log('Error getting active entitlements: $e', error: e);
      return {};
    }
  }

  /// Get all entitlements (active and inactive)
  ///
  /// Returns a map of all entitlements
  Future<Map<String, EntitlementInfo>> getAllEntitlements() async {
    try {
      final customerInfo = await getCustomerInfo();
      if (customerInfo != null) {
        return customerInfo.entitlements.all;
      }
      return {};
    } catch (e) {
      log('Error getting all entitlements: $e', error: e);
      return {};
    }
  }

  /// Set user identifier for RevenueCat
  ///
  /// [userId] - The user identifier to associate with RevenueCat
  Future<void> setUserId(String userId) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      await Purchases.logIn(userId);
      log('User ID set: $userId');
    } catch (e) {
      errorMessage.value = 'Failed to set user ID: $e';
      log('Error setting user ID: $e', error: e);
    }
  }

  /// Log out current user
  Future<void> logOut() async {
    try {
      await Purchases.logOut();
      log('User logged out');
    } catch (e) {
      errorMessage.value = 'Failed to log out: $e';
      log('Error logging out: $e', error: e);
    }
  }

  /// Check if RevenueCat is initialized
  bool get isInitialized => _isInitialized;

  /// Check if content requires premium and if user has access
  ///
  /// [contentType] - The type of content ('subscription' means premium)
  /// Returns true if content is premium and user has subscription, or if content is not premium
  bool canAccessContent(String? contentType) {
    // If content is not premium, user can always access
    if (contentType != 'subscription') {
      return true;
    }

    // If content is premium, check if user has subscription
    return hasPremiumAccess;
  }

  /// Convert RevenueCat Package to SubscriptionPlanModel
  ///
  /// [package] - The RevenueCat package to convert
  /// Returns a SubscriptionPlanModel representation
  SubscriptionPlanModel packageToSubscriptionPlan(Package package) {
    final product = package.storeProduct;
    final price = product.price;
    final currencyCode =
        product.currencyCode.isNotEmpty ? product.currencyCode : 'USD';

    // Extract duration from product identifier or package type
    int durationMonths = 1; // Default to 1 month
    if (package.packageType == PackageType.monthly) {
      durationMonths = 1;
    } else if (package.packageType == PackageType.threeMonth) {
      durationMonths = 3;
    } else if (package.packageType == PackageType.sixMonth) {
      durationMonths = 6;
    } else if (package.packageType == PackageType.annual) {
      durationMonths = 12;
    } else if (package.packageType == PackageType.twoMonth) {
      durationMonths = 2;
    } else {
      // Try to extract from identifier
      final identifier = product.identifier.toLowerCase();
      if (identifier.contains('annual') || identifier.contains('year')) {
        durationMonths = 12;
      } else if (identifier.contains('month')) {
        // Try to extract number
        final match = RegExp(r'(\d+)').firstMatch(identifier);
        if (match != null) {
          durationMonths = int.tryParse(match.group(1) ?? '1') ?? 1;
        }
      }
    }

    return SubscriptionPlanModel(
      id: product.identifier,
      name: product.title.isNotEmpty ? product.title : package.identifier,
      description: product.description.isNotEmpty
          ? product.description
          : '${durationMonths} month subscription plan',
      price: price,
      currency: currencyCode,
      durationMonths: durationMonths,
      productLimit: 0, // Set based on your business logic
      features: [
        'Access to all premium content',
        'HD quality streaming',
        'Ad-free experience',
        'Download for offline viewing',
      ],
      isActive: true,
      isPopular: package.packageType == PackageType.annual ||
          package.packageType == PackageType.sixMonth,
      order: _getPackageOrder(package.packageType),
      isDeleted: false,
    );
  }

  /// Get order value based on package type
  int _getPackageOrder(PackageType packageType) {
    switch (packageType) {
      case PackageType.monthly:
        return 1;
      case PackageType.twoMonth:
        return 2;
      case PackageType.threeMonth:
        return 3;
      case PackageType.sixMonth:
        return 4;
      case PackageType.annual:
        return 5;
      case PackageType.lifetime:
        return 6;
      case PackageType.weekly:
        return 0;
      case PackageType.custom:
        return 99;
      case PackageType.unknown:
        return 100;
    }
  }

  /// Get all subscription plans from RevenueCat
  ///
  /// Returns a list of SubscriptionPlanModel
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans() async {
    try {
      final packages = await getAvailableOfferings();
      return packages
          .map((package) => packageToSubscriptionPlan(package))
          .toList();
    } catch (e) {
      log('Error getting subscription plans: $e', error: e);
      return [];
    }
  }

  /// Get current active subscription info from RevenueCat
  ///
  /// Returns CustomerInfo with subscription details
  Future<Map<String, dynamic>?> getCurrentSubscriptionInfo() async {
    try {
      final customerInfo = await getCustomerInfo();
      if (customerInfo == null || customerInfo.entitlements.active.isEmpty) {
        return null;
      }

      // Get the first active entitlement
      final activeEntitlement = customerInfo.entitlements.active.values.first;

      // Handle dates - RevenueCat expirationDate and latestPurchaseDate
      final expirationDateStr = activeEntitlement.expirationDate;
      final purchaseDateStr = activeEntitlement.latestPurchaseDate;

      return {
        'productId': activeEntitlement.productIdentifier,
        'expirationDate': expirationDateStr,
        'purchaseDate': purchaseDateStr,
        'isActive': activeEntitlement.isActive,
        'willRenew': activeEntitlement.willRenew,
        'periodType': activeEntitlement.periodType.toString(),
      };
    } catch (e) {
      log('Error getting current subscription info: $e', error: e);
      return null;
    }
  }

  /// Open subscription management URL
  ///
  /// Opens the platform-specific subscription management page
  Future<void> openSubscriptionManagement() async {
    try {
      final customerInfo = await getCustomerInfo();
      if (customerInfo != null && customerInfo.managementURL != null) {
        // Use url_launcher to open the management URL
        // This will be handled by the calling code
        log('Management URL: ${customerInfo.managementURL}');
      }
    } catch (e) {
      log('Error getting management URL: $e', error: e);
    }
  }
}
