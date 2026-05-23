import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/core.dart';
import '../../core/controllers/user_subscription_controller.dart';
import '../../data/model/model.dart';
import '../../data/repository/movie_repository.dart';
import '../../network/error_handlers.dart';
import '../../routes/app_pages.dart';

class ComingSoonDetailsController extends GetxController {
  final Rx<MovieModel?> comingSoonDetail = Rx<MovieModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isFavorite = false.obs;
  final RxBool isInWatchlist = false.obs;
  final CarouselSliderController carouselController = CarouselSliderController();
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
    _loadComingSoonDetails();
  }

  Future<void> _loadComingSoonDetails() async {
    try {
      isLoading.value = true;
      final comingSoonId = Get.parameters['id'];

      if (comingSoonId == null || comingSoonId.isEmpty) {
        Utils.showToast('Coming Soon ID is missing');
        Get.back();
        return;
      }

      final comingSoon =
          await _movieRepository.getComingSoonDetails(comingSoonId);
      comingSoonDetail.value = comingSoon;

      // Use flags from details response
      isFavorite.value = comingSoon.isFavorite ?? false;
      isInWatchlist.value = comingSoon.isWatchListed ?? false;
    } catch (e) {
      logger.e(e);
      Utils.showToast('Failed to load coming soon details');
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavorite() async {
    if (comingSoonDetail.value == null) return;

    try {
      final previousValue = isFavorite.value;
      isFavorite.value = !previousValue;

      await _movieRepository.toggleFavorite(
          comingSoonDetail.value!.id, 'coming_soon');
    } catch (e) {
      isFavorite.value = !isFavorite.value;
      logger.e(e);
      Utils.showToast('Failed to update favorite');
    }
  }

  void shareComingSoon() {
    if (comingSoonDetail.value != null) {
      SharePlus.instance.share(
        ShareParams(
          text: 'Check out ${comingSoonDetail.value!.title}',
          subject: comingSoonDetail.value!.title,
        ),
      );
    }
  }

  void viewTrailer() {
    if (comingSoonDetail.value == null) return;

    final comingSoon = comingSoonDetail.value!;

    // Check for trailerId first, then trailer.vimeoId
    String? trailerVimeoId;
    if (comingSoon.trailerId != null && comingSoon.trailerId!.isNotEmpty) {
      trailerVimeoId = comingSoon.trailerId;
    } else if (comingSoon.trailer?.vimeoId != null &&
        comingSoon.trailer!.vimeoId!.isNotEmpty) {
      trailerVimeoId = comingSoon.trailer!.vimeoId;
    }

    if (trailerVimeoId == null || trailerVimeoId.isEmpty) {
      Utils.showToast('Trailer not available');
      return;
    }

    // Navigate to video player screen with trailer info
    Get.toNamed(
      '${AppRoutes.videoPlayer}?vimeoId=${Uri.encodeComponent(trailerVimeoId)}&title=${Uri.encodeComponent(comingSoon.title)}',
    );
  }

  void navigateToSubscription() {
    Get.toNamed(AppRoutes.subscription);
  }

  Future<void> toggleWatchlist() async {
    if (comingSoonDetail.value == null) return;

    try {
      final previousValue = isInWatchlist.value;
      isInWatchlist.value = !previousValue;

      await _movieRepository.toggleWatchlist(
          comingSoonDetail.value!.id, 'coming_soon');
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
