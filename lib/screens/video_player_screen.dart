import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../data/repository/movie_repository.dart';
import '../../network/error_handlers.dart';
import '../../widgets/vimeo_video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  String? _vimeoId;
  String? _contentId;
  String? _contentType;
  String? _episodeId;
  Timer? _updateTimer;
  int _currentPositionSeconds = 0;
  int _totalDurationSeconds = 0;
  int _startTime = 60; // Default start time: 60 seconds (1 minute)
  final GlobalKey _playerKey = GlobalKey();
  final MovieRepository _movieRepository = Get.find(
    tag: (MovieRepository).toString(),
  );

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();

    // Get video info from parameters
    final vimeoIdParam = Get.parameters['vimeoId'];
    if (vimeoIdParam != null && vimeoIdParam.isNotEmpty) {
      _vimeoId = Uri.decodeComponent(vimeoIdParam);
    }

    // Get content info for continue watching
    _contentId = Get.parameters['contentId'];
    _contentType = Get.parameters['contentType'];
    _episodeId = Get.parameters['episodeId'];

    // Get start time from parameters (for continue watching)
    // Use resume point from continue watching if available, otherwise start from beginning
    final startTimeParam = Get.parameters['startTime'];
    if (startTimeParam != null && startTimeParam.isNotEmpty) {
      final parsedStartTime = int.tryParse(startTimeParam) ?? 0;
      // Use provided start time if it's greater than 0, otherwise start from beginning
      _startTime = parsedStartTime > 0 ? parsedStartTime : 0;
    } else {
      // Start from beginning if no start time provided
      _startTime = 0;
    }

    // Start tracking video position
    if (_contentId != null && _contentType != null) {
      // Call start continue watching API when video starts
      _movieRepository
          .startContinueWatching(
        _contentId!,
        _contentType!,
        episodeId: _episodeId,
      )
          .catchError((e) {
        // Silently handle error - don't interrupt playback
        logger.e('Failed to start continue watching: $e');
      });

      // Update continue watching every 2 minutes
      _updateTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
        _updateContinueWatching();
      });
    }
  }

  void _updateContinueWatching() {
    if (_contentId == null || _contentType == null) {
      return;
    }

    // Use current video position (in seconds)
    // If position is 0, it means we couldn't get it, so skip update
    if (_currentPositionSeconds <= 0) {
      return;
    }

    // Use total duration if available, otherwise use current position as fallback
    final totalDuration = _totalDurationSeconds > 0
        ? _totalDurationSeconds
        : _currentPositionSeconds;

    // Update continue watching API with actual video position and total duration
    _movieRepository
        .updateContinueWatching(
      _contentId!,
      _contentType!,
      _currentPositionSeconds,
      totalDuration,
      episodeId: _episodeId,
    )
        .catchError((e) {
      // Silently handle error - don't interrupt playback
      logger.e('Failed to update continue watching: $e');
    });
  }

  void _handleBackButton() {
    // Update continue watching before closing screen
    if (_contentId != null && _contentType != null) {
      _updateContinueWatching();
    }
    Get.back();
  }

  @override
  void dispose() {
    // Final update before disposing (when screen is closed)
    // This ensures update happens regardless of how screen is closed
    if (_contentId != null && _contentType != null) {
      _updateContinueWatching();
    }

    _updateTimer?.cancel();
    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);

    // Use Vimeo player if vimeoId is available, otherwise show message
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: _vimeoId != null && _vimeoId!.isNotEmpty
                  ? VimeoVideoPlayer(
                      key: _playerKey,
                      videoId: _vimeoId!,
                      isAutoPlay: true,
                      isLooping: false,
                      isMuted: false,
                      showTitle: false,
                      showByline: false,
                      backgroundColor: Colors.black,
                      startTime: _startTime,
                      onPlay: () {
                        // Video started playing
                      },
                      onPause: () {
                        // Video paused
                        _updateContinueWatching();
                      },
                      onFinish: () {
                        // Video finished - final update
                        _updateContinueWatching();
                      },
                      onSeek: () {
                        // Video seeked
                        _updateContinueWatching();
                      },
                      currentPositionInSeconds: (position) {
                        // This callback is called automatically by the Vimeo player
                        // whenever the position updates
                        if (mounted) {
                          setState(() {
                            _currentPositionSeconds = position.toInt();
                          });
                          logger.d(
                              'Position updated: $_currentPositionSeconds seconds');
                        }
                      },
                      totalDurationInSeconds: (duration) {
                        // This callback is called when video duration is available
                        if (mounted) {
                          setState(() {
                            _totalDurationSeconds = duration.toInt();
                          });
                          logger.d(
                              'Total duration: $_totalDurationSeconds seconds');
                        }
                      },
                    )
                  : Text(
                      'Video not available',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
            IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 28,
              ),
              onPressed: _handleBackButton,
            ),
          ],
        ),
      ),
    );
  }
}
