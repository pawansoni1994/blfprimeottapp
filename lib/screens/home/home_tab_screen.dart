import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/core.dart';
import '../../data/model/model.dart';
import '../../routes/app_pages.dart';
import 'home_controller.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen>
    with WidgetsBindingObserver {
  late HomeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(HomeController());
    WidgetsBinding.instance.addObserver(this);
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // Refresh continue watching when screen becomes visible
  //   // Add a small debounce to avoid too many calls (refresh at most once per second)
  //   final now = DateTime.now();
  //   if (_lastRefreshTime == null ||
  //       now.difference(_lastRefreshTime!).inSeconds >= 1) {
  //     _lastRefreshTime = now;
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if (mounted) {
  //         controller.fetchContinueWatching();
  //       }
  //     });
  //   }
  // }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      controller.fetchContinueWatching();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppStrings.appName.tr,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              size: 24.sp,
              color: Colors.white,
            ),
            onPressed: () {
              Get.toNamed(AppRoutes.search);
            },
          ),
        ],
      ),
      // drawer: _buildDrawer(controller),
      body: RefreshIndicator(
        child: ListView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: [
            // Feature Movies Carousel
            _buildBannerCarousel(controller),
            SizedBox(height: 12.h),
            // Continue Watching Section
            _buildContinueWatchingSection(controller),
            SizedBox(height: 12.h),
            // Genre Filter Chips
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildGenreChips(controller),
            ),
            // Latest Movies Section
            _buildLatestMoviesSection(controller),
            SizedBox(height: 6.h),
            // Top in Category Movies Section (1st category)
            _buildCategoryMoviesSection(controller),
            SizedBox(height: 6.h),
            // Languages Chips Section
            if (controller.languages.isNotEmpty ||
                controller.isLoadingLanguages.value)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _buildLanguagesChips(controller),
              ),
            SizedBox(height: 16.h),
            // Extra Banners
            Obx(() {
              if (controller.isLoadingExtraBanners.value &&
                  controller.extraBanners.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: ShimmerLoader(
                    height: 200.h,
                    width: double.infinity,
                    radius: 12.r,
                  ),
                );
              }
              return Column(
                children: controller.extraBanners
                    .map((banner) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: InkWell(
                            onTap: () => controller.onExtraBannerTap(banner),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: CustomImageView(
                                imageUrl: banner.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              );
            }),
            // Latest Series Section
            _buildLatestSeriesSection(controller),
            SizedBox(height: 6.h),
            // Top in Category Series Section (2nd category)
            _buildCategorySeriesSection(controller),
            SizedBox(height: 6.h),
            // Latest Songs Section
            _buildLatestSongsSection(controller),
            SizedBox(height: 6.h),
            // Series Section
            _buildMovieSection(
              controller: controller,
              title: AppStrings.series.tr,
              movies: controller.series,
            ),
            SizedBox(height: 6.h),
            // Movies Section
            _buildMovieSection(
              controller: controller,
              title: AppStrings.movies.tr,
              movies: controller.movies,
            ),
            SizedBox(height: 10.h),
          ],
        ),
        onRefresh: () async {
          controller.fetchContinueWatching();
          controller.fetchLatestMovies();
          controller.fetchLatestSeries();
          controller.fetchLatestSongs();
          controller.fetchExtraBanners();
          return Future.value();
        },
      ),
    );
  }

  Widget _buildBannerCarousel(HomeController controller) {
    return Obx(() {
      if (controller.isLoadingBanners.value && controller.banners.isEmpty) {
        return ShimmerLoader(
          height: 300.h,
          width: double.infinity,
        );
      }

      if (controller.banners.isEmpty) {
        return SizedBox.shrink();
      }

      return Column(
        children: [
          CarouselSlider.builder(
            carouselController: controller.carouselController,
            itemCount: controller.banners.length,
            itemBuilder: (context, index, realIndex) {
              final banner = controller.banners[index];
              return _buildBannerItem(banner, controller);
            },
            options: CarouselOptions(
              height: 300.h,
              viewportFraction: 1.0,
              autoPlay: controller.banners.length > 1,
              autoPlayInterval: Duration(seconds: 3),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: false,
              onPageChanged: (index, reason) {
                controller.onBannerChanged(index);
              },
            ),
          ),
          SizedBox(height: 6.h),
          // Banner Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              controller.banners.length,
              (index) => Container(
                width: 8.w,
                height: 8.h,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: controller.currentBannerIndex.value == index
                      ? AppColors.kPrimaryColor
                      : Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildBannerItem(BannerModel banner, HomeController controller) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          banner.imageUrl.isNotEmpty
              ? CustomImageView(
                  imageUrl: banner.imageUrl,
                  fit: BoxFit.cover,
                )
              : Container(
                  color: Colors.grey.withValues(alpha: 0.3),
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.white,
                    size: 50.sp,
                  ),
                ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                  AppColors.darkBackground,
                ],
                stops: [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),
          // Content Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Categories in Row (joined with bullet) - from banner's linkId.category
                  if (banner.categoryIds.isNotEmpty)
                    _buildBannerCategories(banner, controller),
                  SizedBox(height: 6.h),
                  // Watch Now Button with Gradient
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 180.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.kPrimaryColor,
                              AppColors.kPrimaryColor.withValues(alpha: 0.6),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // Navigate to details page (movie/series) or handle other link types
                              controller.onBannerTap(banner);
                            },
                            borderRadius: BorderRadius.circular(8.r),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 12.h,
                                horizontal: 16.w,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 24.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Watch Now',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Add to List Button
                      Container(
                        width: 48.w,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              controller.addBannerToWatchlist(banner);
                            },
                            borderRadius: BorderRadius.circular(8.r),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCategories(BannerModel banner, HomeController controller) {
    // Get category names by matching IDs from banner.categoryIds with controller.categories
    final bannerCategories = controller.categories
        .where((cat) => banner.categoryIds.contains(cat.id))
        .map((cat) => cat.name)
        .toList();

    if (bannerCategories.isEmpty) {
      return SizedBox.shrink();
    }

    return Text(
      bannerCategories.take(4).join(' • '),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13.sp,
        color: Colors.white.withValues(alpha: 0.85),
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.8),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildGenreChips(HomeController controller) {
    return Obx(
      () {
        if (controller.isLoadingCategories.value) {
          return SizedBox(
            height: 50.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: ShimmerLoader(
                    height: 40.h,
                    width: 100.w,
                    radius: 10.r,
                  ),
                );
              },
            ),
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: controller.genres.map((genre) {
              final isSelected = controller.selectedGenre.value == genre;
              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: InkWell(
                  onTap: () {
                    if (genre == 'All') {
                      controller.selectGenre(genre);
                    } else {
                      // Navigate to view all screen with selected category
                      Get.toNamed(
                        '${AppRoutes.viewAll}?title=${Uri.encodeComponent(genre)}&category=${Uri.encodeComponent(genre)}',
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(20.r),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
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
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.kPrimaryColor
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      genre,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.8),
                        fontSize: 14.sp,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildLanguagesChips(HomeController controller) {
    return Obx(
      () {
        if (controller.isLoadingLanguages.value) {
          return SizedBox(
            height: 50.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: ShimmerLoader(
                    height: 40.h,
                    width: 100.w,
                    radius: 10.r,
                  ),
                );
              },
            ),
          );
        }

        if (controller.languages.isEmpty) {
          return SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Text(
                AppStrings.topByLanguages.tr,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: controller.languages.map((language) {
                  final isSelected =
                      controller.selectedLanguage.value == language.id;
                  return Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: InkWell(
                      onTap: () {
                        controller.selectLanguage(language);
                      },
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.kPrimaryColor
                              : AppColors.kNeutral90Color
                                  .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.kPrimaryColor
                                : Colors.white.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.kPrimaryColor
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          language.name,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.8),
                            fontSize: 14.sp,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLatestMoviesSection(HomeController controller) {
    return Obx(
      () {
        if (controller.isLoadingLatestMovies.value) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              SizedBox(
                height: 250.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: ShimmerLoader(
                        height: 200.h,
                        width: 140.w,
                        radius: 12.r,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        if (controller.latestMovies.isEmpty) {
          return SizedBox.shrink();
        }

        // Show only 7-8 movies
        final moviesToShow = controller.latestMovies.take(8).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.latestReleases.tr,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.toNamed(
                        '${AppRoutes.viewAll}?title=${Uri.encodeComponent(AppStrings.latestReleases.tr)}&type=${Uri.encodeComponent('latest')}',
                      );
                    },
                    child: Text(
                      AppStrings.viewAll.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.kPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: moviesToShow.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () async {
                      await Get.toNamed(
                        '${AppRoutes.movieDetails}?id=${Uri.encodeComponent(moviesToShow[index].id)}',
                      );
                      controller.fetchContinueWatching();
                    },
                    child: _buildMovieCard(moviesToShow[index]),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLatestSeriesSection(HomeController controller) {
    return Obx(
      () {
        if (controller.isLoadingLatestSeries.value) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: ShimmerLoader(
                        height: 200.h,
                        width: 140.w,
                        radius: 12.r,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        if (controller.latestSeries.isEmpty) {
          return SizedBox.shrink();
        }

        // Show only 7-8 series
        final seriesToShow = controller.latestSeries.take(8).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.latestSeries.tr,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.toNamed(
                        '${AppRoutes.viewAllSeries}?title=${Uri.encodeComponent(AppStrings.latestSeries.tr)}',
                      );
                    },
                    child: Text(
                      AppStrings.viewAll.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.kPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: seriesToShow.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () async {
                      Get.toNamed(
                        '${AppRoutes.seriesDetails}?id=${Uri.encodeComponent(seriesToShow[index].id)}',
                      );
                      controller.fetchContinueWatching();
                    },
                    child: _buildMovieCard(seriesToShow[index], isSeries: true),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLatestSongsSection(HomeController controller) {
    return Obx(
      () {
        if (controller.isLoadingLatestSongs.value) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              SizedBox(
                height: 200.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: ShimmerLoader(
                        height: 200.h,
                        width: 140.w,
                        radius: 12.r,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        if (controller.latestSongs.isEmpty) {
          return SizedBox.shrink();
        }

        // Show only 7-8 songs
        final songsToShow = controller.latestSongs.take(8).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Latest Songs',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.toNamed(
                        '${AppRoutes.viewAll}?title=${Uri.encodeComponent('Latest Songs')}&type=songs',
                      );
                    },
                    child: Text(
                      AppStrings.viewAll.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.kPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: songsToShow.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () async {
                      await Get.toNamed(
                        '${AppRoutes.songDetails}?id=${Uri.encodeComponent(songsToShow[index].id)}',
                      );
                    },
                    child: _buildMovieCard(songsToShow[index]),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryMoviesSection(HomeController controller) {
    return Obx(
      () {
        if (controller.isLoadingCategoryMovies.value) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              SizedBox(
                height: 250.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: ShimmerLoader(
                        height: 200.h,
                        width: 140.w,
                        radius: 12.r,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        if (controller.categoryMovies.isEmpty ||
            controller.categoryMoviesCategoryName.value.isEmpty) {
          return SizedBox.shrink();
        }

        // Show only 7-8 movies
        final moviesToShow = controller.categoryMovies.take(8).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top in ${controller.categoryMoviesCategoryName.value}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.toNamed(
                        '${AppRoutes.viewAll}?title=${Uri.encodeComponent('Top in ${controller.categoryMoviesCategoryName.value}')}&category=${Uri.encodeComponent(controller.categoryMoviesCategoryName.value)}&type=movie',
                      );
                    },
                    child: Text(
                      AppStrings.viewAll.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.kPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: moviesToShow.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () async {
                      await Get.toNamed(
                        '${AppRoutes.movieDetails}?id=${Uri.encodeComponent(moviesToShow[index].id)}',
                      );
                      controller.fetchContinueWatching();
                    },
                    child: _buildMovieCard(moviesToShow[index]),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategorySeriesSection(HomeController controller) {
    return Obx(
      () {
        if (controller.isLoadingCategorySeries.value) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: ShimmerLoader(
                        height: 200.h,
                        width: 140.w,
                        radius: 12.r,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        if (controller.categorySeries.isEmpty ||
            controller.categorySeriesCategoryName.value.isEmpty) {
          return SizedBox.shrink();
        }

        // Show only 7-8 series
        final seriesToShow = controller.categorySeries.take(8).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top in ${controller.categorySeriesCategoryName.value}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.toNamed(
                        '${AppRoutes.viewAllSeries}?title=${Uri.encodeComponent('Top in ${controller.categorySeriesCategoryName.value}')}&category=${Uri.encodeComponent(controller.categorySeriesCategoryName.value)}',
                      );
                    },
                    child: Text(
                      AppStrings.viewAll.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.kPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: seriesToShow.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () async {
                      await Get.toNamed(
                        '${AppRoutes.seriesDetails}?id=${Uri.encodeComponent(seriesToShow[index].id)}',
                      );
                      controller.fetchContinueWatching();
                    },
                    child: _buildMovieCard(seriesToShow[index], isSeries: true),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMovieSection({
    required HomeController controller,
    required String title,
    required List<MovieModel> movies,
  }) {
    if (movies.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () async {
                  await Get.toNamed(
                    '${AppRoutes.viewAll}?title=${Uri.encodeComponent(title)}',
                  );
                  controller.fetchContinueWatching();
                },
                child: Text(
                  AppStrings.viewAll.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.kPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 200.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () async {
                  await Get.toNamed(
                    '${AppRoutes.movieDetails}?id=${Uri.encodeComponent(movies[index].id)}',
                  );
                  controller.fetchContinueWatching();
                },
                child: _buildMovieCard(movies[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContinueWatchingSection(HomeController controller) {
    return Obx(
      () {
        // Only show if list is not empty
        if (controller.continueWatching.isEmpty) {
          return SizedBox.shrink();
        }

        if (controller.isLoadingContinueWatching.value) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: ShimmerLoader(
                        height: 200.h,
                        width: 140.w,
                        radius: 12.r,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10.h),
            ],
          );
        }

        final itemsToShow = controller.continueWatching.take(10).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Continue Watching',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.toNamed(AppRoutes.continueWatchingViewAll);
                    },
                    child: Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.kPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 185,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: itemsToShow.length,
                itemBuilder: (context, index) {
                  final item = itemsToShow[index];
                  return InkWell(
                    onTap: () {
                      // Use videoId from continue watching response, fallback to content vimeoId
                      String continueWatchingVideoId =
                          item.videoId.isNotEmpty ? item.videoId : '';

                      // If no videoId from continue watching, try to get from content
                      if (continueWatchingVideoId.isEmpty) {
                        // For series with episode, try to get episode vimeoId
                        if (item.contentType == 'series' &&
                            item.episodeId != null &&
                            item.content.episodes.isNotEmpty) {
                          final episode = item.content.episodes.firstWhere(
                            (ep) => ep.id == item.episodeId,
                            orElse: () => item.content.episodes.first,
                          );
                          continueWatchingVideoId = episode.vimeoId;
                        }

                        // Fallback to content's effective vimeoId
                        if (continueWatchingVideoId.isEmpty) {
                          continueWatchingVideoId =
                              item.content.effectiveVimeoId ?? '';
                        }
                      }

                      if (continueWatchingVideoId.isEmpty) {
                        // Fallback to details screen if no video available
                        if (item.contentType == 'movie') {
                          Get.toNamed(
                            '${AppRoutes.movieDetails}?id=${Uri.encodeComponent(item.contentId)}',
                          );
                        } else if (item.contentType == 'series') {
                          Get.toNamed(
                            '${AppRoutes.seriesDetails}?id=${Uri.encodeComponent(item.contentId)}',
                          );
                        } else if (item.contentType == 'song') {
                          Get.toNamed(
                            '${AppRoutes.songDetails}?id=${Uri.encodeComponent(item.contentId)}',
                          );
                        } else if (item.contentType == 'comingsoon') {
                          Get.toNamed(
                            '${AppRoutes.comingSoonDetails}?id=${Uri.encodeComponent(item.contentId)}',
                          );
                        }
                        return;
                      }

                      // Navigate directly to video player with saved duration as startTime
                      // Build route with episodeId for series
                      final routeParams =
                          'vimeoId=${Uri.encodeComponent(continueWatchingVideoId)}'
                          '&title=${Uri.encodeComponent(item.content.title)}'
                          '&contentId=${Uri.encodeComponent(item.contentId)}'
                          '&contentType=${item.contentType}'
                          '&startTime=${item.resumePoint}';

                      final finalRoute = item.episodeId != null &&
                              item.episodeId!.isNotEmpty
                          ? '$routeParams&episodeId=${Uri.encodeComponent(item.episodeId!)}'
                          : routeParams;

                      Get.toNamed('${AppRoutes.videoPlayer}?$finalRoute');
                    },
                    child: _buildContinueWatchingCard(item),
                  );
                },
              ),
            ),
            SizedBox(height: 10.h),
          ],
        );
      },
    );
  }

  Widget _buildContinueWatchingCard(ContinueWatchingModel item) {
    final posterUrl = item.content.poster ?? '';

    return Container(
      width: 190,
      margin: EdgeInsets.only(right: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 120,
                width: 190,
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
                  child: posterUrl.isNotEmpty
                      ? CustomImageView(
                          imageUrl: posterUrl,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(12.r),
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
          SizedBox(height: 6.h),
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
        ],
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

  Widget _buildMovieCard(MovieModel movie, {bool isSeries = false}) {
    return Container(
      width: isSeries ? 190 : 140,
      margin: EdgeInsets.only(right: 12.w),
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
          if (isSeries) SizedBox(height: 6.h),
          if (isSeries)
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
          if (movie.duration.isNotEmpty) SizedBox(height: 2.h),
          if (movie.duration.isNotEmpty)
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
