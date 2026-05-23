import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/core.dart';
import '../../core/controllers/user_subscription_controller.dart';
import '../../data/model/model.dart';
import '../../data/repository/movie_repository.dart';
import '../../network/error_handlers.dart';
import '../../routes/app_pages.dart';

class SongDetailsController extends GetxController {
  final Rx<MovieModel?> songDetail = Rx<MovieModel?>(null);
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
    _loadSongDetails();
  }

  Future<void> _loadSongDetails() async {
    try {
      isLoading.value = true;
      final songId = Get.parameters['id'];

      if (songId == null || songId.isEmpty) {
        Utils.showToast('Song ID is missing');
        Get.back();
        return;
      }

      final song = await _movieRepository.getSongDetails(songId);
      songDetail.value = song;

      // Use flags from details response
      isFavorite.value = song.isFavorite ?? false;
      isInWatchlist.value = song.isWatchListed ?? false;
    } catch (e) {
      logger.e(e);
      Utils.showToast('Failed to load song details');
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavorite() async {
    if (songDetail.value == null) return;

    try {
      final previousValue = isFavorite.value;
      isFavorite.value = !previousValue;

      await _movieRepository.toggleFavorite(songDetail.value!.id, 'song');
    } catch (e) {
      isFavorite.value = !isFavorite.value;
      logger.e(e);
      Utils.showToast('Failed to update favorite');
    }
  }

  void shareSong() {
    if (songDetail.value != null) {
      SharePlus.instance.share(
        ShareParams(
          text: 'Check out ${songDetail.value!.title}',
          subject: songDetail.value!.title,
        ),
      );
    }
  }

  void purchaseMovie() async {
    if (songDetail.value == null) return;

    bool response = await _movieRepository.purchaseMovie(songDetail.value!.id,
        "song", "${DateTime.now()}", songDetail.value!.buyPrice.toString());
    songDetail.value?.isPurchased = response;
    update();
  }

  void playSong() {
    if (songDetail.value == null) return;

    // Check if premium and user doesn't have subscription
    if (songDetail.value?.type == ContentType.subscription &&
        !hasSubscription) {
      navigateToSubscription();
      return;
    }

    // Use effectiveVimeoId which checks both direct vimeoId and source.vimeoId
    final vimeoId = songDetail.value!.effectiveVimeoId;
    if (vimeoId == null || vimeoId.isEmpty) {
      Utils.showToast('Song video not available');
      return;
    }

    // Call continue watching API
    _movieRepository
        .startContinueWatching(
      songDetail.value!.id,
      'song',
    )
        .catchError((e) {
      // Silently handle error - don't interrupt playback
      logger.e('Failed to start continue watching: $e');
    });

    // Navigate to video player screen with video source
    Get.toNamed(
      '${AppRoutes.videoPlayer}?vimeoId=${Uri.encodeComponent(vimeoId)}&title=${Uri.encodeComponent(songDetail.value!.title)}&contentId=${Uri.encodeComponent(songDetail.value!.id)}&contentType=song',
    );
  }

  void navigateToSubscription() {
    Get.toNamed(AppRoutes.subscription);
  }

  void viewTrailer() {
    if (songDetail.value == null) return;

    final song = songDetail.value!;

    // Check for trailerId first, then trailer.vimeoId
    String? trailerVimeoId;
    if (song.trailerId != null && song.trailerId!.isNotEmpty) {
      trailerVimeoId = song.trailerId;
    } else if (song.trailer?.vimeoId != null &&
        song.trailer!.vimeoId!.isNotEmpty) {
      trailerVimeoId = song.trailer!.vimeoId;
    }

    if (trailerVimeoId == null || trailerVimeoId.isEmpty) {
      Utils.showToast('Trailer not available');
      return;
    }

    // Navigate to video player screen with trailer info
    Get.toNamed(
      '${AppRoutes.videoPlayer}?vimeoId=${Uri.encodeComponent(trailerVimeoId)}&title=${Uri.encodeComponent(song.title)}',
    );
  }

  Future<void> toggleWatchlist() async {
    if (songDetail.value == null) return;

    try {
      final previousValue = isInWatchlist.value;
      isInWatchlist.value = !previousValue;

      await _movieRepository.toggleWatchlist(songDetail.value!.id, 'song');
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
