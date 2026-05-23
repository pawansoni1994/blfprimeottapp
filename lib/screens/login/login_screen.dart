import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import '../../core/core.dart';
import 'login_controller.dart';
import 'widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final formKey = GlobalKey<FormState>();
  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50.h),
              // Welcome Back Heading
              Text(
                AppStrings.welcomeBack.tr,
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12.h),
              // Subtitle
              Text(
                AppStrings.welcomeSubtitle.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 40.h),
              // Login Form
              LoginFormWidget(formKey: formKey),
              SizedBox(height: 16.h),
              // Forgot Password Link (Right Aligned)
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.forgotPassword);
                  },
                  child: Text(
                    AppStrings.forgotPassword.tr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              // Log in Button
              CustomButton(
                text: AppStrings.logIn.tr,
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    controller.login();
                  }
                },
                backgroundColor: AppColors.kPrimaryColor,
                borderRadius: 30.r,
                elevation: 0,
                size: ButtonSize.medium,
              ),
              SizedBox(height: 32.h),
              // Don't have an account? Sign up
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(text: AppStrings.dontHaveAccount.tr),
                      TextSpan(text: ' '),
                      TextSpan(
                        text: AppStrings.signUp.tr,
                        style: TextStyle(
                          color: AppColors.kPrimaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 18.sp,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.toNamed(AppRoutes.register);
                          },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
