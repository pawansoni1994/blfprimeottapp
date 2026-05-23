// ignore_for_file: sized_box_for_whitespace, avoid_unnecessary_containers, prefer_const_constructors, file_names, prefer_is_empty, unnecessary_cast, avoid_print, use_build_context_synchronously, unused_local_variable

import 'package:blf_mobile/routes/app_pages.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/core.dart';
import 'add_audition_controller.dart';

class AddAuditionScreen extends StatelessWidget {
  const AddAuditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AddAuditionController controller = Get.put(AddAuditionController());
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.uploadAudition.tr,
      ),
      body: Obx(() {
        // Show success screen if submitted
        if (controller.isSubmitted.value) {
          return _buildSuccessScreen(controller);
        }

        if (controller.isAuditionUploaded.value) {
          return Padding(
            padding: const EdgeInsets.all(30),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "Thank you for your audition. Our team will review it and get back to you soon.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  CustomButton(
                    text: "Contact Us",
                    onPressed: () => Get.toNamed(AppRoutes.contactUs),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  CustomButton(
                    text: "Update Audition",
                    backgroundColor: Colors.grey,
                    onPressed: () =>
                        controller.isAuditionUploaded.value = false,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          );
        }

        // Show form
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                _buildNameField(controller),
                SizedBox(height: 16.h),
                _buildCityField(controller),
                SizedBox(height: 16.h),
                _buildAgeField(controller),
                SizedBox(height: 16.h),
                _buildIntroField(controller),
                SizedBox(height: 16.h),
                _buildSocialProfileUrlField(controller),
                SizedBox(height: 16.h),
                _buildUploadAuditionUrlField(controller),
                SizedBox(height: 16.h),
                _buildMessageField(controller),
                SizedBox(height: 20.h),
                _buildAgreeCheckbox(controller),
                SizedBox(height: 30.h),
                _buildSubmitButton(controller, formKey),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNameField(AddAuditionController controller) {
    return Focus(
      focusNode: controller.nameFocus,
      child: CustomTextField(
        controller: controller.nameController,
        labelText: 'Name',
        hintText: 'Enter your name',
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.text,
        onFieldSubmitted: (_) {
          FocusScope.of(Get.context!).requestFocus(controller.cityFocus);
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Enter a Name';
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

  Widget _buildCityField(AddAuditionController controller) {
    return Focus(
      focusNode: controller.cityFocus,
      child: CustomTextField(
        controller: controller.cityController,
        labelText: 'City',
        hintText: 'Enter your city',
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.text,
        onFieldSubmitted: (_) {
          FocusScope.of(Get.context!).requestFocus(controller.ageFocus);
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Enter a City';
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

  Widget _buildAgeField(AddAuditionController controller) {
    return Focus(
      focusNode: controller.ageFocus,
      child: CustomTextField(
        controller: controller.ageController,
        labelText: 'Age',
        hintText: 'Enter your age',
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.number,
        onFieldSubmitted: (_) {
          FocusScope.of(Get.context!).requestFocus(controller.introFocus);
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Enter an Age';
          }
          final age = int.tryParse(value.trim());
          if (age == null || age <= 0) {
            return 'Enter a valid Age';
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

  Widget _buildIntroField(AddAuditionController controller) {
    return Focus(
      focusNode: controller.introFocus,
      child: CustomTextField(
        controller: controller.introController,
        labelText: 'Intro',
        hintText: 'Enter your introduction',
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.text,
        maxLines: 3,
        onFieldSubmitted: (_) {
          FocusScope.of(Get.context!)
              .requestFocus(controller.socialProfileUrlFocus);
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Enter an Intro';
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

  Widget _buildSocialProfileUrlField(AddAuditionController controller) {
    return Focus(
      focusNode: controller.socialProfileUrlFocus,
      child: CustomTextField(
        controller: controller.socialProfileUrlController,
        labelText: 'Social Profile URL',
        hintText: 'Enter your social profile URL',
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.url,
        onFieldSubmitted: (_) {
          FocusScope.of(Get.context!)
              .requestFocus(controller.uploadAuditionUrlFocus);
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Enter a Social Profile URL';
          }
          final url = Uri.tryParse(value.trim());
          if (url == null || !url.hasAbsolutePath) {
            return 'Enter a valid URL';
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

  Widget _buildUploadAuditionUrlField(AddAuditionController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Audition Video URL',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.kPrimaryColor,
              size: 16.sp,
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                'Upload your audition video to Google Drive, Dropbox, or any cloud storage. Then paste the shareable link here.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Focus(
          focusNode: controller.uploadAuditionUrlFocus,
          child: CustomTextField(
            controller: controller.uploadAuditionUrlController,
            hintText:
                'https://drive.google.com/file/... or paste your video link',
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.url,
            onFieldSubmitted: (_) {
              FocusScope.of(Get.context!).requestFocus(controller.messageFocus);
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please provide your audition video URL';
              }
              final url = Uri.tryParse(value.trim());
              if (url == null || !url.hasAbsolutePath) {
                return 'Please enter a valid video URL (e.g., Google Drive, Dropbox link)';
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
        ),
      ],
    );
  }

  Widget _buildMessageField(AddAuditionController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Message',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller.messageController,
          focusNode: controller.messageFocus,
          minLines: 3,
          maxLines: 6,
          keyboardType: TextInputType.multiline,
          onFieldSubmitted: (_) {
            FocusScope.of(Get.context!).unfocus();
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter a Message';
            }
            return null;
          },
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: 'Enter your message',
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14.sp,
              fontWeight: FontWeight.w300,
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColors.kPrimaryColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.white, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgreeCheckbox(AddAuditionController controller) {
    return Obx(
      () => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Checkbox(
              value: controller.isAgreed.value,
              onChanged: (value) {
                controller.isAgreed.value = value ?? false;
              },
              activeColor: AppColors.kPrimaryColor,
              checkColor: Colors.white,
              side: BorderSide(color: Colors.white),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    TextSpan(text: 'I agree to the '),
                    TextSpan(
                      text: AppStrings.termsAndConditions.tr,
                      style: TextStyle(
                        color: AppColors.kPrimaryColor,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          final Uri url = Uri.parse('https://www.google.com');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(
    AddAuditionController controller,
    GlobalKey<FormState> formKey,
  ) {
    return Obx(
      () => CustomButton(
        text: 'Submit',
        onPressed: controller.isLoading.value
            ? null
            : () {
                if (formKey.currentState?.validate() ?? false) {
                  controller.submitAudition();
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

  Widget _buildSuccessScreen(AddAuditionController controller) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.kPrimaryColor,
              size: 80.sp,
            ),
            SizedBox(height: 24.h),
            Text(
              'Thank you for audition. Team will get back to you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 40.h),
            CustomButton(
              text: 'Update Audition',
              onPressed: () {
                controller.updateAudition();
              },
              backgroundColor: AppColors.kPrimaryColor,
              textColor: Colors.white,
              borderRadius: 30.r,
              elevation: 0,
              size: ButtonSize.medium,
            ),
            SizedBox(height: 16.h),
            Container(
              height: 50.h,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: ElevatedButton(
                onPressed: () {
                  controller.resetForm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                child: Text(
                  'Re-send Form',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
