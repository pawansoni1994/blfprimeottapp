import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../data/local/hive/hive_manager.dart';
import '../../data/repository/auth_repository.dart';
import '../../network/error_handlers.dart';
import '../../routes/app_pages.dart';

class RegisterController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  Future<void> register() async {
    try {
      final AuthRepository authRepository = Get.find(
        tag: (AuthRepository).toString(),
      );

       await authRepository.sendOtp({
        "phone": phoneController.text.trim(),
      });

      final HiveManager hiveManager = Get.find(tag: (HiveManager).toString());
      hiveManager.setString(HiveManager.phoneKey, phoneController.text.trim());
      hiveManager.setString(
          HiveManager.fullNameKey, nameController.text.trim());
      hiveManager.setString(HiveManager.emailKey, emailController.text.trim());
      hiveManager.setString(
          HiveManager.passwordKey, passwordController.text.trim());
      Get.toNamed(
        '${AppRoutes.otpVerification}?phone=${Uri.encodeComponent(phoneController.text.trim())}&type=${Uri.encodeComponent("register")}',
      );
    } catch (e) {
      // Error is already handled by ApiService (shows toast)
      // Loading is automatically handled by ApiService
      logger.e(e);
    }
  }
}
