import '../../network/network.dart';
import '../model/model.dart';

/// Abstract class defining the contract for the movie repository.
abstract class MovieRepository {
  Future<MovieListResponseModel> getMovies({
    int page = 1,
    int limit = 10,
    String? search,
    String? categoryId,
    String? type,
    String? languageId,
    bool? isPremium,
    bool? isForKids,
  });
  Future<MovieListResponseModel> getSeries({
    int page = 1,
    int limit = 10,
    String? search,
    String? categoryId,
    String? languageId,
    bool? isPremium,
    bool? isForKids,
  });
  Future<List<MovieModel>> getLatestMovies({bool? isForKids});
  Future<List<MovieModel>> getLatestSeries({bool? isForKids});
  Future<List<MovieModel>> getLatestSongs({bool? isForKids});
  Future<MovieListResponseModel> getSongs({
    int page = 1,
    int limit = 10,
    String? search,
    String? categoryId,
    String? languageId,
    bool? isPremium,
    bool? isForKids,
  });
  Future<MovieModel> getMovieDetails(String movieId);
  Future<MovieModel> getSeriesDetails(String seriesId);
  Future<MovieModel> getSongDetails(String songId);
  Future<MovieModel> getComingSoonDetails(String comingSoonId);
  Future<MovieListResponseModel> getFavorites({
    int page = 1,
    int limit = 10,
  });
  // Helper method to get itemType map for favorites
  Future<Map<String, String>> getFavoritesItemTypes({
    int page = 1,
    int limit = 10,
  });
  Future<bool> toggleFavorite(String movieId, String itemType);
  Future<MovieListResponseModel> getWatchlist({
    int page = 1,
    int limit = 10,
  });
  Future<Map<String, String>> getWatchlistItemTypes({
    int page = 1,
    int limit = 10,
  });
  Future<bool> toggleWatchlist(String movieId, String itemType);
  Future<MovieListResponseModel> getComingSoon({
    int page = 1,
    int limit = 10,
  });
  Future<bool> purchaseMovie(
      String movieId, String itemType, String transactionId, price);
  Future<void> startContinueWatching(
      String contentId, String contentType, {String? episodeId});
  Future<void> updateContinueWatching(
      String contentId, String contentType, int duration, int totalDuration,
      {String? episodeId});
  Future<List<ContinueWatchingModel>> getContinueWatching({int limit = 10});
  Future<ContinueWatchingResponseModel> getContinueWatchingPaginated({
    int page = 1,
    int limit = 20,
  });
}

/// The concrete implementation of the MovieRepository.
class MovieRepositoryImpl implements MovieRepository {
  final ApiService apiService;

  MovieRepositoryImpl({required this.apiService});

  @override
  Future<MovieListResponseModel> getMovies({
    int page = 1,
    int limit = 10,
    String? search,
    String? categoryId,
    String? type,
    String? languageId,
    bool? isPremium,
    bool? isForKids,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      if (categoryId != null && categoryId.isNotEmpty) {
        queryParameters['category'] = categoryId;
      }

      if (languageId != null && languageId.isNotEmpty) {
        queryParameters['language'] = languageId;
      }

      if (type != null && type.isNotEmpty && type != 'All') {
        // Map UI type to API type
        String apiType = type.toLowerCase();
        if (apiType == 'movie') {
          queryParameters['type'] = 'movie';
        } else if (apiType == 'Series' || apiType == 'series') {
          queryParameters['type'] = 'series';
        }
      }

      if (isPremium != null) {
        queryParameters['isPremium'] = isPremium.toString();
      }

      if (isForKids != null) {
        queryParameters['isForKids'] = isForKids.toString();
      }

      final response = await apiService.get<MovieListResponseModel>(
        endpoint: AppUrls.movies,
        queryParameters: queryParameters,
        fromJson: (json) => MovieListResponseModel.fromJson(json),
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
  Future<MovieListResponseModel> getSeries({
    int page = 1,
    int limit = 10,
    String? search,
    String? categoryId,
    String? languageId,
    bool? isPremium,
    bool? isForKids,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      if (categoryId != null && categoryId.isNotEmpty) {
        queryParameters['category'] = categoryId;
      }

      if (languageId != null && languageId.isNotEmpty) {
        queryParameters['language'] = languageId;
      }

      if (isPremium != null) {
        queryParameters['isPremium'] = isPremium.toString();
      }

      if (isForKids != null) {
        queryParameters['isForKids'] = isForKids.toString();
      }

      final response = await apiService.get<MovieListResponseModel>(
        endpoint: AppUrls.series,
        queryParameters: queryParameters,
        fromJson: (json) => MovieListResponseModel.fromJson(json),
        showLoading: false,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MovieModel>> getLatestMovies({bool? isForKids}) async {
    try {
      final Map<String, dynamic> queryParameters = {};

      if (isForKids != null) {
        queryParameters['isForKids'] = isForKids.toString();
      }

      // The API might return a list directly or wrapped in a response
      final response = await apiService.get<dynamic>(
        endpoint: AppUrls.latestMovies,
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
        fromJson: (json) => json, // Get raw response
        showLoading: false, // We'll handle loading in the controller
      );

      // Handle both cases: direct list or wrapped in response
      List<MovieModel> movies = [];
      if (response is List) {
        // If response is a list directly
        movies = response
            .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response is Map<String, dynamic>) {
        // If response is wrapped in an object
        if (response['data'] != null && response['data'] is List) {
          movies = (response['data'] as List)
              .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          // Try to parse as MovieListResponseModel
          final movieListResponse = MovieListResponseModel.fromJson(response);
          movies = movieListResponse.data;
        }
      }

      return movies;
    } catch (e) {
      // The ApiService handles showing the error toast.
      // Rethrowing allows the UI layer to know the request failed.
      rethrow;
    }
  }

  @override
  Future<List<MovieModel>> getLatestSeries({bool? isForKids}) async {
    try {
      final Map<String, dynamic> queryParameters = {};

      if (isForKids != null) {
        queryParameters['isForKids'] = isForKids.toString();
      }

      // The API might return a list directly or wrapped in a response
      final response = await apiService.get<dynamic>(
        endpoint: AppUrls.latestSeries,
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
        fromJson: (json) => json, // Get raw response
        showLoading: false, // We'll handle loading in the controller
      );

      // Handle both cases: direct list or wrapped in response
      List<MovieModel> movies = [];
      if (response is List) {
        // If response is a list directly
        movies = response
            .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response is Map<String, dynamic>) {
        // If response is wrapped in an object
        if (response['data'] != null && response['data'] is List) {
          movies = (response['data'] as List)
              .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          // Try to parse as MovieListResponseModel
          final movieListResponse = MovieListResponseModel.fromJson(response);
          movies = movieListResponse.data;
        }
      }

      return movies;
    } catch (e) {
      // The ApiService handles showing the error toast.
      // Rethrowing allows the UI layer to know the request failed.
      rethrow;
    }
  }

  @override
  Future<List<MovieModel>> getLatestSongs({bool? isForKids}) async {
    try {
      final Map<String, dynamic> queryParameters = {};

      if (isForKids != null) {
        queryParameters['isForKids'] = isForKids.toString();
      }

      // The API might return a list directly or wrapped in a response
      final response = await apiService.get<dynamic>(
        endpoint: AppUrls.latestSongs,
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
        fromJson: (json) => json, // Get raw response
        showLoading: false, // We'll handle loading in the controller
      );

      // Handle both cases: direct list or wrapped in response
      List<MovieModel> songs = [];
      if (response is List) {
        // If response is a list directly
        songs = response
            .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response is Map<String, dynamic>) {
        // If response is wrapped in an object
        if (response['data'] != null && response['data'] is List) {
          songs = (response['data'] as List)
              .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          // Try to parse as MovieListResponseModel
          final songListResponse = MovieListResponseModel.fromJson(response);
          songs = songListResponse.data;
        }
      }

      return songs;
    } catch (e) {
      // The ApiService handles showing the error toast.
      // Rethrowing allows the UI layer to know the request failed.
      rethrow;
    }
  }

  @override
  Future<MovieListResponseModel> getSongs({
    int page = 1,
    int limit = 10,
    String? search,
    String? categoryId,
    String? languageId,
    bool? isPremium,
    bool? isForKids,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      if (categoryId != null && categoryId.isNotEmpty) {
        queryParameters['category'] = categoryId;
      }

      if (languageId != null && languageId.isNotEmpty) {
        queryParameters['language'] = languageId;
      }

      if (isPremium != null) {
        queryParameters['isPremium'] = isPremium.toString();
      }

      if (isForKids != null) {
        queryParameters['isForKids'] = isForKids.toString();
      }

      final response = await apiService.get<MovieListResponseModel>(
        endpoint: AppUrls.songs,
        queryParameters: queryParameters,
        fromJson: (json) => MovieListResponseModel.fromJson(json),
        showLoading: false,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MovieModel> getMovieDetails(String movieId) async {
    try {
      final response = await apiService.get<Map<String, dynamic>>(
        endpoint: AppUrls.movieDetails(movieId),
        fromJson: (json) => json as Map<String, dynamic>,
        showLoading: false,
      );

      // Handle common shapes:
      // 1) { success: true, data: {...} }
      // 2) { data: {...} }
      // 3) Movie object directly
      if (response['data'] != null &&
          response['data'] is Map<String, dynamic>) {
        return MovieModel.fromJson(response['data'] as Map<String, dynamic>);
      }
      if (response['_id'] != null || response['id'] != null) {
        return MovieModel.fromJson(response);
      }
      throw Exception('Invalid response format');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MovieModel> getSeriesDetails(String seriesId) async {
    try {
      final response = await apiService.get<Map<String, dynamic>>(
        endpoint: AppUrls.seriesDetails(seriesId),
        fromJson: (json) => json as Map<String, dynamic>,
        showLoading: false,
      );

      if (response['data'] != null &&
          response['data'] is Map<String, dynamic>) {
        return MovieModel.fromJson(response['data'] as Map<String, dynamic>);
      }
      if (response['_id'] != null || response['id'] != null) {
        return MovieModel.fromJson(response);
      }
      throw Exception('Invalid response format');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MovieModel> getSongDetails(String songId) async {
    try {
      final response = await apiService.get<Map<String, dynamic>>(
        endpoint: AppUrls.songDetails(songId),
        fromJson: (json) => json as Map<String, dynamic>,
        showLoading: false,
      );

      if (response['data'] != null &&
          response['data'] is Map<String, dynamic>) {
        return MovieModel.fromJson(response['data'] as Map<String, dynamic>);
      }
      if (response['_id'] != null || response['id'] != null) {
        return MovieModel.fromJson(response);
      }
      throw Exception('Invalid response format');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MovieModel> getComingSoonDetails(String comingSoonId) async {
    try {
      final response = await apiService.get<Map<String, dynamic>>(
        endpoint: AppUrls.comingSoonDetails(comingSoonId),
        fromJson: (json) => json as Map<String, dynamic>,
        showLoading: false,
      );

      if (response['data'] != null &&
          response['data'] is Map<String, dynamic>) {
        return MovieModel.fromJson(response['data'] as Map<String, dynamic>);
      }
      if (response['_id'] != null || response['id'] != null) {
        return MovieModel.fromJson(response);
      }
      throw Exception('Invalid response format');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MovieListResponseModel> getFavorites({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'page': page,
        'limit': limit,
      };

      final response = await apiService.get<Map<String, dynamic>>(
        endpoint: AppUrls.favorites,
        queryParameters: queryParameters,
        fromJson: (json) => json as Map<String, dynamic>,
        showLoading: false,
      );

      // Handle response structure - favorites items have nested itemId objects
      List<MovieModel> movies = [];
      if (response['data'] != null && response['data'] is List) {
        final dataList = response['data'] as List;
        movies = dataList.where((item) {
          // Filter out items where itemId is null
          if (item is Map<String, dynamic>) {
            return item['itemId'] != null && item['itemId'] is Map;
          }
          return false;
        }).map((item) {
          if (item is Map<String, dynamic>) {
            // Check if item has a nested 'itemId' property (favorite object)
            if (item['itemId'] != null && item['itemId'] is Map) {
              // Extract movie data from itemId field
              final movieData =
                  Map<String, dynamic>.from(item['itemId'] as Map);
              return MovieModel.fromJson(movieData);
            } else if (item['movieId'] != null && item['movieId'] is Map) {
              // Fallback for old 'movieId' field
              final movieData =
                  Map<String, dynamic>.from(item['movieId'] as Map);
              return MovieModel.fromJson(movieData);
            } else if (item['movie'] != null && item['movie'] is Map) {
              // Fallback for 'movie' field
              final movieData = Map<String, dynamic>.from(item['movie'] as Map);
              return MovieModel.fromJson(movieData);
            } else {
              // It's the movie object directly
              return MovieModel.fromJson(item);
            }
          }
          throw Exception('Invalid favorite item format');
        }).toList();
      }

      // Parse pagination
      PaginationModel pagination = PaginationModel(
        page: response['pagination']?['page'] ?? page,
        limit: response['pagination']?['limit'] ?? limit,
        total: response['pagination']?['total'] ?? movies.length,
        pages: response['pagination']?['pages'] ?? 1,
      );

      return MovieListResponseModel(
        success: response['success'] ?? (response['message'] != null),
        data: movies,
        pagination: pagination,
      );
    } catch (e) {
      // The ApiService handles showing the error toast.
      // Rethrowing allows the UI layer to know the request failed.
      rethrow;
    }
  }

  @override
  Future<Map<String, String>> getFavoritesItemTypes({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'page': page,
        'limit': limit,
      };

      final response = await apiService.get<Map<String, dynamic>>(
        endpoint: AppUrls.favorites,
        queryParameters: queryParameters,
        fromJson: (json) => json as Map<String, dynamic>,
        showLoading: false,
      );

      // Extract itemType for each favorite item
      Map<String, String> itemTypes = {};
      if (response['data'] != null && response['data'] is List) {
        final dataList = response['data'] as List;
        for (var item in dataList) {
          if (item is Map<String, dynamic>) {
            final itemIdObj = item['itemId'];
            final itemType = item['itemType'];
            if (itemIdObj != null && itemType != null && itemType is String) {
              // Get the actual item ID from nested itemId object
              String? actualItemId;
              if (itemIdObj is Map) {
                actualItemId =
                    itemIdObj['_id']?.toString() ?? itemIdObj['id']?.toString();
              }
              if (actualItemId != null) {
                itemTypes[actualItemId] = itemType;
              }
            }
          }
        }
      }

      return itemTypes;
    } catch (e) {
      return {};
    }
  }

  @override
  Future<bool> toggleFavorite(String movieId, String itemType) async {
    try {
      final response = await apiService.post<Map<String, dynamic>>(
        endpoint: AppUrls.toggleFavorite,
        data: {
          'itemId': movieId,
          'itemType': itemType,
        },
        fromJson: (json) => json as Map<String, dynamic>,
        showLoading: false,
      );

      // The API returns the new favorite status
      // Response might be: { success: true, data: { isFavorite: true/false } }
      // or: { isFavorite: true/false }
      if (response['data'] != null && response['data'] is Map) {
        final data = response['data'] as Map<String, dynamic>;
        if (data['isFavorite'] != null) {
          return data['isFavorite'] == true;
        }
      }

      // Check if response has isFavorite directly
      if (response['isFavorite'] != null) {
        return response['isFavorite'] == true;
      }

      // If we can't determine the status, check the favorite status
      return false;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MovieListResponseModel> getWatchlist({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'page': page,
        'limit': limit,
      };

      final response = await apiService.get<Map<String, dynamic>>(
        endpoint: AppUrls.watchlist,
        queryParameters: queryParameters,
        fromJson: (json) => json as Map<String, dynamic>,
        showLoading: false,
      );

      // Handle response structure - favorites items have nested itemId objects
      List<MovieModel> movies = [];
      if (response['data'] != null && response['data'] is List) {
        final dataList = response['data'] as List;
        movies = dataList.where((item) {
          // Filter out items where itemId is null
          if (item is Map<String, dynamic>) {
            return item['itemId'] != null && item['itemId'] is Map;
          }
          return false;
        }).map((item) {
          if (item is Map<String, dynamic>) {
            // Check if item has a nested 'itemId' property (favorite object)
            if (item['itemId'] != null && item['itemId'] is Map) {
              // Extract movie data from itemId field
              final movieData =
                  Map<String, dynamic>.from(item['itemId'] as Map);
              return MovieModel.fromJson(movieData);
            } else if (item['movieId'] != null && item['movieId'] is Map) {
              // Fallback for old 'movieId' field
              final movieData =
                  Map<String, dynamic>.from(item['movieId'] as Map);
              return MovieModel.fromJson(movieData);
            } else if (item['movie'] != null && item['movie'] is Map) {
              // Fallback for 'movie' field
              final movieData = Map<String, dynamic>.from(item['movie'] as Map);
              return MovieModel.fromJson(movieData);
            } else {
              // It's the movie object directly
              return MovieModel.fromJson(item);
            }
          }
          throw Exception('Invalid watchlist item format');
        }).toList();
      }

      // Parse pagination
      PaginationModel pagination = PaginationModel(
        page: response['pagination']?['page'] ?? page,
        limit: response['pagination']?['limit'] ?? limit,
        total: response['pagination']?['total'] ?? movies.length,
        pages: response['pagination']?['pages'] ?? 1,
      );

      return MovieListResponseModel(
        success: response['success'] ?? (response['message'] != null),
        data: movies,
        pagination: pagination,
      );
    } catch (e) {
      // The ApiService handles showing the error toast.
      // Rethrowing allows the UI layer to know the request failed.
      rethrow;
    }
  }

  @override
  Future<Map<String, String>> getWatchlistItemTypes({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'page': page,
        'limit': limit,
      };

      final response = await apiService.get<Map<String, dynamic>>(
        endpoint: AppUrls.watchlist,
        queryParameters: queryParameters,
        fromJson: (json) => json as Map<String, dynamic>,
        showLoading: false,
      );

      // Extract itemType for each watchlist item
      Map<String, String> itemTypes = {};
      if (response['data'] != null && response['data'] is List) {
        final dataList = response['data'] as List;
        for (var item in dataList) {
          if (item is Map<String, dynamic>) {
            final itemIdObj = item['itemId']; // watchlist object
            final itemType = item['itemType'];
            if (itemIdObj != null && itemType != null && itemType is String) {
              // Get the actual item ID from nested itemId object
              String? actualItemId =
                  itemIdObj['_id']?.toString() ?? itemIdObj['id']?.toString();
              if (actualItemId != null) {
                itemTypes[actualItemId] = itemType;
              }
            }
          }
        }
      }

      return itemTypes;
    } catch (e) {
      return {};
    }
  }

  @override
  Future<bool> toggleWatchlist(String movieId, String itemType) async {
    try {
      final response = await apiService.post<Map<String, dynamic>>(
        endpoint: AppUrls.toggleWatchlist,
        data: {
          'itemId': movieId,
          'itemType': itemType,
        },
        fromJson: (json) => json as Map<String, dynamic>,
        showLoading: false,
      );

      // The API returns the new watchlist status
      // Response might be: { success: true, data: { isInWatchlist: true/false } }
      // or: { isInWatchlist: true/false }
      if (response['data'] != null && response['data'] is Map) {
        final data = response['data'] as Map<String, dynamic>;
        if (data['isWatchlist'] != null) {
          return data['isWatchlist'] == true;
        }
      }

      // Check if response has isInWatchlist directly
      if (response['isWatchlist'] != null) {
        return response['isWatchlist'] == true;
      }

      // If we can't determine the status, check the watchlist status
      return false;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MovieListResponseModel> getComingSoon({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'page': page,
        'limit': limit,
      };

      final response = await apiService.get<Map<String, dynamic>>(
        endpoint: AppUrls.comingSoon,
        queryParameters: queryParameters,
        fromJson: (json) => json as Map<String, dynamic>,
        showLoading: false,
      );

      // Handle response structure: { data: [...], pagination: {...} }
      List<MovieModel> movies = [];
      if (response['data'] != null && response['data'] is List) {
        final dataList = response['data'] as List;
        movies = dataList
            .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      // Parse pagination
      PaginationModel pagination = PaginationModel(
        page: response['pagination']?['page'] ?? page,
        limit: response['pagination']?['limit'] ?? limit,
        total: response['pagination']?['total'] ?? movies.length,
        pages: response['pagination']?['pages'] ?? 1,
      );

      return MovieListResponseModel(
        success: true,
        data: movies,
        pagination: pagination,
      );
    } catch (e) {
      // The ApiService handles showing the error toast.
      // Rethrowing allows the UI layer to know the request failed.
      rethrow;
    }
  }

  @override
  Future<bool> purchaseMovie(
      String movieId, String itemType, String transactionId, price) async {
    try {
      final response = await apiService.post<Map<String, dynamic>>(
        endpoint: AppUrls.purchase,
        data: {
          'itemId': movieId,
          'itemType': itemType,
          "price": price,
          "currency": "INR",
          "transactionId": transactionId
        },
        fromJson: (json) => json as Map<String, dynamic>,
        showLoading: true,
      );

      // The API returns the new watchlist status
      // Response might be: { success: true, data: { isInWatchlist: true/false } }
      // or: { isInWatchlist: true/false }
      if (response['data'] != null && response['data'] is Map) {
        return true;
      }

      // If we can't determine the status, check the watchlist status
      return false;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> startContinueWatching(
      String contentId, String contentType, {String? episodeId}) async {
    try {
      final Map<String, dynamic> requestData = {
        'contentId': contentId,
        'contentType': contentType,
      };

      // Add episodeId for series
      if (contentType == 'series' && episodeId != null && episodeId.isNotEmpty) {
        requestData['episodeId'] = episodeId;
      }

      await apiService.post<void>(
        endpoint: AppUrls.continueWatchingStart,
        data: requestData,
        fromJson: (_) {},
        showLoading: false, // Don't show loading for background API call
      );
    } catch (e) {
      // Silently fail - don't interrupt playback if this fails
      // Log error but don't show toast to user
      rethrow;
    }
  }

  @override
  Future<void> updateContinueWatching(
      String contentId, String contentType, int duration, int totalDuration,
      {String? episodeId}) async {
    try {
      final Map<String, dynamic> requestData = {
        'contentId': contentId,
        'contentType': contentType,
        'duration': duration,
        'totalDuration': totalDuration,
      };

      // Add episodeId for series
      if (contentType == 'series' && episodeId != null && episodeId.isNotEmpty) {
        requestData['episodeId'] = episodeId;
      }

      await apiService.put<void>(
        endpoint: AppUrls.continueWatchingUpdate,
        data: requestData,
        fromJson: (_) {},
        showLoading: false, // Don't show loading for background API call
      );
    } catch (e) {
      // Silently fail - don't interrupt playback if this fails
      // Log error but don't show toast to user
      rethrow;
    }
  }

  @override
  Future<List<ContinueWatchingModel>> getContinueWatching(
      {int limit = 10}) async {
    try {
      final response = await apiService.get<ContinueWatchingResponseModel>(
        endpoint: AppUrls.continueWatchingLatest(limit),
        fromJson: (json) => ContinueWatchingResponseModel.fromJson(json),
        showLoading: false,
      );
      return response.data;
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }

  @override
  Future<ContinueWatchingResponseModel> getContinueWatchingPaginated({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await apiService.get<ContinueWatchingResponseModel>(
        endpoint: AppUrls.continueWatching(page, limit),
        fromJson: (json) => ContinueWatchingResponseModel.fromJson(json),
        showLoading: false,
      );
      return response;
    } catch (e) {
      // Return empty response on error
      return ContinueWatchingResponseModel(
        success: false,
        data: [],
      );
    }
  }
}
