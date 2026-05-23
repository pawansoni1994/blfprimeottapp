import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../core/core.dart';
import '../../data/local/hive/hive_manager.dart';
import '../../data/repository/audition_repository.dart';

class AddAuditionController extends GetxController {
  final HiveManager hiveManager = Get.find(tag: (HiveManager).toString());
  final AuditionRepository auditionRepository = Get.find(
    tag: (AuditionRepository).toString(),
  );
  final Logger logger = Logger();

  // Text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController introController = TextEditingController();
  final TextEditingController socialProfileUrlController =
      TextEditingController();
  final TextEditingController uploadAuditionUrlController =
      TextEditingController();
  final TextEditingController messageController = TextEditingController();

  // Focus nodes
  final FocusNode nameFocus = FocusNode();
  final FocusNode cityFocus = FocusNode();
  final FocusNode ageFocus = FocusNode();
  final FocusNode introFocus = FocusNode();
  final FocusNode socialProfileUrlFocus = FocusNode();
  final FocusNode uploadAuditionUrlFocus = FocusNode();
  final FocusNode messageFocus = FocusNode();

  // State management
  final RxBool isLoading = false.obs;
  final RxBool isAgreed = false.obs;
  final RxBool isSubmitted = false.obs;
  RxBool isAuditionUploaded = true.obs;

  @override
  void onInit() {
    checkAudition();
    super.onInit();
  }

  void checkAudition() async {
    isAuditionUploaded.value = await auditionRepository.checkAuditionUploaded();
  }

  @override
  void onClose() {
    nameController.dispose();
    cityController.dispose();
    ageController.dispose();
    introController.dispose();
    socialProfileUrlController.dispose();
    uploadAuditionUrlController.dispose();
    messageController.dispose();
    nameFocus.dispose();
    cityFocus.dispose();
    ageFocus.dispose();
    introFocus.dispose();
    socialProfileUrlFocus.dispose();
    uploadAuditionUrlFocus.dispose();
    messageFocus.dispose();
    super.onClose();
  }

  Future<void> submitAudition() async {
    // Validation
    if (nameController.text.trim().isEmpty) {
      Utils.showToast('Enter a Name');
      return;
    }

    if (cityController.text.trim().isEmpty) {
      Utils.showToast('Enter a City');
      return;
    }

    if (ageController.text.trim().isEmpty) {
      Utils.showToast('Enter an Age');
      return;
    }

    final age = int.tryParse(ageController.text.trim());
    if (age == null || age <= 0) {
      Utils.showToast('Enter a valid Age');
      return;
    }

    if (introController.text.trim().isEmpty) {
      Utils.showToast('Enter an Intro');
      return;
    }

    if (socialProfileUrlController.text.trim().isEmpty) {
      Utils.showToast('Enter a Social Profile URL');
      return;
    }

    // Validate URL format
    final socialUrl = Uri.tryParse(socialProfileUrlController.text.trim());
    if (socialUrl == null || !socialUrl.hasAbsolutePath) {
      Utils.showToast('Enter a valid Social Profile URL');
      return;
    }

    if (uploadAuditionUrlController.text.trim().isEmpty) {
      Utils.showToast('Please provide your audition video URL');
      return;
    }

    // Validate URL format
    final uploadUrl = Uri.tryParse(uploadAuditionUrlController.text.trim());
    if (uploadUrl == null || !uploadUrl.hasAbsolutePath) {
      Utils.showToast(
          'Please enter a valid video URL (e.g., Google Drive, Dropbox link)');
      return;
    }

    if (messageController.text.trim().isEmpty) {
      Utils.showToast('Enter a Message');
      return;
    }

    if (!isAgreed.value) {
      Utils.showToast('Please agree to the terms');
      return;
    }

    try {
      isLoading.value = true;

      // Submit audition to API
      await auditionRepository.submitAudition(
        name: nameController.text.trim(),
        city: cityController.text.trim(),
        age: age,
        intro: introController.text.trim(),
        socialProfileUrl: socialProfileUrlController.text.trim(),
        auditionUrl: uploadAuditionUrlController.text.trim(),
        message: messageController.text.trim(),
      );

      // Set submitted state to show success screen
      isSubmitted.value = true;
      Get.back();
      Utils.showToast(
          "Thank you for your audition. Our team will review it and get back to you soon.");
    } catch (e) {
      logger.e(e);
      // Error is already handled by ApiService (shows toast)
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    nameController.clear();
    cityController.clear();
    ageController.clear();
    introController.clear();
    socialProfileUrlController.clear();
    uploadAuditionUrlController.clear();
    messageController.clear();
    isAgreed.value = false;
    isSubmitted.value = false;
  }

  void updateAudition() {
    // Reset submitted state to allow editing
    isSubmitted.value = false;
  }
}
