import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/model/model.dart';
import '../../data/repository/movie_repository.dart';
import '../../routes/app_pages.dart';

class FavoriteListController extends GetxController {
  final RxList<MovieModel> favoriteList = <MovieModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final ScrollController scrollController = ScrollController();

  final int limit = 10;

  // Map to store itemType for each favorite item (itemId -> itemType)
  final Map<String, String> favoriteItemTypes = <String, String>{};

  final MovieRepository _movieRepository = Get.find(
    tag: (MovieRepository).toString(),
  );

  bool get hasMore => currentPage.value < totalPages.value;

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.8) {
      if (hasMore && !isLoadingMore.value && !isLoading.value) {
        loadMoreFavorites();
      }
    }
  }

  Future<void> fetchFavorites({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage.value = 1;
        favoriteList.clear();
        favoriteItemTypes.clear();
      }
      isLoading.value = true;

      final response = await _movieRepository.getFavorites(
        page: currentPage.value,
        limit: limit,
      );

      // Fetch itemTypes for the current page
      final itemTypes = await _movieRepository.getFavoritesItemTypes(
        page: currentPage.value,
        limit: limit,
      );
      favoriteItemTypes.addAll(itemTypes);

      if (isRefresh || currentPage.value == 1) {
        favoriteList.value = response.data;
      } else {
        favoriteList.addAll(response.data);
      }

      currentPage.value = response.pagination.page;
      totalPages.value = response.pagination.pages;
    } catch (e) {
      // Error is already handled by ApiService
      if (favoriteList.isEmpty) {
        favoriteList.value = [];
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreFavorites() async {
    if (!hasMore || isLoadingMore.value || isLoading.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      final response = await _movieRepository.getFavorites(
        page: currentPage.value,
        limit: limit,
      );

      // Fetch itemTypes for the current page
      final itemTypes = await _movieRepository.getFavoritesItemTypes(
        page: currentPage.value,
        limit: limit,
      );
      favoriteItemTypes.addAll(itemTypes);

      favoriteList.addAll(response.data);
      totalPages.value = response.pagination.pages;
    } catch (e) {
      // Error is already handled by ApiService
      currentPage.value--; // Revert page increment on error
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> removeFromFavorites(String movieId) async {
    // Get itemType from stored map, default to 'movie' if not found
    final itemType = favoriteItemTypes[movieId] ?? 'movie';

    // Store the movie to restore if needed
    final movieToRemove =
        favoriteList.firstWhereOrNull((movie) => movie.id == movieId);

    try {
      // Optimistically remove from UI
      favoriteList.removeWhere((movie) => movie.id == movieId);
      favoriteItemTypes.remove(movieId);

      // Call toggle API with the itemType from response
      final newStatus =
          await _movieRepository.toggleFavorite(movieId, itemType);

      // If toggle didn't remove it (shouldn't happen, but handle edge case)
      if (newStatus && movieToRemove != null) {
        // Movie is still favorited, restore it locally
        favoriteList.add(movieToRemove);
        favoriteItemTypes[movieId] = itemType;
      }
    } catch (e) {
      // Revert on error - restore the movie locally
      if (movieToRemove != null) {
        favoriteList.add(movieToRemove);
        favoriteItemTypes[movieId] = itemType;
      }
      // Error is already handled by ApiService
    }
  }

  void navigateToDetails(MovieModel movie) {
    // Get itemType from stored map to determine correct route
    final itemType =
        favoriteItemTypes[movie.id]?.toLowerCase() ?? movie.type.toLowerCase();

    String route;
    if (itemType == 'song' || itemType == 'songs') {
      route = AppRoutes.songDetails;
    } else if (itemType == 'coming_soon' || itemType == 'coming-soon') {
      route = AppRoutes.comingSoonDetails;
    } else if (itemType == 'series' || movie.episodes.isNotEmpty) {
      route = AppRoutes.seriesDetails;
    } else {
      route = AppRoutes.movieDetails;
    }

    Get.toNamed(
      '$route?id=${Uri.encodeComponent(movie.id)}',
    );
  }

  void refreshFavorites() {
    fetchFavorites(isRefresh: true);
  }
}
