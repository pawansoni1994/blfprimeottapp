import 'package:get/get.dart';
import '../data/local/hive/hive_manager.dart';
import '../data/repository/auth_repository.dart';
import '../data/repository/audition_repository.dart';
import '../data/repository/banner_repository.dart';
import '../data/repository/category_repository.dart';
import '../data/repository/language_repository.dart';
import '../data/repository/movie_repository.dart';
import '../data/repository/subscription_repository.dart';
import '../network/network.dart';

class RepositoryBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        hiveManager: Get.find(tag: (HiveManager).toString()),
        apiService: Get.find(tag: (ApiService).toString()),
      ),
      tag: (AuthRepository).toString(),
      fenix: true,
    );
    Get.lazyPut<CategoryRepository>(
      () => CategoryRepositoryImpl(
        apiService: Get.find(tag: (ApiService).toString()),
      ),
      tag: (CategoryRepository).toString(),
      fenix: true,
    );
    Get.lazyPut<LanguageRepository>(
      () => LanguageRepositoryImpl(
        apiService: Get.find(tag: (ApiService).toString()),
      ),
      tag: (LanguageRepository).toString(),
      fenix: true,
    );
    Get.lazyPut<MovieRepository>(
      () => MovieRepositoryImpl(
        apiService: Get.find(tag: (ApiService).toString()),
      ),
      tag: (MovieRepository).toString(),
      fenix: true,
    );
    Get.lazyPut<SubscriptionRepository>(
      () => SubscriptionRepositoryImpl(
        apiService: Get.find(tag: (ApiService).toString()),
      ),
      tag: (SubscriptionRepository).toString(),
      fenix: true,
    );
    Get.lazyPut<AuditionRepository>(
      () => AuditionRepositoryImpl(
        apiService: Get.find(tag: (ApiService).toString()),
      ),
      tag: (AuditionRepository).toString(),
      fenix: true,
    );
    Get.lazyPut<BannerRepository>(
      () => BannerRepositoryImpl(
        apiService: Get.find(tag: (ApiService).toString()),
      ),
      tag: (BannerRepository).toString(),
      fenix: true,
    );
  }
}
