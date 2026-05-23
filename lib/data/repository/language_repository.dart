import '../../network/network.dart';
import '../model/model.dart';

/// Abstract class defining the contract for the language repository.
abstract class LanguageRepository {
  Future<List<CategoryModel>> getLanguages();
}

/// The concrete implementation of the LanguageRepository.
class LanguageRepositoryImpl implements LanguageRepository {
  final ApiService apiService;

  LanguageRepositoryImpl({required this.apiService});

  @override
  Future<List<CategoryModel>> getLanguages() async {
    try {
      final response = await apiService.get<CategoryResponseModel>(
        endpoint: AppUrls.languages,
        fromJson: (json) => CategoryResponseModel.fromJson(json),
        showLoading: false, // We'll handle loading in the controller
      );
      return response.data;
    } catch (e) {
      // The ApiService handles showing the error toast.
      // Rethrowing allows the UI layer to know the request failed.
      rethrow;
    }
  }
}

