class BannerResponseModel {
  final bool success;
  final List<BannerModel> data;

  BannerResponseModel({
    required this.success,
    required this.data,
  });

  factory BannerResponseModel.fromJson(Map<String, dynamic> json) {
    return BannerResponseModel(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map(
                  (item) => BannerModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class BannerModel {
  final String id;
  final String title;
  final String? description;
  final String imageUrl;
  final String? imageAlt;
  final String linkType; // 'external', 'movie', 'category', 'series', 'none'
  final String? externalUrl;
  final String? movieId;
  final String? categoryName;
  final String? categoryId;
  final List<String> categoryIds; // Category IDs from linkId.category
  final int order;
  final String position; // 'home', 'category', 'movie_detail'

  BannerModel({
    required this.id,
    required this.title,
    this.description,
    required this.imageUrl,
    this.imageAlt,
    required this.linkType,
    this.externalUrl,
    this.movieId,
    this.categoryName,
    this.categoryId,
    this.categoryIds = const [],
    required this.order,
    required this.position,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    // Extract image URL
    String imageUrl = '';
    if (json['image'] != null) {
      if (json['image'] is String) {
        imageUrl = json['image'] as String;
      } else if (json['image'] is Map && json['image']['url'] != null) {
        imageUrl = json['image']['url'].toString();
      }
    }

    // Extract link information based on linkType
    String? movieId;
    String? categoryName;
    String? categoryId;
    List<String> categoryIds = [];

    if (json['linkId'] != null && json['linkId'] is Map) {
      final linkId = json['linkId'] as Map<String, dynamic>;

      if (json['linkType'] == 'movie' || json['linkType'] == 'series') {
        movieId = linkId['_id']?.toString() ?? linkId['id']?.toString();
        // Extract category IDs from linkId.category array
        if (linkId['category'] != null && linkId['category'] is List) {
          categoryIds = (linkId['category'] as List)
              .map((item) => item.toString())
              .toList();
        }
      } else if (json['linkType'] == 'category') {
        categoryId = linkId['_id']?.toString();
        categoryName = linkId['name']?.toString();
      }
    }

    return BannerModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: imageUrl,
      imageAlt: json['image']?['alt']?.toString(),
      linkType: json['linkType']?.toString() ?? 'none',
      externalUrl: json['externalUrl']?.toString(),
      movieId: movieId,
      categoryName: categoryName,
      categoryId: categoryId,
      categoryIds: categoryIds,
      order: json['order'] ?? 0,
      position: json['position']?.toString() ?? 'home',
    );
  }
}
