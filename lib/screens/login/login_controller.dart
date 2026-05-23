import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../data/repository/auth_repository.dart';
import '../../network/error_handlers.dart';
import '../../routes/app_pages.dart';

class LoginController extends GetxController {
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    try {
      final AuthRepository authRepository = Get.find(
        tag: (AuthRepository).toString(),
      );

      final user = await authRepository.login({
        "phone": phoneController.text.trim(),
        "password": passwordController.text.trim(),
      });

      if (user.phone.isNotEmpty || user.email.isNotEmpty) {
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      // Error is already handled by ApiService (shows toast)
      // Loading is automatically handled by ApiService
      logger.e(e);
    }
  }
}
