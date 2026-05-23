import '../../network/network.dart';
import '../model/model.dart';

/// Abstract class defining the contract for the subscription repository.
abstract class SubscriptionRepository {
  Future<SubscriptionPlanResponseModel> getSubscriptionPlans({
    int page = 1,
    int limit = 10,
  });
  Future<PurchaseSubscriptionResponseModel> purchaseSubscription({
    required String transactionId,
    required String subscriptionId,
  });
  Future<CancelSubscriptionResponseModel> cancelSubscription({
    required String subscriptionId,
  });
  Future<PurchaseSubscriptionResponseModel> upgradeSubscription({
    required String transactionId,
    required String subscriptionId,
  });
}

/// The concrete implementation of the SubscriptionRepository.
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final ApiService apiService;

  SubscriptionRepositoryImpl({required this.apiService});

  @override
  Future<SubscriptionPlanResponseModel> getSubscriptionPlans({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'page': page,
        'limit': limit,
      };

      final response = await apiService.get<SubscriptionPlanResponseModel>(
        endpoint: AppUrls.subscriptionPlans,
        queryParameters: queryParameters,
        fromJson: (json) => SubscriptionPlanResponseModel.fromJson(json),
        showLoading: false, // We'll handle loading in the controller
      );
      return response;
    } catch (e) {
      // The ApiService handles showing the error toast.
      // Rethrowing allows the UI layer to know the request failed.
      rethrow;
    }
  }

  @override
  Future<PurchaseSubscriptionResponseModel> purchaseSubscription({
    required String transactionId,
    required String subscriptionId,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'transactionId': transactionId,
        'subscriptionId': subscriptionId,
      };

      final response = await apiService.post<PurchaseSubscriptionResponseModel>(
        endpoint: AppUrls.purchaseSubscription,
        data: body,
        fromJson: (json) => PurchaseSubscriptionResponseModel.fromJson(json),
        showLoading: false, // We'll handle loading in the controller
      );
      return response;
    } catch (e) {
      // The ApiService handles showing the error toast.
      // Rethrowing allows the UI layer to know the request failed.
      rethrow;
    }
  }

  @override
  Future<CancelSubscriptionResponseModel> cancelSubscription({
    required String subscriptionId,
  }) async {
    try {
      final response = await apiService.post<CancelSubscriptionResponseModel>(
        endpoint: AppUrls.cancelSubscription,
        data: {'subscriptionId': subscriptionId},
        fromJson: (json) => CancelSubscriptionResponseModel.fromJson(json),
        showLoading: false, // We'll handle loading in the controller
      );
      return response;
    } catch (e) {
      // The ApiService handles showing the error toast.
      // Rethrowing allows the UI layer to know the request failed.
      rethrow;
    }
  }

  @override
  Future<PurchaseSubscriptionResponseModel> upgradeSubscription({
    required String transactionId,
    required String subscriptionId,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'transactionId': transactionId,
        'subscriptionId': subscriptionId,
      };

      final response = await apiService.post<PurchaseSubscriptionResponseModel>(
        endpoint: AppUrls.upgradeSubscription,
        data: body,
        fromJson: (json) => PurchaseSubscriptionResponseModel.fromJson(json),
        showLoading: false, // We'll handle loading in the controller
      );
      return response;
    } catch (e) {
      // The ApiService handles showing the error toast.
      // Rethrowing allows the UI layer to know the request failed.
      rethrow;
    }
  }
}

