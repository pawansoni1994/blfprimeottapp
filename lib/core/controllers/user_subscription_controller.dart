import 'package:get/get.dart';
import '../../core/utils/subscription_helper.dart';
import '../../network/error_handlers.dart';

/// Global controller to manage user subscription status
/// This controller is initialized in HomeController and can be accessed from anywhere
class UserSubscriptionController extends GetxController {
  final SubscriptionHelper _subscriptionHelper = SubscriptionHelper();

  final RxBool hasSubscription = false.obs;
  final RxBool isLoading = false.obs;
 
  /// Load subscription status from RevenueCat
  Future<void> loadSubscriptionStatus() async {
    try {
      isLoading.value = true;
      hasSubscription.value = await _subscriptionHelper.hasActiveSubscription();
    } catch (e) {
      logger.e(e);
      hasSubscription.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh subscription status (useful after subscription purchase/cancellation)
  Future<void> refreshSubscriptionStatus() async {
    await loadSubscriptionStatus();
  }
}

