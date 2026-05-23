// ignore_for_file: sized_box_for_whitespace, avoid_unnecessary_containers, prefer_const_constructors, file_names, prefer_is_empty, unnecessary_cast, avoid_print, use_build_context_synchronously, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/core.dart';
import '../../data/model/model.dart';
import '../../routes/app_pages.dart';
import 'coming_soon_controller.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ComingSoonController controller = Get.put(ComingSoonController());

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppStrings.comingSoon.tr,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.movies.isEmpty) {
          return _buildShimmerList();
        }

        final movies = controller.filteredMovies;
        if (movies.isEmpty && !controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule_outlined,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 64.sp,
                ),
                SizedBox(height: 16.h),
                Text(
                  AppStrings.comingSoonSubtitle.tr,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          );
        }
        return _buildMoviesList(movies, controller);
      }),
    );
  }

  Widget _buildMoviesList(
      List<MovieModel> movies, ComingSoonController controller) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.fetchComingSoon(isRefresh: true);
      },
      child: ListView.builder(
        controller: controller.scrollController,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: movies.length + (controller.isLoadingMore.value ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= movies.length) {
            // Show shimmer for loading more
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: _buildShimmerBanner(),
            );
          }
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: _buildMovieBanner(movies[index]),
          );
        },
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: _buildShimmerBanner(),
        );
      },
    );
  }

  Widget _buildShimmerBanner() {
    return ShimmerLoader(
      height: 200.h,
      width: double.infinity,
      radius: 12.r,
    );
  }

  Widget _buildMovieBanner(MovieModel movie) {
    return InkWell(
      onTap: () {
        // Coming soon items should navigate to coming soon details
        Get.toNamed(
          '${AppRoutes.comingSoonDetails}?id=${Uri.encodeComponent(movie.id)}',
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: movie.image.isNotEmpty
                    ? (movie.image.startsWith('http') ||
                            movie.image.startsWith('https'))
                        ? CustomImageView(
                            imageUrl: movie.image,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            movie.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.withValues(alpha: 0.3),
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white,
                                  size: 50.sp,
                                ),
                              );
                            },
                          )
                    : Container(
                        color: Colors.grey.withValues(alpha: 0.3),
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.white,
                          size: 50.sp,
                        ),
                      )),
          ),
          SizedBox(height: 8.h),
          Text(
            movie.title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (movie.duration.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14.sp,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                SizedBox(width: 4.w),
                Text(
                  DurationFormatter.formatDuration(movie.duration),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
