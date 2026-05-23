import '../../network/network.dart';
import '../model/model.dart';

/// Abstract class defining the contract for the audition repository.
abstract class AuditionRepository {
  Future<Map<String, dynamic>> submitAudition({
    required String name,
    required String city,
    required int age,
    required String intro,
    required String socialProfileUrl,
    required String auditionUrl,
    required String message,
  });
  Future<List<AuditionModel>> getAuditions();
  Future<bool> checkAuditionUploaded();
}

/// The concrete implementation of the AuditionRepository.
class AuditionRepositoryImpl implements AuditionRepository {
  final ApiService apiService;

  AuditionRepositoryImpl({required this.apiService});

  @override
  Future<Map<String, dynamic>> submitAudition({
    required String name,
    required String city,
    required int age,
    required String intro,
    required String socialProfileUrl,
    required String auditionUrl,
    required String message,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'name': name,
        'city': city,
        'age': age,
        'intro': intro,
        'socialProfileUrl': socialProfileUrl,
        'auditionUrl': auditionUrl,
        'message': message,
        'status': 'active',
      };

      final response = await apiService.post<Map<String, dynamic>>(
        endpoint: AppUrls.audition,
        data: body,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      return response;
    } catch (e) {
      // The ApiService handles showing the error toast.
      // Rethrowing allows the UI layer to know the request failed.
      rethrow;
    }
  }

  @override
  Future<List<AuditionModel>> getAuditions() async {
    try {
      // The API might return a list directly or wrapped in a response
      final response = await apiService.get<dynamic>(
        endpoint: AppUrls.audition,
        fromJson: (json) => json, // Get raw response
        showLoading: false,
      );

      // Handle different response formats
      if (response is List) {
        // If response is a list directly
        return response
            .map((item) => AuditionModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response is Map<String, dynamic>) {
        // If response is wrapped in an object
        if (response['data'] != null && response['data'] is List) {
          final dataList = response['data'] as List;
          return dataList
              .map((item) =>
                  AuditionModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (response['success'] != null) {
          // Try AuditionListResponseModel format
          final model = AuditionListResponseModel.fromJson(response);
          return model.data;
        }
      }

      // Fallback: return empty list
      return [];
    } catch (e) {
      // The ApiService handles showing the error toast.
      // Rethrowing allows the UI layer to know the request failed.
      rethrow;
    }
  }

  @override
  Future<bool> checkAuditionUploaded() async {
    try {
      // The API might return a list directly or wrapped in a response
      final response = await apiService.post<dynamic>(
        endpoint: AppUrls.checkAuditionUploaded,
        fromJson: (json) => json, // Get raw response
        showLoading: true,
      );

      // Handle different response formats
      if (response is Map<String, dynamic>) {
        // If response is wrapped in an object
        if (response['data'] != null && response['data'] is bool) {
          return response['data'] as bool;
        }
      }

      // Fallback: return empty list
      return false;
    } catch (e) {
      // The ApiService handles showing the error toast.
      // Rethrowing allows the UI layer to know the request failed.
      rethrow;
    }
  }
}
