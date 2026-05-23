import 'movie_model.dart';

class MovieListResponseModel {
  final bool success;
  final List<MovieModel> data;
  final PaginationModel pagination;

  MovieListResponseModel({
    required this.success,
    required this.data,
    required this.pagination,
  });

  factory MovieListResponseModel.fromJson(Map<String, dynamic> json) {
    List<MovieModel> movieList = [];
    if (json['data'] != null && json['data'] is List) {
      final dataList = json['data'] as List;
      movieList = dataList.map((item) {
        // Check if item has a nested 'movieId' property (for favorites/watchlist)
        // or if it's the movie object directly (for movies API)
        if (item is Map<String, dynamic>) {
          if (item['movieId'] != null && item['movieId'] is Map) {
            // Handle nested movieId structure (favorites/watchlist)
            return MovieModel.fromJson(item['movieId'] as Map<String, dynamic>);
          } else {
            // Handle direct movie object (movies API)
            return MovieModel.fromJson(item);
          }
        }
        throw Exception('Invalid movie item format');
      }).toList();
    }

    return MovieListResponseModel(
      success: json['success'] ?? false,
      data: movieList,
      pagination: PaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class PaginationModel {
  final int page;
  final int limit;
  final int total;
  final int pages;

  PaginationModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      pages: json['pages'] ?? 1,
    );
  }

  bool get hasMore => page < pages;
}
