import 'package:get/get.dart';
import '../../data/model/model.dart';
import '../../data/repository/audition_repository.dart';

class AuditionListController extends GetxController {
  final RxList<AuditionModel> auditionList = <AuditionModel>[].obs;
  final RxBool isLoading = false.obs;

  final AuditionRepository _auditionRepository = Get.find(
    tag: (AuditionRepository).toString(),
  );

  @override
  void onInit() {
    super.onInit();
    fetchAuditions();
  }

  Future<void> fetchAuditions({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        auditionList.clear();
      }
      isLoading.value = true;

      final auditions = await _auditionRepository.getAuditions();
      auditionList.value = auditions;
    } catch (e) {
      // Error is already handled by ApiService
      if (auditionList.isEmpty) {
        auditionList.value = [];
      }
    } finally {
      isLoading.value = false;
    }
  }

  void refreshAuditions() {
    fetchAuditions(isRefresh: true);
  }
}

