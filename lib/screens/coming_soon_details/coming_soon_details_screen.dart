// ignore_for_file: sized_box_for_whitespace, avoid_unnecessary_containers, prefer_const_constructors, file_names, prefer_is_empty, unnecessary_cast, avoid_print, use_build_context_synchronously, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/core.dart';
import '../../data/model/model.dart';
import 'coming_soon_details_controller.dart';

class ComingSoonDetailsScreen extends StatelessWidget {
  const ComingSoonDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ComingSoonDetailsController controller =
        Get.put(ComingSoonDetailsController());

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.kPrimaryColor,
            ),
          );
        }

        final comingSoon = controller.comingSoonDetail.value;
        if (comingSoon == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 48.sp),
                SizedBox(height: 16.h),
                Text(
                  'Coming Soon item not found',
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
                SizedBox(height: 16.h),
                CustomButton(
                  text: 'Go Back',
                  onPressed: () => Get.back(),
                  backgroundColor: AppColors.kPrimaryColor,
                  textColor: Colors.white,
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            _buildAppBar(comingSoon, controller),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildComingSoonHeader(comingSoon, controller),
                  SizedBox(height: 12.h),
                  _buildActionButtons(controller),
                  SizedBox(height: 12.h),
                  _buildGenreInfo(comingSoon),
                  SizedBox(height: 12.h),
                  _buildTagsSection(comingSoon),
                  SizedBox(height: 12.h),
                  _buildDescription(comingSoon),
                  SizedBox(height: 12.h),
                  _buildCastSection(comingSoon),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAppBar(
      MovieModel comingSoon, ComingSoonDetailsController controller) {
    // Get list of images - use images array, fallback to poster if no images
    final List<String> imageUrls = [];
    if (comingSoon.images.isNotEmpty) {
      imageUrls.addAll(comingSoon.images
          .map((img) => img.url)
          .where((url) => url.isNotEmpty));
    }
    // If no images but has poster, use poster as single image
    if (imageUrls.isEmpty &&
        comingSoon.poster != null &&
        comingSoon.poster!.isNotEmpty) {
      imageUrls.add(comingSoon.poster!);
    }

    return SliverAppBar(
      expandedHeight: 400.h,
      pinned: true,
      backgroundColor: AppColors.darkBackground,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: Builder(
        builder: (context) => FlexibleSpaceBar(
          background: Stack(
            fit: StackFit.expand,
            children: [
              // Images carousel
              if (imageUrls.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    final currentIndex = controller.currentImageIndex.value;
                    FullScreenImageViewer.show(
                      context,
                      imageUrls,
                      initialIndex: currentIndex,
                    );
                  },
                  child: Column(
                    children: [
                      CarouselSlider.builder(
                        carouselController: controller.carouselController,
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index, realIndex) {
                          return SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: CustomImageView(
                              imageUrl: imageUrls[realIndex],
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                        options: CarouselOptions(
                          height: 400.h,
                          viewportFraction: 1.0,
                          autoPlay: imageUrls.length > 1,
                          autoPlayInterval: Duration(seconds: 3),
                          autoPlayAnimationDuration:
                              Duration(milliseconds: 800),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enlargeCenterPage: false,
                          enableInfiniteScroll: false,
                          onPageChanged: (index, reason) {
                            controller.onImageChanged(index);
                          },
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  color: Colors.grey.withValues(alpha: 0.3),
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.white,
                    size: 50.sp,
                  ),
                ),
              // Gradient overlay (ignoring pointer events so taps pass through)
              IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.5),
                        AppColors.darkBackground,
                      ],
                      stops: [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
              // Image indicators (only show if more than one image)
              if (imageUrls.length > 1)
                Positioned(
                  bottom: 20.h,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            imageUrls.length,
                            (index) => Container(
                              width: 8.w,
                              height: 8.h,
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    controller.currentImageIndex.value == index
                                        ? AppColors.kPrimaryColor
                                        : Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        )),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComingSoonHeader(
      MovieModel comingSoon, ComingSoonDetailsController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comingSoon.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Share and Watchlist buttons
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.share,
                  color: Colors.white,
                  size: 24.sp,
                ),
                onPressed: () {
                  ShareUtil.shareContent(
                    contentType: 'comingsoon',
                    contentId: comingSoon.id,
                    title: comingSoon.title,
                  );
                },
                tooltip: 'Share',
              ),
              SizedBox(width: 8.w),
              Obx(() => IconButton(
                    icon: Icon(
                      controller.isInWatchlist.value
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: controller.isInWatchlist.value
                          ? AppColors.kPrimaryColor
                          : Colors.white,
                      size: 24.sp,
                    ),
                    onPressed: controller.toggleWatchlist,
                    tooltip: controller.isInWatchlist.value
                        ? 'Remove from Watch Later'
                        : 'Add to Watch Later',
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ComingSoonDetailsController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          // Watch Trailer button
          Expanded(
            child: CustomButton(
              text: 'Watch Trailer',
              onPressed: controller.viewTrailer,
              backgroundColor: AppColors.kPrimaryColor,
              textColor: Colors.white,
              borderRadius: 8.r,
              elevation: 0,
              size: ButtonSize.medium,
              icon: Icon(
                Icons.play_circle_outline,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreInfo(MovieModel comingSoon) {
    if (comingSoon.category.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        'Genre: ${comingSoon.category.join(", ")}',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 14.sp,
        ),
      ),
    );
  }

  Widget _buildTagsSection(MovieModel comingSoon) {
    if (comingSoon.tags.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tags',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: comingSoon.tags.map((tag) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.kPrimaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.kPrimaryColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(MovieModel comingSoon) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.description.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            comingSoon.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCastSection(MovieModel comingSoon) {
    if (comingSoon.cast.isEmpty) return SizedBox.shrink();

    // Get all cast profile images for full-screen viewer
    final castImages = comingSoon.cast
        .where((cast) => cast.profile.isNotEmpty)
        .map((cast) => cast.profile)
        .toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.cast.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 120.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: comingSoon.cast.length,
              itemBuilder: (context, index) {
                final cast = comingSoon.cast[index];
                return Builder(
                  builder: (context) => Container(
                    width: 90.w,
                    margin: EdgeInsets.only(right: 12.w),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: cast.profile.isNotEmpty
                              ? () {
                                  final imageIndex =
                                      castImages.indexOf(cast.profile);
                                  if (imageIndex >= 0) {
                                    FullScreenImageViewer.show(
                                      context,
                                      castImages,
                                      initialIndex: imageIndex,
                                    );
                                  }
                                }
                              : null,
                          child: Container(
                            width: 80.w,
                            height: 80.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.kPrimaryColor,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: cast.profile.isNotEmpty
                                  ? CustomImageView(
                                      imageUrl: cast.profile,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: Colors.grey.withValues(alpha: 0.3),
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 30.sp,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          cast.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        if (cast.character.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            cast.character,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 10.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
