import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../constants/sizes.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _initializeVideo();
    _hideControlsAfterDelay();
  }

  void _initializeVideo() {
    // Mock video URL - replace with actual video URL from arguments
    _controller = VideoPlayerController.network(
        'https://www.w3schools.com/html/mov_bbb.mp4',
      )
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _controller.play();
          _isPlaying = true;
        });
      });

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        setState(() => _isPlaying = false);
      }
    });
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _hideControlsAfterDelay();
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get video data from navigation arguments
    final videoData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video player
            Center(
              child:
                  _isInitialized
                      ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                      : Container(
                        color: AppColors.surfaceBlack,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.textSecondary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
            ),

            // Controls overlay
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryBlack.withOpacity(0.7),
                      Colors.transparent,
                      Colors.transparent,
                      AppColors.primaryBlack.withOpacity(0.9),
                    ],
                    stops: const [0.0, 0.2, 0.8, 1.0],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Top bar
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlack.withOpacity(
                                    0.5,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: AppColors.textPrimary,
                                  size: 24,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlack.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.share_outlined,
                                color: AppColors.textPrimary,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Play/pause button
                      if (_showControls)
                        GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlack.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: AppColors.textPrimary,
                              size: 48,
                            ),
                          ),
                        ),

                      const Spacer(),

                      // Bottom info
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Progress bar
                            if (_isInitialized)
                              VideoProgressIndicator(
                                _controller,
                                allowScrubbing: true,
                                colors: VideoProgressColors(
                                  playedColor: AppColors.textPrimary,
                                  bufferedColor: AppColors.textPrimary
                                      .withOpacity(0.3),
                                  backgroundColor: AppColors.textPrimary
                                      .withOpacity(0.1),
                                ),
                              ),

                            const SizedBox(height: 16),

                            // Video info
                            if (videoData != null) ...[
                              Text(
                                videoData['headline'] ?? '',
                                style: const TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceBlack,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        (videoData['userName'] ?? 'U')
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontFamily: 'Georgia',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    videoData['userName'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '•',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    videoData['location'] ?? '',
                                    style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
