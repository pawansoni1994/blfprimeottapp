import 'package:get/get.dart';
import '../../core/core.dart';
import '../../data/model/model.dart';
import '../../data/repository/movie_repository.dart';
import '../../routes/app_pages.dart';

class ContinueWatchingViewAllController extends GetxController {
  final MovieRepository _movieRepository = Get.find(
    tag: (MovieRepository).toString(),
  );

  final RxList<ContinueWatchingModel> continueWatching = <ContinueWatchingModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final RxInt totalItems = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchContinueWatching();
  }

  Future<void> fetchContinueWatching({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage.value = 1;
        hasMore.value = true;
        isLoading.value = true;
      } else {
        isLoading.value = true;
      }

      final response = await _movieRepository.getContinueWatchingPaginated(
        page: currentPage.value,
        limit: 20,
      );

      if (isRefresh) {
        continueWatching.value = response.data;
      } else {
        continueWatching.addAll(response.data);
      }

      if (response.pagination != null) {
        hasMore.value = response.pagination!.hasMore;
        totalItems.value = response.pagination!.total;
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      // Error is already handled by ApiService
      if (isRefresh) {
        continueWatching.value = [];
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) {
      return;
    }

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      final response = await _movieRepository.getContinueWatchingPaginated(
        page: currentPage.value,
        limit: 20,
      );

      continueWatching.addAll(response.data);

      if (response.pagination != null) {
        hasMore.value = response.pagination!.hasMore;
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      // Error is already handled by ApiService
      currentPage.value--; // Revert page on error
    } finally {
      isLoadingMore.value = false;
    }
  }

  void navigateToVideo(ContinueWatchingModel item) {
    // Use videoId from continue watching response
    String videoId = item.videoId.isNotEmpty ? item.videoId : '';

    // If no videoId from continue watching, try to get from content
    if (videoId.isEmpty) {
      // For series with episode, try to get episode vimeoId
      if (item.contentType == 'series' &&
          item.episodeId != null &&
          item.content.episodes.isNotEmpty) {
        final episode = item.content.episodes.firstWhere(
          (ep) => ep.id == item.episodeId,
          orElse: () => item.content.episodes.first,
        );
        videoId = episode.vimeoId.isNotEmpty ? episode.vimeoId : '';
      } else {
        // For movies or series without episode, use content vimeoId
        videoId = item.content.effectiveVimeoId ?? '';
      }
    }

    if (videoId.isEmpty) {
      Utils.showToast('Video not available');
      return;
    }

    // Navigate to video player with resume point
    Get.toNamed(
      '${AppRoutes.videoPlayer}?'
      'vimeoId=${Uri.encodeComponent(videoId)}&'
      'contentId=${Uri.encodeComponent(item.contentId)}&'
      'contentType=${Uri.encodeComponent(item.contentType)}&'
      'startTime=${item.resumePoint}'
      '${item.episodeId != null ? '&episodeId=${Uri.encodeComponent(item.episodeId!)}' : ''}',
    );
  }

  void refreshContinueWatching() {
    fetchContinueWatching(isRefresh: true);
  }
}

