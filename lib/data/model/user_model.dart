import 'subscription_model.dart';

class UserResponseModel {
  final UserModel data;
  final String token;

  UserResponseModel({required this.data, required this.token});

  factory UserResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final userData = data['user'];
    Map<String, dynamic> userMap = {};
    if (userData is Map) {
      userMap = Map<String, dynamic>.from(userData);
    }
    return UserResponseModel(
      data: UserModel.fromJson(userMap),
      token: data['token']?.toString() ?? '',
    );
  }
}

class UpdateProfileResponseModel {
  final UserModel data;

  UpdateProfileResponseModel({required this.data});

  factory UpdateProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponseModel(
      data: UserModel.fromJson(json['data']),
    );
  }
}

class UserModel {
  String id = '';
  final String fullName;
  final String phone;
  final String email;
  final String? role;
  final String? profile;
  final String? status;
  final String? deletedAt;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    this.role,
    this.profile,
    this.status,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'].toString(),
      fullName: json['name']?.toString() ?? json['full_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString(),
      profile: json['profile']?.toString(),
      status: json['status']?.toString(),
      deletedAt: json['deleted_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': fullName,
      'phone': phone,
      'email': email,
      'role': role,
      'profile': profile,
      'status': status,
      'deleted_at': deletedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ProfileResponseModel {
  final UserProfileModel data;

  ProfileResponseModel({required this.data});

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileResponseModel(
      data: UserProfileModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class UserProfileModel {
  final String userId;
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profile;
  final String? role;
  final String? status;
  final bool? phoneVerified;
  final bool isDeleted;
  final String? createdAt;
  final String? updatedAt;
  final int? version;
  final String? otp;
  final String? otpExpires;
  final String? resetPasswordToken;
  final UpdatedBy? updatedBy;
  final UserPlanModel? plan;

  UserProfileModel({
    required this.userId,
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profile,
    this.role,
    this.status,
    this.phoneVerified,
    required this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.version,
    this.otp,
    this.otpExpires,
    this.resetPasswordToken,
    this.updatedBy,
    this.plan,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['userId']?.toString() ?? json['_id']?.toString() ?? '',
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      profile: json['profile']?.toString(),
      role: json['role']?.toString(),
      status: json['status']?.toString(),
      phoneVerified: json['phoneVerified'] as bool?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      version: json['__v'] as int?,
      otp: json['otp']?.toString(),
      otpExpires: json['otpExpires']?.toString(),
      resetPasswordToken: json['resetPasswordToken']?.toString(),
      updatedBy: json['updatedBy'] != null
          ? UpdatedBy.fromJson(json['updatedBy'] as Map<String, dynamic>)
          : null,
      plan: json['plan'] != null
          ? UserPlanModel.fromJson(json['plan'] as Map<String, dynamic>)
          : null,
    );
  }
}

class UpdatedBy {
  final String id;
  final String name;
  final String email;

  UpdatedBy({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UpdatedBy.fromJson(Map<String, dynamic> json) {
    return UpdatedBy(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}

class UserPlanModel {
  final String id;
  final String userId;
  final SubscriptionPlanModel? subscriptionId;
  final double amount;
  final String currency;
  final String? transactionId;
  final String startDate;
  final String endDate;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final int? version;

  UserPlanModel({
    required this.id,
    required this.userId,
    this.subscriptionId,
    this.amount = 0.0,
    this.currency = 'INR',
    this.transactionId,
    required this.startDate,
    required this.endDate,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  factory UserPlanModel.fromJson(Map<String, dynamic> json) {
    SubscriptionPlanModel? subscriptionPlan;
    
    // Handle subscriptionId - it might be an object, a string ID, or missing
    if (json['subscriptionId'] != null) {
      if (json['subscriptionId'] is Map<String, dynamic>) {
        // It's a full subscription plan object
        subscriptionPlan = SubscriptionPlanModel.fromJson(
          json['subscriptionId'] as Map<String, dynamic>,
        );
      } else if (json['subscriptionId'] is String) {
        // It's just an ID - we'll need to fetch the plan details separately
        // For now, create a minimal plan model with just the ID
        subscriptionPlan = SubscriptionPlanModel(
          id: json['subscriptionId'] as String,
          name: 'Unknown Plan',
          description: '',
          price: 0.0,
          currency: json['currency']?.toString() ?? 'INR',
          durationMonths: 1,
          productLimit: 0,
          features: [],
          isActive: true,
          isPopular: false,
          order: 0,
          isDeleted: false,
        );
      }
    }

    return UserPlanModel(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      subscriptionId: subscriptionPlan,
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'INR',
      transactionId: json['transactionId']?.toString(),
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      status: json['status']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      version: json['__v'] as int?,
    );
  }
}
