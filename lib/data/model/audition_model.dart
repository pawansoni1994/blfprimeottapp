class AuditionModel {
  final String id;
  final String title;
  final String name;
  final String email;
  final String phone;
  final String smedia;
  final String description;
  final String? createdAt;
  final String? updatedAt;
  final String? status;

  AuditionModel({
    required this.id,
    required this.title,
    required this.name,
    required this.email,
    required this.phone,
    required this.smedia,
    required this.description,
    this.createdAt,
    this.updatedAt,
    this.status,
  });

  factory AuditionModel.fromJson(Map<String, dynamic> json) {
    return AuditionModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      smedia: json['smedia']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'name': name,
      'email': email,
      'phone': phone,
      'smedia': smedia,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'status': status,
    };
  }
}

class AuditionListResponseModel {
  final bool success;
  final List<AuditionModel> data;

  AuditionListResponseModel({
    required this.success,
    required this.data,
  });

  factory AuditionListResponseModel.fromJson(Map<String, dynamic> json) {
    return AuditionListResponseModel(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => AuditionModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

