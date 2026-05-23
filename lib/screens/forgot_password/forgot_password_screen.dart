import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/core.dart';
import 'forgot_password_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});
  final formKey = GlobalKey<FormState>();
  final ForgotPasswordController controller =
      Get.put(ForgotPasswordController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                // Forgot your password Heading
                Text(
                  AppStrings.forgotYourPassword.tr,
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12.h),
                // Subtitle with strikethrough on "email"
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(
                        text: 'Please enter the ',
                      ),
                      TextSpan(
                        text: 'email ',
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      TextSpan(
                        text:
                            'Mobile Number you like your password reset information sent to',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 60.h),
                // Phone Number Label
                Text(
                  AppStrings.phoneNumber.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                // Phone Number Input Field
                Form(
                  key: formKey,
                  child: CustomTextField(
                    hintText: AppStrings.phoneNumber.tr,
                    prefixIcon: Center(child: Text("+91")),
                    keyboardType: TextInputType.phone,
                    controller: controller.phoneController,
                    maxLength: 10,
                    style: TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Phone number is required';
                      }
                      if (value.trim().length != 10) {
                        return 'Phone number must be 10 digits';
                      }
                      if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                        return 'Phone number must contain only digits';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 60.h),
                // Forgot Password Button
                CustomButton(
                  text: AppStrings.forgotPassword.tr,
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      controller.forgotPassword();
                    }
                  },
                  backgroundColor: AppColors.kPrimaryColor,
                  borderRadius: 30.r,
                  elevation: 0,
                  size: ButtonSize.medium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
