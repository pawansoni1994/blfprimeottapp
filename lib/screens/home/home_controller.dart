import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/core.dart';
import '../../core/controllers/user_subscription_controller.dart';
import '../../data/model/model.dart';
import '../../data/repository/banner_repository.dart';
import '../../data/repository/category_repository.dart';
import '../../data/repository/language_repository.dart';
import '../../data/repository/movie_repository.dart';
import '../../data/local/hive/hive_manager.dart';
import '../../network/error_handlers.dart';
import '../../routes/app_pages.dart';

class HomeController extends GetxController {
  final CarouselSliderController carouselController =
      CarouselSliderController();
  final RxInt currentBannerIndex = 0.obs;
  final RxString selectedGenre = 'All'.obs;

  // Categories from API
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoadingCategories = true.obs;

  // Languages from API
  final RxList<CategoryModel> languages = <CategoryModel>[].obs;
  final RxBool isLoadingLanguages = true.obs;
  final RxString selectedLanguage = ''.obs;

  // Banners from API
  final RxList<BannerModel> banners = <BannerModel>[].obs;
  final RxBool isLoadingBanners = true.obs;

  // Extra Banners from API
  final RxList<BannerModel> extraBanners = <BannerModel>[].obs;
  final RxBool isLoadingExtraBanners = false.obs;

  // Latest movies from API
  final RxList<MovieModel> latestMovies = <MovieModel>[].obs;
  final RxBool isLoadingLatestMovies =
      true.obs; // Start as true to show shimmer initially

  // Latest series from API
  final RxList<MovieModel> latestSeries = <MovieModel>[].obs;
  final RxBool isLoadingLatestSeries =
      true.obs; // Start as true to show shimmer initially

  // Latest songs from API
  final RxList<MovieModel> latestSongs = <MovieModel>[].obs;
  final RxBool isLoadingLatestSongs =
      true.obs; // Start as true to show shimmer initially

  // Category-wise movies (1st category)
  final RxList<MovieModel> categoryMovies = <MovieModel>[].obs;
  final RxBool isLoadingCategoryMovies = false.obs;
  final RxString categoryMoviesCategoryName = ''.obs;

  // Category-wise series (2nd category)
  final RxList<MovieModel> categorySeries = <MovieModel>[].obs;
  final RxBool isLoadingCategorySeries = false.obs;
  final RxString categorySeriesCategoryName = ''.obs;

  // Continue watching
  final RxList<ContinueWatchingModel> continueWatching =
      <ContinueWatchingModel>[].obs;
  final RxBool isLoadingContinueWatching = false.obs;

  final HiveManager hiveManager = Get.find(tag: (HiveManager).toString());
  final MovieRepository _movieRepository = Get.find(
    tag: (MovieRepository).toString(),
  );

  // User subscription controller - shared across the app
  late final UserSubscriptionController subscriptionController;

  // Get isForKids from Hive
  bool get isForKids =>
      hiveManager.getBool(HiveManager.isForKidsKey, defaultValue: false);

  // Genre chips - will be populated from categories
  List<String> get genres {
    final List<String> genreList = ['All'];
    genreList.addAll(categories.map((cat) => cat.name).toList());
    return genreList;
  }

  // Movies from API - will be populated when API is implemented
  final RxList<MovieModel> allMovies = <MovieModel>[].obs;

  List<MovieModel> get featuredMovies => allMovies.take(3).toList();
  List<MovieModel> get latestReleases => allMovies.take(6).toList();
  List<MovieModel> get series =>
      allMovies.where((m) => m.type == 'series').toList();
  List<MovieModel> get movies =>
      allMovies.where((m) => m.type == 'movie').toList();

  List<MovieModel> get filteredMovies {
    if (selectedGenre.value == 'All') {
      return allMovies.toList();
    }
    return allMovies.where((m) => m.genre == selectedGenre.value).toList();
  }

  void onBannerChanged(int index) {
    currentBannerIndex.value = index;
  }

  void selectGenre(String genre) {
    selectedGenre.value = genre;
  }

  void shareApp() {
    SharePlus.instance.share(
      ShareParams(
        text: 'Check out this amazing BLF Prime App!',
        subject: 'BLF Prime',
      ),
    );
  }

  Future<void> rateApp() async {
    const String appStoreUrl = 'https://apps.apple.com/app/id123456789'; // iOS
    const String playStoreUrl =
        'https://play.google.com/store/apps/details?id=com.example.app'; // Android

    final Uri url = Uri.parse(
      GetPlatform.isIOS ? appStoreUrl : playStoreUrl,
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Utils.showToast('Could not open app store');
    }
  }

  Future<void> openPrivacyPolicy() async {
    const String privacyPolicyUrl = 'https://example.com/privacy-policy';
    final Uri url = Uri.parse(privacyPolicyUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Utils.showToast('Could not open privacy policy');
    }
  }

  void openAbout() {
    // Navigate to about screen
    // Get.toNamed(AppRoutes.about);
    Utils.showToast('About screen coming soon');
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize and register subscription controller if not already registered
    if (!Get.isRegistered<UserSubscriptionController>()) {
      subscriptionController = Get.put(UserSubscriptionController());
    } else {
      subscriptionController = Get.find<UserSubscriptionController>();
    }
    // Load subscription status
    subscriptionController.loadSubscriptionStatus();

    fetchCategories();
    fetchLanguages();
    fetchBanners();
    fetchExtraBanners();
    fetchContinueWatching();
    fetchLatestMovies();
    fetchLatestSeries();
    fetchLatestSongs();
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh continue watching when screen becomes ready/visible
    fetchContinueWatching();
  }

  Future<void> fetchCategories() async {
    try {
      isLoadingCategories.value = true;
      final CategoryRepository categoryRepository = Get.find(
        tag: (CategoryRepository).toString(),
      );
      final fetchedCategories = await categoryRepository.getActiveCategories();
      categories.value = fetchedCategories;

      // After categories are fetched, fetch category-wise movies and series
      if (fetchedCategories.isNotEmpty) {
        // Fetch movies for 1st category
        if (fetchedCategories.isNotEmpty) {
          fetchCategoryMovies(fetchedCategories[1]);
        }
        // Fetch series for 2nd category
        if (fetchedCategories.length >= 2) {
          fetchCategorySeries(fetchedCategories[2]);
        }
      }
    } catch (e) {
      // Error is already handled by ApiService
      // Keep empty list on error
      categories.value = [];
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> fetchLanguages() async {
    try {
      isLoadingLanguages.value = true;
      final LanguageRepository languageRepository = Get.find(
        tag: (LanguageRepository).toString(),
      );
      final fetchedLanguages = await languageRepository.getLanguages();
      languages.value = fetchedLanguages;
    } catch (e) {
      // Error is already handled by ApiService
      // Keep empty list on error
      languages.value = [];
    } finally {
      isLoadingLanguages.value = false;
    }
  }

  void selectLanguage(CategoryModel language) {
    selectedLanguage.value = language.id;
    // Navigate to view all page with language filter
    Get.toNamed(
      '${AppRoutes.viewAll}?title=${Uri.encodeComponent(language.name)}&language=${Uri.encodeComponent(language.id)}',
    );
  }

  Future<void> fetchBanners() async {
    try {
      isLoadingBanners.value = true;
      final BannerRepository bannerRepository = Get.find(
        tag: (BannerRepository).toString(),
      );
      final fetchedBanners = await bannerRepository.getActiveBanners();
      banners.value = fetchedBanners;
    } catch (e) {
      // Error is already handled by ApiService
      // Keep empty list on error, fallback to static banners
      banners.value = [];
    } finally {
      isLoadingBanners.value = false;
    }
  }

  Future<void> fetchExtraBanners() async {
    try {
      isLoadingExtraBanners.value = true;
      final BannerRepository bannerRepository = Get.find(
        tag: (BannerRepository).toString(),
      );
      final fetchedExtraBanners = await bannerRepository.getExtraBanners();
      extraBanners.value = fetchedExtraBanners;
    } catch (e) {
      // Error is already handled by ApiService
      // Keep empty list on error
      extraBanners.value = [];
    } finally {
      isLoadingExtraBanners.value = false;
    }
  }

  void onBannerTap(BannerModel banner) {
    switch (banner.linkType) {
      case 'external':
        if (banner.externalUrl != null && banner.externalUrl!.isNotEmpty) {
          _launchExternalUrl(banner.externalUrl!);
        }
        break;
      case 'movie':
        if (banner.movieId != null && banner.movieId!.isNotEmpty) {
          Get.toNamed(
            '${AppRoutes.movieDetails}?id=${Uri.encodeComponent(banner.movieId!)}',
          );
        }
        break;
      case 'series':
        if (banner.movieId != null && banner.movieId!.isNotEmpty) {
          Get.toNamed(
            '${AppRoutes.seriesDetails}?id=${Uri.encodeComponent(banner.movieId!)}',
          );
        }
        break;
      case 'category':
        if (banner.categoryName != null && banner.categoryName!.isNotEmpty) {
          Get.toNamed(
            '${AppRoutes.viewAll}?title=${Uri.encodeComponent(banner.categoryName!)}&category=${Uri.encodeComponent(banner.categoryName!)}',
          );
        }
        break;
      case 'none':
      default:
        // Do nothing for 'none' type
        break;
    }
  }

  void onExtraBannerTap(BannerModel banner) {
    // Extra banners typically only have external links
    if (banner.linkType == 'external' &&
        banner.externalUrl != null &&
        banner.externalUrl!.isNotEmpty) {
      _launchExternalUrl(banner.externalUrl!);
    }
  }

  Future<void> addBannerToWatchlist(BannerModel banner) async {
    // Only add to watchlist if banner has a movieId (movie or series)
    if (banner.movieId == null || banner.movieId!.isEmpty) {
      Utils.showToast('Cannot add to watchlist');
      return;
    }

    try {
      await _movieRepository.toggleWatchlist(banner.movieId!, banner.linkType);
      Utils.showToast('Added to watchlist');
    } catch (e) {
      logger.e(e);
      Utils.showToast('Failed to update watchlist');
    }
  }

  Future<void> _launchExternalUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Utils.showToast('Could not open the link');
      }
    } catch (e) {
      Utils.showToast('Invalid URL');
    }
  }

  Future<void> fetchLatestMovies() async {
    try {
      isLoadingLatestMovies.value = true;
      final MovieRepository movieRepository = Get.find(
        tag: (MovieRepository).toString(),
      );
      final fetchedMovies =
          await movieRepository.getLatestMovies(isForKids: isForKids);
      latestMovies.value = fetchedMovies;
    } catch (e) {
      // Error is already handled by ApiService
      // Keep empty list on error
      latestMovies.value = [];
    } finally {
      isLoadingLatestMovies.value = false;
    }
  }

  Future<void> fetchLatestSeries() async {
    try {
      isLoadingLatestSeries.value = true;
      final MovieRepository movieRepository = Get.find(
        tag: (MovieRepository).toString(),
      );
      final fetchedSeries =
          await movieRepository.getLatestSeries(isForKids: isForKids);
      latestSeries.value = fetchedSeries;
    } catch (e) {
      // Error is already handled by ApiService
      // Keep empty list on error
      latestSeries.value = [];
    } finally {
      isLoadingLatestSeries.value = false;
    }
  }

  Future<void> fetchLatestSongs() async {
    try {
      isLoadingLatestSongs.value = true;
      final MovieRepository movieRepository = Get.find(
        tag: (MovieRepository).toString(),
      );
      final fetchedSongs =
          await movieRepository.getLatestSongs(isForKids: isForKids);
      latestSongs.value = fetchedSongs;
    } catch (e) {
      // Error is already handled by ApiService
      // Keep empty list on error
      latestSongs.value = [];
    } finally {
      isLoadingLatestSongs.value = false;
    }
  }

  void refreshMovies() {
    fetchContinueWatching();
    fetchLatestMovies();
    fetchLatestSeries();
    fetchLatestSongs();
    fetchExtraBanners();
  }

  Future<void> fetchContinueWatching() async {
    try {
      isLoadingContinueWatching.value = true;
      final items = await _movieRepository.getContinueWatching(limit: 10);
      continueWatching.value = items;
    } catch (e) {
      // Error is already handled by ApiService
      // Keep empty list on error
      continueWatching.value = [];
    } finally {
      isLoadingContinueWatching.value = false;
    }
  }

  void startVoiceSearch() {
    // This will be called from the UI to show the voice search dialog
  }

  void onVoiceSearchResult(String searchText) {
    // Navigate to view all page with search query
    if (searchText.isNotEmpty) {
      Get.toNamed(
        '${AppRoutes.viewAll}?title=${Uri.encodeComponent('Search Results')}&search=${Uri.encodeComponent(searchText)}',
      );
    }
  }

  Future<void> fetchCategoryMovies(CategoryModel category) async {
    try {
      isLoadingCategoryMovies.value = true;
      categoryMoviesCategoryName.value = category.name;
      final MovieRepository movieRepository = Get.find(
        tag: (MovieRepository).toString(),
      );
      final response = await movieRepository.getMovies(
        page: 1,
        limit: 8,
        categoryId: category.id,
        type: 'movie',
        isForKids: isForKids,
      );
      categoryMovies.value = response.data;
    } catch (e) {
      // Error is already handled by ApiService
      // Keep empty list on error
      categoryMovies.value = [];
    } finally {
      isLoadingCategoryMovies.value = false;
    }
  }

  Future<void> fetchCategorySeries(CategoryModel category) async {
    try {
      isLoadingCategorySeries.value = true;
      categorySeriesCategoryName.value = category.name;
      final MovieRepository movieRepository = Get.find(
        tag: (MovieRepository).toString(),
      );
      final response = await movieRepository.getSeries(
        page: 1,
        limit: 8,
        categoryId: category.id,
        isForKids: isForKids,
      );
      categorySeries.value = response.data;
    } catch (e) {
      // Error is already handled by ApiService
      // Keep empty list on error
      categorySeries.value = [];
    } finally {
      isLoadingCategorySeries.value = false;
    }
  }
}
