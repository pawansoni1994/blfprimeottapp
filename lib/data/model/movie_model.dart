class ContentType {
  static String free = "free";
  static String buy = "buy";
  static String subscription = "subscription";
}

class MovieModel {
  final String id;
  final String title;
  final String description;
  final String slug;
  final String type; // 'movie' or 'series'
  final String? poster;
  bool isPurchased;
  final List<MovieImage> images;
  final List<String> tags;
  final double rating;
  final String duration; // Can be string like "2000" (seconds) or formatted
  final List<String> category;
  final List<String> languages;
  final String? trailerId;
  final List<MovieCast> cast;
  final int views;
  final double? buyPrice;
  final bool? isFavorite;
  final bool? isWatchListed;
  final bool isForKids;
  final String? releaseDate;
  final String? status;
  final CreatedBy? createdBy;
  final CreatedBy? updatedBy;
  final bool isDeleted;
  final String? createdAt;
  final String? updatedAt;
  final int? version; // __v
  final List<MovieEpisode> episodes;
  final MovieTrailer? trailer;
  final MovieSource? source;
  final String? vimeoId; // Direct vimeoId field (alternative to source.vimeoId)

  // Computed properties for backward compatibility
  String get image => poster ?? '';
  String? get genre => category.isNotEmpty ? category.first : null;

  // Get vimeoId from direct field or source
  String? get effectiveVimeoId => vimeoId ?? source?.vimeoId;

  MovieModel({
    required this.id,
    required this.title,
    required this.description,
    required this.slug,
    required this.type,
    this.poster,
    this.isPurchased = false,
    this.images = const [],
    this.tags = const [],
    this.rating = 0.0,
    required this.duration,
    this.category = const [],
    this.languages = const [],
    this.trailerId,
    this.cast = const [],
    this.views = 0,
    this.buyPrice,
    this.isFavorite = false,
    this.isWatchListed = false,
    this.isForKids = false,
    this.releaseDate,
    this.status,
    this.createdBy,
    this.updatedBy,
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
    this.version,
    this.episodes = const [],
    this.trailer,
    this.source,
    this.vimeoId,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    // Handle images - array of objects with url and _id
    List<MovieImage> imageList = [];
    if (json['images'] != null && json['images'] is List) {
      imageList = (json['images'] as List)
          .map((e) => MovieImage.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Handle tags
    List<String> tagList = [];
    if (json['tags'] != null && json['tags'] is List) {
      tagList = (json['tags'] as List)
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // Handle category - can be list of strings or list of objects with name
    List<String> categoryList = [];
    if (json['category'] != null && json['category'] is List) {
      categoryList = (json['category'] as List)
          .map((e) {
            if (e is Map && e['name'] != null) {
              return e['name'].toString();
            }
            return e.toString();
          })
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // Handle languages - list of strings or objects with name
    List<String> languageList = [];
    if (json['languages'] != null && json['languages'] is List) {
      languageList = (json['languages'] as List)
          .map((e) {
            if (e is Map && e['name'] != null) {
              return e['name'].toString();
            }
            return e.toString();
          })
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // Handle cast
    List<MovieCast> castList = [];
    if (json['cast'] != null && json['cast'] is List) {
      castList = (json['cast'] as List)
          .map((e) => MovieCast.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Handle episodes
    List<MovieEpisode> episodeList = [];
    if (json['episodes'] != null && json['episodes'] is List) {
      episodeList = (json['episodes'] as List)
          .map((e) => MovieEpisode.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Handle createdBy
    CreatedBy? createdByObj;
    if (json['createdBy'] != null && json['createdBy'] is Map) {
      createdByObj =
          CreatedBy.fromJson(json['createdBy'] as Map<String, dynamic>);
    }

    // Handle rating
    double ratingValue = 0.0;
    if (json['rating'] != null) {
      if (json['rating'] is int) {
        ratingValue = (json['rating'] as int).toDouble();
      } else if (json['rating'] is double) {
        ratingValue = json['rating'] as double;
      } else {
        ratingValue = double.tryParse(json['rating'].toString()) ?? 0.0;
      }
    }

    // Handle duration - keep as string from API
    String durationValue = json['duration']?.toString() ?? '';

    // Get ID - prefer _id, fallback to id
    String movieId = json['_id']?.toString() ?? json['id']?.toString() ?? '';

    // Handle poster - can be string or object with url
    String posterUrl = '';
    if (json['poster'] != null) {
      if (json['poster'] is String) {
        posterUrl = json['poster'] as String;
      } else if (json['poster'] is Map && json['poster']['url'] != null) {
        posterUrl = json['poster']['url'].toString();
      }
    }

    // Handle trailer
    MovieTrailer? trailerObj;
    if (json['trailer'] != null && json['trailer'] is Map) {
      trailerObj =
          MovieTrailer.fromJson(json['trailer'] as Map<String, dynamic>);
    }

    // Handle source
    MovieSource? sourceObj;
    if (json['source'] != null && json['source'] is Map) {
      sourceObj = MovieSource.fromJson(json['source'] as Map<String, dynamic>);
    }

    // Handle updatedBy
    CreatedBy? updatedByObj;
    if (json['updatedBy'] != null && json['updatedBy'] is Map) {
      updatedByObj =
          CreatedBy.fromJson(json['updatedBy'] as Map<String, dynamic>);
    }

    // Handle direct vimeoId / videoId field
    String? directVimeoId;
    if (json['videoId'] != null) {
      directVimeoId = json['videoId'].toString();
    } else if (json['vimeoId'] != null) {
      directVimeoId = json['vimeoId'].toString();
    }

    // Handle buyPrice
    double? buyPriceValue;
    if (json['buyPrice'] != null) {
      if (json['buyPrice'] is num) {
        buyPriceValue = (json['buyPrice'] as num).toDouble();
      } else {
        buyPriceValue = double.tryParse(json['buyPrice'].toString());
      }
    }

    // Handle favorite/watchlist flags
    final bool isFav = json['isFavorite'] == true;
    final bool isWatch = json['isWatchlisted'] == true ||
        json['isWatchlist'] == true ||
        json['isInWatchlist'] == true;

    final resolvedType = json['type']?.toString() ??
        (episodeList.isNotEmpty ? 'series' : 'movie');

    return MovieModel(
      id: movieId,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      type: resolvedType,
      poster: posterUrl.isNotEmpty ? posterUrl : null,
      images: imageList,
      tags: tagList,
      rating: ratingValue,
      duration: durationValue,
      category: categoryList,
      languages: languageList,
      trailerId: json['trailerId']?.toString(),
      cast: castList,
      views: json['views'] is int
          ? json['views']
          : (int.tryParse(json['views']?.toString() ?? '0') ?? 0),
      buyPrice: buyPriceValue,
      isFavorite: isFav,
      isPurchased: json['isPurchased'] ?? false,
      isWatchListed: isWatch,
      isForKids: json['isForKids'] == true,
      releaseDate: json['releaseDate']?.toString(),
      status: json['status']?.toString(),
      createdBy: createdByObj,
      updatedBy: updatedByObj,
      isDeleted: json['isDeleted'] == true,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      version: json['__v'] is int
          ? json['__v']
          : (int.tryParse(json['__v']?.toString() ?? '0')),
      episodes: episodeList,
      trailer: trailerObj,
      source: sourceObj,
      vimeoId: directVimeoId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'title': title,
      'description': description,
      'slug': slug,
      'type': type,
      'poster': poster,
      'isPurchased': isPurchased,
      'images': images.map((e) => e.toJson()).toList(),
      'tags': tags,
      'rating': rating,
      'duration': duration,
      'category': category,
      'languages': languages,
      'trailerId': trailerId,
      'cast': cast.map((e) => e.toJson()).toList(),
      'views': views,
      'buyPrice': buyPrice,
      'isFavorite': isFavorite,
      'isWatchListed': isWatchListed,
      'isForKids': isForKids,
      'releaseDate': releaseDate,
      'status': status,
      'createdBy': createdBy?.toJson(),
      'updatedBy': updatedBy?.toJson(),
      'isDeleted': isDeleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': version,
      'episodes': episodes.map((e) => e.toJson()).toList(),
      'trailer': trailer?.toJson(),
      'source': source?.toJson(),
      'vimeoId': vimeoId,
    };
  }
}

// Nested models
class MovieImage {
  final String url;
  final String id;

  MovieImage({
    required this.url,
    required this.id,
  });

  factory MovieImage.fromJson(Map<String, dynamic> json) {
    return MovieImage(
      url: json['url']?.toString() ?? '',
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      '_id': id,
    };
  }
}

class MovieCast {
  final String id;
  final String name;
  final String profile;
  final String character;
  final String role;

  MovieCast({
    required this.id,
    required this.name,
    required this.profile,
    required this.character,
    required this.role,
  });

  factory MovieCast.fromJson(Map<String, dynamic> json) {
    // Handle profile - can be string or object with url
    String profileUrl = '';
    if (json['profile'] != null) {
      if (json['profile'] is String) {
        profileUrl = json['profile'] as String;
      } else if (json['profile'] is Map && json['profile']['url'] != null) {
        profileUrl = json['profile']['url'].toString();
      }
    }

    return MovieCast(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      profile: profileUrl,
      character: json['character']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'profile': profile,
      'character': character,
      'role': role,
    };
  }
}

class CreatedBy {
  final String id;
  final String name;
  final String email;

  CreatedBy({
    required this.id,
    required this.name,
    required this.email,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    return CreatedBy(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
    };
  }
}

class MovieEpisode {
  final String id;
  final String movieId; // Can come as movieId or seriesId
  final String vimeoId; // Can come as videoId, vimeoId or inside source
  final String title;
  final String duration; // Keep as string to handle formatted values
  final int? season;
  final int? episodeNumber;
  final String? description;
  final String? thumbnail;
  final String? releaseDate;
  final bool isPublished;
  final String? createdAt;

  MovieEpisode({
    required this.id,
    required this.movieId,
    required this.title,
    required this.duration,
    required this.vimeoId,
    this.season,
    this.episodeNumber,
    this.description,
    this.thumbnail,
    this.releaseDate,
    this.isPublished = false,
    this.createdAt,
  });

  factory MovieEpisode.fromJson(Map<String, dynamic> json) {
    // Handle duration - can be int, string number, or formatted string like "28 Minute"
    String durationValue = '';
    if (json['duration'] != null) {
      if (json['duration'] is int) {
        durationValue = json['duration'].toString();
      } else if (json['duration'] is String) {
        durationValue = json['duration'] as String;
      } else {
        durationValue = json['duration'].toString();
      }
    }

    // Handle vimeoId / videoId
    String vimeoIdValue = '';
    if (json['videoId'] != null) {
      vimeoIdValue = json['videoId'].toString();
    } else if (json['vimeoId'] != null) {
      vimeoIdValue = json['vimeoId'].toString();
    } else if (json['vimeo_id'] != null) {
      vimeoIdValue = json['vimeo_id'].toString();
    } else if (json['source'] != null && json['source'] is Map) {
      final source = json['source'] as Map<String, dynamic>;
      if (source['vimeoId'] != null) {
        vimeoIdValue = source['vimeoId'].toString();
      } else if (source['vimeo_id'] != null) {
        vimeoIdValue = source['vimeo_id'].toString();
      }
    }

    // Handle thumbnail - can be object or string
    String? thumbUrl;
    if (json['thumbnail'] != null) {
      if (json['thumbnail'] is String) {
        thumbUrl = json['thumbnail'] as String;
      } else if (json['thumbnail'] is Map &&
          (json['thumbnail'] as Map)['url'] != null) {
        thumbUrl = (json['thumbnail'] as Map)['url'].toString();
      }
    }

    return MovieEpisode(
      id: json['_id']?.toString() ?? '',
      movieId:
          json['movieId']?.toString() ?? json['seriesId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      duration: durationValue,
      vimeoId: vimeoIdValue,
      season: json['season'] is int
          ? json['season'] as int
          : int.tryParse(json['season']?.toString() ?? ''),
      episodeNumber: json['episode'] is int
          ? json['episode'] as int
          : int.tryParse(json['episode']?.toString() ?? ''),
      description: json['description']?.toString(),
      thumbnail: thumbUrl,
      releaseDate: json['releaseDate']?.toString(),
      isPublished: json['isPublished'] == true,
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'movieId': movieId,
      'title': title,
      'duration': duration,
      'vimeoId': vimeoId,
      'season': season,
      'episode': episodeNumber,
      'description': description,
      'thumbnail': thumbnail,
      'releaseDate': releaseDate,
      'isPublished': isPublished,
      'createdAt': createdAt,
    };
  }
}

class MovieTrailer {
  final String? url;
  final String? vimeoId;
  final String? id;

  MovieTrailer({
    this.url,
    this.vimeoId,
    this.id,
  });

  factory MovieTrailer.fromJson(Map<String, dynamic> json) {
    // Handle vimeoId - can be vimeo_id (snake_case) or vimeoId (camelCase)
    String? vimeoIdValue;
    if (json['vimeoId'] != null) {
      vimeoIdValue = json['vimeoId'].toString();
    } else if (json['vimeo_id'] != null) {
      vimeoIdValue = json['vimeo_id'].toString();
    }

    return MovieTrailer(
      url: json['url']?.toString(),
      vimeoId: vimeoIdValue,
      id: json['_id']?.toString() ?? json['id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'vimeo_id': vimeoId,
      '_id': id,
      'id': id,
    };
  }
}

class MovieSource {
  final String? url;
  final String? vimeoId;
  final String? id;

  MovieSource({
    this.url,
    this.vimeoId,
    this.id,
  });

  factory MovieSource.fromJson(Map<String, dynamic> json) {
    return MovieSource(
      url: json['url']?.toString(),
      id: json['_id']?.toString(),
      vimeoId: json['vimeo_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      '_id': id,
      'vimeo_id': vimeoId,
    };
  }
}
