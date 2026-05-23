import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../network/error_handlers.dart';
import '../../routes/app_pages.dart';
import '/data/repository/auth_repository.dart';

class ForgotPasswordController extends GetxController {
  final AuthRepository _repository = Get.find(tag: (AuthRepository).toString());
  TextEditingController phoneController = TextEditingController();

  void forgotPassword() async {
    try {
      bool success = await _repository.forgotPassword({
        "phone": phoneController.text.trim(),
      });
      if (success) {
        Get.toNamed(
          '${AppRoutes.otpVerification}?phone=${Uri.encodeComponent(phoneController.text.trim())}&type=${Uri.encodeComponent("reset")}',
        );
      }
    } catch (e) {
      logger.e(e);
    }
  }
}
