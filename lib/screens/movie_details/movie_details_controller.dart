import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/core.dart';
import '../../core/controllers/user_subscription_controller.dart';
import '../../data/model/model.dart';
import '../../data/repository/movie_repository.dart';
import '../../network/error_handlers.dart';
import '../../routes/app_pages.dart';

class MovieDetailsController extends GetxController {
  final Rx<MovieModel?> movieDetail = Rx<MovieModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isFavorite = false.obs;
  final RxBool isInWatchlist = false.obs;
  final CarouselSliderController carouselController =
      CarouselSliderController();
  final RxInt currentImageIndex = 0.obs;

  // Similar movies - will be populated from API
  final RxList<MovieModel> similarMovies = <MovieModel>[].obs;

  final MovieRepository _movieRepository = Get.find(
    tag: (MovieRepository).toString(),
  );

  // Get subscription status from shared controller
  bool get hasSubscription {
    if (Get.isRegistered<UserSubscriptionController>()) {
      return Get.find<UserSubscriptionController>().hasSubscription.value;
    }
    return false;
  }

  @override
  void onInit() {
    super.onInit();
    _loadMovieDetails();
  }

  Future<void> _loadMovieDetails() async {
    try {
      isLoading.value = true;
      final movieId = Get.parameters['id'];

      if (movieId == null || movieId.isEmpty) {
        Utils.showToast('Movie ID is missing');
        Get.back();
        return;
      }

      final movie = await _movieRepository.getMovieDetails(movieId);
      movieDetail.value = movie;
      similarMovies.value = [];

      // Use flags from details response
      isFavorite.value = movie.isFavorite ?? false;
      isInWatchlist.value = movie.isWatchListed ?? false;
    } catch (e) {
      logger.e(e);
      Utils.showToast('Failed to load movie details');
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavorite() async {
    if (movieDetail.value == null) return;

    try {
      // Optimistically update UI
      final previousValue = isFavorite.value;
      isFavorite.value = !previousValue;

      // Call toggle API
      _movieRepository.toggleFavorite(movieDetail.value!.id, 'movie');
    } catch (e) {
      // Revert on error
      isFavorite.value = !isFavorite.value;
      logger.e(e);
      Utils.showToast('Failed to update favorite');
    }
  }

  void shareMovie() {
    if (movieDetail.value != null) {
      SharePlus.instance.share(
        ShareParams(
          text: 'Check out ${movieDetail.value!.title}',
          subject: movieDetail.value!.title,
        ),
      );
    }
  }

  void playMovie() {
    if (movieDetail.value == null) return;

    // Check if premium and user doesn't have subscription
    if (movieDetail.value?.type == ContentType.subscription &&
        !hasSubscription) {
      navigateToSubscription();
      return;
    }

    // Use effectiveVimeoId which checks both direct vimeoId and source.vimeoId
    final vimeoId = movieDetail.value!.effectiveVimeoId;
    if (vimeoId == null || vimeoId.isEmpty) {
      Utils.showToast('Video not available');
      return;
    }

    // Call continue watching API
    _movieRepository
        .startContinueWatching(
      movieDetail.value!.id,
      'movie',
    )
        .catchError((e) {
      // Silently handle error - don't interrupt playback
      logger.e('Failed to start continue watching: $e');
    });

    // Navigate to video player screen with video source
    Get.toNamed(
      '${AppRoutes.videoPlayer}?vimeoId=${Uri.encodeComponent(vimeoId)}&title=${Uri.encodeComponent(movieDetail.value!.title)}&contentId=${Uri.encodeComponent(movieDetail.value!.id)}&contentType=movie',
    );
  }

  void navigateToSubscription() {
    Get.toNamed(AppRoutes.subscription);
  }

  void purchaseMovie() async {
    if (movieDetail.value == null) return;

    bool response = await _movieRepository.purchaseMovie(movieDetail.value!.id,
        "movie", "${DateTime.now()}", movieDetail.value!.buyPrice.toString());
    movieDetail.value?.isPurchased = response;
    update();
  }

  void viewTrailer() {
    if (movieDetail.value == null) return;

    final movie = movieDetail.value!;

    // Check for trailerId first, then trailer.vimeoId
    String? trailerVimeoId;
    if (movie.trailerId != null && movie.trailerId!.isNotEmpty) {
      trailerVimeoId = movie.trailerId;
    } else if (movie.trailer?.vimeoId != null &&
        movie.trailer!.vimeoId!.isNotEmpty) {
      trailerVimeoId = movie.trailer!.vimeoId;
    }

    if (trailerVimeoId == null || trailerVimeoId.isEmpty) {
      Utils.showToast('Trailer not available');
      return;
    }

    // Navigate to video player screen with trailer info
    Get.toNamed(
      '${AppRoutes.videoPlayer}?vimeoId=${Uri.encodeComponent(trailerVimeoId)}&title=${Uri.encodeComponent(movie.title)}',
    );
  }

  Future<void> toggleWatchlist() async {
    if (movieDetail.value == null) return;

    try {
      // Optimistically update UI
      final previousValue = isInWatchlist.value;
      isInWatchlist.value = !previousValue;

      // Call toggle API
      await _movieRepository.toggleWatchlist(movieDetail.value!.id, 'movie');
    } catch (e) {
      // Revert on error
      isInWatchlist.value = !isInWatchlist.value;
      logger.e(e);
      Utils.showToast('Failed to update watchlist');
    }
  }

  void onImageChanged(int index) {
    currentImageIndex.value = index;
  }
}
