import 'dart:async';
import 'package:get/get.dart';
import '../../core/core.dart';
import '../../data/local/hive/hive_manager.dart';
import '../../network/error_handlers.dart';
import '../../routes/app_pages.dart';
import '/data/repository/auth_repository.dart';

class OtpVerificationController extends GetxController {
  final AuthRepository _repository = Get.find(tag: (AuthRepository).toString());

  // OTP code entered by user
  String otpCode = '';

  // Phone number passed from previous screen
  final String phoneNumber = Get.parameters['phone'] != null ? Uri.decodeComponent(Get.parameters['phone']!) : '';
  final String type = Get.parameters['type'] != null ? Uri.decodeComponent(Get.parameters['type']!) : '';

  // Timer for resend OTP
  Timer? _timer;
  final RxInt countdown = 60.obs;
  final RxBool canResend = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startTimer() {
    canResend.value = false;
    countdown.value = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  void onOtpChanged(String value) {
    otpCode = value;
  }

  Future<void> verifyOtp() async {
    if (otpCode.length != 6) {
      Utils.showToast('Please enter a valid 6-digit OTP code');
      return;
    }

    if (phoneNumber.isEmpty) {
      Utils.showToast('Phone number is required');
      return;
    }

    try {
      final HiveManager hiveManager = Get.find(tag: (HiveManager).toString());
      bool success = await _repository
          .verifyOtp({"phone": phoneNumber, "otp": otpCode, "type": type});
      if (success) {
        if (type == "register") {
          await _repository.register({
            "phone": hiveManager.getString(HiveManager.phoneKey),
            "name": hiveManager.getString(HiveManager.fullNameKey),
            "email": hiveManager.getString(HiveManager.emailKey),
            "password": hiveManager.getString(HiveManager.passwordKey),
          });
          Utils.showToast('Account created successfully');
          Get.offAllNamed(AppRoutes.home);
        } else {
          // Pass phone and token to reset password screen
          final tempToken = hiveManager.getString(HiveManager.tempTokenKey);
          Get.offNamed(
            '${AppRoutes.resetPassword}?phone=${Uri.encodeComponent(phoneNumber)}&token=${Uri.encodeComponent(tempToken)}',
          );
        }
      } else {
        Utils.showToast('Invalid OTP code. Please try again.');
      }
    } catch (e) {
      isLoading.value = false;
      logger.e(e);
      Utils.showToast('Failed to verify OTP. Please try again.');
    }
  }

  Future<void> resendOtp() async {
    if (!canResend.value) return;

    if (phoneNumber.isEmpty) {
      Utils.showToast('Phone number is required');
      return;
    }

    try {
      isLoading.value = true;
      bool success = await _repository.sendOtp({
        "phone": phoneNumber,
      });

      isLoading.value = false;

      if (success) {
        startTimer();
        Utils.showToast('OTP code has been resent successfully');
      } else {
        Utils.showToast('Failed to resend OTP. Please try again.');
      }
    } catch (e) {
      isLoading.value = false;
      logger.e(e);
      Utils.showToast('Failed to resend OTP. Please try again.');
    }
  }
}
