import 'movie_model.dart';
import 'movie_list_response_model.dart';

class ContinueWatchingEpisode {
  final String id;
  final String title;
  final int episode;
  final int season;

  ContinueWatchingEpisode({
    required this.id,
    required this.title,
    required this.episode,
    required this.season,
  });

  factory ContinueWatchingEpisode.fromJson(Map<String, dynamic> json) {
    return ContinueWatchingEpisode(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      episode: json['episode'] is int
          ? json['episode'] as int
          : int.tryParse(json['episode']?.toString() ?? '0') ?? 0,
      season: json['season'] is int
          ? json['season'] as int
          : int.tryParse(json['season']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'episode': episode,
      'season': season,
    };
  }
}

class ContinueWatchingModel {
  final String id;
  final String contentType;
  final String userId;
  final String contentId;
  final String? episodeId; // Only for series
  final int duration;
  final int totalDuration;
  final String videoId;
  final int resumePoint;
  final int progress;
  final String createdAt;
  final String lastUpdatedAt;
  final String startTime;
  final String updatedAt;
  final MovieModel content;
  final ContinueWatchingEpisode? episode; // Only for series

  ContinueWatchingModel({
    required this.id,
    required this.contentType,
    required this.userId,
    required this.contentId,
    this.episodeId,
    required this.duration,
    required this.totalDuration,
    required this.videoId,
    required this.resumePoint,
    required this.progress,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.startTime,
    required this.updatedAt,
    required this.content,
    this.episode,
  });

  factory ContinueWatchingModel.fromJson(Map<String, dynamic> json) {
    // Handle content - ensure poster is properly formatted for MovieModel
    final contentJson = Map<String, dynamic>.from(json['content'] as Map<String, dynamic>);
    
    // Convert poster object to string URL if needed
    if (contentJson['poster'] != null && contentJson['poster'] is Map) {
      final posterMap = contentJson['poster'] as Map<String, dynamic>;
      if (posterMap['url'] != null) {
        contentJson['poster'] = posterMap['url'].toString();
      }
    }

    // Handle episode (only for series)
    ContinueWatchingEpisode? episodeObj;
    if (json['episode'] != null && json['episode'] is Map) {
      episodeObj = ContinueWatchingEpisode.fromJson(
        json['episode'] as Map<String, dynamic>,
      );
    }
    
    return ContinueWatchingModel(
      id: json['_id']?.toString() ?? '',
      contentType: json['contentType']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      contentId: json['contentId']?.toString() ?? '',
      episodeId: json['episodeId']?.toString(),
      duration: json['duration'] is int
          ? json['duration'] as int
          : int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
      totalDuration: json['totalDuration'] is int
          ? json['totalDuration'] as int
          : int.tryParse(json['totalDuration']?.toString() ?? '0') ?? 0,
      videoId: json['videoId']?.toString() ?? '',
      resumePoint: json['resumePoint'] is int
          ? json['resumePoint'] as int
          : int.tryParse(json['resumePoint']?.toString() ?? '0') ?? 0,
      progress: json['progress'] is int
          ? json['progress'] as int
          : int.tryParse(json['progress']?.toString() ?? '0') ?? 0,
      createdAt: json['createdAt']?.toString() ?? '',
      lastUpdatedAt: json['lastUpdatedAt']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      content: MovieModel.fromJson(contentJson),
      episode: episodeObj,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'contentType': contentType,
      'userId': userId,
      'contentId': contentId,
      'episodeId': episodeId,
      'duration': duration,
      'totalDuration': totalDuration,
      'videoId': videoId,
      'resumePoint': resumePoint,
      'progress': progress,
      'createdAt': createdAt,
      'lastUpdatedAt': lastUpdatedAt,
      'startTime': startTime,
      'updatedAt': updatedAt,
      'content': content.toJson(),
      'episode': episode?.toJson(),
    };
  }
}

class ContinueWatchingResponseModel {
  final bool success;
  final List<ContinueWatchingModel> data;
  final PaginationModel? pagination;

  ContinueWatchingResponseModel({
    required this.success,
    required this.data,
    this.pagination,
  });

  factory ContinueWatchingResponseModel.fromJson(Map<String, dynamic> json) {
    List<ContinueWatchingModel> items = [];
    if (json['data'] != null && json['data'] is List) {
      items = (json['data'] as List)
          .map((item) => ContinueWatchingModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    PaginationModel? paginationObj;
    if (json['pagination'] != null && json['pagination'] is Map) {
      paginationObj = PaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>,
      );
    }

    return ContinueWatchingResponseModel(
      success: json['success'] ?? false,
      data: items,
      pagination: paginationObj,
    );
  }
}

