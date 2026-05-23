import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/core.dart';
import '../../data/local/hive/hive_manager.dart';
import '../../data/repository/auth_repository.dart';
import '../../network/error_handlers.dart';

class EditProfileController extends GetxController {
  final HiveManager hiveManager = Get.find(tag: (HiveManager).toString());
  final AuthRepository authRepository =
      Get.find(tag: (AuthRepository).toString());

  // Text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  // Focus nodes
  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode mobileFocus = FocusNode();

  // Profile image
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString profileImageUrl = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    nameController.text = hiveManager.getString(HiveManager.fullNameKey);
    emailController.text = hiveManager.getString(HiveManager.emailKey);
    mobileController.text = hiveManager.getString(HiveManager.phoneKey);
    profileImageUrl.value = hiveManager.getString(HiveManager.profileKey);
  }

  Future<void> pickImageFromGallery() async {
    try {
      final CustomImagePicker imagePicker = CustomImagePicker();
      final File? image = await imagePicker.pickProfilePicture();
      if (image != null) {
        selectedImage.value = image;
      }
    } catch (e) {
      logger.e(e);
      Utils.showToast('Failed to pick image');
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final imagePicker = ImagePicker();
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        // Crop the image
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          compressFormat: ImageCompressFormat.png,
          maxHeight: 500,
          maxWidth: 500,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: "Crop Your Image",
              lockAspectRatio: true,
              cropStyle: CropStyle.circle,
            ),
            IOSUiSettings(
              title: "Crop Your Image",
              aspectRatioLockEnabled: true,
              aspectRatioPickerButtonHidden: true,
              cropStyle: CropStyle.circle,
            ),
          ],
        );
        if (croppedFile != null) {
          selectedImage.value = File(croppedFile.path);
        }
      }
    } catch (e) {
      logger.e(e);
      Utils.showToast('Failed to capture image');
    }
  }

  void showImagePickerBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.darkBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.white),
              title: Text(
                AppStrings.pickFromGallery.tr,
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Get.back();
                pickImageFromGallery();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.white),
              title: Text(
                AppStrings.pickFromCamera.tr,
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Get.back();
                pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateProfile() async {
    if (nameController.text.trim().isEmpty) {
      Utils.showToast('Please enter your name');
      return;
    }

    if (!Utils.isValidEmail(emailController.text.trim())) {
      Utils.showToast('Please enter a valid email');
      return;
    }

    try {
      // Create FormData for multipart request
      final formData = dio.FormData.fromMap({
        'email': emailController.text.trim(),
        'name': nameController.text.trim(),
      });

      // Add image file if selected
      if (selectedImage.value != null) {
        formData.files.add(
          MapEntry(
            'profile',
            await dio.MultipartFile.fromFile(
              selectedImage.value!.path,
              filename: selectedImage.value!.path.split('/').last,
            ),
          ),
        );
      }

      // Use repository to update profile
      final userId = hiveManager.getString(HiveManager.userIdKey);
      final updatedUser = await authRepository.updateProfile(userId, formData);

      // Update profile image URL if it was updated
      if (updatedUser.profile != null) {
        profileImageUrl.value = updatedUser.profile!;
        hiveManager.setString(HiveManager.profileKey, updatedUser.profile!);
      }

      Utils.showToast('Profile updated successfully');
      Get.back(result: true);
    } catch (e) {
      Utils.closeLoading();
      logger.e(e);
      // Error toast is already shown by ApiService
    }
  }
}
