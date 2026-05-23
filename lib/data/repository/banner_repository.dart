import '../../network/network.dart';
import '../model/model.dart';

/// Abstract class defining the contract for the banner repository.
abstract class BannerRepository {
  Future<List<BannerModel>> getActiveBanners();
  Future<List<BannerModel>> getExtraBanners();
}

/// The concrete implementation of the BannerRepository.
class BannerRepositoryImpl implements BannerRepository {
  final ApiService apiService;

  BannerRepositoryImpl({required this.apiService});

  @override
  Future<List<BannerModel>> getActiveBanners() async {
    try {
      final response = await apiService.get<BannerResponseModel>(
        endpoint: AppUrls.banners,
        fromJson: (json) => BannerResponseModel.fromJson(json),
        showLoading: false, // We'll handle loading in the controller
      );
      // Filter banners by position 'home' and sort by order
      final homeBanners = response.data
          .where((banner) => banner.position == 'home')
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      return homeBanners;
    } catch (e) {
      // The ApiService handles showing the error toast.
      // Rethrowing allows the UI layer to know the request failed.
      rethrow;
    }
  }

  @override
  Future<List<BannerModel>> getExtraBanners() async {
    try {
      final response = await apiService.get<BannerResponseModel>(
        endpoint: AppUrls.extraBanners,
        fromJson: (json) => BannerResponseModel.fromJson(json),
        showLoading: false, // We'll handle loading in the controller
      );
      // Sort by order
      final sortedBanners = response.data.toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      return sortedBanners;
    } catch (e) {
      // The ApiService handles showing the error toast.
      // Rethrowing allows the UI layer to know the request failed.
      rethrow;
    }
  }
}

