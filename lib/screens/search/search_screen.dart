import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/core.dart';
import 'search_controller.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchController controller = Get.put(SearchController());

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          AppStrings.searchMovies.tr,
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
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: _buildSearchBar(context, controller),
          ),
          // Search History or Results
          Expanded(
            child: Obx(() {
              if (controller.searchText.value.isNotEmpty) {
                // Show search suggestions or results
                return _buildSearchSuggestions(controller);
              } else {
                // Show search history
                return _buildSearchHistory(controller);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, SearchController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kNeutral90Color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.searchController,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
              ),
              decoration: InputDecoration(
                hintText: AppStrings.searchMovies.tr,
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 16.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
              ),
              onSubmitted: (value) {
                controller.performSearch(value);
              },
              onChanged: (value) {
                // The listener in controller will update searchText
              },
            ),
          ),
          // Microphone Button
          Obx(() {
            if (controller.searchText.value.isNotEmpty) {
              return IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 24.sp,
                ),
                onPressed: () {
                  controller.clearSearch();
                },
              );
            }
            return IconButton(
              icon: Icon(
                Icons.mic,
                color: AppColors.kPrimaryColor,
                size: 24.sp,
              ),
              onPressed: () {
                controller.startVoiceSearch(context);
              },
            );
          }),
          SizedBox(width: 8.w),
        ],
      ),
    );
  }

  Widget _buildSearchHistory(SearchController controller) {
    return Obx(() {
      if (controller.searchHistory.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history,
                color: Colors.white.withValues(alpha: 0.3),
                size: 64.sp,
              ),
              SizedBox(height: 16.h),
              Text(
                AppStrings.noSearchHistory.tr,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.recentSearches.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    controller.clearHistory();
                  },
                  child: Text(
                    AppStrings.clearAll.tr,
                    style: TextStyle(
                      color: AppColors.kPrimaryColor,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: controller.searchHistory.length,
              itemBuilder: (context, index) {
                final query = controller.searchHistory[index];
                return _buildHistoryItem(controller, query);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildHistoryItem(SearchController controller, String query) {
    return InkWell(
      onTap: () {
        controller.onHistoryItemTap(query);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: AppColors.kNeutral90Color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(
              Icons.history,
              color: Colors.white.withValues(alpha: 0.6),
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                query,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.white.withValues(alpha: 0.5),
                size: 18.sp,
              ),
              onPressed: () {
                controller.removeFromHistory(query);
              },
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions(SearchController controller) {
    // Filter history based on current search
    final filteredHistory = controller.searchHistory
        .where((item) => item
            .toLowerCase()
            .contains(controller.searchText.value.toLowerCase()))
        .toList();

    if (filteredHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              color: Colors.white.withValues(alpha: 0.3),
              size: 64.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              AppStrings.noSuggestionsFound.tr,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 24.h),
            Obx(() => CustomButton(
              text: 'Search "${controller.searchText.value}"',
              onPressed: () {
                controller.performSearch(controller.searchText.value);
              },
              backgroundColor: AppColors.kPrimaryColor,
              textColor: Colors.white,
              borderRadius: 8.r,
              size: ButtonSize.medium,
            )),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Text(
            AppStrings.suggestions.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: filteredHistory.length,
            itemBuilder: (context, index) {
              final query = filteredHistory[index];
              return _buildHistoryItem(controller, query);
            },
          ),
        ),
      ],
    );
  }
}

