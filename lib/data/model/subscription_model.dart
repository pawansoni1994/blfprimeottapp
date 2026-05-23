import 'movie_list_response_model.dart';

class SubscriptionPlanResponseModel {
  final bool success;
  final List<SubscriptionPlanModel> data;
  final PaginationModel pagination;

  SubscriptionPlanResponseModel({
    required this.success,
    required this.data,
    required this.pagination,
  });

  factory SubscriptionPlanResponseModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanResponseModel(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => SubscriptionPlanModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: PaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class SubscriptionPlanModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final int durationMonths;
  final int productLimit;
  final List<String> features;
  final bool isActive;
  final bool isPopular;
  final int order;
  final String? createdBy;
  final bool isDeleted;
  final String? createdAt;
  final String? updatedAt;
  final int? version;

  SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.durationMonths,
    required this.productLimit,
    required this.features,
    required this.isActive,
    required this.isPopular,
    required this.order,
    this.createdBy,
    required this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'INR',
      durationMonths: json['durationMonths'] as int? ?? 1,
      productLimit: json['productLimit'] as int? ?? 0,
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isActive: json['isActive'] as bool? ?? false,
      isPopular: json['isPopular'] as bool? ?? false,
      order: json['order'] as int? ?? 0,
      createdBy: json['createdBy']?.toString(),
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      version: json['__v'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'durationMonths': durationMonths,
      'productLimit': productLimit,
      'features': features,
      'isActive': isActive,
      'isPopular': isPopular,
      'order': order,
      'createdBy': createdBy,
      'isDeleted': isDeleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': version,
    };
  }

  // Helper getters for backward compatibility
  String get priceString => price.toStringAsFixed(0);
  int get duration => durationMonths;
}

class PurchaseSubscriptionResponseModel {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;

  PurchaseSubscriptionResponseModel({
    required this.success,
    this.message,
    this.data,
  });

  factory PurchaseSubscriptionResponseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseSubscriptionResponseModel(
      success: json['success'] ?? false,
      message: json['message']?.toString(),
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
    );
  }
}

class CancelSubscriptionResponseModel {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;

  CancelSubscriptionResponseModel({
    required this.success,
    this.message,
    this.data,
  });

  factory CancelSubscriptionResponseModel.fromJson(Map<String, dynamic> json) {
    return CancelSubscriptionResponseModel(
      success: json['success'] ?? false,
      message: json['message']?.toString(),
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
    );
  }
}

