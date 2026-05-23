import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../core/core.dart';
import '../../data/local/hive/hive_manager.dart';
import '../../network/error_handlers.dart';
import '../../routes/app_pages.dart';
import '../../data/repository/auth_repository.dart';

class ResetPasswordController extends GetxController {
  final AuthRepository _repository = Get.find(tag: (AuthRepository).toString());
  final HiveManager hiveManager = Get.find(tag: (HiveManager).toString());

  // Text controllers
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Focus nodes
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();

  // Loading state
  final RxBool isLoading = false.obs;

  // Phone number and token from previous screen
  String get phoneNumber => Get.parameters['phone'] != null ? Uri.decodeComponent(Get.parameters['phone']!) : '';
  String get token => Get.parameters['token'] != null ? Uri.decodeComponent(Get.parameters['token']!) : '';

  @override
  void onInit() {
    super.onInit();
    // Get token from Hive if not passed as argument
    if (token.isEmpty) {
      final tempToken = hiveManager.getString(HiveManager.tempTokenKey);
      if (tempToken.isNotEmpty) {
        // Use tempToken from Hive
      }
    }
  }

  Future<void> resetPassword() async {
    // Validation
    if (passwordController.text.trim().isEmpty) {
      Utils.showToast('Please enter your new password');
      return;
    }

    if (passwordController.text.trim().length < 6) {
      Utils.showToast('Password must be at least 6 characters');
      return;
    }

    if (confirmPasswordController.text.trim().isEmpty) {
      Utils.showToast('Please confirm your password');
      return;
    }

    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      Utils.showToast('Passwords do not match');
      return;
    }

    if (phoneNumber.isEmpty) {
      Utils.showToast('Phone number is required');
      return;
    }

    // Get token from arguments or Hive
    String resetToken = token;
    if (resetToken.isEmpty) {
      resetToken = hiveManager.getString(HiveManager.tempTokenKey);
    }

    if (resetToken.isEmpty) {
      Utils.showToast('Reset token is missing. Please try again.');
      return;
    }

    try {
      isLoading.value = true;

      final success = await _repository.resetPassword({
        "phone": phoneNumber,
        "password": passwordController.text.trim(),
        "token": resetToken,
      });

      isLoading.value = false;

      if (success) {
        // Clear temp token
        hiveManager.setString(HiveManager.tempTokenKey, '');

        Utils.showToast('Password reset successfully');
        // Navigate to login screen
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      isLoading.value = false;
      logger.e(e);
      // Error toast is already shown by ApiService
    }
  }
}
