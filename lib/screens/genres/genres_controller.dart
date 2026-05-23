import 'package:get/get.dart';
import '../../data/model/model.dart';
import '../../data/repository/category_repository.dart';
import '../../routes/app_pages.dart';

class GenresController extends GetxController {
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoading = true.obs;

  final CategoryRepository categoryRepository = Get.find(
    tag: (CategoryRepository).toString(),
  );

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final fetchedCategories = await categoryRepository.getActiveCategories();
      categories.value = fetchedCategories;
    } catch (e) {
      // Error is already handled by ApiService
      categories.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void onCategoryTap(CategoryModel category) {
    // Navigate to view all page with selected category
    Get.toNamed(
      '${AppRoutes.viewAll}?title=${Uri.encodeComponent(category.name)}&category=${Uri.encodeComponent(category.name)}',
    );
  }

  Future<void> refreshCategories() async {
    await fetchCategories();
  }
}

