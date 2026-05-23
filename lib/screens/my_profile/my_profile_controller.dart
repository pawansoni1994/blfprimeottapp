import 'package:get/get.dart';
import '../../core/core.dart';
import '../../data/local/hive/hive_manager.dart';
import '../../data/model/model.dart';
import '../../data/repository/auth_repository.dart';
import '../../data/repository/subscription_repository.dart';
import '../../network/network.dart';

class MyProfileController extends GetxController {
  final HiveManager hiveManager = Get.find(tag: (HiveManager).toString());
  final AuthRepository _authRepository = Get.find(
    tag: (AuthRepository).toString(),
  );
  final SubscriptionRepository _subscriptionRepository = Get.find(
    tag: (SubscriptionRepository).toString(),
  );
  final ApiService apiService = Get.find(tag: (ApiService).toString());

  // Profile data
  final Rx<UserProfileModel?> profile = Rx<UserProfileModel?>(null);

  // Subscription data
  final RxString subscriptionId = "No Subscription".obs;
  final RxString paymentAmount = "00".obs;
  final RxString startDate = "00".obs;
  final RxString endDate = "00".obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getProfile();
  }

  String formatDate(String dateStr) {
    try {
      if (dateStr.isEmpty || dateStr == "00") return dateStr;
      // Parse date from "yyyy-MM-dd" format
      final dateTime = DateTime.parse(dateStr);
      // Format to "dd MMM yyyy"
      return "${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}";
    } catch (e) {
      logger.e('Date parsing error: $e');
      return dateStr;
    }
  }

  String _getMonthName(int month) {
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
    return months[month - 1];
  }

  Future<void> getProfile() async {
    try {
      isLoading.value = true;
      final response = await _authRepository.getProfile();

      profile.value = response.data;

      // Update local storage with latest profile data
      hiveManager.setString(HiveManager.userIdKey, response.data.id);
      hiveManager.setString(HiveManager.fullNameKey, response.data.name);
      hiveManager.setString(HiveManager.emailKey, response.data.email);
      hiveManager.setString(HiveManager.phoneKey, response.data.phone);
      if (response.data.profile != null) {
        hiveManager.setString(HiveManager.profileKey, response.data.profile!);
      }

      // Update subscription data from plan
      if (response.data.plan != null) {
        final plan = response.data.plan!;
        subscriptionId.value = plan.subscriptionId?.name ?? 'Active Plan';
        paymentAmount.value = plan.amount > 0 
            ? plan.amount.toStringAsFixed(0) 
            : "00";
        startDate.value = plan.startDate.isNotEmpty ? plan.startDate : "00";
        endDate.value = plan.endDate.isNotEmpty ? plan.endDate : "00";
      } else {
        // No active subscription
        subscriptionId.value = "";
        paymentAmount.value = "00";
        startDate.value = "00";
        endDate.value = "00";
      }
    } catch (e) {
      logger.e(e);
      Utils.showToast('Failed to load profile');
    } finally {
      isLoading.value = false;
    }
  }
 
  String getUserName() {
    if (profile.value != null && profile.value!.name.isNotEmpty) {
      return profile.value!.name;
    }
    final name = hiveManager.getString(HiveManager.fullNameKey);
    if (name.isNotEmpty && name.trim().isNotEmpty) {
      return name;
    }
    return hiveManager.getString(HiveManager.emailKey).isNotEmpty
        ? hiveManager.getString(HiveManager.emailKey)
        : "N/A";
  }

  String getUserPhone() {
    if (profile.value != null && profile.value!.phone.isNotEmpty) {
      return profile.value!.phone;
    }
    final phone = hiveManager.getString(HiveManager.phoneKey);
    if (phone.isNotEmpty && phone.trim().isNotEmpty) {
      return phone;
    }
    return hiveManager.getString(HiveManager.emailKey).isNotEmpty
        ? hiveManager.getString(HiveManager.emailKey)
        : "N/A";
  }

  String? getUserImage() {
    if (profile.value != null && profile.value!.profile != null) {
      return profile.value!.profile;
    }
    final image = hiveManager.getString(HiveManager.profileKey);
    return image.isNotEmpty ? image : null;
  }

  Future<void> cancelSubscription() async {
    if (profile.value?.plan == null) {
      Utils.showToast('No active subscription to cancel');
      return;
    }

    final planId = profile.value!.plan!.id;
    if (planId.isEmpty) {
      Utils.showToast('No active subscription to cancel');
      return;
    }

    try {
      isLoading.value = true;

      final response = await _subscriptionRepository.cancelSubscription(
        subscriptionId: planId,
      );

      if (response.success) {
        // Refresh profile to get updated subscription
        await getProfile();
        Utils.showToast(
          response.message ?? 'Subscription cancelled successfully',
        );
      } else {
        Utils.showToast(
          response.message ?? 'Failed to cancel subscription',
        );
      }
    } catch (e) {
      logger.e(e);
      Utils.showToast('Failed to cancel subscription');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    await getProfile();
  }
}
