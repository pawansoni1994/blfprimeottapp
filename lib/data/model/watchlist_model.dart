class WatchlistModel {
  final String videoId;
  final String videoTitle;
  final String videoThumbnail;
  final String videoUrl;
  final int videoType; // 1 = Movie, 2 = Series, 3 = Audition
  final int vFieldType; // 1 = URL, 2 = Upload, 3 = Other

  WatchlistModel({
    required this.videoId,
    required this.videoTitle,
    required this.videoThumbnail,
    required this.videoUrl,
    required this.videoType,
    required this.vFieldType,
  });

  factory WatchlistModel.fromJson(Map<String, dynamic> json) {
    final videoDetail = json['video_detail'] ?? {};
    return WatchlistModel(
      videoId: videoDetail['video_id']?.toString() ?? '',
      videoTitle: videoDetail['video_title']?.toString() ?? '',
      videoThumbnail: videoDetail['video_thumbnail']?.toString() ?? '',
      videoUrl: videoDetail['video_url']?.toString() ?? '',
      videoType: json['video_type'] ?? 1,
      vFieldType: videoDetail['v_field_type'] ?? 1,
    );
  }
}

