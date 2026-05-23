// ignore_for_file: sized_box_for_whitespace, avoid_unnecessary_containers, prefer_const_constructors, file_names, prefer_is_empty, unnecessary_cast, avoid_print, use_build_context_synchronously, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/core.dart';
import '../../data/model/model.dart';
import 'watchlist_controller.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WatchlistController controller = Get.put(WatchlistController());

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: CustomAppBar(
        title: AppStrings.watchlist.tr,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.watchlist.isEmpty) {
          return _buildShimmerGrid();
        }

        if (controller.watchlist.isEmpty && !controller.isLoading.value) {
          return _buildEmptyState();
        }

        return _buildWatchlistGrid(controller);
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 200.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppImages.emptyWatch,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.bookmark_border,
                  size: 80.sp,
                  color: Colors.white.withValues(alpha: 0.3),
                );
              },
            ),
            SizedBox(height: 24.h),
            Text(
              AppStrings.noWatchlist.tr,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 15.w,
        mainAxisSpacing: 15.h,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _buildShimmerCard();
      },
    );
  }

  Widget _buildShimmerCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: ShimmerLoader(
              radius: 12.r,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: double.infinity,
          child: ShimmerLoader(
            height: 16.h,
            radius: 4.r,
          ),
        ),
        SizedBox(height: 4.h),
        ShimmerLoader(
          height: 12.h,
          width: 80.w,
          radius: 4.r,
        ),
      ],
    );
  }

  Widget _buildWatchlistGrid(WatchlistController controller) {
    return GridView.builder(
      controller: controller.scrollController,
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 15.w,
        mainAxisSpacing: 15.h,
      ),
      itemCount: controller.watchlist.length +
          (controller.isLoadingMore.value ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= controller.watchlist.length) {
          // Show shimmer for loading more
          return _buildShimmerCard();
        }
        final movie = controller.watchlist[index];
        return _buildWatchlistItem(movie, controller);
      },
    );
  }

  Widget _buildWatchlistItem(
    MovieModel movie,
    WatchlistController controller,
  ) {
    return InkWell(
      onTap: () => controller.navigateToDetails(movie),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
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
                                fit: BoxFit.fill,
                                borderRadius: BorderRadius.circular(12.r),
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
                                      size: 40.sp,
                                    ),
                                  );
                                },
                              )
                        : Container(
                            color: Colors.grey.withValues(alpha: 0.3),
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.white,
                              size: 40.sp,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                movie.title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                DurationFormatter.formatDuration(movie.duration),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          Positioned(
            right: 4.w,
            top: 4.h,
            child: InkWell(
              onTap: () => controller.removeFromWatchlist(movie.id, movie.type),
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.kPrimaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.bookmark,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
