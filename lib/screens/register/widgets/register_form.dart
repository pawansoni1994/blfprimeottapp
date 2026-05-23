import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/core.dart';
import '../register_controller.dart';

class RegisterFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  const RegisterFormWidget({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegisterController>(
      builder: (controller) => Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Label
            Text(
              '${AppStrings.name.tr} *',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            // Name Field
            CustomTextField(
              hintText: AppStrings.name.tr,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              controller: controller.nameController,
              style: TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            SizedBox(height: 20.h),
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
            // Password Field
            CustomTextField(
              hintText: AppStrings.password.tr,
              controller: controller.passwordController,
              isPassword: true,
              style: TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 20.h),
            // Email Label
            Text(
              '${AppStrings.email.tr} (Optional)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            // Email Field
            CustomTextField(
              hintText: AppStrings.email.tr,
              keyboardType: TextInputType.emailAddress,
              controller: controller.emailController,
              style: TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                }
                final RegExp emailRegex =
                    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
