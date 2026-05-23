import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/model/model.dart';
import '../../data/repository/movie_repository.dart';

class ComingSoonController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  
  // Movies from API
  final RxList<MovieModel> movies = <MovieModel>[].obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalMovies = 0.obs;
  final ScrollController scrollController = ScrollController();

  final int limit = 10;

  List<MovieModel> get filteredMovies => movies;

  bool get hasMore => currentPage.value < totalPages.value;

  @override
  void onInit() {
    super.onInit();
    fetchComingSoon();
    // Setup scroll listener for pagination
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.8) {
      if (hasMore && !isLoadingMore.value && !isLoading.value) {
        loadMoreMovies();
      }
    }
  }

  Future<void> fetchComingSoon({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage.value = 1;
        movies.clear();
      }
      isLoading.value = true;

      final MovieRepository movieRepository = Get.find(
        tag: (MovieRepository).toString(),
      );

      final response = await movieRepository.getComingSoon(
        page: currentPage.value,
        limit: limit,
      );

      if (isRefresh || currentPage.value == 1) {
        movies.value = response.data;
      } else {
        movies.addAll(response.data);
      }

      currentPage.value = response.pagination.page;
      totalPages.value = response.pagination.pages;
      totalMovies.value = response.pagination.total;
    } catch (e) {
      // Error is already handled by ApiService
      if (movies.isEmpty) {
        movies.value = [];
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreMovies() async {
    if (!hasMore || isLoadingMore.value || isLoading.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      final MovieRepository movieRepository = Get.find(
        tag: (MovieRepository).toString(),
      );

      final response = await movieRepository.getComingSoon(
        page: currentPage.value,
        limit: limit,
      );

      movies.addAll(response.data);

      currentPage.value = response.pagination.page;
      totalPages.value = response.pagination.pages;
      totalMovies.value = response.pagination.total;
    } catch (e) {
      // Error is already handled by ApiService
      // Revert page increment on error
      currentPage.value--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}

