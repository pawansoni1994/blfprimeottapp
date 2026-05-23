// ignore_for_file: sized_box_for_whitespace, avoid_unnecessary_containers, prefer_const_constructors, file_names, prefer_is_empty, unnecessary_cast, avoid_print, use_build_context_synchronously, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/core.dart';
import 'edit_profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EditProfileController controller = Get.put(EditProfileController());
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.updateProfile.tr,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              SizedBox(height: 20.h),
              _buildProfileImage(controller),
              SizedBox(height: 32.h),
              _buildNameField(controller),
              SizedBox(height: 16.h),
              _buildEmailField(controller),
              SizedBox(height: 16.h),
              _buildMobileField(controller),
              SizedBox(height: 40.h),
              _buildUpdateButton(controller, formKey),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(EditProfileController controller) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Obx(() {
            final selectedImage = controller.selectedImage.value;
            final profileImage = controller.profileImageUrl.value;

            return Container(
              height: 100.h,
              width: 100.w,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 1, color: AppColors.kPrimaryColor),
                shape: BoxShape.circle,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100.r),
                child: selectedImage != null
                    ? Image.file(
                        selectedImage,
                        fit: BoxFit.cover,
                      )
                    : (profileImage.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: profileImage,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Image.asset(
                              AppImages.avatarImage,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            AppImages.avatarImage,
                            fit: BoxFit.cover,
                          )),
              ),
            );
          }),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: controller.showImagePickerBottomSheet,
              child: Container(
                height: 30.h,
                width: 30.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 2, color: Colors.white),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  color: AppColors.kPrimaryColor,
                  size: 16.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField(EditProfileController controller) {
    return CustomTextField(
      controller: controller.nameController,
      labelText: AppStrings.yourName.tr,
      hintText: AppStrings.yourName.tr,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.name,
      onFieldSubmitted: (_) {
        FocusScope.of(Get.context!).requestFocus(controller.emailFocus);
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your name';
        }
        return null;
      },
      style: TextStyle(color: Colors.white),
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: Colors.white),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: AppColors.kPrimaryColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: Colors.white),
      ),
    );
  }

  Widget _buildEmailField(EditProfileController controller) {
    return Focus(
      focusNode: controller.emailFocus,
      child: CustomTextField(
        controller: controller.emailController,
        labelText: AppStrings.yourEmail.tr,
        hintText: AppStrings.yourEmail.tr,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.emailAddress,
        onFieldSubmitted: (_) {
          FocusScope.of(Get.context!).requestFocus(controller.mobileFocus);
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter your email';
          }
          if (!Utils.isValidEmail(value.trim())) {
            return 'Please enter a valid email';
          }
          return null;
        },
        style: TextStyle(color: Colors.white),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.kPrimaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMobileField(EditProfileController controller) {
    return Focus(
      focusNode: controller.mobileFocus,
      child: CustomTextField(
        controller: controller.mobileController,
        readOnly: true,
        prefixIcon: Center(child: Text("+91")),
        labelText: AppStrings.yourMobile.tr,
        hintText: AppStrings.yourMobile.tr,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.phone,
        maxLength: 10,
        onFieldSubmitted: (_) {
          FocusScope.of(Get.context!).unfocus();
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter your mobile number';
          }
          if (value.trim().length != 10) {
            return 'Phone number must be 10 digits';
          }
          if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
            return 'Phone number must contain only digits';
          }
          return null;
        },
        style: TextStyle(color: Colors.white),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.kPrimaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildUpdateButton(
    EditProfileController controller,
    GlobalKey<FormState> formKey,
  ) {
    return Obx(
      () => CustomButton(
        text: AppStrings.editProfile.tr,
        onPressed: controller.isLoading.value
            ? null
            : () {
                if (formKey.currentState?.validate() ?? false) {
                  controller.updateProfile();
                }
              },
        backgroundColor: AppColors.kPrimaryColor,
        textColor: Colors.white,
        borderRadius: 30.r,
        elevation: 0,
        size: ButtonSize.medium,
        isLoading: controller.isLoading.value,
      ),
    );
  }
}
