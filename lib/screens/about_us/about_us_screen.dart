import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/core.dart';
import '../../routes/app_pages.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppStrings.aboutUs.tr,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLogoSection(),
            SizedBox(height: 30.h),
            _buildAboutSection(),
            SizedBox(height: 30.h),
            _buildMissionSection(),
            SizedBox(height: 30.h),
            _buildVisionSection(),
            SizedBox(height: 30.h),
            _buildFeaturesSection(),
            SizedBox(height: 30.h),
            _buildContactSection(),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Center(
      child: Column(
        children: [
          Image.asset(
            AppImages.logoBlf,
            height: 120,
            width: 120,
          ),
          SizedBox(height: 16.h),
          Text(
            AppStrings.appName.tr,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppStrings.appVersion.tr,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Us',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'BLF Prime is a premier streaming platform dedicated to bringing you the best in entertainment. We offer a vast library of movies, series, and exclusive content for viewers of all ages.',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Our platform is designed to provide an exceptional viewing experience with high-quality content, user-friendly interface, and seamless streaming capabilities.',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildMissionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.flag,
              color: AppColors.kPrimaryColor,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Our Mission',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          'To deliver exceptional entertainment experiences by providing access to premium content, fostering creativity, and connecting audiences with stories that matter.',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildVisionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.remove_red_eye,
              color: AppColors.kPrimaryColor,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Our Vision',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          'To become the leading entertainment platform that inspires, entertains, and enriches lives through the power of storytelling and innovative technology.',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Features',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16.h),
        _buildFeatureItem(
          icon: Icons.high_quality,
          title: 'High Quality Content',
          description: 'Enjoy movies and shows in stunning HD and 4K quality',
        ),
        SizedBox(height: 12.h),
        _buildFeatureItem(
          icon: Icons.download,
          title: 'Download & Watch Offline',
          description:
              'Download your favorite content and watch anytime, anywhere',
        ),
        SizedBox(height: 12.h),
        _buildFeatureItem(
          icon: Icons.favorite,
          title: 'Personalized Experience',
          description:
              'Create watchlists and favorites tailored to your preferences',
        ),
        SizedBox(height: 12.h),
        _buildFeatureItem(
          icon: Icons.child_care,
          title: 'Kids Safe Mode',
          description: 'Protect your children with our safe viewing mode',
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.kPrimaryColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: AppColors.kPrimaryColor,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.contact_support,
              color: AppColors.kPrimaryColor,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _buildClickableContactItem(
          icon: Icons.email,
          label: 'Email',
          value: 'support@blflive.com',
          onTap: () => _launchEmail('support@blflive.com'),
        ),
        SizedBox(height: 12.h),
        _buildClickableContactItem(
          icon: Icons.phone,
          label: 'Phone',
          value: '+911234567890',
          onTap: () => _launchPhone('+911234567890'),
        ),
        SizedBox(height: 12.h),
        _buildClickableContactItem(
          icon: Icons.location_on,
          label: 'Address',
          value: '123 Entertainment Street, Indore, Madhya Pradesh, India',
          onTap: () => _launchMaps(
              '123 Entertainment Street, Indore, Madhya Pradesh, India'),
        ),
        SizedBox(height: 20.h),
        Center(
          child: ElevatedButton(
            onPressed: () {
              Get.toNamed(AppRoutes.contactUs);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kPrimaryColor,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'View Full Contact Page',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClickableContactItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: AppColors.kPrimaryColor,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.kPrimaryColor,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Contact from BLF Prime App',
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        Utils.showToast('Could not open email app');
      }
    } catch (e) {
      Utils.showToast('Error opening email');
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        Utils.showToast('Could not open phone dialer');
      }
    } catch (e) {
      Utils.showToast('Error opening phone dialer');
    }
  }

  Future<void> _launchMaps(String address) async {
    final String encodedAddress = Uri.encodeComponent(address);
    final Uri mapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
    );
    try {
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
      } else {
        Utils.showToast('Could not open maps');
      }
    } catch (e) {
      Utils.showToast('Error opening maps');
    }
  }
}
