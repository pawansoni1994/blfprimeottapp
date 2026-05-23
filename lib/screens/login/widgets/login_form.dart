import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/core.dart';
import '../login_controller.dart';

class LoginFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  const LoginFormWidget({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    LoginController controller = Get.find();
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phone Number Label
          Text(
            '${AppStrings.phoneNumber.tr} *',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          // Phone Number Field with Country Code
          CustomTextField(
            hintText: AppStrings.phoneNumber.tr,
            prefixIcon: Center(child: Text("+91")),
            keyboardType: TextInputType.phone,
            controller: controller.phoneController,
            style: TextStyle(color: Colors.white),
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Phone number is required';
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),
          // Password Label
          Text(
            '${AppStrings.password.tr} *',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          CustomTextField(
            hintText: AppStrings.password.tr,
            controller: controller.passwordController,
            isPassword: true,
            style: TextStyle(color: Colors.white),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              } else if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
