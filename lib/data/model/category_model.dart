class CategoryResponseModel {
  final bool success;
  final List<CategoryModel> data;

  CategoryResponseModel({
    required this.success,
    required this.data,
  });

  factory CategoryResponseModel.fromJson(Map<String, dynamic> json) {
    return CategoryResponseModel(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? description;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['meta']?['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'slug': slug,
      'meta': {
        'description': description,
      },
    };
  }
}

