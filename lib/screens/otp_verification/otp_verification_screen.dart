import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../core/core.dart';
import 'otp_verification_controller.dart';

class OtpVerificationScreen extends StatelessWidget {
  OtpVerificationScreen({super.key});
  final OtpVerificationController controller =
      Get.put(OtpVerificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            // Title
            Text(
              AppStrings.verifyOtp.tr,
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12.h),
            // Subtitle
            Text(
              AppStrings.otpVerificationSubtitle.tr,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
            SizedBox(height: 8.h),
            // Phone number display
            if (controller.phoneNumber.isNotEmpty)
              Text(
                '${AppStrings.phoneNumber.tr}: ${controller.phoneNumber}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.kPrimaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            SizedBox(height: 40.h),
            // OTP Input Field
            PinCodeTextField(
              appContext: context,
              length: 6,
              onChanged: controller.onOtpChanged,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(10.r),
                fieldHeight: 56.h,
                fieldWidth: 48.w,
                activeFillColor: Colors.black,
                inactiveFillColor: Colors.white.withValues(alpha: 0.1),
                selectedFillColor: Colors.black,
                activeColor: AppColors.kPrimaryColor,
                inactiveColor: Colors.white.withValues(alpha: 0.3),
                selectedColor: AppColors.kPrimaryColor,
              ),
              cursorColor: AppColors.kPrimaryColor,
              animationDuration: const Duration(milliseconds: 300),
              enableActiveFill: true,
              keyboardType: TextInputType.number,
              textStyle: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              onCompleted: (value) {
                controller.otpCode = value;
                controller.verifyOtp();
              },
            ),
            SizedBox(height: 32.h),
            // Verify Button
            Obx(() => CustomButton(
                  text: AppStrings.verify.tr,
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          if (controller.otpCode.length == 6) {
                            controller.verifyOtp();
                          } else {
                            // Show error if OTP is incomplete
                          }
                        },
                  backgroundColor: AppColors.kPrimaryColor,
                  borderRadius: 30.r,
                  elevation: 0,
                  size: ButtonSize.medium,
                  isLoading: controller.isLoading.value,
                )),
            SizedBox(height: 24.h),
            // Resend OTP
            Center(
              child: Obx(() {
                if (controller.canResend.value) {
                  return GestureDetector(
                    onTap: controller.resendOtp,
                    child: Text(
                      AppStrings.resendOtp.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.kPrimaryColor,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  );
                } else {
                  return Text(
                    '${AppStrings.resendOtpIn.tr} ${controller.countdown.value}s',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  );
                }
              }),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
