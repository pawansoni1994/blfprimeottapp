import '../../network/network.dart';
import '../model/model.dart';

/// Abstract class defining the contract for the category repository.
abstract class CategoryRepository {
  Future<List<CategoryModel>> getActiveCategories();
}

/// The concrete implementation of the CategoryRepository.
class CategoryRepositoryImpl implements CategoryRepository {
  final ApiService apiService;

  CategoryRepositoryImpl({required this.apiService});

  @override
  Future<List<CategoryModel>> getActiveCategories() async {
    try {
      final response = await apiService.get<CategoryResponseModel>(
        endpoint: AppUrls.categories,
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

