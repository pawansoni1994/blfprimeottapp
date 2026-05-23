import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../routes/app_pages.dart';
import '../../core/core.dart';
import 'register_controller.dart';
import 'widgets/register_form.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});
  final formKey = GlobalKey<FormState>();
  final RegisterController controller = Get.put(RegisterController());

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
              SizedBox(height: 30.h),
              // Create Account Heading
              Text(
                AppStrings.createAccount.tr,
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12.h),
              // Subtitle
              Text(
                AppStrings.createAccountSubtitle.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20.h),
              // Register Form
              RegisterFormWidget(formKey: formKey),
              SizedBox(height: 10.h),
              // Already have an account? Log in
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(text: AppStrings.alreadyHaveAccount.tr),
                      TextSpan(text: ' '),
                      TextSpan(
                        text: AppStrings.logIn.tr,
                        style: TextStyle(
                          color: AppColors.kPrimaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 18.sp,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.toNamed(AppRoutes.login);
                          },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50.h),
              // Terms and Conditions
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    children: [
                      TextSpan(text: AppStrings.bySigningUp.tr),
                      TextSpan(text: ' '),
                      TextSpan(
                        text: AppStrings.termsAndConditions.tr,
                        style: TextStyle(
                          color: AppColors.kPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse('https://www.google.com'));
                          },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              // Create Button
              CustomButton(
                text: AppStrings.create.tr,
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    controller.register();
                  }
                },
                backgroundColor: AppColors.kPrimaryColor,
                borderRadius: 30.r,
                elevation: 0,
                size: ButtonSize.medium,
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
