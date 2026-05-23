import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/core.dart';
import '../../data/model/model.dart';
import 'continue_watching_view_all_controller.dart';

class ContinueWatchingViewAllScreen extends StatelessWidget {
  const ContinueWatchingViewAllScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ContinueWatchingViewAllController controller =
        Get.put(ContinueWatchingViewAllController());

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Continue Watching',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.continueWatching.isEmpty) {
          return _buildShimmerGrid();
        }

        if (controller.continueWatching.isEmpty && !controller.isLoading.value) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.refreshContinueWatching();
          },
          color: AppColors.kPrimaryColor,
          child: GridView.builder(
            padding: EdgeInsets.all(16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
            ),
            itemCount: controller.continueWatching.length +
                (controller.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= controller.continueWatching.length) {
                // Load more indicator
                if (controller.isLoadingMore.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.kPrimaryColor,
                    ),
                  );
                }
                // Trigger load more
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.loadMore();
                });
                return SizedBox.shrink();
              }

              final item = controller.continueWatching[index];
              return _buildContinueWatchingCard(item, controller);
            },
          ),
        );
      }),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return ShimmerLoader(
          height: double.infinity,
          width: double.infinity,
          radius: 12.r,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_outline,
            size: 80.sp,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Continue Watching',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start watching to see your progress here',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueWatchingCard(
    ContinueWatchingModel item,
    ContinueWatchingViewAllController controller,
  ) {
    final posterUrl = item.content.poster ?? '';

    return InkWell(
      onTap: () => controller.navigateToVideo(item),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12.r),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12.r),
                      ),
                      child: posterUrl.isNotEmpty
                          ? CustomImageView(
                              imageUrl: posterUrl,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12.r),
                              ),
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
                  // Progress indicator at bottom
                  if (item.totalDuration > 0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 4.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12.r),
                            bottomRight: Radius.circular(12.r),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12.r),
                            bottomRight: Radius.circular(12.r),
                          ),
                          child: LinearProgressIndicator(
                            value: item.totalDuration > 0
                                ? (item.resumePoint / item.totalDuration)
                                    .clamp(0.0, 1.0)
                                : 0.0,
                            backgroundColor: Colors.black.withValues(alpha: 0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.kPrimaryColor),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.content.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Show duration and resume point info
                  if (item.totalDuration > 0)
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          size: 12.sp,
                          color: Colors.white70,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${_formatDuration(item.resumePoint)} / ${_formatDuration(item.totalDuration)}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  // Show episode info for series
                  if (item.contentType == 'series' && item.episode != null)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        'S${item.episode!.season} E${item.episode!.episode}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.white60,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${secs.toString().padLeft(2, '0')}';
    }
  }
}

