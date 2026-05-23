// ignore_for_file: sized_box_for_whitespace, avoid_unnecessary_containers, prefer_const_constructors, file_names, prefer_is_empty, unnecessary_cast, avoid_print, use_build_context_synchronously, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/core.dart';
import '../../data/model/model.dart';
import '../../routes/app_pages.dart';
import 'view_all_controller.dart';

class ViewAllScreen extends StatelessWidget {
  const ViewAllScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ViewAllController controller = Get.put(ViewAllController());
    final String title = Get.parameters['title'] ?? AppStrings.allMovies.tr;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search bar with filter button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: _buildSearchBarWithFilter(controller),
          ),
          // Movies grid
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.movies.isEmpty) {
                return _buildShimmerGrid();
              }

              final movies = controller.filteredMovies;
              if (movies.isEmpty && !controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.movie_filter_outlined,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 64.sp,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        AppStrings.noResultsFound.tr,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return _buildMoviesGrid(movies, controller);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBarWithFilter(ViewAllController controller) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: TextField(
              onChanged: (value) {
                if (!controller.isDisposed) {
                  controller.updateSearchQuery(value);
                }
              },
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
              controller: controller.searchQueryController,
              enabled: !controller.isDisposed,
              decoration: InputDecoration(
                hintText: AppStrings.searchMovies.tr,
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14.sp,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 24.sp,
                ),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // Filter Button
        Container(
          width: 48.w,
          height: 48.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _showFilterBottomSheet(controller);
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Icon(
                Icons.filter_list,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet(ViewAllController controller) {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: AppColors.darkBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      isScrollControlled: true,
      builder: (context) => _buildFilterBottomSheet(controller),
    );
  }

  Widget _buildFilterBottomSheet(ViewAllController controller) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.filters.tr,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Categories Section
          Text(
            'Categories',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12.h),
          Obx(() => Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  // All option
                  _buildFilterChip(
                    label: 'All',
                    isSelected: controller.selectedCategoryId.value.isEmpty,
                    onTap: () {
                      controller.selectedCategoryId.value = '';
                    },
                  ),
                  // Category options
                  ...controller.categories.map((category) {
                    final isSelected =
                        controller.selectedCategoryId.value == category.id;
                    return _buildFilterChip(
                      label: category.name,
                      isSelected: isSelected,
                      onTap: () {
                        controller.selectedCategoryId.value = category.id;
                      },
                    );
                  }),
                ],
              )),
          SizedBox(height: 24.h),
          // Languages Section
          Text(
            AppStrings.languages.tr,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12.h),
          Obx(() => Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  // All option
                  _buildFilterChip(
                    label: 'All',
                    isSelected: controller.selectedLanguageId.value.isEmpty,
                    onTap: () {
                      controller.selectedLanguageId.value = '';
                    },
                  ),
                  // Language options
                  ...controller.languages.map((language) {
                    final isSelected =
                        controller.selectedLanguageId.value == language.id;
                    return _buildFilterChip(
                      label: language.name,
                      isSelected: isSelected,
                      onTap: () {
                        controller.selectedLanguageId.value = language.id;
                      },
                    );
                  }),
                ],
              )),
          SizedBox(height: 24.h),
          // Type Section
          Text(
            AppStrings.type.tr,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12.h),
          Obx(() => Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _buildFilterChip(
                    label: 'Movie',
                    isSelected: controller.selectedType.value == 'Movie',
                    onTap: () {
                      controller.selectedType.value = 'Movie';
                    },
                  ),
                  _buildFilterChip(
                    label: 'Series',
                    isSelected: controller.selectedType.value == 'Series',
                    onTap: () {
                      controller.selectedType.value = 'Series';
                    },
                  ),
                  _buildFilterChip(
                    label: 'Songs',
                    isSelected: controller.selectedType.value == 'Songs',
                    onTap: () {
                      controller.selectedType.value = 'Songs';
                    },
                  ),
                ],
              )),
          SizedBox(height: 24.h),
          // Apply Button
          CustomButton(
            text: AppStrings.applyFilters.tr,
            onPressed: () {
              Get.back();
            },
            backgroundColor: AppColors.kPrimaryColor,
            textColor: Colors.white,
            borderRadius: 8.r,
            size: ButtonSize.medium,
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.kPrimaryColor
              : AppColors.kNeutral90Color.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected
                ? AppColors.kPrimaryColor
                : Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMoviesGrid(
      List<MovieModel> movies, ViewAllController controller) {
    return GridView.builder(
      controller: controller.scrollController,
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio:
            controller.selectedType.value == 'Series' ? 0.95 : 0.65,
        crossAxisSpacing: 15.w,
        mainAxisSpacing: 15.h,
      ),
      itemCount: movies.length + (controller.isLoadingMore.value ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= movies.length) {
          // Show shimmer for loading more
          return _buildShimmerCard();
        }
        final movie = movies[index];
        return _buildMovieCard(movie);
      },
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 16.h,
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

  Widget _buildMovieCard(MovieModel movie) {
    return InkWell(
      onTap: () {
        // Get the controller to check selected type
        final controller = Get.find<ViewAllController>();
        final selectedType = controller.selectedType.value.toLowerCase();

        // Route based on selected type or item type
        String route;
        if (selectedType == 'songs') {
          route = AppRoutes.songDetails;
        } else if (selectedType == 'series' ||
            movie.type.toLowerCase() == 'series' ||
            movie.episodes.isNotEmpty) {
          route = AppRoutes.seriesDetails;
        } else {
          route = AppRoutes.movieDetails;
        }

        Get.toNamed(
          '$route?id=${Uri.encodeComponent(movie.id)}',
        );
      },
      child: Column(
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
    );
  }
}
