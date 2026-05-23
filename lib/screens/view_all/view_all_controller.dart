import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/model/model.dart';
import '../../data/repository/movie_repository.dart';
import '../../data/local/hive/hive_manager.dart';
import '../home/home_controller.dart';

class ViewAllController extends GetxController {
  final RxString selectedCategoryId = ''.obs; // Category ID, empty means "All"
  final RxString selectedType = 'Movie'.obs; // Movie, Series, Songs
  final RxString selectedLanguageId = ''.obs; // Language ID, empty means "All"
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final TextEditingController searchQueryController = TextEditingController();
  Timer? _searchDebounceTimer;
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;
  // Movies from API
  final RxList<MovieModel> movies = <MovieModel>[].obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalMovies = 0.obs;
  final ScrollController scrollController = ScrollController();

  final int limit = 10;
  final HiveManager hiveManager = Get.find(tag: (HiveManager).toString());

  // Get isForKids from Hive
  bool get isForKids =>
      hiveManager.getBool(HiveManager.isForKidsKey, defaultValue: false);

  // Get categories from HomeController
  List<CategoryModel> get categories {
    try {
      if (Get.isRegistered<HomeController>()) {
        final HomeController homeController = Get.find<HomeController>();
        return homeController.categories;
      }
    } catch (e) {
      // Return empty list if HomeController is not found or not initialized
    }
    return [];
  }

  // Get languages from HomeController
  List<CategoryModel> get languages {
    try {
      if (Get.isRegistered<HomeController>()) {
        final HomeController homeController = Get.find<HomeController>();
        return homeController.languages;
      }
    } catch (e) {
      // Return empty list if HomeController is not found or not initialized
    }
    return [];
  }

  List<MovieModel> get filteredMovies => movies;

  bool get hasMore => currentPage.value < totalPages.value;

  @override
  void onInit() {
    super.onInit();
    // Determine type from route or query
    final typeFromRoute = Get.parameters['type'];
    if (typeFromRoute != null) {
      final typeLower = typeFromRoute.toLowerCase();
      if (typeLower == 'series') {
        selectedType.value = 'Series';
      } else if (typeLower == 'songs') {
        selectedType.value = 'Songs';
      } else {
        selectedType.value = 'Movie';
      }
    } else {
      // Default to movies when not specified
      selectedType.value = 'Movie';
    }
    // Get category from parameters if passed (can be ID or name)
    final categoryFromParams = Get.parameters['category'];
    if (categoryFromParams != null && categoryFromParams.isNotEmpty) {
      final categoryName = Uri.decodeComponent(categoryFromParams);
      // Try to find category by name and get its ID
      final category = categories.firstWhereOrNull(
        (cat) => cat.name == categoryName,
      );
      if (category != null) {
        selectedCategoryId.value = category.id;
      }
    }
    // Get language from parameters if passed (can be ID)
    final languageFromParams = Get.parameters['language'];
    if (languageFromParams != null && languageFromParams.isNotEmpty) {
      selectedLanguageId.value = Uri.decodeComponent(languageFromParams);
    }
    // Get search query from parameters if passed
    final searchFromParams = Get.parameters['search'];
    if (searchFromParams != null && searchFromParams.isNotEmpty) {
      searchQueryController.text = Uri.decodeComponent(searchFromParams);
    }
    fetchMovies();
    // Setup scroll listener for pagination
    scrollController.addListener(_onScroll);
    // Listen to filter changes
    ever(selectedCategoryId, (_) => _onFilterChanged());
    ever(selectedType, (_) => _onFilterChanged());
    ever(selectedLanguageId, (_) => _onFilterChanged());
    // Add debounce listener to search query controller
    searchQueryController.addListener(_onSearchQueryChanged);
  }

  void _onSearchQueryChanged() {
    if (_isDisposed) return;
    // Cancel previous timer if it exists
    _searchDebounceTimer?.cancel();
    // Create a new timer with 500ms delay
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!_isDisposed) {
        _onFilterChanged();
      }
    });
  }

  @override
  void onClose() {
    _isDisposed = true;
    _searchDebounceTimer?.cancel();
    // Remove listener before disposing
    try {
      searchQueryController.removeListener(_onSearchQueryChanged);
    } catch (e) {
      // Listener might not be attached, ignore
    }
    // Note: We don't dispose TextEditingController here to avoid
    // "controller used after disposal" errors during widget deactivation.
    // The controller will be garbage collected when the controller is removed.
    // If you need to dispose it, do it after ensuring the widget is fully removed.
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.8) {
      if (hasMore && !isLoadingMore.value && !isLoading.value) {
        loadMoreMovies();
      }
    }
  }

  void _onFilterChanged() {
    currentPage.value = 1;
    movies.clear();
    fetchMovies();
  }

  Future<void> fetchMovies({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage.value = 1;
        movies.clear();
      }
      isLoading.value = true;

      final MovieRepository movieRepository = Get.find(
        tag: (MovieRepository).toString(),
      );

      // Get category ID if a category is selected (empty means "All")
      String? categoryId;
      if (selectedCategoryId.value.isNotEmpty) {
        categoryId = selectedCategoryId.value;
      }

      // Get language ID if a language is selected (empty means "All")
      String? languageId;
      if (selectedLanguageId.value.isNotEmpty) {
        languageId = selectedLanguageId.value;
      }

      String? searchText;
      try {
        if (!_isDisposed) {
          searchText = searchQueryController.text.isNotEmpty
              ? searchQueryController.text
              : null;
        }
      } catch (e) {
        searchText = null;
      }

      final bool isSeries = selectedType.value == 'Series';
      final bool isSongs = selectedType.value == 'Songs';

      final response = isSeries
          ? await movieRepository.getSeries(
              page: currentPage.value,
              limit: limit,
              search: searchText,
              categoryId: categoryId,
              languageId: languageId,
              isForKids: isForKids,
            )
          : isSongs
              ? await movieRepository.getSongs(
                  page: currentPage.value,
                  limit: limit,
                  search: searchText,
                  categoryId: categoryId,
                  languageId: languageId,
                  isForKids: isForKids,
                )
              : await movieRepository.getMovies(
                  page: currentPage.value,
                  limit: limit,
                  search: searchText,
                  categoryId: categoryId,
                  languageId: languageId,
                  isForKids: isForKids,
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

      // Get category ID if a category is selected (empty means "All")
      String? categoryId;
      if (selectedCategoryId.value.isNotEmpty) {
        categoryId = selectedCategoryId.value;
      }

      // Get language ID if a language is selected
      String? languageId;
      if (selectedLanguageId.value.isNotEmpty) {
        languageId = selectedLanguageId.value;
      }

      String? searchText;
      try {
        if (!_isDisposed) {
          searchText = searchQueryController.text.isNotEmpty
              ? searchQueryController.text
              : null;
        }
      } catch (e) {
        searchText = null;
      }

      final bool isSeries = selectedType.value == 'Series';
      final bool isSongs = selectedType.value == 'Songs';

      final response = isSeries
          ? await movieRepository.getSeries(
              page: currentPage.value,
              limit: limit,
              search: searchText,
              categoryId: categoryId,
              languageId: languageId,
              isForKids: isForKids,
            )
          : isSongs
              ? await movieRepository.getSongs(
                  page: currentPage.value,
                  limit: limit,
                  search: searchText,
                  categoryId: categoryId,
                  languageId: languageId,
                  isForKids: isForKids,
                )
              : await movieRepository.getMovies(
                  page: currentPage.value,
                  limit: limit,
                  search: searchText,
                  categoryId: categoryId,
                  languageId: languageId,
                  isForKids: isForKids,
                );

      movies.addAll(response.data);
      totalPages.value = response.pagination.pages;
      totalMovies.value = response.pagination.total;
    } catch (e) {
      // Error is already handled by ApiService
      currentPage.value--; // Revert page increment on error
    } finally {
      isLoadingMore.value = false;
    }
  }

  void updateSearchQuery(String query) {
    if (_isDisposed) return;
    try {
      searchQueryController.text = query;
    } catch (e) {
      // Controller might be disposed, ignore
    }
  }

  void clearFilters() {
    selectedCategoryId.value = '';
    selectedType.value = 'All';
    selectedLanguageId.value = '';
    if (!_isDisposed) {
      searchQueryController.text = '';
    }
  }

  void refreshMovies() {
    fetchMovies(isRefresh: true);
  }
}
