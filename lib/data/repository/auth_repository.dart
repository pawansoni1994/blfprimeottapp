import '../../network/network.dart';
import '../local/hive/hive_manager.dart';
import '../model/model.dart';

/// Abstract class defining the contract for the authentication repository.
abstract class AuthRepository {
  Future<UserModel> login(Map<String, dynamic> body);
  Future<UserModel> register(Map<String, dynamic> body);
  Future<bool> forgotPassword(Map<String, dynamic> body);
  Future<bool> changePassword(Map<String, dynamic> body);
  Future<bool> sendOtp(Map<String, dynamic> body);
  Future<bool> verifyOtp(Map<String, dynamic> body);
  Future<UserModel> updateProfile(String userId, dynamic formData);
  Future<bool> resetPassword(Map<String, dynamic> body);
  Future<ProfileResponseModel> getProfile();
}

/// The concrete implementation of the AuthRepository.
/// It uses the modern ApiService for all network calls and HiveManager for local storage.
class AuthRepositoryImpl implements AuthRepository {
  final HiveManager hiveManager;
  final ApiService apiService;

  AuthRepositoryImpl({required this.hiveManager, required this.apiService});

  /// Handles saving user data and token to Hive after a successful login or registration.
  void _persistUserData(String token, UserModel user) {
    hiveManager.setString(HiveManager.tokenKey, token);
    hiveManager.setString(HiveManager.userIdKey, user.id.toString());
    hiveManager.setString(HiveManager.emailKey, user.email);
    hiveManager.setString(HiveManager.phoneKey, user.phone);
    hiveManager.setString(HiveManager.fullNameKey, user.fullName);
    hiveManager.setString(HiveManager.profileKey, user.profile ?? '');
  }

  @override
  Future<UserModel> login(Map<String, dynamic> body) async {
    try {
      final response = await apiService.post<UserResponseModel>(
        endpoint: AppUrls.login,
        data: body,
        fromJson: (json) => UserResponseModel.fromJson(json),
      );
      _persistUserData(response.token, response.data);
      return response.data;
    } catch (e) {
      // The ApiService handles showing the error toast.
      // Rethrowing allows the UI layer to know the login failed.
      rethrow;
    }
  }

  @override
  Future<UserModel> register(Map<String, dynamic> body) async {
    try {
      final response = await apiService.post<UserResponseModel>(
        endpoint: AppUrls.register,
        data: body,
        fromJson: (json) => UserResponseModel.fromJson(json),
      );
      _persistUserData(response.token, response.data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> forgotPassword(Map<String, dynamic> body) async {
    try {
      // Assuming the API returns a simple success message, e.g., {"status": "success", "message": "..."}
      // We don't need to parse a complex model, just confirm it was successful.
      await apiService.post<void>(
        endpoint: AppUrls.forgotPassword,
        data: body,
        fromJson: (_) {},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> changePassword(Map<String, dynamic> body) async {
    try {
      await apiService.post<void>(
        endpoint: AppUrls.changePassword,
        data: body,
        fromJson: (_) {},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> sendOtp(Map<String, dynamic> body) async {
    try {
      await apiService.post<void>(
        endpoint: AppUrls.sendOtp,
        data: body,
        fromJson: (_) {},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> verifyOtp(Map<String, dynamic> body) async {
    try {
      // Assuming the API returns a temporary token upon successful OTP verification.
      // e.g., {"data": {"temp_token": "some_token"}}
      final response = await apiService.post<Map<String, dynamic>>(
        endpoint: AppUrls.verifyOtp,
        data: body,
        fromJson: (json) => json, // Get the raw map
      );

      final tempToken = response['token'] as String?;
      if (tempToken != null) {
        hiveManager.setString(HiveManager.tempTokenKey, tempToken);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserModel> updateProfile(String userId, dynamic formData) async {
    try {
      final response = await apiService.put<UpdateProfileResponseModel>(
        endpoint: AppUrls.updateProfile(userId),
        data: formData,
        fromJson: (json) => UpdateProfileResponseModel.fromJson(json),
      );

      // Update local storage with the updated user data
      final user = response.data;
      hiveManager.setString(HiveManager.fullNameKey, user.fullName);
      hiveManager.setString(HiveManager.emailKey, user.email);
      if (user.profile != null) {
        hiveManager.setString(HiveManager.profileKey, user.profile!);
      }

      return user;
    } catch (e) {
      // The ApiService handles showing the error toast.
      // Rethrowing allows the UI layer to know the update failed.
      rethrow;
    }
  }

  @override
  Future<bool> resetPassword(Map<String, dynamic> body) async {
    try {
      try {
        await apiService.post<void>(
          endpoint: AppUrls.resetPassword,
          data: body,
          fromJson: (_) {},
        );
        return true;
      } finally {
        hiveManager.setString(HiveManager.tokenKey, '');
      }
    } catch (e) {
      // The ApiService handles showing the error toast.
      // Rethrowing allows the UI layer to know the reset failed.
      rethrow;
    }
  }

  @override
  Future<ProfileResponseModel> getProfile() async {
    try {
      final response = await apiService.get<ProfileResponseModel>(
        endpoint: AppUrls.profile,
        fromJson: (json) => ProfileResponseModel.fromJson(json),
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
