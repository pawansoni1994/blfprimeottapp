import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/core.dart';
import '../../core/controllers/user_subscription_controller.dart';
import '../../data/model/model.dart';
import '../../data/repository/movie_repository.dart';
import '../../network/error_handlers.dart';
import '../../routes/app_pages.dart';

class SeriesDetailsController extends GetxController {
  final Rx<MovieModel?> seriesDetail = Rx<MovieModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isFavorite = false.obs;
  final RxBool isInWatchlist = false.obs;
  final CarouselSliderController carouselController =
      CarouselSliderController();
  final RxInt currentImageIndex = 0.obs;

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
    _loadSeriesDetails();
  }

  Future<void> _loadSeriesDetails() async {
    try {
      isLoading.value = true;
      final movieId = Get.parameters['id'];

      if (movieId == null || movieId.isEmpty) {
        Utils.showToast('Series ID is missing');
        Get.back();
        return;
      }

      final series = await _movieRepository.getSeriesDetails(movieId);
      seriesDetail.value = series;

      // Use flags from details response
      isFavorite.value = series.isFavorite ?? false;
      isInWatchlist.value = series.isWatchListed ?? false;
    } catch (e) {
      logger.e(e);
      Utils.showToast('Failed to load series details');
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavorite() async {
    if (seriesDetail.value == null) return;

    try {
      final previousValue = isFavorite.value;
      isFavorite.value = !previousValue;

      await _movieRepository.toggleFavorite(seriesDetail.value!.id, 'series');
    } catch (e) {
      isFavorite.value = !isFavorite.value;
      logger.e(e);
      Utils.showToast('Failed to update favorite');
    }
  }

  void shareSeries() {
    if (seriesDetail.value != null) {
      SharePlus.instance.share(
        ShareParams(
          text: 'Check out ${seriesDetail.value!.title}',
          subject: seriesDetail.value!.title,
        ),
      );
    }
  }

  void viewTrailer() {
    if (seriesDetail.value == null) return;

    final series = seriesDetail.value!;

    // Check for trailerId first, then trailer.vimeoId
    String? trailerVimeoId;
    if (series.trailerId != null && series.trailerId!.isNotEmpty) {
      trailerVimeoId = series.trailerId;
    } else if (series.trailer?.vimeoId != null &&
        series.trailer!.vimeoId!.isNotEmpty) {
      trailerVimeoId = series.trailer!.vimeoId;
    }

    if (trailerVimeoId == null || trailerVimeoId.isEmpty) {
      Utils.showToast('Trailer not available');
      return;
    }

    // Navigate to video player screen with trailer info
    Get.toNamed(
      '${AppRoutes.videoPlayer}?vimeoId=${Uri.encodeComponent(trailerVimeoId)}&title=${Uri.encodeComponent(series.title)}',
    );
  }

  void purchaseMovie() async {
    if (seriesDetail.value == null) return;

    bool response = await _movieRepository.purchaseMovie(seriesDetail.value!.id,
        "series", "${DateTime.now()}", seriesDetail.value!.buyPrice.toString());
    seriesDetail.value?.isPurchased = response;
    update();
  }

  void playEpisode(MovieEpisode episode) {
    if (seriesDetail.value == null) return;

    // Check if premium and user doesn't have subscription
    if (seriesDetail.value?.type == ContentType.subscription &&
        !hasSubscription) {
      navigateToSubscription();
      return;
    }

    if (seriesDetail.value?.type == ContentType.buy &&
        !seriesDetail.value!.isPurchased) {
      _movieRepository.purchaseMovie(seriesDetail.value!.id, "series",
          "${DateTime.now()}", seriesDetail.value!.buyPrice.toString());
    }

    // Check if episode has vimeoId
    if (episode.vimeoId.isEmpty) {
      Utils.showToast('Episode video not available');
      return;
    }

    // Call continue watching API
    _movieRepository
        .startContinueWatching(
      seriesDetail.value!.id,
      'series',
      episodeId: episode.id,
    )
        .catchError((e) {
      // Silently handle error - don't interrupt playback
      logger.e('Failed to start continue watching: $e');
    });

    Get.toNamed(
      '${AppRoutes.videoPlayer}?vimeoId=${Uri.encodeComponent(episode.vimeoId)}&title=${Uri.encodeComponent('${seriesDetail.value!.title} - ${episode.title}')}&contentId=${Uri.encodeComponent(seriesDetail.value!.id)}&contentType=series&episodeId=${Uri.encodeComponent(episode.id)}',
    );
  }

  void navigateToSubscription() {
    Get.toNamed(AppRoutes.subscription);
  }

  Future<void> toggleWatchlist() async {
    if (seriesDetail.value == null) return;

    try {
      final previousValue = isInWatchlist.value;
      isInWatchlist.value = !previousValue;

      await _movieRepository.toggleWatchlist(seriesDetail.value!.id, 'series');
    } catch (e) {
      isInWatchlist.value = !isInWatchlist.value;
      logger.e(e);
      Utils.showToast('Failed to update watchlist');
    }
  }

  void onImageChanged(int index) {
    currentImageIndex.value = index;
  }
}
